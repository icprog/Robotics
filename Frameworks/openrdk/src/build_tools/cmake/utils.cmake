INCLUDE(${OpenRDK_CMAKE_MODULE_PATH}/prettymessage.cmake)

IF(RDK_INSIDE_OpenRDK)
	SET(OpenRDK_LIBRARY_OUTPUT_DIRECTORY "${OpenRDK_OUTPUT_TREE}/lib")
	SET(OpenRDK_RUNTIME_OUTPUT_DIRECTORY "${OpenRDK_OUTPUT_TREE}/bin")
ELSE(RDK_INSIDE_OpenRDK)
	SET(OpenRDK_LIBRARY_OUTPUT_DIRECTORY "${OpenRDK_OUTPUT_TREE}/libext")
	SET(OpenRDK_RUNTIME_OUTPUT_DIRECTORY "${OpenRDK_OUTPUT_TREE}/binext")
ENDIF(RDK_INSIDE_OpenRDK)

######################################################################
# Macro for find libraries (required/optional)                       #
# an optional boolean parameter could be passed if the library is    #
# in a non-standard path                                             #
# In this case a ${LNAME}_ROOT path should be specified using ccmake #
######################################################################
MACRO(RDK_FIND_LIB LNAME required)
	IF(${ARGC} GREATER 2)
		RDK_FIND_LIB_nested(${LNAME} ${required} ${ARGV2})
	ELSE(${ARGC} GREATER 2)
		RDK_FIND_LIB_nested(${LNAME} ${required} FALSE)
	ENDIF(${ARGC} GREATER 2)
ENDMACRO(RDK_FIND_LIB LNAME required)

