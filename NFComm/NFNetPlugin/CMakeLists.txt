set(ProjectName "NFNetPlugin")

file(GLOB NFNet_ROOT_Cpp CONFIGURE_DEPENDS *.cpp)
file(GLOB NFNet_ROOT_Hpp CONFIGURE_DEPENDS *.h)

#Exclude this file
#file(GLOB RemoveItems_Cpp TestClient.cpp TestServer.cpp)
#list(REMOVE_ITEM NFNet_ROOT_Cpp ${RemoveItems_Cpp})

add_library(NFNetPlugin STATIC ${NFNet_ROOT_Cpp} ${NFNet_ROOT_Hpp})

nf_configure_library(NFNetPlugin "NFComm/NFNetPlugin")
add_dependencies(NFNetPlugin NFCore)
target_link_libraries(NFNetPlugin NFCore NFMessageDefine noah::libevent Threads::Threads)
target_compile_definitions(NFNetPlugin PRIVATE _THREAD_SAFE)