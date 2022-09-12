# It's important to specify the minimum CMake version upfront required by
# CMakeLists.txt. This is so that a user can clearly understand the reason the 
# build will fail before the build actually occurs, instead of searching for the
# CMake function that was used that is causing the failure.
cmake_minimum_required(VERSION 3.1)

# Set the global package-wide C++ standard. This will be inherited by all
# targets specified in the project. One can also specify the C++ standard in a
# target-specific manner, using:
#   set_target_properties(foo PROPERTIES CXX_STANDARD 11)
#   target_compile_features(foo PUBLIC cxx_std_14)
# together.
set(CMAKE_CXX_STANDARD 11)

# Set the project name and version number. This allows for a user of your
# library or tool to specify a particular version when they include it, as in 
#   find_package(noteOff 1.0 REQUIRED)
project(noteOff VERSION 1.0)
set(noteOff_VERSION 1.0)

# enable unit testing via "make test" once the code has been compiled.
include(CTest)

# Function to prepend the subdirectory to source files in subdirectories
FUNCTION(PREPEND var )
   SET(listVar "")
   FOREACH(f ${${var}})
       LIST(APPEND listVar "${CMAKE_CURRENT_SOURCE_DIR}/${f}")
   ENDFOREACH(f)
   SET(${var} "${listVar}" PARENT_SCOPE)
ENDFUNCTION(PREPEND)

# After a normal build, we can specify the location of various outputs of the
# build. We put executables and static libraries outside the build directory in
# bin/ and lib/, respectively.
set(CMAKE_RUNTIME_OUTPUT_DIRECTORY "${CMAKE_CURRENT_SOURCE_DIR}/bin")
set(CMAKE_ARCHIVE_OUTPUT_DIRECTORY "${CMAKE_CURRENT_SOURCE_DIR}/lib")

# Find LAPACK on the system. This is mostly for demonstration.
find_package(LAPACK REQUIRED)

# Include source code and headers. This calls the CMakeLists.txt in each
# subdirectory. These can define their own libraries, executables, etc. as targets, 
# but here we define all exportable targets in the root CMakeLists.txt.
add_subdirectory(src)
add_subdirectory(include)

# Add the test directory. It is optional and can be disabled during with
#   cmake -DBUILD_TESTING=OFF ..
# To run unit tests produced here, we only need to run:
#   make test
# or
#   ctest 
# In case your tests are printing to console, you can view their output to
# stdout with:
#   ctest -V


# Add the library noteOff as a target, with the contents of src/ and include/
# as dependencies.
add_library(noteOff STATIC ${noteOff_SRC} ${noteOff_INC})

# These variables slightly modify the install location to allow for version
# specific installations.
set(noteOff_INCLUDE_DEST "include/noteOff-${noteOff_VERSION}")
set(noteOff_LIB_DEST "lib/noteOff-${noteOff_VERSION}")


# generator expressions are needed for the include directories, since installing headers changes the include path
# Specify that noteOff requires the files located in the include/ directory at
# compile time. This would normally look like 
#   target_include_directories(noteOff PUBLIC include/)
# PUBLIC means that other libraries including noteOff should also include the
# directory include/.
# However, there is a catch. If we are installing the project in
# CMAKE_INSTALL_PREFIX, we can't specify include/ in the build directory: we have 
# copied the contents of include to CMAKE_INSTALL_PREFIX/include and we would
# like  other projects to include this directory instead of include/. The follow
# CMake command handles this. $<BUILD_INTERFACE:...> and
# $<INSTALL_INTERFACE:...> are macros whose values change depending on if we are
# simply building the code or if we are installing it.
target_include_directories(noteOff PUBLIC
   # headers to include when building from source
   $<BUILD_INTERFACE:${noteOff_SOURCE_DIR}/include> 
   $<BUILD_INTERFACE:${noteOff_BINARY_DIR}/include> 

   # headers to include when installing  (implicitly prefixes with ${CMAKE_INSTALL_PREFIX}).
   $<INSTALL_INTERFACE:include> 
   )

# Specify that noteOff requires LAPACK to link properly. Ideally, LAPACK would
# specify LAPACK::LAPACK for linking so that we can avoid using the variables.
# However, each package is different and one must check the documentation to 
# see what variables are defined.
target_link_libraries(noteOff ${LAPACK_LIBRARIES})

# Install noteOff in CMAKE_INSTALL_PREFIX (defaults to /usr/local on linux). 
# To change the install location, run 
#   cmake -DCMAKE_INSTALL_PREFIX=<desired-install-path> ..

# install(...) specifies installation rules for the project. It can specify
# location of installed files on the system, user permissions, build
# configurations, etc. Here, we are only copying files.
# install(TARGETS ...) specifies rules for installing targets. 
# Here, we are taking a target or list of targets (noteOff) and telling CMake
# the following:
#   - put shared libraries associated with noteOff in ${noteOff_LIB_DEST}
#   - put static libraries associated with noteOff in ${noteOff_LIB_DEST}
#   - put include files associated with noteOff in ${noteOff_INCLUDE_DEST}
# We also need to specify the export that is associated with noteOff; an export 
# is just a list of targets to be installed.
# So we are associating noteOff with noteOffTargets.
install(
    # targets to install
    TARGETS noteOff 
    # name of the CMake "export group" containing the targets we want to install
    EXPORT noteOffTargets
    # Dynamic, static library and include destination locations after running
    # "make install"
    LIBRARY DESTINATION ${noteOff_LIB_DEST}
    ARCHIVE DESTINATION ${noteOff_LIB_DEST} 
    INCLUDES DESTINATION ${noteOff_INCLUDE_DEST}
    )

# We now need to install the export noteOffTargets that we defined above. This
# is needed in order for another project to import noteOff using 
#   find_package(noteOff)
# find_package(noteOff) will look for noteOff-config.cmake to provide
# information about the targets contained in the project noteOff. Fortunately,
# this is specified in the export noteOffTargets, so we will install this too.
# install(EXPORT ...) will install the information about an export. Here, we
# save it to a file {$noteOff_LIB_DEST}/noteOffTargets.cmake and prepend 
# everything inside noteOffTargets  with the namespace noteOff::.
install(
    # The export we want to save (matches name defined above containing the
    # install targets)
    EXPORT noteOffTargets
    # CMake file in which to store the export's information
    FILE  noteOffTargets.cmake
    # Namespace prepends all targets in the export (when we import later, we
    # will use noteOff::noteOff)
    NAMESPACE noteOff::
    # where to place the resulting file (here, we're putting it with the library)
    DESTINATION ${noteOff_LIB_DEST}
    )

# install(FILES ...) simply puts files in a certain place with certain
# properties. We're just copying them to the desired place here.
install(FILES ${noteOff_INC} DESTINATION ${noteOff_INCLUDE_DEST})

# Write a "version file" in case some wants to only load a particular version of
# noteOff @BUG this fails at the moment.
include(CMakePackageConfigHelpers)
write_basic_package_version_file(
    noteOffConfigVersion.cmake
    VERSION ${noteOff_VERSION}
    COMPATIBILITY AnyNewerVersion
    )

# Copies the resulting CMake config files to the installed library directory
install(
    FILES 
        "cmake/noteOff-config.cmake"
        "${CMAKE_CURRENT_BINARY_DIR}/noteOffConfigVersion.cmake"
    DESTINATION ${noteOff_LIB_DEST}
    )

