set(ProjectName "NFMessageDefine")

set(NF_MESSAGE_DEFINE_PROTO_FILES
	"${CMAKE_CURRENT_SOURCE_DIR}/NFDefine.proto"
	"${CMAKE_CURRENT_SOURCE_DIR}/NFMsgBase.proto"
	"${CMAKE_CURRENT_SOURCE_DIR}/NFMsgPreGame.proto"
	"${CMAKE_CURRENT_SOURCE_DIR}/NFMsgShare.proto")

set(NF_MESSAGE_DEFINE_GENERATED_DIR "${PROJECT_BINARY_DIR}/generated/NFComm/NFMessageDefine")
file(MAKE_DIRECTORY "${NF_MESSAGE_DEFINE_GENERATED_DIR}")

set(NF_MESSAGE_DEFINE_GENERATED_SRCS)
set(NF_MESSAGE_DEFINE_GENERATED_HDRS)

foreach(proto_file IN LISTS NF_MESSAGE_DEFINE_PROTO_FILES)
	get_filename_component(proto_name "${proto_file}" NAME_WE)
	set(generated_src "${NF_MESSAGE_DEFINE_GENERATED_DIR}/${proto_name}.pb.cc")
	set(generated_hdr "${NF_MESSAGE_DEFINE_GENERATED_DIR}/${proto_name}.pb.h")

	add_custom_command(
		OUTPUT "${generated_src}" "${generated_hdr}"
		COMMAND $<TARGET_FILE:protobuf::protoc>
			--proto_path=${CMAKE_CURRENT_SOURCE_DIR}
			--cpp_out=${NF_MESSAGE_DEFINE_GENERATED_DIR}
			${proto_name}.proto
		DEPENDS "${proto_file}" protobuf::protoc
		WORKING_DIRECTORY "${CMAKE_CURRENT_SOURCE_DIR}"
		VERBATIM)

	list(APPEND NF_MESSAGE_DEFINE_GENERATED_SRCS "${generated_src}")
	list(APPEND NF_MESSAGE_DEFINE_GENERATED_HDRS "${generated_hdr}")
endforeach()

file(GLOB NFMessageDefine_ROOT_CC CONFIGURE_DEPENDS *.cc)
file(GLOB NFMessageDefine_ROOT_Hpp CONFIGURE_DEPENDS *.h)
file(GLOB NFMessageDefine_CHECKED_IN_PB_CC CONFIGURE_DEPENDS *.pb.cc)
file(GLOB NFMessageDefine_CHECKED_IN_PB_H CONFIGURE_DEPENDS *.pb.h)
list(REMOVE_ITEM NFMessageDefine_ROOT_CC ${NFMessageDefine_CHECKED_IN_PB_CC})
list(REMOVE_ITEM NFMessageDefine_ROOT_Hpp ${NFMessageDefine_CHECKED_IN_PB_H})

add_library(NFMessageDefine STATIC
	${NF_MESSAGE_DEFINE_GENERATED_SRCS}
	${NF_MESSAGE_DEFINE_GENERATED_HDRS}
	${NFMessageDefine_ROOT_CC}
	${NFMessageDefine_ROOT_Hpp})

nf_configure_library(NFMessageDefine "NFComm/NFMessageDefine")
target_include_directories(NFMessageDefine PUBLIC "${PROJECT_BINARY_DIR}/generated")
target_link_libraries(NFMessageDefine PUBLIC protobuf::libprotobuf)
target_compile_definitions(NFMessageDefine PRIVATE _THREAD_SAFE)