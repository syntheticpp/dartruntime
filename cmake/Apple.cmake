# Copyright (c) 2012, Peter Kümmel
# All rights reserved. Use of this source code is governed by a
# BSD-style license that can be found in the LICENSE file.


include(Gcc)

set(warn "${warn} -Wno-trigraphs -fmessage-length=0 -Wno-deprecated-declarations")
set(bin_sub_dir \${CONFIGURATION})
message(STATUS "Using SDK in '${CMAKE_OSX_SYSROOT}'")
set(multi "-arch i386 -isysroot ${CMAKE_OSX_SYSROOT}")

# Clang?
