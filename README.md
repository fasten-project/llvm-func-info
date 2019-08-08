#llvm-func-pass

A simple LLVM pass that dumps
function information.


## Install

```shell
mkdir build
cd build
cmake -DLLVM_BUILD_DIR=<directory where LLVM is built> ..
make
```

This will generate the `libLLVMFuncInfoPass.so` file
inside the `build/FuncInfoPass` directory.

## Run pass

```shell
opt --load build/FuncInfoPass/libLLVMFuncInfoPass.so -FuncInfoPass -o /dev/null < <bitcode file>
```
