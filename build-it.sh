#!/bin/bash
# shellcheck disable=SC2199
# shellcheck source=/dev/null
#
# Copyright (C) 2020-22 UtsavBalar1231 <utsavbalar1231@gmail.com>
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#    http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

#                                              #
# THANK @UTSAVBALAR1231 FOR THIS BUILD SCRIPT #
#                                              #

HOME=/home/jimmy/cmpl
desk=/home/jimmy/Desktop
KBUILD_COMPILER_STRING=$(/home/jimmy/cmpl/clang/bin/clang --version | head -n 1 | perl -pe 's/\(http.*?\)//gs' | sed -e 's/  */ /g' -e 's/[[:space:]]*$//')
KBUILD_LINKER_STRING=$(/home/jimmy/cmpl/clang/bin/ld.lld --version | head -n 1 | perl -pe 's/\(http.*?\)//gs' | sed -e 's/  */ /g' -e 's/[[:space:]]*$//' | sed 's/(compatible with [^)]*)//')
export KBUILD_COMPILER_STRING
export KBUILD_LINKER_STRING
export ARCH=arm64
export SUBARCH=arm64
export HEADER_ARCH=arm64

# Set compiler Path
export PATH="/home/jimmy/cmpl/gas:/home/jimmy/cmpl/clang/bin:$PATH"
export LD_LIBRARY_PATH="/home/jimmy/cmpl/clang/lib64:$LD_LIBRARY_PATH"

DATE=$(date +"%Y-%m-%d-%H%M")
DEVICE="alioth"

# Set our directory
OUT_DIR=out/

# How much kebabs we need? Kanged from @raphielscape :)
if [[ -z "${KEBABS}" ]]; then
    COUNT="$(grep -c '^processor' /proc/cpuinfo)"
    export KEBABS="$((COUNT + 2))"
fi

ARGS="ARCH=arm64 \
O=${OUT_DIR} \
LLVM=1 \
CLANG_TRIPLE=aarch64-linux-gnu- \
CROSS_COMPILE=aarch64-linux-gnu- \
CROSS_COMPILE_COMPAT=arm-linux-gnueabi- \
-j${KEBABS}"

dts_source=arch/arm64/boot/dts/vendor/qcom

# Correct panel dimensions on MIUI builds
function miui_fix_dimens() {
    sed -i 's/<70>/<695>/g' $dts_source/dsi-panel-j3s-37-02-0a-dsc-video.dtsi
    sed -i 's/<70>/<695>/g' $dts_source/dsi-panel-j11-38-08-0a-fhd-cmd.dtsi
    sed -i 's/<70>/<695>/g' $dts_source/dsi-panel-k11a-38-08-0a-dsc-cmd.dtsi
    sed -i 's/<71>/<710>/g' $dts_source/dsi-panel-j1s*
    sed -i 's/<71>/<710>/g' $dts_source/dsi-panel-j2*
    sed -i 's/<155>/<1544>/g' $dts_source/dsi-panel-j3s-37-02-0a-dsc-video.dtsi
    sed -i 's/<155>/<1545>/g' $dts_source/dsi-panel-j11-38-08-0a-fhd-cmd.dtsi
    sed -i 's/<155>/<1546>/g' $dts_source/dsi-panel-k11a-38-08-0a-dsc-cmd.dtsi
    sed -i 's/<154>/<1537>/g' $dts_source/dsi-panel-j1s*
    sed -i 's/<154>/<1537>/g' $dts_source/dsi-panel-j2*
}

# Enable back mi smartfps while disabling qsync min refresh-rate
function miui_fix_fps() {
    sed -i 's/qcom,mdss-dsi-qsync-min-refresh-rate/\/\/qcom,mdss-dsi-qsync-min-refresh-rate/g' $dts_source/dsi-panel*
    sed -i 's/\/\/ mi,mdss-dsi-smart-fps-max_framerate/mi,mdss-dsi-smart-fps-max_framerate/g' $dts_source/dsi-panel*
    sed -i 's/\/\/ mi,mdss-dsi-pan-enable-smart-fps/mi,mdss-dsi-pan-enable-smart-fps/g' $dts_source/dsi-panel*
    sed -i 's/\/\/ qcom,mdss-dsi-pan-enable-smart-fps/qcom,mdss-dsi-pan-enable-smart-fps/g' $dts_source/dsi-panel*
}

