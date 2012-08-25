# Copyright (c) 2011, 2012 Peter Kümmel
# All rights reserved. Use of this source code is governed by a
# BSD-style license that can be found in the LICENSE file.


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


macro(t_removeForeignOsSources)
    t_removeSources(LINUX _win _macos _android)
    t_removeSources(APPLE _win _linux _android)
    t_removeSources(WIN32 _macos _linux _posix _android)
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
    set_target_properties(${t_name} PROPERTIES OUTPUT_NAME ${t_name})
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


macro(t_install)
    install(TARGETS ${t_name}
            RUNTIME DESTINATION bin
            LIBRARY DESTINATION lib
            ARCHIVE DESTINATION lib/static)
endmacro()


macro(t_installFiles dir)
    install(FILES ${ARGN} DESTINATION ${dir})
endmacro()


macro(t_linkLibraries)
    list(APPEND t_libraries ${ARGN})
endmacro()


macro(t_makeExecutable)
    list(SORT t_sources)
    add_executable(${t_name} ${t_sources} ${t_headers})
    if(LINUX OR APPLE)
        set(_libdarts ${t_libraries} ${t_libraries}) # no -Wl-*group on Mac
    else()
        set(_libdarts ${t_libraries})
    endif()
    if(verbose)
        foreach(_it ${t_sources})
            message(STATUS "Building executable '${t_name}' with: ${_it}")
        endforeach()
    endif()
    target_link_libraries(${t_name} ${_libdarts} ${libopenssl} ${librt})
    _addDependencies()
    _addDefinitions()
    _addCompileFlags()
    _includeDirectories()
endmacro()


macro(t_makeTest)
    t_makeExecutable()
    add_test(NAME ${t_name} COMMAND ${t_name})
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


macro(createStringLiteralHelper _var _in _out _inc _varname)
    set(_dart_files ${ARGN})
    add_custom_command(
        OUTPUT ${_out}
        COMMAND ${PYTHON_EXECUTABLE}
        ARGS ${t_top}/tools/create_string_literal.py
                --output ${_out}
                --input_cc ${_in}
                --include ${_inc}
                --var_name ${_varname}
                ${_dart_files}
        DEPENDS ${_in} ${_dart_files} COMMENT "Generating ${_out}")
    if(verbose)
        message(STATUS "Adding rule for ${_out}")
        foreach(_it ${_dart_files})
            message(STATUS "Embedding dart file: ${_it}")
        endforeach()
    endif()
    set(${_var} ${_out})
endmacro()


macro(t_embedDartFiles _in _out _inc _varname)
    createStringLiteralHelper(_gen ${t_top}/${_in} ${_out} ${_inc} ${_varname} ${t_dart_sources})
    list(APPEND t_sources ${_gen})
    set(t_dart_sources)
endmacro()


macro(t_concatLibrary _out)
    set(_dart_files ${ARGN})
    add_custom_command(
        OUTPUT ${_out}
        COMMAND ${PYTHON_EXECUTABLE}
        ARGS ${t_top}/tools/concat_library.py
                ${_dart_files}
                --output ${_out}
        DEPENDS ${_dart_files} COMMENT "Generating ${_out}")
    set_source_files_properties(${_out} PROPERTIES GENERATED TRUE)
    if(verbose)
        message(STATUS "Adding rule for ${_out}")
        foreach(_it ${_dart_files})
            message(STATUS "Concatenating library: ${_it}")
        endforeach()
    endif()
endmacro()



macro(t_setDartFiles)
    set(t_dart_sources ${ARGN})
endmacro()


macro(t_addDartFiles)
    foreach(_it ${ARGN})
        get_filename_component(_file ${t_top}/${_it} ABSOLUTE)
        list(APPEND t_dart_sources ${_file})
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


macro(createSnapshotBinFile _var _in _out_base _exe_name)
    set(_out ${_out_base}.bin)
    set(_exe ${EXECUTABLE_OUTPUT_PATH}/${bin_sub_dir}/${_exe_name})
    add_custom_command(
        OUTPUT ${_out}
        COMMAND ${PYTHON_EXECUTABLE}
        ARGS ${t_top}/tools/create_snapshot_bin.py --executable ${_exe}
             --output_bin ${_out} --target_os linux
        DEPENDS ${_bin} ${_in} COMMENT "Generating ${_out}")
    if(verbose)
        message(STATUS "Adding rule for ${_out}")
    endif()
    set(${_var} ${_out})
endmacro()


macro(createSnapshotFile _var _in _out_base _exe_name)
    set(_out ${_out_base}.cc)
    set(_bin ${_out_base}.bin)
    set(_exe ${EXECUTABLE_OUTPUT_PATH}/${bin_sub_dir}/${_exe_name})
    add_custom_command(
        OUTPUT ${_out}
        COMMAND ${PYTHON_EXECUTABLE}
        ARGS ${t_top}/tools/create_snapshot_file.py
            --input_bin ${_bin} --input_cc ${_in} --output ${_out}
        DEPENDS ${_bin} ${_in} COMMENT "Generating ${_out}")
    if(verbose)
        message(STATUS "Adding rule for ${_out}")
    endif()
    set(${_var} ${_out})
endmacro()


macro(t_addSnapshotFile _in _out_base _exe_name)
    createSnapshotBinFile(_gen ${t_top}/${_in} ${_out_base} ${_exe_name})
    createSnapshotFile(_gen ${t_top}/${_in} ${_out_base} ${_exe_name})
    list(APPEND t_sources ${_gen})
    list(APPEND t_dependencies ${_exe_name})
endmacro()


