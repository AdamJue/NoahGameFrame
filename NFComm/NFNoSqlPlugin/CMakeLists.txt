set(ProjectName "NFNoSqlPlugin")

set(ProjectName "NFNoSqlPlugin")
file(GLOB NFNoSqlPlugin_ROOT_Cpp CONFIGURE_DEPENDS
		*.cpp)

file(GLOB NFNoSqlPlugin_ROOT_Hpp CONFIGURE_DEPENDS
		*.h)

add_library(NFNoSqlPlugin STATIC
		${NFNoSqlPlugin_ROOT_Cpp}
		${NFNoSqlPlugin_ROOT_Hpp})

nf_configure_library(NFNoSqlPlugin "NFComm/NFNoSqlPlugin")
link_NFSDK("NFNoSqlPlugin")
target_link_libraries(NFNoSqlPlugin noah::hiredis noah::libevent)
target_compile_definitions(NFNoSqlPlugin PRIVATE ELPP_NO_DEFAULT_LOG_FILE)

