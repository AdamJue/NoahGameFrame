file(GLOB navigation_ROOT_Cpp CONFIGURE_DEPENDS *.cpp)
file(GLOB navigation_ROOT_Hpp CONFIGURE_DEPENDS *.hpp)
file(GLOB navigation_ROOT_H CONFIGURE_DEPENDS *.h)

add_library(navigation STATIC
	${navigation_ROOT_Cpp} 
	${navigation_ROOT_H} 
		${navigation_ROOT_Hpp})

nf_configure_library(navigation "NFDeps")