# Enable back refresh rates supported on MIUI
function miui_fix_dfps() {
    sed -i 's/120 90 60/120 90 60 50 30/g' $dts_source/dsi-panel-g7a-37-02-0a-dsc-video.dtsi
    sed -i 's/120 90 60/120 90 60 50 30/g' $dts_source/dsi-panel-g7a-37-02-0b-dsc-video.dtsi
    sed -i 's/120 90 60/120 90 60 50 30/g' $dts_source/dsi-panel-g7a-36-02-0c-dsc-video.dtsi
    sed -i 's/144 120 90 60/144 120 90 60 50 48 30/g' $dts_source/dsi-panel-j3s-37-02-0a-dsc-video.dtsi
}

# Enable back brightness control from dtsi
function miui_fix_fod() {
    sed -i 's/\/\/39 01 00 00 01 00 03 51 03 FF/39 01 00 00 01 00 03 51 03 FF/g' $dts_source/dsi-panel-j11-38-08-0a-fhd-cmd.dtsi
    sed -i 's/\/\/39 01 00 00 00 00 03 51 03 FF/39 01 00 00 00 00 03 51 03 FF/g' $dts_source/dsi-panel-j11-38-08-0a-fhd-cmd.dtsi
    sed -i 's/\/\/39 00 00 00 00 00 05 51 0F 8F 00 00/39 00 00 00 00 00 05 51 0F 8F 00 00/g' $dts_source/dsi-panel-j1s-42-02-0a-dsc-cmd.dtsi
    sed -i 's/\/\/39 01 00 00 00 00 05 51 07 FF 00 00/39 01 00 00 00 00 05 51 07 FF 00 00/g' $dts_source/dsi-panel-j1s-42-02-0a-dsc-cmd.dtsi
    sed -i 's/\/\/39 00 00 00 00 00 05 51 0F 8F 00 00/39 00 00 00 00 00 05 51 0F 8F 00 00/g' $dts_source/dsi-panel-j1s-42-02-0a-mp-dsc-cmd.dtsi
    sed -i 's/\/\/39 01 00 00 00 00 05 51 07 FF 00 00/39 01 00 00 00 00 05 51 07 FF 00 00/g' $dts_source/dsi-panel-j1s-42-02-0a-mp-dsc-cmd.dtsi
    sed -i 's/\/\/39 01 00 00 00 00 03 51 0F FF/39 01 00 00 00 00 03 51 0F FF/g' $dts_source/dsi-panel-j1u-42-02-0b-dsc-cmd.dtsi
    sed -i 's/\/\/39 01 00 00 00 00 03 51 07 FF/39 01 00 00 00 00 03 51 07 FF/g' $dts_source/dsi-panel-j1u-42-02-0b-dsc-cmd.dtsi
    sed -i 's/\/\/39 01 00 00 00 00 03 51 00 00/39 01 00 00 00 00 03 51 00 00/g' $dts_source/dsi-panel-j2-38-0c-0a-dsc-cmd.dtsi
    sed -i 's/\/\/39 01 00 00 00 00 03 51 00 00/39 01 00 00 00 00 03 51 00 00/g' $dts_source/dsi-panel-j2-38-0c-0a-dsc-cmd.dtsi
    sed -i 's/\/\/39 01 00 00 00 00 03 51 0F FF/39 01 00 00 00 00 03 51 0F FF/g' $dts_source/dsi-panel-j2-42-02-0b-dsc-cmd.dtsi
    sed -i 's/\/\/39 01 00 00 00 00 03 51 07 FF/39 01 00 00 00 00 03 51 07 FF/g' $dts_source/dsi-panel-j2-42-02-0b-dsc-cmd.dtsi
    sed -i 's/\/\/39 00 00 00 00 00 05 51 0F 8F 00 00/39 00 00 00 00 00 05 51 0F 8F 00 00/g' $dts_source/dsi-panel-j2-mp-42-02-0b-dsc-cmd.dtsi
    sed -i 's/\/\/39 01 00 00 00 00 05 51 07 FF 00 00/39 01 00 00 00 00 05 51 07 FF 00 00/g' $dts_source/dsi-panel-j2-mp-42-02-0b-dsc-cmd.dtsi
    sed -i 's/\/\/39 01 00 00 00 00 03 51 0F FF/39 01 00 00 00 00 03 51 0F FF/g' $dts_source/dsi-panel-j2-p1-42-02-0b-dsc-cmd.dtsi
    sed -i 's/\/\/39 01 00 00 00 00 03 51 07 FF/39 01 00 00 00 00 03 51 07 FF/g' $dts_source/dsi-panel-j2-p1-42-02-0b-dsc-cmd.dtsi
    sed -i 's/\/\/39 00 00 00 00 00 03 51 0D FF/39 00 00 00 00 00 03 51 0D FF/g' $dts_source/dsi-panel-j2-p2-1-38-0c-0a-dsc-cmd.dtsi
    sed -i 's/\/\/39 01 00 00 11 00 03 51 03 FF/39 01 00 00 11 00 03 51 03 FF/g' $dts_source/dsi-panel-j2-p2-1-38-0c-0a-dsc-cmd.dtsi
    sed -i 's/\/\/39 00 00 00 00 00 05 51 0F 8F 00 00/39 00 00 00 00 00 05 51 0F 8F 00 00/g' $dts_source/dsi-panel-j2-p2-1-42-02-0b-dsc-cmd.dtsi
    sed -i 's/\/\/39 01 00 00 00 00 05 51 07 FF 00 00/39 01 00 00 00 00 05 51 07 FF 00 00/g' $dts_source/dsi-panel-j2-p2-1-42-02-0b-dsc-cmd.dtsi
    sed -i 's/\/\/39 00 00 00 00 00 05 51 0F 8F 00 00/39 00 00 00 00 00 05 51 0F 8F 00 00/g' $dts_source/dsi-panel-j2s-mp-42-02-0a-dsc-cmd.dtsi
    sed -i 's/\/\/39 01 00 00 00 00 05 51 07 FF 00 00/39 01 00 00 00 00 05 51 07 FF 00 00/g' $dts_source/dsi-panel-j2s-mp-42-02-0a-dsc-cmd.dtsi
    sed -i 's/\/\/39 00 00 00 00 00 03 51 03 FF/39 00 00 00 00 00 03 51 03 FF/g' $dts_source/dsi-panel-j9-38-0a-0a-fhd-video.dtsi
    sed -i 's/\/\/39 01 00 00 00 00 03 51 03 FF/39 01 00 00 00 00 03 51 03 FF/g' $dts_source/dsi-panel-j9-38-0a-0a-fhd-video.dtsi
}

