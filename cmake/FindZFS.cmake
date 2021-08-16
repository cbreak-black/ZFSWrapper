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

find_library(ZFS_CORE_LIB NAMES "zfs_core")
find_library(ZFS_LIB NAMES "zfs")
find_library(ZPOOL_LIB NAMES "zpool")
find_library(NVPAIR_LIB NAMES "nvpair")

add_library(ZFSDependencies INTERFACE IMPORTED)
set_target_properties(ZFSDependencies PROPERTIES
	INTERFACE_INCLUDE_DIRECTORIES
		"${ZFS_INCLUDE_DIR};${SPL_INCLUDE_DIR}"
)
target_link_libraries(ZFSDependencies INTERFACE
	${ZFS_CORE_LIB} ${ZFS_LIB} ${ZPOOL_LIB} ${NVPAIR_LIB}
)

include(FindPackageHandleStandardArgs)

find_package_handle_standard_args(ZFS DEFAULT_MSG
    ZFS_INCLUDE_DIR
    SPL_INCLUDE_DIR
    ZFS_CORE_LIB
    ZFS_LIB
    ZPOOL_LIB
    NVPAIR_LIB
)
