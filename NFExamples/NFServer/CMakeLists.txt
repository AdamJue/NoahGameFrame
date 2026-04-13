set(ProjectName "NFServer")

file(GLOB NFServer_ROOT_Cpp *.cpp)
file(GLOB NFServer_ROOT_Hpp *.h)

add_executable(NFServer ${NFServer_ROOT_Cpp} ${NFServer_ROOT_Hpp})

target_link_libraries(NFServer NFPluginLoader)
add_dependencies(NFServer NFCore)
nf_configure_executable(NFServer "NFComm/NFServer")
target_link_libraries(NFServer Threads::Threads)
target_compile_definitions(NFServer PRIVATE _X64 _CONSOLE)