AOSP_BUILD()
{
 # AOSP Build
 echo "------ Stating AOSP Build ------"
 os=aosp
# Make defconfig
 make -j${KEBABS} ${ARGS} ${DEVICE}_defconfig
 make -j${KEBABS} ${ARGS} 2>&1 | tee build.log
 find ${OUT_DIR}/$dts_source -name '*.dtb' -exec cat {} + > ${OUT_DIR}/arch/arm64/boot/dtb

 mkdir -p ${desk}/anykernel/kernels/$os
 # Import Anykernel3 folder
 if [[ -f ${OUT_DIR}/arch/arm64/boot/Image.gz ]]; then
     cp ${OUT_DIR}/arch/arm64/boot/Image.gz ${desk}/anykernel/kernels/$os
 else
   if [[ -f ${OUT_DIR}/arch/arm64/boot/Image ]]; then
       cp ${OUT_DIR}/arch/arm64/boot/Image ${desk}/anykernel/kernels/$os
   else
     echo  ".no image found."
   fi
 fi
 cp ${OUT_DIR}/arch/arm64/boot/dtb ${desk}/anykernel/kernels/$os
 cp ${OUT_DIR}/arch/arm64/boot/dtbo.img ${desk}/anykernel/kernels/$os
 echo "------ Finishing AOSP Build ------"
}

