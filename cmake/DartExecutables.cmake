# Copyright (c) 2011, 2012 Peter Kümmel
# All rights reserved. Use of this source code is governed by a
# BSD-style license that can be found in the LICENSE file.

#
# snapshot tool
#

t_init(gen_snapshot)
t_addSources(bin/gen_snapshot.cc bin/builtin.cc)
t_linkLibraries(${libdart_withcore})
t_includeDirectories(.)
t_makeExecutable()


#
# dart executables
#

t_init(dart_plain)
# TODO using bin/main.cc without corelib makes no sense
t_addSources(bin/main.cc bin/builtin_nolib.cc bin/snapshot_empty.cc)
t_addSources(vm/bootstrap_nocorelib.cc)
t_linkLibraries(
    libdart_api
    libdart_lib
    libdart_vm
    libdart_builtin
    libdart_jscre
    libdart_double_conversion)
t_includeDirectories(.)
t_makeExecutable()

t_init(dart_no_snapshot)
t_addSources(bin/main.cc bin/builtin.cc bin/snapshot_empty.cc)
t_linkLibraries(${libdart_withcore})
t_includeDirectories(.)
t_makeExecutable()


t_init(dart)
t_addSources(bin/main.cc bin/builtin_nolib.cc)
t_embed_builtin_dart(web ../lib/web/web.dart)
t_addSnapshotFile(bin/snapshot_in.cc ${gen_dir}/snapshot_gen gen_snapshot)
t_linkLibraries(${libdart_withcore})
t_includeDirectories(.)
t_makeExecutable()
t_install()

