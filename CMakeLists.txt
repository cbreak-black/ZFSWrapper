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
option(ZFSW_HAS_ZPOOL_STATUS_INCOMPATIBLE_FEAT "ZFS has symbol ZPOOL_STATUS_INCOMPATIBLE_FEAT" OFF)

################################################################################
# Dependencies
################################################################################

list(APPEND CMAKE_MODULE_PATH "${CMAKE_CURRENT_LIST_DIR}/cmake")

find_package(ZFS REQUIRED)

################################################################################
# Library
################################################################################

set(ZFS_WRAPPER_SOURCES
	include/ZFSNVList.hpp
	include/ZFSStrings.hpp
	include/ZFSUtils.hpp
	src/ZFSNVList.cpp
	src/ZFSStrings.cpp
	src/ZFSUtils.cpp
)

if(ZFSW_BUILD_SHARED_LIBRARY)
	set(ZFSW_LIBRARY_TYPE SHARED)
else()
	set(ZFSW_LIBRARY_TYPE STATIC)
endif()

find_package(Threads REQUIRED)

add_library(${PROJECT_NAME} ${ZFSW_LIBRARY_TYPE}
	${ZFS_WRAPPER_SOURCES}
)

if(ZFSW_HAS_ZPOOL_STATUS_COMPATIBILITY_ERR)
	add_compile_definitions(${PROJECT_NAME} ZFSW_HAS_ZPOOL_STATUS_COMPATIBILITY_ERR)
endif()

target_link_libraries(${PROJECT_NAME}
	ZFSDependencies
	Threads::Threads
)

target_include_directories(${PROJECT_NAME}
	PUBLIC
		$<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}/include>
		$<INSTALL_INTERFACE:include> # <prefix>/include/
)

target_compile_options(${PROJECT_NAME} PRIVATE
	-Wall -Wextra -pedantic -Werror
	-Wno-error=unknown-pragmas
	-Wno-missing-field-initializers
)

# Organization in Xcode and Co
source_group(TREE ${CMAKE_CURRENT_SOURCE_DIR} FILES ${QN_SOURCES})