AOSP_LTO_BUILD()
{
 # AOSP LTO Build
 echo "------ Stating AOSP LTO Build ------"
 os=aosp

# Make defconfig
make -j${KEBABS} ${ARGS} ${DEVICE}_defconfig

# Enable LTO
    scripts/config --file ${OUT_DIR}/.config \
        -e LTO_CLANG

    # Make olddefconfig
    cd ${OUT_DIR} || exit
    make -j${KEBABS} ${ARGS} olddefconfig
    cd ../ || exit

 make -j${KEBABS} ${ARGS} 2>&1 | tee build.log
 find ${OUT_DIR}/$dts_source -name '*.dtb' -exec cat {} + > ${OUT_DIR}/arch/arm64/boot/dtb

 mkdir -p ${desk}/anykernel/kernels/$os
 # Import Anykernel3 folder
 if [[ -f ${OUT_DIR}/arch/arm64/boot/Image.gz ]]; then
     cp ${OUT_DIR}/arch/arm64/boot/Image.gz ${desk}/anykernel/kernels/$os
 else
   if [[ -f ${OUT_DIR}/arch/arm64/boot/Image ]]; then
       cp ${OUT_DIR}/arch/arm64/boot/Image ${desk}/anykernel/kernels/$os
   else
     echo  ".no image found."
   fi
 fi
 cp ${OUT_DIR}/arch/arm64/boot/dtb ${desk}/anykernel/kernels/$os
 cp ${OUT_DIR}/arch/arm64/boot/dtbo.img ${desk}/anykernel/kernels/$os
 echo "------ Finishing AOSP LTO Build ------"
}

MIUI_BUILD()
{
# MIUI Build
echo "------ Starting MIUI Build ------"
os=miui

# Make defconfig
make -j${KEBABS} ${ARGS} "${DEVICE}"_defconfig

scripts/config --file ${OUT_DIR}/.config \
    -d LOCALVERSION_AUTO \
    -d TOUCHSCREEN_COMMON \
    --set-str STATIC_USERMODEHELPER_PATH /system/bin/micd \
    -e BOOT_INFO \
    -e BINDER_OPT \
    -e DEBUG_KERNEL \
    -e IPC_LOGGING \
    -e KPERFEVENTS \
    -e LAST_TOUCH_EVENTS \
    -e MIGT \
    -e MIHW \
    -e MILLET \
    -e MIUI_DRM_WAKE_OPT \
    -e MIUI_ZRAM_MEMORY_TRACKING \
    -e MI_RECLAIM \
    -e PERF_HUMANTASK \
    -e TASK_DELAY_ACCT

# Make olddefconfig
cd ${OUT_DIR} || exit
make -j${KEBABS} ${ARGS} CC="clang" HOSTCC="gcc" HOSTCXX="g++" olddefconfig
cd ../ || exit

miui_fix_dimens
miui_fix_fps
miui_fix_dfps
miui_fix_fod

make -j${KEBABS} ${ARGS} CC="clang" HOSTCC="gcc" HOSTCXX="g++" 2>&1 | tee build.log

find ${OUT_DIR}/$dts_source -name '*.dtb' -exec cat {} + >${OUT_DIR}/arch/arm64/boot/dtb

mkdir -p ${desk}/anykernel/kernels/$os
# Import Anykernel3 folder
if [[ -f ${OUT_DIR}/arch/arm64/boot/Image.gz ]]; then
    cp ${OUT_DIR}/arch/arm64/boot/Image.gz ${desk}/anykernel/kernels/$os
else
    if [[ -f ${OUT_DIR}/arch/arm64/boot/Image ]]; then
        cp ${OUT_DIR}/arch/arm64/boot/Image ${desk}/anykernel/kernels/$os
    else
        echo ".no image found."
    fi
fi
cp ${OUT_DIR}/arch/arm64/boot/dtb ${desk}/anykernel/kernels/$os
cp ${OUT_DIR}/arch/arm64/boot/dtbo.img ${desk}/anykernel/kernels/$os
echo "------ Finishing MIUI Build ------"
}

