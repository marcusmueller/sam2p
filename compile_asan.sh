#! /bin/bash --
# by pts@fazekas.hu at Wed Oct  3 18:10:23 CEST 2018

set -ex

export CXX="${CXX:-g++}"

if test -f bts2.tth; then :; else
  CC="$CXX" ./gen_bts2_tth.sh
fi

$CXX -O0 -g -fsanitize=address -ansi -Wall -W -Wextra print_sizeofs.c -o print_sizeofs
./print_sizeofs >sizeofs.h

SAM2P_VERSION="$(bash ./mkdist.sh --getversion)"
test "$SAM2P_VERSION"

# Don't use `-nostdlib -lc', it prevents linking crtbeginT.o or causes segfault.
# With or without -fno-use-cxa-atexit, doesn't make a difference.
$CXX -O0 -g -fsanitize=address \
    -DHAVE_CONFIG2_H -DUSE_CONFIG_STDC_H -DSAM2P_VERSION=\""$SAM2P_VERSION"\" \
    -fsigned-char -fno-rtti -fno-exceptions -nostdinc++ -ansi -pedantic -Wall -W -Wextra \
    sam2p_main.cpp appliers.cpp crc32.c in_ps.cpp in_tga.cpp in_pnm.cpp in_bmp.cpp in_gif.cpp in_lbm.cpp in_xpm.cpp mapping.cpp in_pcx.cpp in_jai.cpp in_png.cpp in_jpeg.cpp in_tiff.cpp rule.cpp minips.cpp encoder.cpp pts_lzw.c pts_fax.c pts_defl.c error.cpp image.cpp gensio.cpp snprintf.c gensi.cpp out_gif.cpp \
    -o sam2p.asan
