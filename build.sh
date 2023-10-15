
ZIPNAME="ZERO-X-Kernel-$(TZ=Asia/Jakarta date +"%Y%m%d-%H%M").zip"
#workdir="$HOME/clang"
#srcdir="$workdir/android_kernel_xiaomi_ginkgo"
GCC_64_DIR="$HOME/aarch64-linux-android-4.9"
GCC_32_DIR="$HOME/arm-linux-androideabi-4.9"
objdir="$HOME/clang"
TC_DIR="$objdir/proton-clang"
DEFCONFIG="vendor/ginkgo-perf_defconfig"

# Build Environment
sudo -E apt-get -qq update
sudo -E apt-get -qq install bc python2 python3 python-is-python3

export PATH="$TC_DIR/bin:$PATH"
export ARCH=arm64
export out=out

#PATH="$srcdir/proton-clang/bin:${PATH}" make O=/OUT ARCH=arm64 SUBARCH=arm CC=$srcdir/proton-clang/bin/clang LD=$srcdir/proton-clang/bin/arm-linux-gnueabi-ld.bfd SELINUX_DEFCONFIG=selinux_defconfig CONFIG_NO_ERROR_ON_MISMATCH=y ginkgo-perf_defconfig

#PATH="$srcdir/proton-clang/bin:${PATH}" make O=/OUT ARCH=arm64 SUBARCH=arm CC=$srcdir/proton-clang/bin/clang LD=$srcdir/proton-clang/bin/arm-linux-gnueabi-ld.bfd SELINUX_DEFCONFIG=selinux_defconfig CONFIG_NO_ERROR_ON_MISMATCH=y oldconfig

#PATH="$srcdir/proton-clang/bin:${PATH}" make O=/OUT ARCH=arm64 SUBARCH=arm CC=$srcdir/proton-clang/bin/clang LD=$srcdir/proton-clang/bin/arm-linux-gnueabi-ld.bfd SELINUX_DEFCONFIG=selinux_defconfig CONFIG_NO_ERROR_ON_MISMATCH=y prepare

#PATH="$srcdir/proton-clang/bin:${PATH}" make O=/OUT ARCH=arm64 SUBARCH=arm CC=$srcdir/proton-clang/bin/clang LD=$srcdir/proton-clang/bin/arm-linux-gnueabi-ld.bfd SELINUX_DEFCONFIG=selinux_defconfig CONFIG_NO_ERROR_ON_MISMATCH=y nconfig

if [[ $1 = "-r" || $1 = "--regen" ]]; then
make O=out ARCH=arm64 $DEFCONFIG savedefconfig
cp out/defconfig arch/arm64/configs/$DEFCONFIG
exit
fi

mkdir -p out
make O=out ARCH=arm64 $DEFCONFIG
#make O=out ARCH=arm64 menuconfig
echo -e "\nStarting compilation...\n"

make -j$(nproc --all) \
O=out \
ARCH=arm64 \
CC=clang \
LD=ld.lld \
AR=llvm-ar \
AS=llvm-as \
NM=llvm-nm \
OBJCOPY=llvm-objcopy \
OBJDUMP=llvm-objdump \
STRIP=llvm-strip \
CROSS_COMPILE=$GCC_64_DIR/bin/aarch64-linux-android- \
CROSS_COMPILE_ARM32=$GCC_32_DIR/bin/arm-linux-androideabi- \
CLANG_TRIPLE=aarch64-linux-gnu- \
SELINUX_DEFCONFIG=selinux_defconfig \
Image.gz-dtb dtbo.img \
 

if [ -f "out/arch/arm64/boot/Image.gz-dtb" ] && [ -f "out/arch/arm64/boot/dtbo.img" ]; then
echo -e "\nKernel compiled succesfully! Zipping up...\n"
fi
cp out/arch/arm64/boot/Image.gz-dtb AnyKernel3
cp out/arch/arm64/boot/dtbo.img AnyKernel3
rm -f *zip
cd AnyKernel3
git checkout master &> /dev/null
zip -r9 "../$ZIPNAME" * -x '*.git*' README.md *placeholder
cd ..
echo -e "\nCompleted in $((SECONDS / 60)) minute(s) and $((SECONDS % 60)) second(s) !"

exit