AOSPA_BUILD()
{
 # AOSPA Build
 echo "------ Starting AOSPA Build ------"
 os=aospa

 # Make defconfig
 make -j${KEBABS} ${ARGS} "${DEVICE}"_defconfig

 scripts/config --file ${OUT_DIR}/.config \
     -d SDCARD_FS \
     -e UNICODE

 # Make olddefconfig
 cd ${OUT_DIR} || exit
 make -j${KEBABS} ${ARGS} olddefconfig
 cd ../ || exit

 make -j${KEBABS} ${ARGS} 2>&1 | tee build.log

 find ${OUT_DIR}/$dts_source -name '*.dtb' -exec cat {} + > ${OUT_DIR}/arch/arm64/boot/dtb

 mkdir -p ${desk}/anykernel/kernels/$os
 # Import Anykernel3 folder
 if [[ -f ${OUT_DIR}/arch/arm64/boot/Image.gz ]]; then
     cp ${OUT_DIR}/arch/arm64/boot/Image.gz ${desk}/anykernel/kernels/$os
 else
   if [[ -f ${OUT_DIR}/arch/arm64/boot/Image ]]; then
       cp ${OUT_DIR}/arch/arm64/boot/Image ${desk}/anykernel/kernels/$os
   else
      echo ".no image found."
   fi
 fi
 cp ${OUT_DIR}/arch/arm64/boot/dtb ${desk}/anykernel/kernels/$os
 cp ${OUT_DIR}/arch/arm64/boot/dtbo.img ${desk}/anykernel/kernels/$os
 echo "------ Finishing AOSPA Build ------"
}

AOSPA_LTO_BUILD()
{
 # AOSPA LTO Build
 echo "------ Starting AOSPA LTO Build ------"
 os=aospa

 # Make defconfig
 make -j${KEBABS} ${ARGS} "${DEVICE}"_defconfig

 scripts/config --file ${OUT_DIR}/.config \
     -d SDCARD_FS \
     -e UNICODE
 # Enable LTO
     -e LTO_CLANG

 # Make olddefconfig
 cd ${OUT_DIR} || exit
 make -j${KEBABS} ${ARGS} olddefconfig
 cd ../ || exit

 make -j${KEBABS} ${ARGS} 2>&1 | tee build.log

 find ${OUT_DIR}/$dts_source -name '*.dtb' -exec cat {} + > ${OUT_DIR}/arch/arm64/boot/dtb

 mkdir -p ${desk}/anykernel/kernels/$os
 # Import Anykernel3 folder
 if [[ -f ${OUT_DIR}/arch/arm64/boot/Image.gz ]]; then
     cp ${OUT_DIR}/arch/arm64/boot/Image.gz ${desk}/anykernel/kernels/$os
 else
   if [[ -f ${OUT_DIR}/arch/arm64/boot/Image ]]; then
       cp ${OUT_DIR}/arch/arm64/boot/Image ${desk}/anykernel/kernels/$os
   else
      echo ".no image found."
   fi
 fi
 cp ${OUT_DIR}/arch/arm64/boot/dtb ${desk}/anykernel/kernels/$os
 cp ${OUT_DIR}/arch/arm64/boot/dtbo.img ${desk}/anykernel/kernels/$os
 echo "------ Finishing AOSPA LTO Build ------"
}

