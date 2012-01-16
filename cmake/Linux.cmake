# Copyright (c) 2012, Peter Kümmel
# All rights reserved. Use of this source code is governed by a
# BSD-style license that can be found in the LICENSE file.

set(LINUX 1)

include(Gcc)

if(ia32)
    set(arch 32)
elseif(x64)
    set(arch 64)
endif()

set(multi "-m${arch} -MMD ")

set(link "${link} -fPIC")
set(librt -lrt)

# Use FindOpenssl
set(libopenssl -lpthread -lcrypto)

