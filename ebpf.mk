LINUX_VERSION=$(shell make -f environments/$(DISTRO).mk linux-version)
LINUX_HEADERS=$(shell make -f environments/$(DISTRO).mk linux-headers)
DISTRO_ID=$(shell make -f environments/$(DISTRO).mk distro-id)
DEST_DIR=/dist/$(DISTRO_ID)/$(shell uname -m)/$(LINUX_VERSION)

build:
	@mkdir -p "$(DEST_DIR)"
	clang -D__KERNEL__ -D__ASM_SYSREG_H \
		-Wno-unused-value -Wno-pointer-sign -Wno-compare-distinct-pointer-types \
		-O2 -emit-llvm -c tcptracer-bpf.c \
		$(foreach path,$(LINUX_HEADERS), -I $(path)/arch/x86/include -I $(path)/arch/x86/include/generated -I $(path)/include -I $(path)/include/generated/uapi -I $(path)/arch/x86/include/uapi -I $(path)/include/uapi) \
		-o - | llc -march=bpf -filetype=obj -o "${DEST_DIR}/ebpf.o"
