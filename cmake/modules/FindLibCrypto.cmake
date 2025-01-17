# - Try to find LibCrypto include dirs and libraries
#
# Usage of this module as follows:
#
#     find_package(LibCrypto)
#
# Variables used by this module, they can change the default behaviour and need
# to be set before calling find_package:
#
# Variables defined by this module:
#
#  LibCrypto_FOUND             System has libcrypto, include and library dirs found
#  LibCrypto_INCLUDE_DIR       The crypto include directories.
#  LibCrypto_LIBRARY           The crypto library, depending on the value of BUILD_SHARED_LIBS.
#  LibCrypto_SHARED_LIBRARY    The path to libcrypto.so
#  LibCrypto_STATIC_LIBRARY    The path to libcrypto.a

find_package(crypto QUIET)

if (crypto_FOUND)
    get_target_property(crypto_INCLUDE_DIR crypto INTERFACE_INCLUDE_DIRECTORIES)
    message(STATUS "S2N found target: crypto")
    message(STATUS "crypto Include Dir: ${crypto_INCLUDE_DIR}")
    set(LIBCRYPTO_FOUND true)
    set(LibCrypto_FOUND true)
else()
    find_path(LibCrypto_INCLUDE_DIR
        NAMES openssl/crypto.h
        HINTS "${CMAKE_INSTALL_PREFIX}"
        PATH_SUFFIXES include
        )
    find_library(LibCrypto_SHARED_LIBRARY
        NAMES libcrypto.so libcrypto.dylib
        HINTS "${CMAKE_INSTALL_PREFIX}"
        PATH_SUFFIXES build/crypto build lib64 lib
        )
    find_library(LibCrypto_STATIC_LIBRARY
        NAMES libcrypto.a
        HINTS "${CMAKE_INSTALL_PREFIX}"
        PATH_SUFFIXES build/crypto build lib64 lib
        )

    if (NOT LibCrypto_LIBRARY)
        if (BUILD_SHARED_LIBS)
            set(LibCrypto_LIBRARY ${LibCrypto_SHARED_LIBRARY})
        else()
            set(LibCrypto_LIBRARY ${LibCrypto_STATIC_LIBRARY})
        endif()
    endif()

    include(FindPackageHandleStandardArgs)
    find_package_handle_standard_args(LibCrypto DEFAULT_MSG
        LibCrypto_LIBRARY
        LibCrypto_INCLUDE_DIR
        )

    mark_as_advanced(
        LibCrypto_ROOT_DIR
        LibCrypto_INCLUDE_DIR
        LibCrypto_LIBRARY
        LibCrypto_SHARED_LIBRARY
        LibCrypto_STATIC_LIBRARY
        )

    # some versions of cmake have a super esoteric bug around capitalization differences between
    # find dependency and find package, just avoid that here by checking and
    # setting both.
    if(LIBCRYPTO_FOUND OR LibCrypto_FOUND)
        set(LIBCRYPTO_FOUND true)
        set(LibCrypto_FOUND true)

        message(STATUS "LibCrypto Include Dir: ${LibCrypto_INCLUDE_DIR}")
        message(STATUS "LibCrypto Shared Lib:  ${LibCrypto_SHARED_LIBRARY}")
        message(STATUS "LibCrypto Static Lib:  ${LibCrypto_STATIC_LIBRARY}")
        if (NOT TARGET crypto AND
            (EXISTS "${LibCrypto_LIBRARY}")
            )
            set(THREADS_PREFER_PTHREAD_FLAG ON)
            find_package(Threads REQUIRED)
            add_library(crypto UNKNOWN IMPORTED)
            set_target_properties(crypto PROPERTIES
                INTERFACE_INCLUDE_DIRECTORIES "${LibCrypto_INCLUDE_DIR}")
            set_target_properties(crypto PROPERTIES
                IMPORTED_LINK_INTERFACE_LANGUAGES "C"
                IMPORTED_LOCATION "${LibCrypto_LIBRARY}")
            add_dependencies(crypto Threads::Threads)
        endif()
    endif()
endif()
