ADD_LIBRARY(rdkra_main SHARED ragent.cpp main.cpp agentcmdreceiver.cpp)
INCLUDE_DIRECTORIES(${LIBXML2_INCLUDE_DIR})
TARGET_LINK_LIBRARIES(rdkra_main ${RDKCORE_LIBRARIES};${PTHREAD_LIBRARIES})
SET_TARGET_PROPERTIES(rdkra_main PROPERTIES LINK_FLAGS "${RDKCORE_LDFLAGS}")
SET_TARGET_PROPERTIES(rdkra_main PROPERTIES COMPILE_FLAGS "${RDKCORE_CPPFLAGS} ${RDKCORE_CXXFLAGS}")

RDK_ADD_EXECUTABLE(ragent2 ragent2.cpp)
TARGET_LINK_LIBRARIES(ragent2 rdkra_main)
#SET_TARGET_PROPERTIES(ragent2 PROPERTIES LINK_FLAGS "${LIBXML2_LIBRARIES}")
#TARGET_LINK_LIBRARIES(ragent2 rdkra_main rdkcore dl)
#SET_TARGET_PROPERTIES(ragent2 PROPERTIES COMPILE_FLAGS ${RDKCORE_CPPFLAGS} ${RDKCORE_CXXFLAGS})
#SET_TARGET_PROPERTIES(ragent2 PROPERTIES LINK_FLAGS ${RDKCORE_LDFLAGS})

#RDK_ADD_EXECUTABLE(test_config test_config.cpp)
#TARGET_LINK_LIBRARIES(test_config rdkra_main rdkcore dl)
#SET_TARGET_PROPERTIES(test_config PROPERTIES COMPILE_FLAGS ${RDKCORE_CPPFLAGS} ${RDKCORE_CXXFLAGS})
#SET_TARGET_PROPERTIES(test_config PROPERTIES LINK_FLAGS ${RDKCORE_LDFLAGS})
