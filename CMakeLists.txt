cmake_minimum_required(VERSION 3.10)

set(CMAKE_CXX_STANDARD 17)

project(ZFSWrapper)

################################################################################
# Settings
################################################################################

set(CMAKE_POSITION_INDEPENDENT_CODE ON)
set(CMAKE_INTERPROCEDURAL_OPTIMIZATION OFF)
set(CMAKE_CXX_VISIBILITY_PRESET hidden)
set(CMAKE_VISIBILITY_INLINES_HIDDEN 1)

option(ZFSW_BUILD_SHARED_LIBRARY "Build the ZFSWrapper as shared library" OFF)

option(ZFSW_HAS_ZPOOL_STATUS_COMPATIBILITY_ERR "ZFS has symbol ZPOOL_STATUS_COMPATIBILITY_ERR" OFF)

################################################################################
# Dependencies
################################################################################

find_path(ZFS_INCLUDE_DIR NAMES "libzfs.h"
	HINTS
		/usr/include/libzfs           # libzfslinux-dev on Ubuntu
		/usr/local/zfs/include/libzfs # OpenZFSOnOSX 2.0
)
find_path(SPL_INCLUDE_DIR NAMES "stdlib.h"
	HINTS
		/usr/include/libspl           # libzfslinux-dev on Unbuntu
		/usr/local/zfs/include/libspl # OpenZFSOnOSX 2.0
)

find_library(ZFS_CORE_LIB NAMES "libzfs_core")
find_library(ZFS_LIB NAMES "libzfs")
find_library(ZPOOL_LIB NAMES "libpool")
find_library(NVPAIR_LIB NAMES "libnvpair")

add_library(ZFSDependencies INTERFACE IMPORTED)
set_target_properties(ZFSDependencies PROPERTIES
	INTERFACE_INCLUDE_DIRECTORIES
		"${ZFS_INCLUDE_DIR};${SPL_INCLUDE_DIR}"
)
target_link_libraries(ZFSDependencies INTERFACE
	${ZFS_CORE_LIB} ${ZFS_LIB} ${ZPOOL_LIB} ${NVPAIR_LIB}
)

################################################################################
# Library
################################################################################

set(ZFS_WRAPPER_SOURCES
	ZFSNVList.cpp
	ZFSNVList.hpp
	ZFSStrings.cpp
	ZFSStrings.hpp
	ZFSUtils.cpp
	ZFSUtils.hpp
)

if(ZFSW_BUILD_SHARED_LIBRARY)
	set(ZFSW_LIBRARY_TYPE SHARED)
else()
	set(ZFSW_LIBRARY_TYPE STATIC)
endif()

add_library(${PROJECT_NAME} ${ZFSW_LIBRARY_TYPE}
	${ZFS_WRAPPER_SOURCES}
)

if(ZFSW_HAS_ZPOOL_STATUS_COMPATIBILITY_ERR)
	add_compile_definitions(${PROJECT_NAME} ZFSW_HAS_ZPOOL_STATUS_COMPATIBILITY_ERR)
endif()

target_link_libraries(${PROJECT_NAME}
	ZFSDependencies
)

target_include_directories(${PROJECT_NAME}
	PUBLIC
		$<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}/>
		$<INSTALL_INTERFACE:include> # <prefix>/include/
)

target_compile_options(${PROJECT_NAME} PRIVATE
	-Wall -Wextra -pedantic -Werror
	-Wno-error=unknown-pragmas
	-Wno-missing-field-initializers
)

# Organization in Xcode and Co
source_group(TREE ${CMAKE_CURRENT_SOURCE_DIR} FILES ${QN_SOURCES})
