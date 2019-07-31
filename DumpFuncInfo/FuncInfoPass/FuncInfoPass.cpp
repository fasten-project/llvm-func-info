#include <iostream>

#include "llvm/Pass.h"
#include "llvm/IR/DebugInfoMetadata.h"
#include "llvm/IR/Instructions.h"
#include "llvm/IR/Function.h"
#include "llvm/Support/raw_ostream.h"


using namespace llvm;


namespace {
  struct FuncInfoPass : public FunctionPass {
    static char ID;
    FuncInfoPass():
      FunctionPass(ID) {}

    bool runOnFunction(Function &F) override {
      std::string info = F.getName().str();
      DISubprogram *subprog = F.getSubprogram();
      if (subprog) {
        info += "," + subprog->getFilename().str();
      }
      errs() << info << "\n";
      return false;
    }
  };
}


char FuncInfoPass::ID = 0;
static RegisterPass<FuncInfoPass> X(
    "FuncInfoPass",
    "Pass that dumps function information defined in a bitcode file",
    false /* Only looks at CFG */,
    false /* Analysis Pass */);
