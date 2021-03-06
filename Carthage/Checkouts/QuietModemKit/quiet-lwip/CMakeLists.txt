cmake_minimum_required (VERSION 2.6)
project (Quiet-LWIP)
include(CheckLibraryExists)
include(CheckIncludeFiles)
include(FindPackageHandleStandardArgs)

if(CMAKE_BUILD_TYPE STREQUAL "Debug")
    add_definitions(-DQUIET_DEBUG)
    #set(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} -g3 -O0 -fsanitize=address")
    set(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} -g3 -O0")
    set(CMAKE_EXE_LINKER_FLAGS "${CMAKE_EXE_LINKER_FLAGS} -Wl,-no_pie")
else()
    if("${CMAKE_C_COMPILER_ID}" STREQUAL "Clang")
      # set(CMAKE_C_FLAGS ${CMAKE_C_FLAGS} "-Ofast -fsanitize=address -g3")
      # set(CMAKE_EXE_LINKER_FLAGS ${CMAKE_EXE_LINKER_FLAGS} "-Ofast -flto")
    else()
      set(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} -O2 -g")
    endif()
endif()

set(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} -std=c11 -Wpedantic -Wall")
if (NOT APPLE)
  set(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} -D_XOPEN_SOURCE=700")
endif()
set(SRCFILES src/driver.c src/util.c)

include_directories(${CMAKE_SOURCE_DIR}/include)
include_directories(${CMAKE_SOURCE_DIR}/include/lwip)
include_directories(${CMAKE_SOURCE_DIR}/include/lwip/ipv4)
set(LIBRARY_OUTPUT_PATH ${PROJECT_BINARY_DIR}/lib)
set(EXECUTABLE_OUTPUT_PATH ${PROJECT_BINARY_DIR}/bin)
add_subdirectory(src/lwip)

set(CMAKE_THREAD_PREFER_PTHREAD ON)
find_package(Threads)
set(CORE_DEPENDENCIES quiet ${CMAKE_THREAD_LIBS_INIT})

find_library(PORTAUDIO portaudio)
if (PORTAUDIO)
  set(SRCFILES ${SRCFILES} src/driver_portaudio.c)
  add_definitions(-DQUIET_PORTAUDIO=1)
  set(CORE_DEPENDENCIES ${CORE_DEPENDENCIES} portaudio)
  add_custom_target(quiet-lwip-portaudio-h ALL COMMAND ${CMAKE_COMMAND} -E copy ${CMAKE_SOURCE_DIR}/include/quiet-lwip-portaudio.h ${CMAKE_BINARY_DIR}/include/quiet-lwip-portaudio.h)

else()
    unset(PORTAUDIO CACHE)
    message(WARNING "

quiet-lwip could not find portaudio. this will prevent quiet-lwip
from building its sound streaming programs. you can get portaudio from
    http://www.portaudio.com/download.html

")
endif()

find_path(quiet_include NAMES quiet.h)
find_library(quiet_library NAMES quiet)
find_package_handle_standard_args(Quiet DEFAULT_MSG quiet_library quiet_include)
mark_as_advanced(quiet_include quiet_library)
if(QUIET_FOUND)
    add_library(quiet UNKNOWN IMPORTED)
    set_target_properties(quiet PROPERTIES IMPORTED_LOCATION "${quiet_library}" INTERFACE_INCLUDE_DIRECTORIES "${quiet_include}")
else()
    message(FATAL_ERROR "
quiet-lwip requires libquiet but cannot find it")
endif()

add_library(quiet_lwip STATIC ${SRCFILES} $<TARGET_OBJECTS:lwip_sys> $<TARGET_OBJECTS:lwip_core> $<TARGET_OBJECTS:lwip_api> $<TARGET_OBJECTS:lwip_netif> $<TARGET_OBJECTS:lwip_ipv4>)
target_link_libraries(quiet_lwip ${CORE_DEPENDENCIES})
add_library(quiet_lwip_shared SHARED ${SRCFILES} $<TARGET_OBJECTS:lwip_sys> $<TARGET_OBJECTS:lwip_core> $<TARGET_OBJECTS:lwip_api> $<TARGET_OBJECTS:lwip_netif> $<TARGET_OBJECTS:lwip_ipv4>)
target_link_libraries(quiet_lwip_shared ${CORE_DEPENDENCIES})
set_target_properties(quiet_lwip_shared PROPERTIES OUTPUT_NAME "quiet_lwip")
add_custom_target(lib DEPENDS quiet_lwip quiet_lwip_shared)

add_custom_target(lwip-h ALL COMMAND ${CMAKE_COMMAND} -E copy_directory ${CMAKE_SOURCE_DIR}/include/lwip/ ${CMAKE_BINARY_DIR}/include/lwip)
add_custom_target(quiet-lwip-h ALL COMMAND ${CMAKE_COMMAND} -E copy ${CMAKE_SOURCE_DIR}/include/quiet-lwip.h ${CMAKE_BINARY_DIR}/include/quiet-lwip.h)
add_custom_target(lwip-socket-h ALL COMMAND ${CMAKE_COMMAND} -E copy ${CMAKE_SOURCE_DIR}/include/quiet-lwip/lwip-socket.h ${CMAKE_BINARY_DIR}/include/lwip-socket.h)
add_custom_target(lwip-netdb-h ALL COMMAND ${CMAKE_COMMAND} -E copy ${CMAKE_SOURCE_DIR}/include/quiet-lwip/lwip-netdb.h ${CMAKE_BINARY_DIR}/include/lwip-netdb.h)

install(DIRECTORY ${CMAKE_BINARY_DIR}/include/ DESTINATION include/quiet-lwip
        FILES_MATCHING PATTERN "*.h")
install(TARGETS quiet_lwip
        RUNTIME DESTINATION bin
        LIBRARY DESTINATION lib
        ARCHIVE DESTINATION lib)
install(TARGETS quiet_lwip_shared
        RENAME quiet_lwip
        LIBRARY DESTINATION lib
        ARCHIVE DESTINATION lib)

add_subdirectory(examples)
