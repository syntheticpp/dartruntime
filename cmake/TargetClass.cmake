# Copyright (c) 2011, Peter Kümmel
# All rights reserved. Use of this source code is governed by a
# BSD-style license that can be found in the LICENSE file.


find_package(PythonInterp)


macro(t_setTopDir _dir)
    get_filename_component(t_top ${_dir} ABSOLUTE)
endmacro()


macro(t_init _name)
    set(t_name ${_name})
    set(t_sources)
    set(t_headers)
    set(t_libraries)
    set(t_dart_sources)
    set(t_dependencies)
    set(t_definitions)
    set(t_compile_flags)
    set(t_include_dirs)
endmacro()


macro(t_addSources)
    foreach(_it ${ARGN})
        list(APPEND t_sources ${t_top}/${_it})
    endforeach()
endmacro()


macro(t_addHeaders)
    foreach(_it ${ARGN})
        list(APPEND t_headers ${t_top}/${_it})
    endforeach()
endmacro()


macro(t_removeSources _sys)
    if(${_sys} OR ${_sys} MATCHES ALL)
        foreach(_it ${ARGN})
            list(REMOVE_ITEM t_sources ${t_top}/${_it})
        endforeach()
        foreach(_match ${ARGN})
            foreach(_it ${t_sources})
                if(${_it} MATCHES ${_match})
                    list(REMOVE_ITEM t_sources ${_it})
                endif()
            endforeach()
        endforeach()
    endif()
endmacro()


