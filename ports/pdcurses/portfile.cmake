include(${CMAKE_TRIPLET_FILE})
include(vcpkg_common_functions)
set(SOURCE_PATH ${CURRENT_BUILDTREES_DIR}/src)
find_program(NMAKE nmake)

vcpkg_download_distfile(ARCHIVE
    URLS "http://downloads.sourceforge.net/project/pdcurses/pdcurses/3.4/pdcurs34.zip"
    FILENAME "pdcurs34.zip"
    SHA512 0b916bfe37517abb80df7313608cc4e1ed7659a41ce82763000dfdfa5b8311ffd439193c74fc84a591f343147212bf1caf89e7db71f1f7e4fa70f534834cb039
)
vcpkg_extract_source_archive(${ARCHIVE})

set(PDC_NMAKE_CMD ${NMAKE} -f vcwin32.mak WIDE=Y UTF8=Y)
set(PDC_NMAKE_CWD ${SOURCE_PATH}/win32)
set(PDC_PDCLIB ${SOURCE_PATH}/win32/pdcurses)
set(PDC_PANELLIB ${SOURCE_PATH}/win32/panel)
set(PDC_OUTPUT bin)

if (VCPKG_LIBRARY_LINKAGE STREQUAL "static")
    set(PDC_PDCLIB ${PDC_PDCLIB}.lib)
    set(PDC_PANELLIB ${PDC_PANELLIB}.lib)
    set(PDC_OUTPUT lib)
else()
    set(PDC_PDCLIB ${PDC_PDCLIB}.dll)
    set(PDC_PANELLIB ${PDC_PANELLIB}.dll)
    set(PDC_NMAKE_CMD ${PDC_NMAKE_CMD} DLL=Y)
endif()

message(STATUS "Build ${TARGET_TRIPLET}-rel")
vcpkg_execute_required_process(
    COMMAND ${PDC_NMAKE_CMD}
    WORKING_DIRECTORY ${PDC_NMAKE_CWD}
    LOGNAME build-${TARGET_TRIPLET}-rel
)
message(STATUS "Build ${TARGET_TRIPLET}-rel done")
file (
    COPY ${PDC_PDCLIB} ${PDC_PANELLIB}
    DESTINATION ${CURRENT_PACKAGES_DIR}/${PDC_OUTPUT}
)

message(STATUS "Build ${TARGET_TRIPLET}-dbg")
vcpkg_execute_required_process(
    COMMAND ${PDC_NMAKE_CMD} DEBUG=Y
    WORKING_DIRECTORY ${PDC_NMAKE_CWD}
    LOGNAME build-${TARGET_TRIPLET}-dbg
)
message(STATUS "Build ${TARGET_TRIPLET}-dbg done")
file (
    COPY ${PDC_PDCLIB} ${PDC_PANELLIB}
    DESTINATION ${CURRENT_PACKAGES_DIR}/debug/${PDC_OUTPUT}
)

file(
    COPY ${SOURCE_PATH}/curses.h ${SOURCE_PATH}/panel.h ${SOURCE_PATH}/term.h
    DESTINATION ${CURRENT_PACKAGES_DIR}/include
)
file(INSTALL ${CMAKE_CURRENT_LIST_DIR}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/pdcurses RENAME copyright)
