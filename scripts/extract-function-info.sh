#! /bin/bash

bitcode_file=$1
opt_lib=$2

if [ -z $bitcode_file ]; then
  echo "You have to specify the path of bitcode file"
  exit 1
fi

if [ -z $opt_lib ]; then
  echo "You have to specify the path of optimisation pass"
  exit 1
fi


bitcode_file=$(realpath $1)
opt_lib=$(realpath $2)
out=$(opt --load $opt_lib -FunctionInfoPass -o /dev/null < $bitcode_file 2>&1)
if [ $? -ne 0 ]; then
  echo "Optimisation pass exited with a non zero exit code"
  echo $out
  exit 1
fi

execfile=$(echo $bitcode_file | sed 's/.bc//g')
slibs=$(ldd $execfile |
  grep so |
  sed -e '/^[^\t]/ d' |
  sed -e 's/\t//' |
  sed -e 's/.*=..//' |
  sed -e 's/ (0.*)//' |
  sort |
  uniq)

if [ $? -ne 0 ]; then
  echo "Cannot determine the shared libraries of executable $execfile"
  exit 1
fi

echo "$out" |
grep -oP '[^ ]*,definition,[^ ]*' |
sed 's/definition,//g'

echo "$out" |
grep -oP '[^ ]*,declaration,-[^ ]*' |
sed -r 's/([a-zA-Z_0-9]+),declaration,.*(,[01])/\1\2/g' |
while read -r func_entry; do
  func=$(echo $func_entry | sed -r 's/(.*),[01]/\1/')
  static=$(echo $func_entry | sed -r 's/.*([01])/\1/')
  found=1
  while read lib; do
    if [[ "$lib" =~ ^/.*  ]]; then
      if nm -D $lib | grep -q $func; then
        found=1
        baselib=$(basename $lib)
        dirlib=$(dirname $lib)
        echo "$func,$dirlib,$baselib,$static"
        break
      fi
    fi
  done <<< $(echo "$slibs")
  if [ $found -eq 0 ]; then
    >&2 echo "Couldn't find symbol entry for function $func"
  fi
done
