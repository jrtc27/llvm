//===-- RISCVTargetMachine.cpp - Define TargetMachine for RISCV -----------===//
//
//                     The LLVM Compiler Infrastructure
//
// This file is distributed under the University of Illinois Open Source
// License. See LICENSE.TXT for details.
//
//===----------------------------------------------------------------------===//
//
// Implements the info about RISCV target spec.
//
//===----------------------------------------------------------------------===//

#include "RISCV.h"
#include "RISCVTargetMachine.h"
#include "RISCVTargetObjectFile.h"
#include "llvm/ADT/STLExtras.h"
#include "llvm/CodeGen/Passes.h"
#include "llvm/CodeGen/TargetLoweringObjectFileImpl.h"
#include "llvm/CodeGen/TargetPassConfig.h"
#include "llvm/IR/LegacyPassManager.h"
#include "llvm/Support/FormattedStream.h"
#include "llvm/Support/TargetRegistry.h"
#include "llvm/Target/TargetOptions.h"
using namespace llvm;

extern "C" void LLVMInitializeRISCVTarget() {
  RegisterTargetMachine<RISCVTargetMachine> X(getTheRISCV32Target());
  RegisterTargetMachine<RISCVTargetMachine> Y(getTheRISCV64Target());
  RegisterTargetMachine<RISCVTargetMachine> C32(getTheRISCV32CheriTarget());
  RegisterTargetMachine<RISCVTargetMachine> C64(getTheRISCV64CheriTarget());
}

static std::string computeDataLayout(const Triple &TT,
                                     const TargetOptions &Options) {
  assert((TT.isArch32Bit() || TT.isArch64Bit()) &&
         "only RV32 and RV64 are currently supported");

  StringRef IntegerTypes;
  if (TT.isArch64Bit())
    IntegerTypes = "-p:64:64-i64:64-i128:128-n64";
  else
    IntegerTypes = "-p:32:32-i64:64-n32";

  Triple::ArchType Arch = Triple(TT).getArch();
  StringRef CapTypes = "";
  StringRef PurecapOptions = "";
  if (Arch == Triple::riscv32_cheri || Arch == Triple::riscv64_cheri) {
    if (TT.isArch64Bit())
      CapTypes = "-pf200:128:128:128:64";
    else
      CapTypes = "-pf200:64:64:64:32";

    StringRef ABI = Options.MCOptions.getABIName();
    if (ABI == "purecap")
      PurecapOptions = MCTargetOptions::cheriUsesCapabilityTable()
                           ? "-A200-P200-G200"
                           : "-A200-P200";
  }

  return ("e-m:e" + CapTypes + IntegerTypes + PurecapOptions + "-S128").str();
}

static Reloc::Model getEffectiveRelocModel(const Triple &TT,
                                           Optional<Reloc::Model> RM) {
  if (!RM.hasValue())
    return Reloc::Static;
  return *RM;
}

static CodeModel::Model getEffectiveCodeModel(Optional<CodeModel::Model> CM) {
  if (CM)
    return *CM;
  return CodeModel::Small;
}

RISCVTargetMachine::RISCVTargetMachine(const Target &T, const Triple &TT,
                                       StringRef CPU, StringRef FS,
                                       const TargetOptions &Options,
                                       Optional<Reloc::Model> RM,
                                       Optional<CodeModel::Model> CM,
                                       CodeGenOpt::Level OL, bool JIT)
    : LLVMTargetMachine(T, computeDataLayout(TT, Options), TT, CPU, FS, Options,
                        getEffectiveRelocModel(TT, RM),
                        getEffectiveCodeModel(CM), OL),
      TLOF(make_unique<RISCVELFTargetObjectFile>()),
      Subtarget(TT, CPU, FS, *this) {
  initAsmInfo();
}

namespace {
class RISCVPassConfig : public TargetPassConfig {
public:
  RISCVPassConfig(RISCVTargetMachine &TM, PassManagerBase &PM)
      : TargetPassConfig(TM, PM) {}

  RISCVTargetMachine &getRISCVTargetMachine() const {
    return getTM<RISCVTargetMachine>();
  }

  void addIRPasses() override;
  bool addInstSelector() override;
  void addPreEmitPass() override;
};
}

TargetPassConfig *RISCVTargetMachine::createPassConfig(PassManagerBase &PM) {
  return new RISCVPassConfig(*this, PM);
}

void RISCVPassConfig::addIRPasses() {
  addPass(createAtomicExpandPass());
  TargetPassConfig::addIRPasses();
}

bool RISCVPassConfig::addInstSelector() {
  addPass(createRISCVISelDag(getRISCVTargetMachine()));

  return false;
}

void RISCVPassConfig::addPreEmitPass() { addPass(&BranchRelaxationPassID); }
