include_guard(GLOBAL)

function(nf_set_output_dirs target)
	set_target_properties(${target} PROPERTIES
		ARCHIVE_OUTPUT_DIRECTORY_DEBUG "${NF_DEBUG_OUTPUT_DIR}"
		RUNTIME_OUTPUT_DIRECTORY_DEBUG "${NF_DEBUG_OUTPUT_DIR}"
		LIBRARY_OUTPUT_DIRECTORY_DEBUG "${NF_DEBUG_OUTPUT_DIR}"
		ARCHIVE_OUTPUT_DIRECTORY_RELEASE "${NF_RELEASE_OUTPUT_DIR}"
		RUNTIME_OUTPUT_DIRECTORY_RELEASE "${NF_RELEASE_OUTPUT_DIR}"
		LIBRARY_OUTPUT_DIRECTORY_RELEASE "${NF_RELEASE_OUTPUT_DIR}"
		ARCHIVE_OUTPUT_DIRECTORY_RELWITHDEBINFO "${NF_RELEASE_OUTPUT_DIR}"
		RUNTIME_OUTPUT_DIRECTORY_RELWITHDEBINFO "${NF_RELEASE_OUTPUT_DIR}"
		LIBRARY_OUTPUT_DIRECTORY_RELWITHDEBINFO "${NF_RELEASE_OUTPUT_DIR}"
		ARCHIVE_OUTPUT_DIRECTORY_MINSIZEREL "${NF_RELEASE_OUTPUT_DIR}"
		RUNTIME_OUTPUT_DIRECTORY_MINSIZEREL "${NF_RELEASE_OUTPUT_DIR}"
		LIBRARY_OUTPUT_DIRECTORY_MINSIZEREL "${NF_RELEASE_OUTPUT_DIR}")
endfunction()

function(nf_apply_common_target_settings target)
	target_compile_features(${target} PUBLIC cxx_std_17)
	target_include_directories(${target} BEFORE PUBLIC
		"${PROJECT_BINARY_DIR}/generated"
		"${PROJECT_BINARY_DIR}/generated/NFComm/NFMessageDefine")
	target_include_directories(${target} PUBLIC
		"${PROJECT_SOURCE_DIR}"
		"${PROJECT_SOURCE_DIR}/Dependencies"
		"${PROJECT_SOURCE_DIR}/NFComm/NFPluginModule")

	target_compile_definitions(${target} PRIVATE NF_NONCLIENT_BUILD)

	if(MSVC)
		target_compile_definitions(${target} PRIVATE
			_CRT_SECURE_NO_WARNINGS
			_CRT_NONSTDC_NO_DEPRECATE
			WIN32_LEAN_AND_MEAN)
	endif()

	if(NF_ENABLE_STATIC_LIBSTDCXX AND CMAKE_CXX_COMPILER_ID MATCHES "GNU|Clang")
		target_link_options(${target} PRIVATE -static-libstdc++)
	endif()
endfunction()

function(nf_configure_library target folder)
	nf_apply_common_target_settings(${target})
	set_target_properties(${target} PROPERTIES
		OUTPUT_NAME_DEBUG "${target}"
		PREFIX ""
		FOLDER "${folder}")
	nf_set_output_dirs(${target})
endfunction()

function(nf_configure_executable target folder)
	nf_apply_common_target_settings(${target})
	set_target_properties(${target} PROPERTIES
		OUTPUT_NAME_DEBUG "${target}"
		FOLDER "${folder}")
	nf_set_output_dirs(${target})
endfunction()

function(link_NFSDK projName)
	add_dependencies(${projName} NFNetPlugin NFCore NFMessageDefine)
	target_link_libraries(${projName} NFCore NFMessageDefine NFNetPlugin)
endfunction()

function(nf_add_simple_static_library target folder)
	file(GLOB sources CONFIGURE_DEPENDS "*.cpp" "*.cc" "*.h")
	add_library(${target} STATIC ${sources})
	nf_configure_library(${target} "${folder}")
endfunction()
