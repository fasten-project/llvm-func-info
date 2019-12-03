llvm-func-pass
===============

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

This will dump to standard error
information about each function found
in the LLVM module.
Each row has the following form:

```
function_name,type,dirname,filename,static
```

The column `function_name` is the name of the function,
the column `type` indicates whether it's a function
definition or declaration
the third column (`dirname`) is the directory
that includes the file shown by the fourth column (`filename`)
defining this function,
and the last column shows if this function is static or not.

This is an example of this pass output:

```
function_name,function_type,directory,filename,static
error,definition,/home/user/projects/debianutils-4.8.4,run-parts.c,0
fwrite,declaration,-,-,0
vfprintf,declaration,-,-,0
fputc,declaration,-,-,0
version,definition,/home/user/projects/debianutils-4.8.4,run-parts.c,0
exit,declaration,-,-,0
usage,definition,/home/user/projects/debianutils-4.8.4,run-parts.c,0
set_umask,definition,/home/user/projects/debianutils-4.8.4,run-parts.c,0
__isoc99_sscanf,declaration,-,-,0
umask,declaration,-,-,0
add_argument,definition,/home/user/projects/debianutils-4.8.4,run-parts.c,0
realloc,declaration,-,-,0
__errno_location,declaration,-,-,0
strerror,declaration,-,-,0
valid_name,definition,/home/user/projects/debianutils-4.8.4,run-parts.c,0
regexec,declaration,-,-,0
run_part,definition,/home/user/projects/debianutils-4.8.4,run-parts.c,0
pipe,declaration,-,-,0
fork,declaration,-,-,0
sigemptyset,declaration,-,-,0
sigaddset,declaration,-,-,0
sigprocmask,declaration,-,-,0
setsid,declaration,-,-,0
dup2,declaration,-,-,0
close,declaration,-,-,0
execv,declaration,-,-,0
sigdelset,declaration,-,-,0
waitpid,declaration,-,-,0
pselect,declaration,-,-,0
read,declaration,-,-,0
printf,declaration,-,-,0
fflush,declaration,-,-,0
write,declaration,-,-,0
fprintf,declaration,-,-,0
run_parts,definition,/home/user/projects/debianutils-4.8.4,run-parts.c,0
strlen,declaration,-,-,0
malloc,declaration,-,-,0
strcpy,declaration,-,-,0
alphasort,declaration,-,-,0
scandir,declaration,-,-,0
strcat,declaration,-,-,0
__xstat,declaration,-,-,0
access,declaration,-,-,0
puts,declaration,-,-,0
free,declaration,-,-,0
main,definition,/home/user/projects/debianutils-4.8.4,run-parts.c,0
getopt_long,declaration,-,-,0
strdup,declaration,-,-,0
handle_signal,definition,/home/user/projects/debianutils-4.8.4,run-parts.c,1
sigaction,declaration,-,-,0
regcomp,declaration,-,-,0
regex_get_error,definition,/home/user/projects/debianutils-4.8.4,run-parts.c,1
regfree,declaration,-,-,0
regerror,declaration,-,-,0
```

Note that the columns `dirname`,
and `filename` for function declarations
are empty.
This is because, they are defined
in external libraries used by the module.

In order to determine the library
that includes those symbols,
run the following script:

```bash
./scripts/extract-llvm-info.sh <bitcode-file> <llvm-pass-lib>
```

The first argument is that path of the bitcode file
that we need to analyse,
whereas the second one denotes that path
of the library of our LLVM pass.

Example:


```bash
./scripts/extract-llvm-info.sh /home/user/projects/debianutils-4.8.4,run-parts.bc build/FuncInfoPass/libLLVMFuncInfoPass.so
```

This will generate the following output:

```
error,/home/user/projects/debianutils-4.8.4,run-parts.c,0
version,/home/user/projects/debianutils-4.8.4,run-parts.c,0
usage,/home/user/projects/debianutils-4.8.4,run-parts.c,0
set_umask,/home/user/projects/debianutils-4.8.4,run-parts.c,0
add_argument,/home/user/projects/debianutils-4.8.4,run-parts.c,0
valid_name,/home/user/projects/debianutils-4.8.4,run-parts.c,0
run_part,/home/user/projects/debianutils-4.8.4,run-parts.c,0
run_parts,/home/user/projects/debianutils-4.8.4,run-parts.c,0
main,/home/user/projects/debianutils-4.8.4,run-parts.c,0
handle_signal,/home/user/projects/debianutils-4.8.4,run-parts.c,1
regex_get_error,/home/user/projects/debianutils-4.8.4,run-parts.c,1
fwrite,/lib/x86_64-linux-gnu,libc.so.6,0
vfprintf,/lib/x86_64-linux-gnu,libc.so.6,0
fputc,/lib/x86_64-linux-gnu,libc.so.6,0
exit,/lib/x86_64-linux-gnu,libc.so.6,0
__isoc99_sscanf,/lib/x86_64-linux-gnu,libc.so.6,0
umask,/lib/x86_64-linux-gnu,libc.so.6,0
realloc,/lib64,ld-linux-x86-64.so.2,0
__errno_location,/lib/x86_64-linux-gnu,libc.so.6,0
strerror,/lib/x86_64-linux-gnu,libc.so.6,0
regexec,/lib/x86_64-linux-gnu,libc.so.6,0
pipe,/lib/x86_64-linux-gnu,libc.so.6,0
fork,/lib/x86_64-linux-gnu,libc.so.6,0
sigemptyset,/lib/x86_64-linux-gnu,libc.so.6,0
sigaddset,/lib/x86_64-linux-gnu,libc.so.6,0
sigprocmask,/lib/x86_64-linux-gnu,libc.so.6,0
setsid,/lib/x86_64-linux-gnu,libc.so.6,0
dup2,/lib/x86_64-linux-gnu,libc.so.6,0
close,/lib/x86_64-linux-gnu,libc.so.6,0
execv,/lib/x86_64-linux-gnu,libc.so.6,0
sigdelset,/lib/x86_64-linux-gnu,libc.so.6,0
waitpid,/lib/x86_64-linux-gnu,libc.so.6,0
pselect,/lib/x86_64-linux-gnu,libc.so.6,0
read,/lib/x86_64-linux-gnu,libc.so.6,0
printf,/lib/x86_64-linux-gnu,libc.so.6,0
fflush,/lib/x86_64-linux-gnu,libc.so.6,0
write,/lib/x86_64-linux-gnu,libc.so.6,0
fprintf,/lib/x86_64-linux-gnu,libc.so.6,0
strlen,/lib/x86_64-linux-gnu,libc.so.6,0
malloc,/lib64,ld-linux-x86-64.so.2,0
strcpy,/lib/x86_64-linux-gnu,libc.so.6,0
alphasort,/lib/x86_64-linux-gnu,libc.so.6,0
scandir,/lib/x86_64-linux-gnu,libc.so.6,0
strcat,/lib/x86_64-linux-gnu,libc.so.6,0
__xstat,/lib/x86_64-linux-gnu,libc.so.6,0
access,/lib/x86_64-linux-gnu,libc.so.6,0
puts,/lib/x86_64-linux-gnu,libc.so.6,0
free,/lib64,ld-linux-x86-64.so.2,0
getopt_long,/lib/x86_64-linux-gnu,libc.so.6,0
strdup,/lib/x86_64-linux-gnu,libc.so.6,0
sigaction,/lib/x86_64-linux-gnu,libc.so.6,0
regcomp,/lib/x86_64-linux-gnu,libc.so.6,0
regfree,/lib/x86_64-linux-gnu,libc.so.6,0
regerror,/lib/x86_64-linux-gnu,libc.so.6,0
```