########################################
# Auxiliary macro used by RDK_FIND_LIB #
########################################
MACRO(RDK_FIND_LIB_nested LNAME required withroot)
	IF("${withroot}" STREQUAL "TRUE")
		verbose("Setting a root variable for library '${LNAME}'")
		SET(ROOT_${LNAME} "" CACHE STRING "Root directory for lib '${LNAME}'")
	ENDIF("${withroot}" STREQUAL "TRUE")

	INCLUDE (${OpenRDK_CMAKE_MODULE_PATH}/Find${LNAME}.cmake)
	IF(NOT ${LNAME}_FOUND)
		IF("${required}" STREQUAL "required")
			error("${LNAME} not found, it is REQUIRED to build the RDK")
		ELSE("${required}" STREQUAL "required")
			info("${LNAME} not found but it is not required")
		ENDIF("${required}" STREQUAL "required")
	ELSE(NOT ${LNAME}_FOUND)

	info("${LNAME} found")
	verbose("   ${LNAME}_LIBRARIES = ${${LNAME}_LIBRARIES}")
	verbose("   ${LNAME}_INCLUDE_DIR = ${${LNAME}_INCLUDE_DIR}")
	verbose("   ${LNAME}_LINK_DIRECTORIES = ${${LNAME}_LINK_DIRECTORIES}")
	verbose("   ${LNAME}_DEFINITIONS = ${${LNAME}_DEFINITIONS}")
	IF("${required}" STREQUAL "required")
		LIST(APPEND _rdkcore_include_directories ${${LNAME}_INCLUDE_DIR})
		LIST(APPEND _rdkcore_link_directories ${${LNAME}_LINK_DIRECTORIES})
		LIST(APPEND _rdkcore_libraries ${${LNAME}_LIBRARIES})
	ENDIF("${required}" STREQUAL "required")
	LIST(APPEND _rdkcore_definitions ${${LNAME}_DEFINITIONS})
	SET(FINDOPENRDK_LIBRARIES_SECTION "${FINDOPENRDK_LIBRARIES_SECTION}
SET(${LNAME}_FOUND YES)
SET(${LNAME}_INCLUDE_DIR \"${${LNAME}_INCLUDE_DIR}\" )
SET(${LNAME}_LINK_DIRECTORIES \"${${LNAME}_LINK_DIRECTORIES}\" )
SET(${LNAME}_LIBRARIES \"${${LNAME}_LIBRARIES}\" )
SET(${LNAME}_DEFINITIONS \"${${LNAME}_DEFINITIONS}\" )
")
	ENDIF(NOT ${LNAME}_FOUND)
ENDMACRO(RDK_FIND_LIB_nested LNAME)

################################################################################
# Macro to add an OpenRDK module in the build system; it links against rdkcore #
################################################################################
MACRO(RDK_ADD_RAGENT_MODULE PARAM_FILE_LIST)
	STRING(REGEX REPLACE ".*/([^/]*)$" "\\1" MODULE_NAME ${CMAKE_CURRENT_SOURCE_DIR})
	string(TOLOWER ${MODULE_NAME} MODULE_NAME)
	SET(FILE_LIST ${PARAM_FILE_LIST})
	IF("${FILE_LIST}" STREQUAL "ALL_FILES" OR "${FILE_LIST}" STREQUAL "AUTO")
		FILE(GLOB FILE_LIST "*.cpp" "*.c")
	ENDIF("${FILE_LIST}" STREQUAL "ALL_FILES" OR "${FILE_LIST}" STREQUAL "AUTO")
	IF("${FILE_LIST}" STREQUAL "ALL_FILES_RECURSE")
		FILE(GLOB_RECURSE FILE_LIST "*.cpp" "*.c")
	ENDIF("${FILE_LIST}" STREQUAL "ALL_FILES_RECURSE")
	SET(THIS_MODULE_NAME "rdkram_${MODULE_NAME}")
	SET(RDK_THIS_MODULE_NAME ${THIS_MODULE_NAME})

	GET_FILENAME_COMPONENT(THIS_TARGET_DIR ${CMAKE_CURRENT_SOURCE_DIR} NAME)
	LIST(FIND RDK_FORCE_REMOVE_TARGET_LIST ${THIS_TARGET_DIR} TO_REMOVE)
	IF(NOT ${TO_REMOVE} EQUAL -1)
		RDK_ADD_FORCE_REMOVE_COMMAND(${RDK_THIS_MODULE_NAME} ${OpenRDK_LIBRARY_OUTPUT_DIRECTORY})
	ELSE(NOT ${TO_REMOVE} EQUAL -1)
		INCLUDE_DIRECTORIES(${RDKCORE_INCLUDE_DIR})
		LINK_DIRECTORIES(${RDKCORE_LINK_DIRECTORIES})
		ADD_LIBRARY(${THIS_MODULE_NAME} SHARED ${FILE_LIST})
		TARGET_LINK_LIBRARIES(${THIS_MODULE_NAME} ${RDKCORE_LIBRARIES})
		SET_TARGET_PROPERTIES(${THIS_MODULE_NAME} PROPERTIES COMPILE_FLAGS "${RDKCORE_CPPFLAGS} ${RDKCORE_CXXFLAGS}")
		SET_TARGET_PROPERTIES(${THIS_MODULE_NAME} PROPERTIES LINK_FLAGS "${RDKCORE_LDFLAGS}")
		# NOTE: depending on the operating system, shared libraries and their static counterpart are treated as LIBRARY, RUNTIME or ARCHIVE
		SET_TARGET_PROPERTIES(${THIS_MODULE_NAME} PROPERTIES LIBRARY_OUTPUT_DIRECTORY "${OpenRDK_LIBRARY_OUTPUT_DIRECTORY}")
		verbose("Adding module \"${RDK_THIS_MODULE_NAME}\"")
	ENDIF(NOT ${TO_REMOVE} EQUAL -1)
ENDMACRO(RDK_ADD_RAGENT_MODULE)

#####################################################
# Macro to add an application that links to rdkcore #
#####################################################
MACRO(RDK_ADD_EXECUTABLE PARAM_EXE_NAME PARAM_FILE_LIST)
	SET(EXE_NAME "${PARAM_EXE_NAME}")
	string(TOLOWER ${EXE_NAME} EXE_NAME)
	IF("${EXE_NAME}" MATCHES "auto")
		STRING(REGEX REPLACE ".*/([^/]*)$" "\\1" EXE_NAME ${CMAKE_CURRENT_SOURCE_DIR})
	ENDIF("${EXE_NAME}" MATCHES "auto")
	SET(FILE_LIST ${PARAM_FILE_LIST})
	IF("${FILE_LIST}" MATCHES "ALL_FILES")
		FILE(GLOB FILE_LIST "*.cpp")
	ENDIF("${FILE_LIST}" MATCHES "ALL_FILES")
	SET(RDK_THIS_EXE_NAME ${EXE_NAME})

	GET_FILENAME_COMPONENT(THIS_TARGET_DIR ${CMAKE_CURRENT_SOURCE_DIR} NAME)
	LIST(FIND RDK_FORCE_REMOVE_TARGET_LIST ${THIS_TARGET_DIR} TO_REMOVE)
	IF(NOT ${TO_REMOVE} EQUAL -1)
		RDK_ADD_FORCE_REMOVE_COMMAND(${RDK_THIS_EXE_NAME} ${OpenRDK_RUNTIME_OUTPUT_DIRECTORY})
	ELSE(NOT ${TO_REMOVE} EQUAL -1)
		INCLUDE_DIRECTORIES(${RDKCORE_INCLUDE_DIR})
		LINK_DIRECTORIES(${RDKCORE_LINK_DIRECTORIES})
		ADD_EXECUTABLE(${RDK_THIS_EXE_NAME} ${FILE_LIST})
		TARGET_LINK_LIBRARIES(${RDK_THIS_EXE_NAME} ${RDKCORE_LIBRARIES})
		SET_TARGET_PROPERTIES(${RDK_THIS_EXE_NAME} PROPERTIES COMPILE_FLAGS "${RDKCORE_CPPFLAGS} ${RDKCORE_CXXFLAGS}")
		SET_TARGET_PROPERTIES(${RDK_THIS_EXE_NAME} PROPERTIES LINK_FLAGS "${RDKCORE_LDFLAGS}")
		# NOTE: depending on the operating system, shared libraries and their static counterpart are treated as LIBRARY, RUNTIME or ARCHIVE
		SET_TARGET_PROPERTIES(${RDK_THIS_EXE_NAME} PROPERTIES RUNTIME_OUTPUT_DIRECTORY "${OpenRDK_RUNTIME_OUTPUT_DIRECTORY}")
		SET_TARGET_PROPERTIES(${RDK_THIS_EXE_NAME} PROPERTIES ARCHIVE_OUTPUT_DIRECTORY "${OpenRDK_RUNTIME_OUTPUT_DIRECTORY}")
		verbose("Adding executable \"${RDK_THIS_EXE_NAME}\"")
	ENDIF(NOT ${TO_REMOVE} EQUAL -1)
ENDMACRO(RDK_ADD_EXECUTABLE)

########################################################################
# Macro to add an library in the build system; it may not link rdkcore #
########################################################################
MACRO(RDK_ADD_LIBRARY)
	STRING(REGEX REPLACE ".*/([^/]*)$" "\\1" LIBRARY_NAME ${CMAKE_CURRENT_SOURCE_DIR})
	string(TOLOWER ${LIBRARY_NAME} LIBRARY_NAME)
	SET(FILE_LIST ${ARGV0})
	IF("${FILE_LIST}" STREQUAL "ALL_FILES")
		FILE(GLOB FILE_LIST "*.cpp")
	ELSEIF("${FILE_LIST}" STREQUAL "ALL_FILES_RECURSE")
		FILE(GLOB_RECURSE FILE_LIST "*.cpp")
	ENDIF("${FILE_LIST}" STREQUAL "ALL_FILES")
	# this will fail if library has more than one cpp file...
	IF(NOT "${ARGV1}" STREQUAL "")
		SET(LIBRARY_NAME "${ARGV1}")
	ENDIF(NOT "${ARGV1}" STREQUAL "")
	SET(THIS_LIBRARY_NAME "rdk_${LIBRARY_NAME}")
	SET(RDK_THIS_LIBRARY_NAME ${THIS_LIBRARY_NAME})

	GET_FILENAME_COMPONENT(THIS_TARGET_DIR ${CMAKE_CURRENT_SOURCE_DIR} NAME)
	LIST(FIND RDK_FORCE_REMOVE_TARGET_LIST ${THIS_TARGET_DIR} TO_REMOVE)
	IF(NOT ${TO_REMOVE} EQUAL -1)
		RDK_ADD_FORCE_REMOVE_COMMAND(${RDK_THIS_LIBRARY_NAME} ${OpenRDK_LIBRARY_OUTPUT_DIRECTORY})
	ELSE(NOT ${TO_REMOVE} EQUAL -1)
		IF("${FILE_LIST}" STREQUAL "")
			verbose("WARNING: Empty library: no source files specified for library \"${THIS_LIBRARY_NAME}\"")
		ELSE("${FILE_LIST}" STREQUAL "")
			INCLUDE_DIRECTORIES(${RDKCORE_INCLUDE_DIR})
			LINK_DIRECTORIES(${RDKCORE_LINK_DIRECTORIES})
			INCLUDE_DIRECTORIES(${RDKCORE_INCLUDE_DIR})
			LINK_DIRECTORIES(${RDKCORE_LINK_DIRECTORIES})
			ADD_LIBRARY(${THIS_LIBRARY_NAME} SHARED ${FILE_LIST})
			TARGET_LINK_LIBRARIES(${RDK_THIS_LIBRARY_NAME} ${RDKCORE_LIBRARIES})
			SET_TARGET_PROPERTIES(${RDK_THIS_LIBRARY_NAME} PROPERTIES COMPILE_FLAGS "${RDKCORE_CPPFLAGS} ${RDKCORE_CXXFLAGS}")
			SET_TARGET_PROPERTIES(${RDK_THIS_LIBRARY_NAME} PROPERTIES LINK_FLAGS "${RDKCORE_LDFLAGS}")
			# NOTE: depending on the operating system, shared libraries and their static counterpart are treated as LIBRARY, RUNTIME or ARCHIVE
			SET_TARGET_PROPERTIES(${RDK_THIS_LIBRARY_NAME} PROPERTIES LIBRARY_OUTPUT_DIRECTORY "${OpenRDK_LIBRARY_OUTPUT_DIRECTORY}")
			verbose("Adding library \"${RDK_THIS_LIBRARY_NAME}\"")
		ENDIF("${FILE_LIST}" STREQUAL "")
	ENDIF(NOT ${TO_REMOVE} EQUAL -1)
ENDMACRO(RDK_ADD_LIBRARY)

#################################################################
# Macro to recursively add all subdirectories to the build tree #
#################################################################
MACRO(RDK_ADD_ALL_SUBDIRECTORIES)

	IF(${ARGC} EQUAL 0)
		EXEC_PROGRAM("find . -maxdepth 1 -type d -not -iname .svn -not -iname . -not -iname cmakefiles -not -iname oldies" ${CMAKE_CURRENT_SOURCE_DIR} OUTPUT_VARIABLE tempdirs)
	ELSE(${ARGC} EQUAL 0)
		STRING(REPLACE ";" "\n" tempdirs "${ARGV}")
	ENDIF(${ARGC} EQUAL 0)

	IF(NOT ${tempdirs} STREQUAL "")
		STRING(REPLACE "\n" ";" dirs ${tempdirs})
		FOREACH(d ${dirs})
			IF(NOT "${d}" MATCHES "(CMake.*|dontcompile_*|oldies)")
				EXEC_PROGRAM("find ${d} -maxdepth 1 -type f -name DO_NOT_COMPILE" ${CMAKE_CURRENT_SOURCE_DIR} OUTPUT_VARIABLE excludedir)
				IF(NOT "${excludedir}" STREQUAL "")
					GET_FILENAME_COMPONENT(THIS_TARGET_DIR_tmp ${excludedir} PATH)
					GET_FILENAME_COMPONENT(THIS_TARGET_DIR ${THIS_TARGET_DIR_tmp} NAME)
					LIST(APPEND RDK_FORCE_REMOVE_TARGET_LIST ${THIS_TARGET_DIR})
				ENDIF(NOT "${excludedir}" STREQUAL "")
				GET_FILENAME_COMPONENT(cmakeliststxt "${d}/CMakeLists.txt" ABSOLUTE)
				IF(EXISTS "${cmakeliststxt}")
					ADD_SUBDIRECTORY(${d})
				ENDIF(EXISTS "${cmakeliststxt}")
			ENDIF(NOT "${d}" MATCHES "(CMake.*|dontcompile_*|oldies)")
		ENDFOREACH(d ${dirs})
	ENDIF(NOT ${tempdirs} STREQUAL "")
ENDMACRO(RDK_ADD_ALL_SUBDIRECTORIES)

#########################################
# Macro for building rconsoleqt modules #
#########################################
MACRO(RCONSOLE_QT_MODULE)
	STRING(REGEX REPLACE ".*/([^/]*)$" "\\1" MODULE_NAME ${CMAKE_CURRENT_SOURCE_DIR})
	IF("${COMPILE_FILES}" MATCHES "AUTO")
		FILE(GLOB COMPILE_FILE_LIST "*.cpp")
	ELSE("${COMPILE_FILES}" MATCHES "AUTO")
		SET(COMPILE_FILE_LIST ${COMPILE_FILES})
	ENDIF("${COMPILE_FILES}" MATCHES "AUTO")

	SET(THIS_MODULE_NAME "rdkrqm_${MODULE_NAME}")
	SET(RDK_THIS_RQ_MODULE_NAME ${THIS_MODULE_NAME})

	SET(MOCD_FILES "")
	FOREACH(F ${MOC_FILES})
		QT_WRAP_CPP(${RDK_THIS_RQ_MODULE_NAME} MOCD_FILES "${F}")
	ENDFOREACH(F ${MOC_FILES})
	#MESSAGE(STATUS "These are moc'd:" "${MOCD_FILES}")
	INCLUDE_DIRECTORIES(${QT_INCLUDE_DIR})
	INCLUDE_DIRECTORIES(${RDKCORE_INCLUDE_DIR})
	LINK_DIRECTORIES(${RDKCORE_LINK_DIRECTORIES})
	ADD_DEFINITIONS(${RDKCORE_DEFINITIONS})
	ADD_LIBRARY(${RDK_THIS_RQ_MODULE_NAME} SHARED ${COMPILE_FILE_LIST} ${MOCD_FILES})
	TARGET_LINK_LIBRARIES(${RDK_THIS_RQ_MODULE_NAME} ${RDKCORE_LIBRARIES})
	TARGET_LINK_LIBRARIES(${RDK_THIS_RQ_MODULE_NAME} ${QT_LIBRARIES} ${QT_QT_LIBRARY})
	TARGET_LINK_LIBRARIES(${RDK_THIS_RQ_MODULE_NAME} rdkrq_common)
	TARGET_LINK_LIBRARIES(${RDK_THIS_RQ_MODULE_NAME} ${LINK_LIBS})

	SET_TARGET_PROPERTIES(${RDK_THIS_RQ_MODULE_NAME} PROPERTIES LIBRARY_OUTPUT_DIRECTORY "${OpenRDK_LIBRARY_OUTPUT_DIRECTORY}")
	verbose("Adding rq module \"${RDK_THIS_RQ_MODULE_NAME}\"")
ENDMACRO(RCONSOLE_QT_MODULE)

##############################################################
# Macro for force-removing old target (DO_NOT_COMPILE stuff) #
##############################################################
MACRO(RDK_ADD_FORCE_REMOVE_COMMAND RDK_SONAME OUTDIR)
	verbose("Removing old target [${RDK_SONAME}]")
	ADD_CUSTOM_TARGET(${RDK_SONAME} ALL rm -f *${RDK_SONAME}* WORKING_DIRECTORY ${OUTDIR} COMMENT "Force-removing old target ${RDK_SONAME}, if it exists")
ENDMACRO(RDK_ADD_FORCE_REMOVE_COMMAND RDK_SONAME)

##############################################
# Macro for printing some useful information #
##############################################
MACRO(RDK_PRINT_VARIABLES)
	info("")
	info("Found OpenRDK Installation (version: ${OpenRDK_VERSION} arch: ${OpenRDK_ARCH} codename: ${OpenRDK_CODENAME})")
	info("Found project ${PROJECT_NAME} (version: ${PROJECT_VERSION} arch: ${PROJECT_ARCH})")
	info("")
	info("Variables:")
	info("PROJECT_ROOT = ${PROJECT_ROOT}")
	verbose("PROJECT_LIBRARY_OUTPUT_PATH = ${PROJECT_LIBRARY_OUTPUT_PATH}")
	info("OpenRDK_ROOT = ${OpenRDK_ROOT}")
	info("OpenRDK_RESOURCES = ${OpenRDK_RESOURCES}")
	info("OpenRDK_OUTPUT_TREE = ${OpenRDK_OUTPUT_TREE}")
	verbose("RDKCORE_INCLUDE_DIR = ${RDKCORE_INCLUDE_DIR}")
	verbose("RDKCORE_DEFINITIONS = ${RDKCORE_DEFINITIONS}")
	verbose("RDKCORE_LINK_DIRECTORIES = ${RDKCORE_LINK_DIRECTORIES}")
	verbose("RDKCORE_LIBRARIES = ${RDKCORE_LIBRARIES}")
	verbose("RDKCORE_CXXFLAGS = ${RDKCORE_CXXFLAGS}")
	verbose("RDKCORE_LDFLAGS = ${RDKCORE_LDFLAGS}")

	IF("${CMAKE_CROSSCOMPILING}" STREQUAL "TRUE" OR "${CMAKE_CROSSCOMPILING}" STREQUAL "ON")  ##Updated
		info("")
		info("..:: Cross Compiling Detected ::..")
		info("CMAKE_CXX_COMPILER = ${CMAKE_CXX_COMPILER}")
		info("CMAKE_C_COMPILER = ${CMAKE_C_COMPILER}")
		info("CMAKE_AR = ${CMAKE_AR}")
		info("CMAKE_RANLIB = ${CMAKE_RANLIB}")
		info("CMAKE_LD = ${CMAKE_LINKER}")
		info("CMAKE_STRIP = ${CMAKE_STRIP}")
		info("CMAKE_OBJCOPY = ${CMAKE_OBJCOPY}")
		info("CMAKE_OBJDUMP = ${CMAKE_OBJDUMP}")
	ENDIF("${CMAKE_CROSSCOMPILING}" STREQUAL "TRUE" OR "${CMAKE_CROSSCOMPILING}" STREQUAL "ON")  ##Updated

ENDMACRO(RDK_PRINT_VARIABLES)
