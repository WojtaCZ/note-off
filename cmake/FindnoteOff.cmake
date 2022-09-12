# - Try to find the noteOff library
# Once done this will define
#
#  noteOff_FOUND - system has noteOff
#  noteOff_INCLUDE_DIR - noteOff include directory
#  noteOff_LIB - noteOff library directory
#  noteOff_LIBRARIES - noteOff libraries to link

if(noteOff_FOUND)
    return()
endif()

# We prioritize libraries installed in /usr/local with the prefix .../noteOff-*, 
# so we make a list of them here
file(GLOB lib_glob "/usr/local/lib/noteOff-*")
file(GLOB inc_glob "/usr/local/include/noteOff-*")

# Find the library with the name "noteOff" on the system. Store the final path
# in the variable noteOff_LIB
find_library(noteOff_LIB 
    # The library is named "noteOff", but can have various library forms, like
    # libnoteOff.a, libnoteOff.so, libnoteOff.so.1.x, etc. This should
    # search for any of these.
    NAMES noteOff
    # Provide a list of places to look based on prior knowledge about the system.
    # We want the user to override /usr/local with environment variables, so
    # this is included here.
    HINTS
        ${noteOff_DIR}
        ${noteOff_DIR}
        $ENV{noteOff_DIR}
        $ENV{noteOff_DIR}
        ENV noteOff_DIR
    # Provide a list of places to look as defaults. /usr/local shows up because
    # that's the default install location for most libs. The globbed paths also
    # are placed here as well.
    PATHS
        /usr
        /usr/local
        /usr/local/lib
        ${lib_glob}
    # Constrain the end of the full path to the detected library, not including
    # the name of library itself.
    PATH_SUFFIXES 
        lib
)

# Find the path to the file "source_file.hpp" on the system. Store the final
# path in the variables noteOff_INCLUDE_DIR. The HINTS, PATHS, and
# PATH_SUFFIXES, arguments have the same meaning as in find_library().
find_path(noteOff_INCLUDE_DIR source_file.hpp
    HINTS
        ${noteOff_DIR}
        ${noteOff_DIR}
        $ENV{noteOff_DIR}
        $ENV{noteOff_DIR}
        ENV noteOff_DIR
    PATHS
        /usr
        /usr/local
        /usr/local/include
        ${inc_glob}
    PATH_SUFFIXES 
        include
)


# Check that both the paths to the include and library directory were found.
include(FindPackageHandleStandardArgs)
find_package_handle_standard_args(noteOff
    "\nnoteOff not found --- You can download it using:\n\tgit clone 
    https://github.com/mmorse1217/cmake-project-template\n and setting the noteOff_DIR environment variable accordingly"
    noteOff_LIB noteOff_INCLUDE_DIR)

# These variables don't show up in the GUI version of CMake. Not required but
# people seem to do this...
mark_as_advanced(noteOff_INCLUDE_DIR noteOff_LIB)

# Finish defining the variables specified above. Variables names here follow
# CMake convention.
set(noteOff_INCLUDE_DIRS ${noteOff_INCLUDE_DIR})
set(noteOff_LIBRARIES ${noteOff_LIB})

# If the above CMake code was successful and we found the library, and there is
# no target defined, lets make one.
if(noteOff_FOUND AND NOT TARGET noteOff::noteOff)
    add_library(noteOff::noteOff UNKNOWN IMPORTED)
    # Set location of interface include directory, i.e., the directory
    # containing the header files for the installed library
    set_target_properties(noteOff::noteOff PROPERTIES
        INTERFACE_INCLUDE_DIRECTORIES "${noteOff_INCLUDE_DIRS}"
        )

    # Set location of the installed library
    set_target_properties(noteOff::noteOff PROPERTIES
        IMPORTED_LINK_INTERFACE_LANGUAGES "CXX"
        IMPORTED_LOCATION "${noteOff_LIBRARIES}"
        )
endif()
