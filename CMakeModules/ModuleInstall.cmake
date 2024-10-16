# INSTALL and SOURCE_GROUP commands for OSG/OT/Producer Modules

# Required Vars:
# ${LIB_NAME}
# ${TARGET_H}

SET(HEADERS_GROUP "Header Files")

SOURCE_GROUP(
    ${HEADERS_GROUP}
    FILES ${TARGET_H}
)

IF(MSVC AND OSG_MSVC_VERSIONED_DLL)
    HANDLE_MSVC_DLL()
ENDIF()


IF(OSG_EXPORT_TARGETS)

    INSTALL(
        TARGETS ${LIB_NAME}
        EXPORT  ${LIB_NAME}
        RUNTIME DESTINATION ${INSTALL_BINDIR} COMPONENT libopenscenegraph
        LIBRARY DESTINATION ${INSTALL_LIBDIR} COMPONENT libopenscenegraph
        ARCHIVE DESTINATION ${INSTALL_ARCHIVEDIR} COMPONENT libopenscenegraph-dev
    )

    INSTALL(
        EXPORT ${LIB_NAME}
        NAMESPACE ${PKG_NAMESPACE}::
        DESTINATION ${INSTALL_CONFIGDIR}
        FILE ${LIB_NAME}-targets.cmake
        COMPONENT libopenscenegraph-dev
    )

    SET(COMPONENT_CMAKE_DEPENDENCIES ${TARGET_LIBRARIES})

    # These two libraries are special cases because they will always be included
    # by the config-file.
    LIST(REMOVE_ITEM COMPONENT_CMAKE_DEPENDENCIES OpenThreads)
    LIST(REMOVE_ITEM COMPONENT_CMAKE_DEPENDENCIES osg)

    SET(TARGET_IMPORT_INPUT_FILE  "${PROJECT_SOURCE_DIR}/packaging/cmake/openscenegraph-component-import-targets.cmake")
    SET(TARGET_IMPORT_OUTPUT_FILE "${PROJECT_BINARY_DIR}/packaging/cmake/openscenegraph-${LIB_NAME}-import-targets.cmake")
    CONFIGURE_FILE(
        ${TARGET_IMPORT_INPUT_FILE}
        ${TARGET_IMPORT_OUTPUT_FILE}
        @ONLY
    )
    INSTALL(
        FILES ${TARGET_IMPORT_OUTPUT_FILE}
        DESTINATION ${INSTALL_CONFIGDIR}
        COMPONENT libopenscenegraph-dev
    )

ELSE()

    INSTALL(
        TARGETS ${LIB_NAME}
        RUNTIME DESTINATION ${INSTALL_BINDIR} COMPONENT libopenscenegraph
        LIBRARY DESTINATION ${INSTALL_LIBDIR} COMPONENT libopenscenegraph
        ARCHIVE DESTINATION ${INSTALL_ARCHIVEDIR} COMPONENT libopenscenegraph-dev
    )

ENDIF()

IF(MSVC AND DYNAMIC_OPENSCENEGRAPH)
    GET_TARGET_PROPERTY(PREFIX ${LIB_NAME} PREFIX)
    IF("${PREFIX}" STREQUAL PREFIX-NOTFOUND) # Fix for PREFIX-NOTFOUND left in file names
        SET(PREFIX "")
    ENDIF()
    IF( ${CMAKE_GENERATOR} STREQUAL "Ninja" )
        INSTALL(FILES ${CMAKE_CURRENT_BINARY_DIR}/${PREFIX}${LIB_NAME}${CMAKE_RELEASE_POSTFIX}.pdb DESTINATION ${INSTALL_BINDIR} COMPONENT libopenscenegraph CONFIGURATIONS Release)
        INSTALL(FILES ${CMAKE_CURRENT_BINARY_DIR}/${PREFIX}${LIB_NAME}${CMAKE_RELWITHDEBINFO_POSTFIX}.pdb DESTINATION ${INSTALL_BINDIR} COMPONENT libopenscenegraph CONFIGURATIONS RelWithDebInfo)
        INSTALL(FILES ${CMAKE_CURRENT_BINARY_DIR}/${PREFIX}${LIB_NAME}${CMAKE_DEBUG_POSTFIX}.pdb DESTINATION ${INSTALL_BINDIR} COMPONENT libopenscenegraph CONFIGURATIONS Debug)
    ELSE( ${CMAKE_GENERATOR} STREQUAL "Ninja" )
        INSTALL(FILES ${OUTPUT_BINDIR}/${PREFIX}${LIB_NAME}${CMAKE_RELWITHDEBINFO_POSTFIX}.pdb DESTINATION ${INSTALL_BINDIR} COMPONENT libopenscenegraph CONFIGURATIONS RelWithDebInfo)
        INSTALL(FILES ${OUTPUT_BINDIR}/${PREFIX}${LIB_NAME}${CMAKE_DEBUG_POSTFIX}.pdb DESTINATION ${INSTALL_BINDIR} COMPONENT libopenscenegraph CONFIGURATIONS Debug)
    ENDIF( ${CMAKE_GENERATOR} STREQUAL "Ninja" )
ENDIF(MSVC AND DYNAMIC_OPENSCENEGRAPH)

IF(NOT OSG_COMPILE_FRAMEWORKS)
    INSTALL (
        FILES        ${TARGET_H}
        DESTINATION ${INSTALL_INCDIR}/${LIB_NAME}
        COMPONENT libopenscenegraph-dev
    )
ELSE()
    SET(CMAKE_BUILD_WITH_INSTALL_RPATH TRUE)
    SET(CMAKE_INSTALL_RPATH "${OSG_COMPILE_FRAMEWORKS_INSTALL_NAME_DIR}")
    
    SET_TARGET_PROPERTIES(${LIB_NAME} PROPERTIES
         FRAMEWORK TRUE
         FRAMEWORK_VERSION ${OPENSCENEGRAPH_SOVERSION}
         PUBLIC_HEADER  "${TARGET_H}"
         INSTALL_NAME_DIR "${OSG_COMPILE_FRAMEWORKS_INSTALL_NAME_DIR}"
    )
    # MESSAGE("${OSG_COMPILE_FRAMEWORKS_INSTALL_NAME_DIR}")
ENDIF()


# Install pkgconfig file for this component
SET(COMPONENT_PKGCONFIG_REQUIRES)
FOREACH(component ${TARGET_LIBRARIES})
    IF(${component} STREQUAL "OpenThreads")
        # Skip OpenThreads because that's handled separately
        CONTINUE()
    ENDIF()
    SET(COMPONENT_PKGCONFIG_REQUIRES "${COMPONENT_PKGCONFIG_REQUIRES} openscenegraph-${component}")
ENDFOREACH()

SET(PKGCONFIG_INPUT_FILE  "${PROJECT_SOURCE_DIR}/packaging/pkgconfig/component.pc.in")
SET(PKGCONFIG_OUTPUT_FILE "${PROJECT_BINARY_DIR}/packaging/pkgconfig/openscenegraph-${LIB_NAME}.pc")
CONFIGURE_FILE(
    ${PKGCONFIG_INPUT_FILE}
    ${PKGCONFIG_OUTPUT_FILE}
    @ONLY
)
INSTALL(
    FILES ${PKGCONFIG_OUTPUT_FILE}
    DESTINATION ${INSTALL_PKGCONFIGDIR}
    COMPONENT libopenscenegraph-dev
)