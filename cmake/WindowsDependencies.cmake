

message(STATUS)

set(deps_dir ${CMAKE_BINARY_DIR}/windows-dependencies)

if(NOT EXISTS ${deps_dir}/Python/python.exe)
    
    set(deps_file      dart-windows-dependencies.zip)
    set(deps_file_path ${CMAKE_BINARY_DIR}/../${deps_file})
    
    if(EXISTS ${deps_file_path})
        # local file system
        message(STATUS "Using already downloaded dependency package'${deps_file_path}'")
    else()
        # download
        set(deps_file_path ${CMAKE_BINARY_DIR}/${deps_file})
        set(deps_server http://downloads.sourceforge.net/project/scusi)
        message(STATUS "Downloading ${deps_file} from '${deps_server}'")
        file(DOWNLOAD ${deps_server}/${deps_file} ${deps_file_path} SHOW_PROGRESS STATUS status LOG log)
        list(GET status 0 status_code)
        list(GET status 1 status_string)
        if(NOT status_code EQUAL 0)
            message(FATAL_ERROR "error: downloading '${deps_file}' failed. status_code: ${status_code}, status_string: ${status_string}. \nLog: ${log} ")
        endif()
    endif()
    
    file(REMOVE_RECURSE ${deps_dir})
    
    # extract
    execute_process(COMMAND ${CMAKE_COMMAND} -E tar xzf ${deps_file_path} WORKING_DIRECTORY ${CMAKE_BINARY_DIR})
    set(openssl ${deps_dir}/OpenSSL-Win32 CACHE STRING "OpenSSL dir" FORCE)
    set(PYTHON_EXECUTABLE ${deps_dir}/Python/python.exe CACHE STRING "Python binary" FORCE)
    file(MAKE_DIRECTORY ${EXECUTABLE_OUTPUT_PATH})
    file(MAKE_DIRECTORY ${EXECUTABLE_OUTPUT_PATH}/Debug)
    file(MAKE_DIRECTORY ${EXECUTABLE_OUTPUT_PATH}/Release)
    configure_file(${openssl}/bin/libeay32.dll ${EXECUTABLE_OUTPUT_PATH} COPYONLY)
    configure_file(${openssl}/bin/libeay32.dll ${EXECUTABLE_OUTPUT_PATH}/Debug COPYONLY)
    configure_file(${openssl}/bin/libeay32.dll ${EXECUTABLE_OUTPUT_PATH}/Release COPYONLY)
    
endif()

message(STATUS "Using Windows dependencies in ${deps_dir}")
