# Copyright (c) 2012, Peter Kümmel
# All rights reserved. Use of this source code is governed by a
# BSD-style license that can be found in the LICENSE file.


execute_process(COMMAND ${CMAKE_CXX_COMPILER} -dumpversion OUTPUT_VARIABLE GCC_VERSION)
if(verbose)
    message(STATUS "Using GCC version ${GCC_VERSION}")
endif()

set(warn  "-Wall -Wextra -Wno-unused-parameter -Wnon-virtual-dtor")
if(GCC_VERSION VERSION_LESS 4.6)
    set(warn "${warn} -Werror")
endif()
if(NOT GCC_VERSION VERSION_LESS 4.3)
    set(warn "${warn} -Wno-conversion-null -Wvla")
endif()

set(link  "-fvisibility=hidden -fvisibility-inlines-hidden")
set(lang  "-fno-rtti -fno-exceptions")
