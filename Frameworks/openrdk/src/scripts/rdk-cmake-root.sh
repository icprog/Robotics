#!/bin/bash
if [ -f CMakeLists.txt ]; then
	echo "The CMakeLists.txt file already exists, please remove it by hand if you want to run this script."
else
	echo "Generating CMakeLists.txt for root directory of external project."
	cat >CMakeLists.txt <<EOF

# This is the root CMakeLists.txt of your external OpenRDK project. This file has been generated by `basename 0`
CMAKE_MINIMUM_REQUIRED(VERSION 2.6)

PROJECT(MyOpenRDK CXX C)

# This is required for future release of OpenRDK that will support standard path (aka /usr/local)
SET(LOCALOPENRDK 1)
IF(EXISTS notlocalopenrdk)
	SET(LOCALOPENRDK 0)
ENDIF(EXISTS notlocalopenrdk)

SET(OpenRDK_FOUND OFF)

EXECUTE_PROCESS(COMMAND rdk-config --cmakeinclude OUTPUT_VARIABLE openrdkExternalInclude OUTPUT_STRIP_TRAILING_WHITESPACE)

INCLUDE("\${openrdkExternalInclude}")
MESSAGE(STATUS "Using \${openrdkExternalInclude}")

IF(NOT OpenRDK_FOUND)
MESSAGE(FATAL_ERROR "It seems I cannot find your copy of OpenRDK.
This could be because I cannot determine the path of \"FindOpenRDK.cmake\" file that will setup correct building flags.
Try using the \"setenv\" script that should be located in the \"src\" directory of your OpenRDK installation:
cd <where-your-OpenRDK-installation-is>/src
. setenv
cd -
")
ENDIF(NOT OpenRDK_FOUND)

SET(OpenRDK_LD_FLAGS "\${OpenRDK_LD_FLAGS}")
SET(OpenRDK_CPP_FLAGS "\${OpenRDK_CPP_FLAGS}")

RDK_PRINT_VARIABLES()
RDK_ADD_ALL_SUBDIRECTORIES()
EOF
fi