macro(t_findSources _subdir _ending)
    set(_dir ${t_top}/${_subdir})
    file(GLOB _files ${_dir}/*${_ending})
    list(APPEND t_sources ${_files})
endmacro()


macro(t_findHeaders _subdir _ending)
    set(_dir ${t_top}/${_subdir})
    file(GLOB _files ${_dir}/*${_ending})
    list(APPEND t_headers ${_files})
endmacro()


macro(t_includeDirectories)
    foreach(_it ${ARGN})
        t_includeDirectoriesAbsolute(${t_top}/${_it})
    endforeach()
endmacro()


macro(t_includeDirectoriesAbsolute)
    foreach(_it ${ARGN})
        set(t_include_dirs "${t_include_dirs} -I${_it}")
    endforeach()
endmacro()


macro(t_makeLibrary)
    list(SORT t_sources)
    add_library(${t_name} STATIC ${t_sources} ${t_headers})
    if(verbose)
        foreach(_it ${t_sources})
            message(STATUS "Building library '${t_name}' with: ${_it}")
        endforeach()
    endif()
    _addDependencies()
    _addDefinitions()
    _addCompileFlags()
    _includeDirectories()
endmacro()


macro(t_linkLibraries)
    list(APPEND t_libraries ${ARGN})
endmacro()


macro(t_makeExecutable)
    list(SORT t_sources)
    add_executable(${t_name} ${t_sources} ${t_headers})
    set(_libdarts dart_api dart_vm dart_builtin dart_lib)
    if(LINUX OR APPLE)
        set(_libdarts ${_libdarts} ${t_libraries} ${_libdarts}) # no -Wl-*group on Mac
        set(_libplatform -lpthread -lcrypto ${librt})
    endif()
    if(WIN32)
        list(APPEND _libdarts ${t_libraries})
        set(_libplatform ${libopenssl} ws2_32 Rpcrt4)
    endif()
    if(verbose)
        foreach(_it ${t_sources})
            message(STATUS "Building executable '${t_name}' with: ${_it}")
        endforeach()
    endif()
    target_link_libraries(${t_name} ${_libdarts} jscre double_conversion ${_libplatform})
    _addDependencies()
    _addDefinitions()
    _addCompileFlags()
    _includeDirectories()
endmacro()


macro(_addDependencies)
    if(t_dependencies)
        add_dependencies(${t_name} ${t_dependencies})
    endif()
endmacro()


macro(t_addDefinitions)
    foreach(_it ${ARGN})
        list(APPEND t_definitions ${_it})
        if(verbose)
            message(STATUS "Target ${t_name}: adding definition ${_it}")
        endif()
    endforeach()
endmacro()


macro(_addDefinitions)
    if(t_definitions)
        set_target_properties(${t_name} PROPERTIES COMPILE_DEFINITIONS "${t_definitions}")
    endif()
endmacro()


macro(t_addCompileFlags _sys)
    if(${_sys} OR ${_sys} MATCHES ALL)
        foreach(_it ${ARGN})
            list(APPEND t_compile_flags ${_it})
        endforeach()
    endif()
endmacro()


macro(_addCompileFlags)
    if(t_compile_flags)
        set_target_properties(${t_name} PROPERTIES COMPILE_FLAGS "${t_compile_flags}")
        if(verbose)
            message(STATUS "Target ${t_name}: adding CXX flags '${t_compile_flags}'")
        endif()
    endif()
endmacro()

macro(_includeDirectories)
    if(t_include_dirs)
        set_target_properties(${t_name} PROPERTIES COMPILE_FLAGS ${t_include_dirs})
        if(verbose)
            message(STATUS "Target ${t_name}: adding include directories '${t_include_dirs}'")
        endif()
    endif()
endmacro()


macro(createStringLiteralHelper _var _in _out)
    set(_dart_files ${ARGN})
    add_custom_command(
        OUTPUT ${_out}
        COMMAND ${PYTHON_EXECUTABLE}
        ARGS ${t_top}/tools/create_string_literal.py
             --output ${_out} --input_cc ${_in} ${_dart_files}
        DEPENDS ${_in} COMMENT "Generating ${_out}")
    if(verbose)
        message(STATUS "Adding rule for ${_out}")
        foreach(_it ${_dart_files})
            message(STATUS "Embedding dart file: ${_it}")
        endforeach()
    endif()
    set(${_var} ${_out})
endmacro()


macro(t_embedDartFiles _in _out)
    createStringLiteralHelper(_gen ${t_top}/${_in} ${_out} ${t_dart_sources})
    list(APPEND t_sources ${_gen})
    set(t_dart_sources)
endmacro()


macro(t_addDartFiles)
    foreach(_it ${ARGN})
        list(APPEND t_dart_sources ${t_top}/${_it})
    endforeach()
endmacro()


macro(t_prependDartFiles)
    set(_dart_files)
    foreach(_it ${ARGN})
        list(APPEND _dart_files ${t_top}/${_it})
        list(REMOVE_ITEM t_dart_sources  ${t_top}/${_it})
    endforeach()
    set(t_dart_sources ${_dart_files} ${t_dart_sources})
endmacro()


macro(t_removeDartFiles)
    foreach(_it ${ARGN})
        list(REMOVE_ITEM t_dart_sources ${t_top}/${_it})
    endforeach()
endmacro()


macro(t_findDartFiles _dir)
    file(GLOB _dart_files ${t_top}/${_dir}/*.dart)
    list(SORT _dart_files)
    list(APPEND t_dart_sources ${_dart_files})
endmacro()


macro(createSnapshotFile _var _in _out_base _exe_name)
    set(_out ${_out_base}.cc)
    set(_bin ${_out_base}.bin)
    set(_exe ${EXECUTABLE_OUTPUT_PATH}/${bin_sub_dir}/${_exe_name})
    add_custom_command(
        OUTPUT ${_out}
        COMMAND ${PYTHON_EXECUTABLE}
        ARGS ${t_top}/tools/create_snapshot_file.py --executable ${_exe}
             --output_bin ${_bin} --input_cc ${_in} --output ${_out}
        DEPENDS ${_exe} ${_in} COMMENT "Generating ${_out}")
    if(verbose)
        message(STATUS "Adding rule for ${_out}")
    endif()
    set(${_var} ${_out})
endmacro()


macro(t_addSnapshotFile _in _out_base _exe_name)
    createSnapshotFile(_gen ${t_top}/${_in} ${_out_base} ${_exe_name})
    list(APPEND t_sources ${_gen})
    list(APPEND t_dependencies ${_exe_name})
endmacro()


