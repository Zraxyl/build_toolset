#!/usr/bin/env python3

import os, sys, re, subprocess, argparse
from itertools import filterfalse

def parse_args():
    p = argparse.ArgumentParser(description="Generate build order for Zraxyl packages")
    p.add_argument("pkgname", help="Target package name")
    p.add_argument("package_dirs", nargs="+", help="Directories to scan for PKGBUILDs")
    p.add_argument("--skip-checkdepends", action="store_true",
                   help="Ignore checkdepends=() when resolving dependencies")
    p.add_argument("--skip-makedepends", action="store_true",
                   help="Ignore makedepends=() when resolving dependencies")
    p.add_argument("--onlynew", action="store_true",
                   help="Only include packages newer than installed version in bottle repo")
    p.add_argument("--debug", action="store_true",
                   help="Print debug info about skipped packages")
    return p.parse_args()

def pkgbuild_version(path):
    try:
        cmd = [
            "bash -c",
            f"source '{path}' >/dev/null 2>&1; printf '%s-%s' \"$pkgver\" \"$pkgrel\""
        ]
        return subprocess.check_output(cmd, text=True).strip()
    except subprocess.CalledProcessError:
        return None


def repo_version(pkgname):
    try:
        out = subprocess.check_output(["bottle", "-Si", pkgname], text=True)
        for line in out.splitlines():
            if line.startswith("Version"):
                return line.split(":", 1)[1].strip()
    except subprocess.CalledProcessError:
        return None
    return None

def vercmp(a, b):
    try:
        r = subprocess.run(["vercmp", a or "0", b or "0"],
                           check=False, capture_output=True, text=True)
        return int(r.stdout.strip())
    except Exception:
        return 0

def unique_everseen(iterable, key=None):
    seen = set()
    seen_add = seen.add
    if key is None:
        for element in filterfalse(seen.__contains__, iterable):
            seen_add(element)
            yield element
    else:
        for element in iterable:
            k = key(element)
            if k not in seen:
                seen_add(k)
                yield element


def die(msg):
    sys.exit("ERROR: " + msg)


def parse_pkgbuild_name(path):
    try:
        cmd = [
            "bash -c",
            f"source '{path}' >/dev/null 2>&1; printf '%s\\n' \"${{pkgname[@]}}\""
        ]
        output = subprocess.check_output(cmd, text=True).strip()
        names = [line.strip() for line in output.splitlines() if line.strip()]
        return names
    except subprocess.CalledProcessError as e:
        die(f"failed to parse pkgname from {path}: {e}")


def parse_pkgbuild_deps(path, skip_makedepends=False, skip_checkdepends=False):
    deps = []
    vars_to_check = ["depends"]

    if not skip_makedepends:
        vars_to_check.append("makedepends")
    if not skip_checkdepends:
        vars_to_check.append("checkdepends")

    for var in vars_to_check:
        try:
            cmd = [
                "bash", "-c",
                "source '{}' >/dev/null 2>&1; printf '%s\\n' \"${{{}[@]}}\"".format(path, var)
            ]
            output = subprocess.check_output(cmd, text=True).strip()
            deps.extend(line.strip().split(":")[0] for line in output.splitlines() if line.strip())
        except subprocess.CalledProcessError:
            # if var missing then skip it
            continue

    return deps


class ZPackage:
    def __init__(self, dir, pkgbuild, skip_makedepends=False, skip_checkdepends=False):
        self.dir = dir
        self.pkgbuild = pkgbuild
        self.names = parse_pkgbuild_name(pkgbuild)
        self.deps = parse_pkgbuild_deps(pkgbuild,
                                        skip_makedepends=skip_makedepends,
                                        skip_checkdepends=skip_checkdepends)
        self.needed_by = set()

    def __repr__(self):
        return f"<ZPackage {self.names}>"


def read_packages_from_dirs(directories, skip_makedepends=False, skip_checkdepends=False):
    pkgs_map = {}
    all_packages = []
    for d in directories:
        for pkgdir_name in sorted(os.listdir(d)):
            dir_path = os.path.join(d, pkgdir_name)
            pkgbuild = os.path.join(dir_path, "PKGBUILD")
            if os.path.isfile(pkgbuild):
                pkg = ZPackage(dir_path, pkgbuild,
                                  skip_makedepends=skip_makedepends,
                                  skip_checkdepends=skip_checkdepends)
                for name in pkg.names:
                    if name in pkgs_map:
                        other_path = pkgs_map[name].dir
                        die(f"Duplicated package: {name}\n  - {other_path}\n  - {pkg.dir}")
                    pkgs_map[name] = pkg
                pkg.version = pkgbuild_version(pkgbuild)
                all_packages.append(pkg)

    for pkg in all_packages:
        for dep in pkg.deps:
            if dep in pkgs_map:
                pkgs_map[dep].needed_by.add(pkg)
    return pkgs_map


def recursive_dependencies(pkgname, pkgs_map, seen=None):
    if seen is None:
        seen = set()
    if pkgname in seen:
        return []
    seen.add(pkgname)

    if pkgname not in pkgs_map:
        return []

    pkg = pkgs_map[pkgname]
    order = []
    for dep in sorted(pkg.deps):
        order += recursive_dependencies(dep, pkgs_map, seen)
    order.append(pkgname)
    return list(unique_everseen(order))


def main():
    parser = argparse.ArgumentParser(description="Create buildorder from packages")
    parser.add_argument("pkgname", help="Target package name")
    parser.add_argument("package_dirs", nargs="+", help="Directories with PKGBUILD")
    args = parse_args()

    pkgs_map = read_packages_from_dirs(
        args.package_dirs,
        skip_makedepends=args.skip_makedepends,
        skip_checkdepends=args.skip_checkdepends,
    )

    if args.pkgname not in pkgs_map:
        die(f"Package {args.pkgname} not found in provided directories")

    order = recursive_dependencies(args.pkgname, pkgs_map)

    if args.onlynew:
        filtered = []
        for pkg in order:
            repo_ver = repo_version(pkg)
            local_ver = pkgs_map[pkg].version if pkg in pkgs_map else None
            if local_ver and repo_ver:
                cmp = vercmp(local_ver, repo_ver)
                if cmp > 0:
                    filtered.append(pkg)
                elif args.debug:
                    print(f"DEBUG: Skipping {pkg} (local={local_ver}, repo={repo_ver})", file=sys.stderr)
            elif local_ver and not repo_ver:
                filtered.append(pkg)
                if args.debug:
                    print(f"DEBUG: Keeping {pkg} (not found in PKGBUILD repo)", file=sys.stderr)
            elif args.debug:
                print(f"DEBUG: Skipping {pkg} (no local version or comparison failed)", file=sys.stderr)
        order = filtered

    print(" ".join(order))


if __name__ == "__main__":
    main()
