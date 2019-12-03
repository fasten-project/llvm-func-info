llvm-func-pass
===============

A simple LLVM pass that dumps
function information.


## Install

Necessary setup:

```bash
sudo apt install graphviz-dev
pip3 install pygraphviz networkx
sudo ln -s /usr/bin/opt-<version> /usr/bin/opt
```

To build LLVM pass run:
```shell
mkdir build
cd build
cmake ..
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
error,definition,/home/builder/projects/debianutils-4.8.4,run-parts.c,0
fwrite,declaration,-,-,0
vfprintf,declaration,-,-,0
fputc,declaration,-,-,0
version,definition,/home/builder/projects/debianutils-4.8.4,run-parts.c,0
exit,declaration,-,-,0
usage,definition,/home/builder/projects/debianutils-4.8.4,run-parts.c,0
set_umask,definition,/home/builder/projects/debianutils-4.8.4,run-parts.c,0
__isoc99_sscanf,declaration,-,-,0
umask,declaration,-,-,0
add_argument,definition,/home/builder/projects/debianutils-4.8.4,run-parts.c,0
realloc,declaration,-,-,0
__errno_location,declaration,-,-,0
strerror,declaration,-,-,0
valid_name,definition,/home/builder/projects/debianutils-4.8.4,run-parts.c,0
regexec,declaration,-,-,0
run_part,definition,/home/builder/projects/debianutils-4.8.4,run-parts.c,0
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
run_parts,definition,/home/builder/projects/debianutils-4.8.4,run-parts.c,0
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
main,definition,/home/builder/projects/debianutils-4.8.4,run-parts.c,0
getopt_long,declaration,-,-,0
strdup,declaration,-,-,0
handle_signal,definition,/home/builder/projects/debianutils-4.8.4,run-parts.c,1
sigaction,declaration,-,-,0
regcomp,declaration,-,-,0
regex_get_error,definition,/home/builder/projects/debianutils-4.8.4,run-parts.c,1
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
./scripts/extract-llvm-info.sh /home/builder/projects/debianutils-4.8.4,run-parts.bc build/FuncInfoPass/libLLVMFuncInfoPass.so
```

This will generate the following output:

```
public:/home/builder/debianutils-4.8.6.1/run-parts.c:error public:/lib/x86_64-linux-gnu/libc.so.6:fwrite
public:/home/builder/debianutils-4.8.6.1/run-parts.c:error public:/lib/x86_64-linux-gnu/libc.so.6:vfprintf
public:/home/builder/debianutils-4.8.6.1/run-parts.c:error public:/lib/x86_64-linux-gnu/libc.so.6:fputc
public:/home/builder/debianutils-4.8.6.1/run-parts.c:main public:/home/builder/debianutils-4.8.6.1/run-parts.c:error
public:/home/builder/debianutils-4.8.6.1/run-parts.c:main public:/home/builder/debianutils-4.8.6.1/run-parts.c:error
public:/home/builder/debianutils-4.8.6.1/run-parts.c:main public:/home/builder/debianutils-4.8.6.1/run-parts.c:error
public:/home/builder/debianutils-4.8.6.1/run-parts.c:main public:/lib/x86_64-linux-gnu/libc.so.6:fwrite
public:/home/builder/debianutils-4.8.6.1/run-parts.c:main public:/lib/x86_64-linux-gnu/libc.so.6:fwrite
public:/home/builder/debianutils-4.8.6.1/run-parts.c:main public:/lib/x86_64-linux-gnu/libc.so.6:fwrite
public:/home/builder/debianutils-4.8.6.1/run-parts.c:main public:/lib/x86_64-linux-gnu/libc.so.6:umask
public:/home/builder/debianutils-4.8.6.1/run-parts.c:main public:/lib/x86_64-linux-gnu/libc.so.6:umask
public:/home/builder/debianutils-4.8.6.1/run-parts.c:main public:/home/builder/debianutils-4.8.6.1/run-parts.c:add_argument
public:/home/builder/debianutils-4.8.6.1/run-parts.c:main public:/home/builder/debianutils-4.8.6.1/run-parts.c:add_argument
public:/home/builder/debianutils-4.8.6.1/run-parts.c:main public:/lib/x86_64-linux-gnu/libc.so.6:getopt_long
public:/home/builder/debianutils-4.8.6.1/run-parts.c:main public:/lib/x86_64-linux-gnu/libc.so.6:strdup
public:/home/builder/debianutils-4.8.6.1/run-parts.c:main public:/lib/x86_64-linux-gnu/libc.so.6:__isoc99_sscanf
public:/home/builder/debianutils-4.8.6.1/run-parts.c:main public:/lib/x86_64-linux-gnu/libc.so.6:exit
public:/home/builder/debianutils-4.8.6.1/run-parts.c:main public:/lib/x86_64-linux-gnu/libc.so.6:exit
public:/home/builder/debianutils-4.8.6.1/run-parts.c:main public:/lib/x86_64-linux-gnu/libc.so.6:exit
public:/home/builder/debianutils-4.8.6.1/run-parts.c:main public:/lib/x86_64-linux-gnu/libc.so.6:exit
public:/home/builder/debianutils-4.8.6.1/run-parts.c:main public:/lib/x86_64-linux-gnu/libc.so.6:exit
public:/home/builder/debianutils-4.8.6.1/run-parts.c:main public:/home/builder/debianutils-4.8.6.1/run-parts.c:usage
public:/home/builder/debianutils-4.8.6.1/run-parts.c:main public:/home/builder/debianutils-4.8.6.1/run-parts.c:version
public:/home/builder/debianutils-4.8.6.1/run-parts.c:main public:/lib/x86_64-linux-gnu/libc.so.6:sigaction
public:/home/builder/debianutils-4.8.6.1/run-parts.c:main public:/lib/x86_64-linux-gnu/libc.so.6:sigemptyset
public:/home/builder/debianutils-4.8.6.1/run-parts.c:main public:/lib/x86_64-linux-gnu/libc.so.6:sigaddset
public:/home/builder/debianutils-4.8.6.1/run-parts.c:main public:/lib/x86_64-linux-gnu/libc.so.6:sigprocmask
public:/home/builder/debianutils-4.8.6.1/run-parts.c:main public:/lib/x86_64-linux-gnu/libc.so.6:regcomp
public:/home/builder/debianutils-4.8.6.1/run-parts.c:main public:/lib/x86_64-linux-gnu/libc.so.6:regcomp
public:/home/builder/debianutils-4.8.6.1/run-parts.c:main public:/lib/x86_64-linux-gnu/libc.so.6:regcomp
public:/home/builder/debianutils-4.8.6.1/run-parts.c:main public:/lib/x86_64-linux-gnu/libc.so.6:regcomp
public:/home/builder/debianutils-4.8.6.1/run-parts.c:main public:/lib/x86_64-linux-gnu/libc.so.6:regcomp
public:/home/builder/debianutils-4.8.6.1/run-parts.c:main static:/home/builder/debianutils-4.8.6.1/run-parts.c:regex_get_error
public:/home/builder/debianutils-4.8.6.1/run-parts.c:main public:/lib/x86_64-linux-gnu/libc.so.6:fprintf
public:/home/builder/debianutils-4.8.6.1/run-parts.c:main public:/home/builder/debianutils-4.8.6.1/run-parts.c:run_parts
public:/home/builder/debianutils-4.8.6.1/run-parts.c:main public:/lib/x86_64-linux-gnu/libc.so.6:regfree
public:/home/builder/debianutils-4.8.6.1/run-parts.c:main public:/lib/x86_64-linux-gnu/libc.so.6:regfree
public:/home/builder/debianutils-4.8.6.1/run-parts.c:main public:/lib/x86_64-linux-gnu/libc.so.6:regfree
public:/home/builder/debianutils-4.8.6.1/run-parts.c:main public:/lib/x86_64-linux-gnu/libc.so.6:regfree
public:/home/builder/debianutils-4.8.6.1/run-parts.c:main public:/lib/x86_64-linux-gnu/libc.so.6:regfree
public:/home/builder/debianutils-4.8.6.1/run-parts.c:main public:/lib/x86_64-linux-gnu/libc.so.6:free
public:/home/builder/debianutils-4.8.6.1/run-parts.c:main public:/lib/x86_64-linux-gnu/libc.so.6:free
public:/home/builder/debianutils-4.8.6.1/run-parts.c:add_argument public:/home/builder/debianutils-4.8.6.1/run-parts.c:error
public:/home/builder/debianutils-4.8.6.1/run-parts.c:add_argument public:/lib/x86_64-linux-gnu/libc.so.6:exit
public:/home/builder/debianutils-4.8.6.1/run-parts.c:add_argument public:/lib/x86_64-linux-gnu/libc.so.6:__errno_location
public:/home/builder/debianutils-4.8.6.1/run-parts.c:add_argument public:/lib/x86_64-linux-gnu/libc.so.6:strerror
public:/home/builder/debianutils-4.8.6.1/run-parts.c:add_argument public:/lib/x86_64-linux-gnu/libc.so.6:realloc
public:/home/builder/debianutils-4.8.6.1/run-parts.c:usage public:/lib/x86_64-linux-gnu/libc.so.6:fwrite
public:/home/builder/debianutils-4.8.6.1/run-parts.c:usage public:/lib/x86_64-linux-gnu/libc.so.6:exit
public:/home/builder/debianutils-4.8.6.1/run-parts.c:version public:/lib/x86_64-linux-gnu/libc.so.6:fwrite
public:/home/builder/debianutils-4.8.6.1/run-parts.c:version public:/lib/x86_64-linux-gnu/libc.so.6:exit
static:/home/builder/debianutils-4.8.6.1/run-parts.c:regex_get_error public:/home/builder/debianutils-4.8.6.1/run-parts.c:error
static:/home/builder/debianutils-4.8.6.1/run-parts.c:regex_get_error public:/lib/x86_64-linux-gnu/libc.so.6:exit
static:/home/builder/debianutils-4.8.6.1/run-parts.c:regex_get_error public:/lib/x86_64-linux-gnu/libc.so.6:regerror
static:/home/builder/debianutils-4.8.6.1/run-parts.c:regex_get_error public:/lib/x86_64-linux-gnu/libc.so.6:regerror
static:/home/builder/debianutils-4.8.6.1/run-parts.c:regex_get_error public:/lib/x86_64-linux-gnu/libc.so.6:malloc
public:/home/builder/debianutils-4.8.6.1/run-parts.c:run_parts public:/home/builder/debianutils-4.8.6.1/run-parts.c:error
public:/home/builder/debianutils-4.8.6.1/run-parts.c:run_parts public:/home/builder/debianutils-4.8.6.1/run-parts.c:error
public:/home/builder/debianutils-4.8.6.1/run-parts.c:run_parts public:/home/builder/debianutils-4.8.6.1/run-parts.c:error
public:/home/builder/debianutils-4.8.6.1/run-parts.c:run_parts public:/home/builder/debianutils-4.8.6.1/run-parts.c:error
public:/home/builder/debianutils-4.8.6.1/run-parts.c:run_parts public:/home/builder/debianutils-4.8.6.1/run-parts.c:error
public:/home/builder/debianutils-4.8.6.1/run-parts.c:run_parts public:/home/builder/debianutils-4.8.6.1/run-parts.c:error
public:/home/builder/debianutils-4.8.6.1/run-parts.c:run_parts public:/lib/x86_64-linux-gnu/libc.so.6:fputc
public:/home/builder/debianutils-4.8.6.1/run-parts.c:run_parts public:/lib/x86_64-linux-gnu/libc.so.6:exit
public:/home/builder/debianutils-4.8.6.1/run-parts.c:run_parts public:/lib/x86_64-linux-gnu/libc.so.6:exit
public:/home/builder/debianutils-4.8.6.1/run-parts.c:run_parts public:/lib/x86_64-linux-gnu/libc.so.6:exit
public:/home/builder/debianutils-4.8.6.1/run-parts.c:run_parts public:/lib/x86_64-linux-gnu/libc.so.6:exit
public:/home/builder/debianutils-4.8.6.1/run-parts.c:run_parts public:/lib/x86_64-linux-gnu/libc.so.6:fprintf
public:/home/builder/debianutils-4.8.6.1/run-parts.c:run_parts public:/lib/x86_64-linux-gnu/libc.so.6:fprintf
public:/home/builder/debianutils-4.8.6.1/run-parts.c:run_parts public:/lib/x86_64-linux-gnu/libc.so.6:fprintf
public:/home/builder/debianutils-4.8.6.1/run-parts.c:run_parts public:/lib/x86_64-linux-gnu/libc.so.6:free
public:/home/builder/debianutils-4.8.6.1/run-parts.c:run_parts public:/lib/x86_64-linux-gnu/libc.so.6:free
public:/home/builder/debianutils-4.8.6.1/run-parts.c:run_parts public:/lib/x86_64-linux-gnu/libc.so.6:free
public:/home/builder/debianutils-4.8.6.1/run-parts.c:run_parts public:/lib/x86_64-linux-gnu/libc.so.6:strlen
public:/home/builder/debianutils-4.8.6.1/run-parts.c:run_parts public:/lib/x86_64-linux-gnu/libc.so.6:strlen
public:/home/builder/debianutils-4.8.6.1/run-parts.c:run_parts public:/lib/x86_64-linux-gnu/libc.so.6:strlen
public:/home/builder/debianutils-4.8.6.1/run-parts.c:run_parts public:/lib/x86_64-linux-gnu/libc.so.6:strlen
public:/home/builder/debianutils-4.8.6.1/run-parts.c:run_parts public:/lib/x86_64-linux-gnu/libc.so.6:access
public:/home/builder/debianutils-4.8.6.1/run-parts.c:run_parts public:/lib/x86_64-linux-gnu/libc.so.6:access
public:/home/builder/debianutils-4.8.6.1/run-parts.c:run_parts public:/lib/x86_64-linux-gnu/libc.so.6:access
public:/home/builder/debianutils-4.8.6.1/run-parts.c:run_parts public:/lib/x86_64-linux-gnu/libc.so.6:__errno_location
public:/home/builder/debianutils-4.8.6.1/run-parts.c:run_parts public:/lib/x86_64-linux-gnu/libc.so.6:__errno_location
public:/home/builder/debianutils-4.8.6.1/run-parts.c:run_parts public:/lib/x86_64-linux-gnu/libc.so.6:__errno_location
public:/home/builder/debianutils-4.8.6.1/run-parts.c:run_parts public:/lib/x86_64-linux-gnu/libc.so.6:__errno_location
public:/home/builder/debianutils-4.8.6.1/run-parts.c:run_parts public:/lib/x86_64-linux-gnu/libc.so.6:scandir
public:/home/builder/debianutils-4.8.6.1/run-parts.c:run_parts public:/home/builder/debianutils-4.8.6.1/run-parts.c:run_part
public:/home/builder/debianutils-4.8.6.1/run-parts.c:run_parts public:/lib/x86_64-linux-gnu/libc.so.6:strerror
public:/home/builder/debianutils-4.8.6.1/run-parts.c:run_parts public:/lib/x86_64-linux-gnu/libc.so.6:strerror
public:/home/builder/debianutils-4.8.6.1/run-parts.c:run_parts public:/lib/x86_64-linux-gnu/libc.so.6:strerror
public:/home/builder/debianutils-4.8.6.1/run-parts.c:run_parts public:/lib/x86_64-linux-gnu/libc.so.6:strerror
public:/home/builder/debianutils-4.8.6.1/run-parts.c:run_parts public:/lib/x86_64-linux-gnu/libc.so.6:malloc
public:/home/builder/debianutils-4.8.6.1/run-parts.c:run_parts public:/lib/x86_64-linux-gnu/libc.so.6:puts
public:/home/builder/debianutils-4.8.6.1/run-parts.c:run_parts public:/lib/x86_64-linux-gnu/libc.so.6:puts
public:/home/builder/debianutils-4.8.6.1/run-parts.c:run_parts public:/lib/x86_64-linux-gnu/libc.so.6:puts
public:/home/builder/debianutils-4.8.6.1/run-parts.c:run_parts public:/lib/x86_64-linux-gnu/libc.so.6:strcat
public:/home/builder/debianutils-4.8.6.1/run-parts.c:run_parts public:/lib/x86_64-linux-gnu/libc.so.6:realloc
public:/home/builder/debianutils-4.8.6.1/run-parts.c:run_parts public:/lib/x86_64-linux-gnu/libc.so.6:strcpy
public:/home/builder/debianutils-4.8.6.1/run-parts.c:run_parts public:/lib/x86_64-linux-gnu/libc.so.6:strcpy
public:/home/builder/debianutils-4.8.6.1/run-parts.c:run_parts public:/lib/x86_64-linux-gnu/libc.so.6:strcpy
public:/home/builder/debianutils-4.8.6.1/run-parts.c:run_parts public:/lib/x86_64-linux-gnu/libc.so.6:__xstat
public:/home/builder/debianutils-4.8.6.1/run-parts.c:run_part public:/home/builder/debianutils-4.8.6.1/run-parts.c:error
public:/home/builder/debianutils-4.8.6.1/run-parts.c:run_part public:/home/builder/debianutils-4.8.6.1/run-parts.c:error
public:/home/builder/debianutils-4.8.6.1/run-parts.c:run_part public:/home/builder/debianutils-4.8.6.1/run-parts.c:error
public:/home/builder/debianutils-4.8.6.1/run-parts.c:run_part public:/home/builder/debianutils-4.8.6.1/run-parts.c:error
public:/home/builder/debianutils-4.8.6.1/run-parts.c:run_part public:/home/builder/debianutils-4.8.6.1/run-parts.c:error
public:/home/builder/debianutils-4.8.6.1/run-parts.c:run_part public:/home/builder/debianutils-4.8.6.1/run-parts.c:error
public:/home/builder/debianutils-4.8.6.1/run-parts.c:run_part public:/home/builder/debianutils-4.8.6.1/run-parts.c:error
public:/home/builder/debianutils-4.8.6.1/run-parts.c:run_part public:/home/builder/debianutils-4.8.6.1/run-parts.c:error
public:/home/builder/debianutils-4.8.6.1/run-parts.c:run_part public:/home/builder/debianutils-4.8.6.1/run-parts.c:error
public:/home/builder/debianutils-4.8.6.1/run-parts.c:run_part public:/home/builder/debianutils-4.8.6.1/run-parts.c:error
public:/home/builder/debianutils-4.8.6.1/run-parts.c:run_part public:/home/builder/debianutils-4.8.6.1/run-parts.c:error
public:/home/builder/debianutils-4.8.6.1/run-parts.c:run_part public:/lib/x86_64-linux-gnu/libc.so.6:exit
public:/home/builder/debianutils-4.8.6.1/run-parts.c:run_part public:/lib/x86_64-linux-gnu/libc.so.6:exit
public:/home/builder/debianutils-4.8.6.1/run-parts.c:run_part public:/lib/x86_64-linux-gnu/libc.so.6:exit
public:/home/builder/debianutils-4.8.6.1/run-parts.c:run_part public:/lib/x86_64-linux-gnu/libc.so.6:exit
public:/home/builder/debianutils-4.8.6.1/run-parts.c:run_part public:/lib/x86_64-linux-gnu/libc.so.6:exit
public:/home/builder/debianutils-4.8.6.1/run-parts.c:run_part public:/lib/x86_64-linux-gnu/libc.so.6:exit
public:/home/builder/debianutils-4.8.6.1/run-parts.c:run_part public:/lib/x86_64-linux-gnu/libc.so.6:exit
public:/home/builder/debianutils-4.8.6.1/run-parts.c:run_part public:/lib/x86_64-linux-gnu/libc.so.6:sigemptyset
public:/home/builder/debianutils-4.8.6.1/run-parts.c:run_part public:/lib/x86_64-linux-gnu/libc.so.6:sigemptyset
public:/home/builder/debianutils-4.8.6.1/run-parts.c:run_part public:/lib/x86_64-linux-gnu/libc.so.6:sigaddset
public:/home/builder/debianutils-4.8.6.1/run-parts.c:run_part public:/lib/x86_64-linux-gnu/libc.so.6:sigprocmask
public:/home/builder/debianutils-4.8.6.1/run-parts.c:run_part public:/lib/x86_64-linux-gnu/libc.so.6:sigprocmask
public:/home/builder/debianutils-4.8.6.1/run-parts.c:run_part public:/lib/x86_64-linux-gnu/libc.so.6:fprintf
public:/home/builder/debianutils-4.8.6.1/run-parts.c:run_part public:/lib/x86_64-linux-gnu/libc.so.6:setsid
public:/home/builder/debianutils-4.8.6.1/run-parts.c:run_part public:/lib/x86_64-linux-gnu/libc.so.6:pselect
public:/home/builder/debianutils-4.8.6.1/run-parts.c:run_part public:/lib/x86_64-linux-gnu/libc.so.6:__errno_location
public:/home/builder/debianutils-4.8.6.1/run-parts.c:run_part public:/lib/x86_64-linux-gnu/libc.so.6:__errno_location
public:/home/builder/debianutils-4.8.6.1/run-parts.c:run_part public:/lib/x86_64-linux-gnu/libc.so.6:__errno_location
public:/home/builder/debianutils-4.8.6.1/run-parts.c:run_part public:/lib/x86_64-linux-gnu/libc.so.6:__errno_location
public:/home/builder/debianutils-4.8.6.1/run-parts.c:run_part public:/lib/x86_64-linux-gnu/libc.so.6:__errno_location
public:/home/builder/debianutils-4.8.6.1/run-parts.c:run_part public:/lib/x86_64-linux-gnu/libc.so.6:__errno_location
public:/home/builder/debianutils-4.8.6.1/run-parts.c:run_part public:/lib/x86_64-linux-gnu/libc.so.6:__errno_location
public:/home/builder/debianutils-4.8.6.1/run-parts.c:run_part public:/lib/x86_64-linux-gnu/libc.so.6:__errno_location
public:/home/builder/debianutils-4.8.6.1/run-parts.c:run_part public:/lib/x86_64-linux-gnu/libc.so.6:__errno_location
public:/home/builder/debianutils-4.8.6.1/run-parts.c:run_part public:/lib/x86_64-linux-gnu/libc.so.6:sigdelset
public:/home/builder/debianutils-4.8.6.1/run-parts.c:run_part public:/lib/x86_64-linux-gnu/libc.so.6:write
public:/home/builder/debianutils-4.8.6.1/run-parts.c:run_part public:/lib/x86_64-linux-gnu/libc.so.6:write
public:/home/builder/debianutils-4.8.6.1/run-parts.c:run_part public:/lib/x86_64-linux-gnu/libc.so.6:pipe
public:/home/builder/debianutils-4.8.6.1/run-parts.c:run_part public:/lib/x86_64-linux-gnu/libc.so.6:pipe
public:/home/builder/debianutils-4.8.6.1/run-parts.c:run_part public:/lib/x86_64-linux-gnu/libc.so.6:strerror
public:/home/builder/debianutils-4.8.6.1/run-parts.c:run_part public:/lib/x86_64-linux-gnu/libc.so.6:strerror
public:/home/builder/debianutils-4.8.6.1/run-parts.c:run_part public:/lib/x86_64-linux-gnu/libc.so.6:strerror
public:/home/builder/debianutils-4.8.6.1/run-parts.c:run_part public:/lib/x86_64-linux-gnu/libc.so.6:strerror
public:/home/builder/debianutils-4.8.6.1/run-parts.c:run_part public:/lib/x86_64-linux-gnu/libc.so.6:strerror
public:/home/builder/debianutils-4.8.6.1/run-parts.c:run_part public:/lib/x86_64-linux-gnu/libc.so.6:strerror
public:/home/builder/debianutils-4.8.6.1/run-parts.c:run_part public:/lib/x86_64-linux-gnu/libc.so.6:strerror
public:/home/builder/debianutils-4.8.6.1/run-parts.c:run_part public:/lib/x86_64-linux-gnu/libc.so.6:strerror
public:/home/builder/debianutils-4.8.6.1/run-parts.c:run_part public:/lib/x86_64-linux-gnu/libc.so.6:strerror
public:/home/builder/debianutils-4.8.6.1/run-parts.c:run_part public:/lib/x86_64-linux-gnu/libc.so.6:fork
public:/home/builder/debianutils-4.8.6.1/run-parts.c:run_part public:/lib/x86_64-linux-gnu/libc.so.6:dup2
public:/home/builder/debianutils-4.8.6.1/run-parts.c:run_part public:/lib/x86_64-linux-gnu/libc.so.6:dup2
public:/home/builder/debianutils-4.8.6.1/run-parts.c:run_part public:/lib/x86_64-linux-gnu/libc.so.6:close
public:/home/builder/debianutils-4.8.6.1/run-parts.c:run_part public:/lib/x86_64-linux-gnu/libc.so.6:close
public:/home/builder/debianutils-4.8.6.1/run-parts.c:run_part public:/lib/x86_64-linux-gnu/libc.so.6:close
public:/home/builder/debianutils-4.8.6.1/run-parts.c:run_part public:/lib/x86_64-linux-gnu/libc.so.6:close
public:/home/builder/debianutils-4.8.6.1/run-parts.c:run_part public:/lib/x86_64-linux-gnu/libc.so.6:close
public:/home/builder/debianutils-4.8.6.1/run-parts.c:run_part public:/lib/x86_64-linux-gnu/libc.so.6:close
public:/home/builder/debianutils-4.8.6.1/run-parts.c:run_part public:/lib/x86_64-linux-gnu/libc.so.6:close
public:/home/builder/debianutils-4.8.6.1/run-parts.c:run_part public:/lib/x86_64-linux-gnu/libc.so.6:close
public:/home/builder/debianutils-4.8.6.1/run-parts.c:run_part public:/lib/x86_64-linux-gnu/libc.so.6:close
public:/home/builder/debianutils-4.8.6.1/run-parts.c:run_part public:/lib/x86_64-linux-gnu/libc.so.6:close
public:/home/builder/debianutils-4.8.6.1/run-parts.c:run_part public:/lib/x86_64-linux-gnu/libc.so.6:execv
public:/home/builder/debianutils-4.8.6.1/run-parts.c:run_part public:/lib/x86_64-linux-gnu/libc.so.6:waitpid
public:/home/builder/debianutils-4.8.6.1/run-parts.c:run_part public:/lib/x86_64-linux-gnu/libc.so.6:waitpid
public:/home/builder/debianutils-4.8.6.1/run-parts.c:run_part public:/lib/x86_64-linux-gnu/libc.so.6:read
public:/home/builder/debianutils-4.8.6.1/run-parts.c:run_part public:/lib/x86_64-linux-gnu/libc.so.6:read
public:/home/builder/debianutils-4.8.6.1/run-parts.c:run_part public:/lib/x86_64-linux-gnu/libc.so.6:printf
public:/home/builder/debianutils-4.8.6.1/run-parts.c:run_part public:/lib/x86_64-linux-gnu/libc.so.6:fflush
public:/home/builder/debianutils-4.8.6.1/run-parts.c:run_part public:/lib/x86_64-linux-gnu/libc.so.6:fflush
public:/home/builder/debianutils-4.8.6.1/run-parts.c:set_umask public:/home/builder/debianutils-4.8.6.1/run-parts.c:error
public:/home/builder/debianutils-4.8.6.1/run-parts.c:set_umask public:/lib/x86_64-linux-gnu/libc.so.6:umask
public:/home/builder/debianutils-4.8.6.1/run-parts.c:set_umask public:/lib/x86_64-linux-gnu/libc.so.6:__isoc99_sscanf
public:/home/builder/debianutils-4.8.6.1/run-parts.c:set_umask public:/lib/x86_64-linux-gnu/libc.so.6:exit
public:/home/builder/debianutils-4.8.6.1/run-parts.c:valid_name public:/lib/x86_64-linux-gnu/libc.so.6:regexec
public:/home/builder/debianutils-4.8.6.1/run-parts.c:valid_name public:/lib/x86_64-linux-gnu/libc.so.6:regexec
public:/home/builder/debianutils-4.8.6.1/run-parts.c:valid_name public:/lib/x86_64-linux-gnu/libc.so.6:regexec
public:/home/builder/debianutils-4.8.6.1/run-parts.c:valid_name public:/lib/x86_64-linux-gnu/libc.so.6:regexec
public:/home/builder/debianutils-4.8.6.1/run-parts.c:valid_name public:/lib/x86_64-linux-gnu/libc.so.6:regexec
```

