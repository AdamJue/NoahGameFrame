cmake_minimum_required(VERSION 3.21)

if(POLICY CMP0091)
	cmake_policy(SET CMP0091 NEW)
endif()

project(NoahFrame LANGUAGES C CXX)

set_property(GLOBAL PROPERTY USE_FOLDERS On)

option(BUILD_TOOLS_ONLY "Build only Noah helper tools" OFF)
option(BUILD_MID_WARE_SDK "Build SDK, examples and external middleware" OFF)
option(NF_BUILD_RENDER "Build NFRenderPlugin" ${WIN32})
option(NF_BUILD_BLUEPRINT "Build NFBluePrintPlugin" ${WIN32})
option(NF_ENABLE_STATIC_LIBSTDCXX "Statically link libstdc++ on GCC/Clang" OFF)

set(CMAKE_C_STANDARD 11)
set(CMAKE_C_STANDARD_REQUIRED ON)
set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_CXX_EXTENSIONS OFF)
set(CMAKE_EXPORT_COMPILE_COMMANDS ON)

if(MSVC)
	set(CMAKE_MSVC_RUNTIME_LIBRARY "MultiThreaded$<$<CONFIG:Debug>:Debug>")
	add_compile_options(/EHsc /permissive-)
	add_compile_definitions(NF_DISABLE_MSVC_AUTO_LINK)
else()
	add_compile_options(-fPIC)
endif()

# OSX上强制生成so后缀的动态库而不是dylib后缀动态库
if(APPLE)
	set(CMAKE_SHARED_LIBRARY_SUFFIX ".so")
endif()

set(SolutionDir ${PROJECT_SOURCE_DIR})
set(NF_DEBUG_OUTPUT_DIR "${PROJECT_SOURCE_DIR}/_Out/Debug")
set(NF_RELEASE_OUTPUT_DIR "${PROJECT_SOURCE_DIR}/_Out/Release")
if(CMAKE_CONFIGURATION_TYPES)
	set(NFOutPutDir "${PROJECT_SOURCE_DIR}/_Out/$<CONFIG>")
elseif(CMAKE_BUILD_TYPE STREQUAL "Debug")
	set(NFOutPutDir "${NF_DEBUG_OUTPUT_DIR}")
else()
	set(NFOutPutDir "${NF_RELEASE_OUTPUT_DIR}")
endif()

if(CMAKE_CONFIGURATION_TYPES)
	message(STATUS "NF output dirs: Debug=${NF_DEBUG_OUTPUT_DIR}, Release=${NF_RELEASE_OUTPUT_DIR}")
elseif(CMAKE_BUILD_TYPE STREQUAL "Debug")
	message(STATUS "NFOutPutDir: ${NF_DEBUG_OUTPUT_DIR}")
else()
	message(STATUS "NFOutPutDir: ${NF_RELEASE_OUTPUT_DIR}")
endif()

list(APPEND CMAKE_MODULE_PATH "${PROJECT_SOURCE_DIR}/cmake")

include_directories(
	BEFORE
	"${PROJECT_BINARY_DIR}/generated"
	"${PROJECT_BINARY_DIR}/generated/NFComm/NFMessageDefine"
)

include_directories(
	"${PROJECT_SOURCE_DIR}"
	"${PROJECT_SOURCE_DIR}/Dependencies"
	"${PROJECT_SOURCE_DIR}/NFComm/NFPluginModule")

find_package(Threads REQUIRED)
find_package(Protobuf CONFIG REQUIRED)
find_package(Lua REQUIRED)
find_package(SDL2 CONFIG QUIET)
set(LIBEVENT_STATIC_LINK TRUE)
if(WIN32)
	find_package(Libevent CONFIG REQUIRED COMPONENTS core extra)
else()
	find_package(Libevent CONFIG REQUIRED COMPONENTS core extra pthreads)
endif()
find_package(hiredis CONFIG REQUIRED)

include(NoahBuild)

add_library(noah_libevent INTERFACE)
target_link_libraries(noah_libevent INTERFACE libevent::core libevent::extra)
if(TARGET libevent::pthreads)
	target_link_libraries(noah_libevent INTERFACE libevent::pthreads)
endif()
add_library(noah::libevent ALIAS noah_libevent)

add_library(noah_hiredis INTERFACE)
target_link_libraries(noah_hiredis INTERFACE hiredis::hiredis)
add_library(noah::hiredis ALIAS noah_hiredis)

add_library(noah_lua INTERFACE)
target_include_directories(noah_lua INTERFACE "${LUA_INCLUDE_DIR}")
target_link_libraries(noah_lua INTERFACE "${LUA_LIBRARIES}")
add_library(noah::lua ALIAS noah_lua)

if(TARGET SDL2::SDL2 OR TARGET SDL2::SDL2-static)
	add_library(noah_sdl2 INTERFACE)
	target_link_libraries(noah_sdl2 INTERFACE
		$<TARGET_NAME_IF_EXISTS:SDL2::SDL2main>
		$<IF:$<TARGET_EXISTS:SDL2::SDL2>,SDL2::SDL2,SDL2::SDL2-static>)
	add_library(noah::sdl2 ALIAS noah_sdl2)
elseif(NF_BUILD_RENDER)
	message(FATAL_ERROR "NF_BUILD_RENDER=ON requires the SDL2 package from vcpkg.")
endif()

if(BUILD_TOOLS_ONLY)
	message(STATUS "Build Tools Only")
	add_subdirectory(NFTools)
elseif(BUILD_MID_WARE_SDK)
	message(STATUS "Build SDK & MIDWARE")
	add_subdirectory(NFTools)
	add_subdirectory(Dependencies)
	add_subdirectory(NFComm)
	add_subdirectory(NFServer)
	add_subdirectory(Tutorial)
	add_subdirectory(NFExamples)
	add_subdirectory(../NFMidWare NFMidWare)
	add_subdirectory(../NFComm/NFMessageDefineEx NFComm/NFMessageDefineEx)
	add_subdirectory(../NFComm/NFServerEx NFComm/NFServerEx)
else()
	message(STATUS "Build SDK")
	add_subdirectory(Dependencies)
	add_subdirectory(NFComm)
	add_subdirectory(NFServer)
	add_subdirectory(Tutorial)
	add_subdirectory(NFExamples)
endif()
