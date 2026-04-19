set(ProjectName "NFSecurityPlugin")
file(GLOB NFSecurityPlugin_ROOT_Cpp
	*.cpp)
	
file(GLOB NFSecurityPlugin_ROOT_Hpp 
	*.h)

add_library(NFSecurityPlugin STATIC
	${NFSecurityPlugin_ROOT_Cpp}
	${NFSecurityPlugin_ROOT_Hpp})
	
set_target_properties( NFSecurityPlugin PROPERTIES OUTPUT_NAME_DEBUG "NFSecurityPlugin")
set_target_properties( NFSecurityPlugin PROPERTIES PREFIX "")
set_target_properties( NFSecurityPlugin PROPERTIES 
	FOLDER "NFComm/NFSecurityPlugin"
	ARCHIVE_OUTPUT_DIRECTORY ${NFOutPutDir}
	RUNTIME_OUTPUT_DIRECTORY ${NFOutPutDir}
	LIBRARY_OUTPUT_DIRECTORY ${NFOutPutDir} )

link_NFSDK("NFSecurityPlugin")

if(UNIX)

	add_definitions(
		-DELPP_NO_DEFAULT_LOG_FILE
	)
	
else()

	add_definitions(
		-DWIN
		-DELPP_NO_DEFAULT_LOG_FILE
	)
endif()
