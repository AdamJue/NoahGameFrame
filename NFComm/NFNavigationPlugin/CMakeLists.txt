set(ProjectName "NFNavigationPlugin")
file(GLOB NFNavigationPlugin_ROOT_Cpp *.cpp)
file(GLOB NFNavigationPlugin_ROOT_Hpp *.h)
	
add_library(NFNavigationPlugin STATIC
	${NFNavigationPlugin_ROOT_Cpp}
	${NFNavigationPlugin_ROOT_Hpp})
target_include_directories(NFNavigationPlugin PUBLIC
	${SolutionDir}/Dependencies/navigation/)
add_dependencies(NFNavigationPlugin navigation NFCore)
nf_configure_library(NFNavigationPlugin "NFComm/NFNavigationPlugin")
target_link_libraries(NFNavigationPlugin navigation NFCore)
link_NFSDK("NFNavigationPlugin")