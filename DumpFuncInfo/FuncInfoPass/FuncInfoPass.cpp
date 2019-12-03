#include <iostream>

#include "llvm/Pass.h"
#include "llvm/IR/DebugInfoMetadata.h"
#include "llvm/IR/Function.h"
#include "llvm/IR/Module.h"
#include "llvm/Support/raw_ostream.h"


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
