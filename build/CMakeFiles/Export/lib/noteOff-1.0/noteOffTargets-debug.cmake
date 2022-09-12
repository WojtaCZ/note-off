#----------------------------------------------------------------
# Generated CMake target import file for configuration "Debug".
#----------------------------------------------------------------

# Commands may need to know the format version.
set(CMAKE_IMPORT_FILE_VERSION 1)

# Import target "noteOff::noteOff" for configuration "Debug"
set_property(TARGET noteOff::noteOff APPEND PROPERTY IMPORTED_CONFIGURATIONS DEBUG)
set_target_properties(noteOff::noteOff PROPERTIES
  IMPORTED_LINK_INTERFACE_LANGUAGES_DEBUG "CXX"
  IMPORTED_LOCATION_DEBUG "${_IMPORT_PREFIX}/lib/noteOff-1.0/libnoteOff.a"
  )

list(APPEND _IMPORT_CHECK_TARGETS noteOff::noteOff )
list(APPEND _IMPORT_CHECK_FILES_FOR_noteOff::noteOff "${_IMPORT_PREFIX}/lib/noteOff-1.0/libnoteOff.a" )

# Commands beyond this point should not need to know the version.
set(CMAKE_IMPORT_FILE_VERSION)
