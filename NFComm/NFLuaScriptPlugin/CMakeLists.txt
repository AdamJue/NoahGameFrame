set(ProjectName "NFLuaScriptPlugin")
file(GLOB NFLuaScriptPlugin_ROOT_Cpp *.cpp)
file(GLOB NFLuaScriptPlugin_ROOT_Hpp *.h)

add_library(NFLuaScriptPlugin STATIC
	${NFLuaScriptPlugin_ROOT_Cpp}
	${NFLuaScriptPlugin_ROOT_Hpp})

add_dependencies(NFLuaScriptPlugin NFCore)
nf_configure_library(NFLuaScriptPlugin "NFComm/NFLuaScriptPlugin")
target_link_libraries(NFLuaScriptPlugin NFCore noah::lua)