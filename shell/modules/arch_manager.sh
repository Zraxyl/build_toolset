get_arch() {
	ARCH=$(uname -m)
	drunk_debug "[ System arch is ]: ${ARCH}"
}

arch_check_and_warn() {
	# Func name says it
	wants=$1
	has=$(uname -m)

	if [ "$wants" = "$has" ]; then
		true
	else
		drunk_warn "Youre machine isn't based on target arch, make sure to use qemu and targeted DrunkOS rootfs for builds!!!"
	fi
}

set_aarch64() {
	# Make sure to failsafe check and warn dev if host if different arch system
	arch_check_and_warn aarch64

	# Now do the trick
	if [ -f "$P_ROOT/tools/tmp/is_arch" ]; then
		drunk_debug "Already set to AArch64"
	else
		drunk_debug "Arch set to AArch64"
		echo 'aarch64' > $P_ROOT/tools/tmp/is_arch
	fi
}

set_x86_64() {
	# Now do the trick
	if [ -f "$P_ROOT/tools/tmp/is_arch" ]; then
		drunk_debug "Already set to X86_64"
	else
		drunk_debug "Arch set to X86_64"
		echo 'x86_64' > $P_ROOT/tools/tmp/is_arch
	fi
}

set_arch() {
	# name says it again

	has=$(uname -m)
	if [ "x86_64" = $has ]; then
		set_x86_64
	elif [ "aarch64" = $has ]; then
		set_aarch64
	else
		drunk_err "You're arch is unsupported - ${has}"
	fi
}

get_target_arch() {
	cat "${P_ROOT}/tools/tmp/is_arch"
}

# TODO: Finish this here ( Currently using pkg_location hax )
set_arch_dir() {
	# Here we will set a pkgbuild dir for setup if user has predefined
	# its location by giving a new build script argument

	export ARCH=$(cat $P_ROOT/tools/tmp/is_arch)

	if [ $ARCH == x86_64 ]; then
		drunk_message "Using X86_64 PKGBUILD files"
	elif [ $ARCH == aarch64 ]; then
		drunk_message "Using AArch64 PKGBUILD files"
	else
		drunk_err "Didnt find any supported arch"
	fi
}
