// Copyright (c) 2018-2020 FASTEN.
//
// This file is part of FASTEN
// (see https://www.fasten-project.eu/).
//
// Licensed to the Apache Software Foundation (ASF) under one
// or more contributor license agreements.  See the NOTICE file
// distributed with this work for additional information
// regarding copyright ownership.  The ASF licenses this file
// to you under the Apache License, Version 2.0 (the
// "License"); you may not use this file except in compliance
// with the License.  You may obtain a copy of the License at
//
//   http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing,
// software distributed under the License is distributed on an
// "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
// KIND, either express or implied.  See the License for the
// specific language governing permissions and limitations
// under the License.
//
#include <iostream>

#include <llvm/Pass.h>
#include <llvm/IR/DebugInfoMetadata.h>
#include <llvm/IR/Function.h>
#include <llvm/IR/Module.h>
#include <llvm/Support/raw_ostream.h>


using namespace llvm;


namespace llvm {


struct FunctionInfoPass : public ModulePass {
  static char ID;
  FunctionInfoPass():
    ModulePass(ID) {}

  bool runOnModule(Module &M) override {
    errs() << "function_name,function_type,directory,filename,static\n";
    for (Function &F : M.getFunctionList()) {
      dumpFunctionInfo(F);
    }
    return false;
  }

  void dumpFunctionInfo(Function &F) {
    if (F.isIntrinsic()) {
      return;
    }
    std::string info = F.getName().str();
    if (F.isDeclaration()) {
      info += ",declaration,-";
    }
    DISubprogram *subprog = F.getSubprogram();
    if (subprog) {
      info += ",definition," + subprog->getDirectory().str() +
        "/" + subprog->getFilename().str();
    }
    bool internal = F.hasInternalLinkage() || F.hasPrivateLinkage();
    errs() << info << "," << internal << "\n";
  }
};


} // namespace llvm


char FunctionInfoPass::ID = 0;
static RegisterPass<FunctionInfoPass> X(
    "FunctionInfoPass",
    "Pass that dumps function information",
    false /* Only looks at CFG */,
    false /* Analysis Pass */);
