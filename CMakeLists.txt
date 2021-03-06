cmake_minimum_required(VERSION 3.10)

if(POLICY CMP0068)
  cmake_policy(SET CMP0068 NEW)
  set(CMAKE_BUILD_WITH_INSTALL_NAME_DIR ON)
endif()

if(POLICY CMP0075)
  cmake_policy(SET CMP0075 NEW)
endif()

if(POLICY CMP0077)
  cmake_policy(SET CMP0077 NEW)
endif()

project(brutus)
set(BRUTUS_SOURCE_DIR ${CMAKE_CURRENT_SOURCE_DIR})

find_package(MLIR REQUIRED CONFIG)

message(STATUS "Using MLIRConfig.cmake in: ${MLIR_DIR}")
message(STATUS "Using LLVMConfig.cmake in: ${LLVM_DIR}")

set(LLVM_RUNTIME_OUTPUT_INTDIR ${CMAKE_BINARY_DIR}/bin)
set(LLVM_LIBRARY_OUTPUT_INTDIR ${CMAKE_BINARY_DIR}/lib)
set(MLIR_BINARY_DIR ${CMAKE_BINARY_DIR})

list(APPEND CMAKE_MODULE_PATH "${MLIR_CMAKE_DIR}")
list(APPEND CMAKE_MODULE_PATH "${LLVM_CMAKE_DIR}")
list(APPEND CMAKE_MODULE_PATH "${BRUTUS_SOURCE_DIR}/cmake/modules")
include(TableGen)
include(AddLLVM)
include(AddMLIR)
include(HandleLLVMOptions)
include(FindJulia)

find_package(Julia REQUIRED)
# TODO: Check that Julia_LLVM_VERSION and this LLVM_VERSION match

set(LLVM_TOOLS_BINARY_DIR "${LLVM_INSTALL_PREFIX}/${LLVM_TOOLS_INSTALL_DIR}")

include_directories(${LLVM_INCLUDE_DIRS})
include_directories(${MLIR_INCLUDE_DIRS})
include_directories(${PROJECT_SOURCE_DIR}/include)
include_directories(${PROJECT_BINARY_DIR}/include)
include_directories(${Julia_INCLUDE_DIRS})
link_directories(${LLVM_BUILD_LIBRARY_DIR})
add_definitions(${LLVM_DEFINITIONS})

add_subdirectory(include)
add_subdirectory(lib)
add_subdirectory(test)
add_subdirectory(tools)

set(JLRUN "${CMAKE_BINARY_DIR}/jl.sh")
file( WRITE  ${JLRUN} "#!/bin/bash\n")
file( APPEND ${JLRUN} "export LD_LIBRARY_PATH=${CMAKE_BINARY_DIR}/lib\n")
file( APPEND ${JLRUN} "export JULIA_PROJECT=${BRUTUS_SOURCE_DIR}/Brutus\n")
file( APPEND ${JLRUN} "${Julia_EXECUTABLE}\n")
execute_process( COMMAND chmod +x ${JLRUN})


set(FISHENV "${CMAKE_BINARY_DIR}/env.fish")
file( WRITE  ${FISHENV} "set -x -g LD_LIBRARY_PATH ${CMAKE_BINARY_DIR}/lib\n")
file( APPEND ${FISHENV} "set -x -g JULIA_PROJECT ${BRUTUS_SOURCE_DIR}/Brutus\n")
file( APPEND ${FISHENV} "alias julia='${Julia_EXECUTABLE}'\n")
