#
# Include API header and, on win32, link import libs. Set API_VERSION  and
# API_OCPN_MIN_VERSION
#
cmake_minimum_required(VERSION 3.10)

if (TARGET ocpn::api)
  return ()
endif ()

set(API_VERSION "1.22" PARENT_SCOPE)
set(API_OCPN_MIN_VERSION "5.14.2" PARENT_SCOPE)

add_library(OCPN_API_MSVC INTERFACE)
add_library(ocpn::api_wx32 ALIAS OCPN_API_MSVC)
add_library(ocpn::api ALIAS OCPN_API_MSVC)
target_include_directories(
  OCPN_API_MSVC
    INTERFACE "${CMAKE_CURRENT_SOURCE_DIR}"
)
if (WIN32 AND MSVC)
  if (CMAKE_SIZEOF_VOID_P EQUAL 8)
    target_link_libraries(
      OCPN_API_MSVC
        INTERFACE "${CMAKE_CURRENT_SOURCE_DIR}/msvc-win64/opencpn.lib"
    )
  else ()
    target_link_libraries(
      OCPN_API_MSVC
        INTERFACE "${CMAKE_CURRENT_SOURCE_DIR}/msvc-wx32/opencpn.lib"
    )
    # Assuming unicode build, required for mingw headers
    target_compile_definitions(OCPN_API_MSVC INTERFACE -DUNICODE)
  endif ()
endif ()
