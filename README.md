# Zraxyl Build Toolset

**Unified and Legacy-Compatible Development Environment Management**

---

## Overview

- Integrated toolset for environment setup, module management, and consistent builds  
- Supports both:  
  - Modern unified workflow (`build_toolset.sh`) with order enforcement, logging, CLI & TUI modes  
  - Original scriptlets (`envsetup.sh`, `load_modules.sh`, etc.) for legacy compatibility

---

## Required Packages

Install dependencies before use:

```sh
bottle -Syu --needed base-devel docker bash libisofs libisoburn dialog git
```

---

## Getting Started

### 1. Prepare Your Environment

- Create a new, empty working directory (do **not** use root)

### 2. Clone the Repository

```sh
git clone https://github.com/Zraxyl/build_toolset
```

---

## Two Supported Workflows

### A. Legacy Scripts (Fully Supported)

- `envsetup.sh` – Environment and `.env` setup  
- `load_modules.sh` – Module updates and git submodules  
- `initial_setup.sh` – First-time setup (calls other scripts)  
- `dialog.sh` – Interactive TUI menu  

**Example:**

```sh
ln -sf tools/envsetup.sh envsetup
./envsetup --help
./load_modules.sh
./initial_setup.sh
./dialog.sh
```

> **Note:** You must run these in logical order:  
> `envsetup.sh` → `load_modules.sh` → `initial_setup.sh` → `dialog.sh`

---

### B. Unified Script (Recommended)

- Single script: `build_toolset.sh`  
- Order-aware, idempotent, with comprehensive logging  
- Supports both CLI flags and interactive TUI menu  

---

## Unified Script Usage

- **CLI flags** (must appear in this order):

  ```sh
  ./build_toolset.sh --env --modules --init --dialog
  ./build_toolset.sh --env --modules
  ./build_toolset.sh --init
  ```

- **TUI menu only**:

  ```sh
  ./build_toolset.sh --dialog
  ```

- **No arguments** shows help:

  ```sh
  ./build_toolset.sh
  ```

---

## Logging

- All actions and errors are logged with timestamps to `build_toolset.log`

---

## Order Enforcement & Idempotency

- **Strict order:** Flags must follow `--env` → `--modules` → `--init` → `--dialog`  
- **Idempotent:** Each step runs at most once per invocation, even if redundantly specified  
- **Errors:** Out‑of‑order or invalid sequences abort with clear, actionable messages

---

## Contribution

- Fork the repo and submit pull requests  
- Maintain **Bash 4.x+** compliance and use the central error/logging framework

---

## Support

- Check `build_toolset.log` for troubleshooting details  
- Include log excerpts when requesting help

---

## Quick Reference

| Script               | Purpose                                   | Order Enforcement | Logging           |
|----------------------|-------------------------------------------|-------------------|-------------------|
| `envsetup.sh`        | Environment and `.env` setup               | Manual            | No                |
| `load_modules.sh`    | Module updates and git submodules          | Manual            | No                |
| `initial_setup.sh`   | First-time setup (calls others)            | Manual            | No                |
| `dialog.sh`          | Interactive TUI menu (legacy mode)         | Manual            | No                |
| **`build_toolset.sh`** | **Unified, order‑aware CLI & TUI**         | **Automatic**     | **Yes**           |

---

**Recommendation:** Use `build_toolset.sh` for reliable, traceable, and consistent workflows. Legacy scripts remain available for backward compatibility and phased migration.