FUNC_ZIP()
{
# Export Zip name
export ZIPNAME="${VERSION}.zip"
cd ${desk}/anykernel || exit
zip -r9 "${ZIPNAME}" ./* -x .git .gitignore ./*.zip
cd "$(pwd)" || exit
}

FUNC_CLEAN()
{
# Cleanup
rm -fr ${desk}/anykernel/kernels
rm -fr ${OUT_DIR}/arch/arm64/boot/dtb
rm -fr ${OUT_DIR}/arch/arm64/boot/dtbo.img
rm -fr ${OUT_DIR}/arch/arm64/boot/Image.gz
rm -fr ${OUT_DIR}/arch/arm64/boot/Image
}

OPTION_1()
{
START_TIME=`date +%s`
VERSION="KimciLodon-v2-aosp-${DEVICE^^}-${DATE}"
FUNC_CLEAN
AOSP_BUILD
FUNC_ZIP
END_TIME=`date +%s`
let "ELAPSED_TIME=$END_TIME-$START_TIME"
echo ""
echo "Total compiling time is $ELAPSED_TIME seconds"
echo ""
exit
}

OPTION_2()
{
START_TIME=`date +%s`
VERSION="KimciLodon-v2-miui-${DEVICE^^}-${DATE}"
FUNC_CLEAN
MIUI_BUILD
FUNC_ZIP
END_TIME=`date +%s`
let "ELAPSED_TIME=$END_TIME-$START_TIME"
echo ""
echo "Total compiling time is $ELAPSED_TIME seconds"
echo ""
exit
}

OPTION_3()
{
START_TIME=`date +%s`
VERSION="KimciLodon-v2-aospa-${DEVICE^^}-${DATE}"
FUNC_CLEAN
AOSPA_BUILD
FUNC_ZIP
END_TIME=`date +%s`
let "ELAPSED_TIME=$END_TIME-$START_TIME"
echo ""
echo "Total compiling time is $ELAPSED_TIME seconds"
echo ""
exit
}

OPTION_4()
{
START_TIME=`date +%s`
VERSION="KimciLodon-v2-aosp-lto-${DEVICE^^}-${DATE}"
FUNC_CLEAN
AOSP_LTO_BUILD
FUNC_ZIP
END_TIME=`date +%s`
let "ELAPSED_TIME=$END_TIME-$START_TIME"
echo ""
echo "Total compiling time is $ELAPSED_TIME seconds"
echo ""
exit
}

OPTION_5()
{
START_TIME=`date +%s`
VERSION="KimciLodon-v2-aospa-lto-${DEVICE^^}-${DATE}"
FUNC_CLEAN
AOSPA_LTO_BUILD
FUNC_ZIP
END_TIME=`date +%s`
let "ELAPSED_TIME=$END_TIME-$START_TIME"
echo ""
echo "Total compiling time is $ELAPSED_TIME seconds"
echo ""
exit
}

OPTION_6()
{
START_TIME=`date +%s`
VERSION="KimciLodon-v2-all-${DEVICE^^}-${DATE}"
FUNC_CLEAN
AOSP_BUILD
MIUI_BUILD
AOSPA_BUILD
FUNC_ZIP
END_TIME=`date +%s`
let "ELAPSED_TIME=$END_TIME-$START_TIME"
echo ""
echo "Total compiling time is $ELAPSED_TIME seconds"
echo ""
exit
}

OPTION_7()
{
START_TIME=`date +%s`
VERSION="KimciLodon-v2-all-lto-${DEVICE^^}-${DATE}"
FUNC_CLEAN
AOSP_LTO_BUILD
MIUI_BUILD
AOSPA_LTO_BUILD
FUNC_ZIP
END_TIME=`date +%s`
let "ELAPSED_TIME=$END_TIME-$START_TIME"
echo ""
echo "Total compiling time is $ELAPSED_TIME seconds"
echo ""
exit
}

# ----------------------------------
# CHECK COMMAND LINE FOR ANY ENTRIES
# ----------------------------------
if [ "$@" == 0 ]; then
	OPTION_0
fi
if [ "$@" == 1 ]; then
	OPTION_1
fi
if [ "$@" == 2 ]; then
	OPTION_2
fi
if [ "$@" == 3 ]; then
	OPTION_3
fi
if [ "$@" == 4 ]; then
	OPTION_4
fi
if [ "$@" == 5 ]; then
	OPTION_5
fi
if [ "$@" == 6 ]; then
	OPTION_6
fi
if [ "$@" == 7 ]; then
	OPTION_7
fi

# -------------
# PROGRAM START
# -------------
rm -rf ./build/build.log
clear
echo "kimciLodon Build Script"
echo ""
echo " 0) Clean Workspace"
echo ""
echo " 1) Build kimciLodon kernel for AOSP"
echo " 2) Build kimciLodon kernel for MIUI"
echo " 3) Build kimciLodon kernel for AOSPA"
echo " 4) Build kimciLodon lto kernel for AOSP"
echo " 5) Build kimciLodon lto kernel for AOSPA"
echo " 6) Build all kernel"
echo " 7) Build all lto kernel"
echo ""
echo " 00) Exit"
echo ""
echo "Jobs: ${KEBABS}"
read -p "Please select an option " prompt
echo ""
if [ $prompt == "0" ]; then
	FUNC_CLEAN
	exit
elif [ $prompt == "1" ]; then
	OPTION_1
elif [ $prompt == "2" ]; then
	OPTION_2
elif [ $prompt == "3" ]; then
	OPTION_3
elif [ $prompt == "4" ]; then
	OPTION_4
elif [ $prompt == "5" ]; then
	OPTION_5
elif [ $prompt == "6" ]; then
	OPTION_6
elif [ $prompt == "7" ]; then
	OPTION_7
elif [ $prompt == "00" ]; then
	exit
fi
