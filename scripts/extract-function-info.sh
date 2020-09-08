# Copyright (c) 2018-2020 FASTEN.
#
# This file is part of FASTEN
# (see https://www.fasten-project.eu/).
#
# Licensed to the Apache Software Foundation (ASF) under one
# or more contributor license agreements.  See the NOTICE file
# distributed with this work for additional information
# regarding copyright ownership.  The ASF licenses this file
# to you under the Apache License, Version 2.0 (the
# "License"); you may not use this file except in compliance
# with the License.  You may obtain a copy of the License at
#
#   http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing,
# software distributed under the License is distributed on an
# "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
# KIND, either express or implied.  See the License for the
# specific language governing permissions and limitations
# under the License.
#
#! /bin/bash

dir=$(dirname $0)
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

declare -A functions

for func_entry in $(echo "$out" |
    grep -oP '[^ ]*,definition,[^ ]*' |
    sed 's/definition,//g'); do
  func=$(echo $func_entry | sed -r 's/([^,]*),.*/\1/')
  info=$(echo $func_entry | sed -r 's/[^,]*,(.*)/\1/')
  functions["$func"]="$info"
done


for func_entry in $(echo "$out" |
    grep -oP '[^ ]*,declaration,-[^ ]*' |
    sed -r 's/([a-zA-Z_0-9]+),declaration,.*(,[01])/\1\2/g'); do
  func=$(echo $func_entry | sed -r 's/(.*),[01]/\1/')
  static=$(echo $func_entry | sed -r 's/.*([01])/\1/')
  found=1
  while read lib; do
    if [[ "$lib" =~ ^/.*  ]]; then
      if nm -D $lib | grep -q $func; then
        found=1
        functions["$func"]="$lib,$static"
        break
      fi
    fi
  done <<< $(echo "$slibs")
  if [ $found -eq 0 ]; then
    >&2 echo "Couldn't find symbol entry for function $func"
    exit 1
  fi
done

wpa -dump-callgraph -ander $bitcode_file > /dev/null

if [ $? -ne 0 ]; then
  echo "SVF produced an non-zero exit code"
  exit 1
fi

for edge in $(python3 $dir/extract-edgelist.py callgraph_final.dot); do
  snode=$(echo $edge | cut -f1 -d ':')
  tnode=$(echo $edge | cut -f2 -d ':')

  snode_info="${functions[$snode]}"
  tnode_info="${functions[$tnode]}"

  if [ -z $tnode_info ]; then
    # The target is an intrinsic function; so we omit it.
    continue
  fi

  lib_snode=$(echo "$snode_info" | cut -f1 -d ',')
  static_snode=$(echo "$snode_info" | cut -f2 -d ',')

  lib_tnode=$(echo "$tnode_info" | cut -f1 -d ',')
  static_tnode=$(echo "$tnode_info" | cut -f2 -d ',')

  if [ $static_snode -eq 0 ]; then
    static_snode="public"
  else
    static_snode="static"
  fi

  if [ $static_tnode -eq 0 ]; then
    static_tnode="public"
  else
    static_tnode="static"
  fi

  echo "$static_snode:$lib_snode:$snode $static_tnode:$lib_tnode:$tnode"
done
