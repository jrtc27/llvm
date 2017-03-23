//===-------- MipsELFStreamer.cpp - ELF Object Output ---------------------===//
//
//                     The LLVM Compiler Infrastructure
//
// This file is distributed under the University of Illinois Open Source
// License. See LICENSE.TXT for details.
//
//===----------------------------------------------------------------------===//

#include "MipsELFStreamer.h"
#include "MipsFixupKinds.h"
#include "MipsMCExpr.h"
#include "MipsOptionRecord.h"
#include "MipsTargetStreamer.h"
#include "llvm/MC/MCAssembler.h"
#include "llvm/MC/MCContext.h"
#include "llvm/MC/MCInst.h"
#include "llvm/MC/MCSymbolELF.h"
#include "llvm/Support/Casting.h"
#include "llvm/Support/ELF.h"

using namespace llvm;

void MipsELFStreamer::EmitInstruction(const MCInst &Inst,
                                      const MCSubtargetInfo &STI) {
  MCELFStreamer::EmitInstruction(Inst, STI);

  MCContext &Context = getContext();
  const MCRegisterInfo *MCRegInfo = Context.getRegisterInfo();

  for (unsigned OpIndex = 0; OpIndex < Inst.getNumOperands(); ++OpIndex) {
    const MCOperand &Op = Inst.getOperand(OpIndex);

    if (!Op.isReg())
      continue;

    unsigned Reg = Op.getReg();
    RegInfoRecord->SetPhysRegUsed(Reg, MCRegInfo);
  }

  createPendingLabelRelocs();
}

void MipsELFStreamer::createPendingLabelRelocs() {
  MipsTargetELFStreamer *ELFTargetStreamer =
      static_cast<MipsTargetELFStreamer *>(getTargetStreamer());

  // FIXME: Also mark labels when in MIPS16 mode.
  if (ELFTargetStreamer->isMicroMipsEnabled()) {
    for (auto *L : Labels) {
      auto *Label = cast<MCSymbolELF>(L);
      getAssembler().registerSymbol(*Label);
      Label->setOther(ELF::STO_MIPS_MICROMIPS);
    }
  }

  Labels.clear();
}

void MipsELFStreamer::EmitLabel(MCSymbol *Symbol, SMLoc Loc) {
  MCELFStreamer::EmitLabel(Symbol);
  Labels.push_back(Symbol);
}

void MipsELFStreamer::SwitchSection(MCSection *Section,
                                    const MCExpr *Subsection) {
  MCELFStreamer::SwitchSection(Section, Subsection);
  Labels.clear();
}

void MipsELFStreamer::EmitValueImpl(const MCExpr *Value, unsigned Size,
                                    SMLoc Loc) {
  MCELFStreamer::EmitValueImpl(Value, Size, Loc);
  Labels.clear();
}

void MipsELFStreamer::EmitMemcap(const MCSymbol *Symbol, int64_t Offset, SMLoc Loc) {
  EmitMemcapImpl(Symbol, Offset, Loc);
}

void MipsELFStreamer::EmitMemcapImpl(const MCSymbol *Symbol, int64_t Offset, SMLoc Loc) {
  MCELFStreamer::EmitMemcapImpl(Symbol, Offset, Loc);
  MCContext &Context = getContext();

  const MCSymbolRefExpr *SRE =
    MCSymbolRefExpr::create(Symbol, MCSymbolRefExpr::VK_None, Context);

  // TODO: CHERI-128

  const MipsMCExpr *BaseExpr = MipsMCExpr::create(
      MipsMCExpr::MEK_BASE64, SRE, Context);
  const MCBinaryExpr *OffsetExpr = MCBinaryExpr::createAdd(
      MipsMCExpr::create(MipsMCExpr::MEK_OFFSET64, SRE, Context),
      MCConstantExpr::create(Offset, Context), Context);
  const MipsMCExpr *SizeExpr = MipsMCExpr::create(
      MipsMCExpr::MEK_SIZE64, SRE, Context);

  unsigned ByteAlignment = 32;
  insert(new MCAlignFragment(ByteAlignment, 0, 1, ByteAlignment));

  // Update the maximum alignment on the current section if necessary.
  MCSection *CurSec = getCurrentSectionOnly();
  if (ByteAlignment > CurSec->getAlignment())
    CurSec->setAlignment(ByteAlignment);

  MCDataFragment *DF = new MCDataFragment();
  MCFixup MemcapFixup = MCFixup::create(0, nullptr, MCFixupKind(Mips::fixup_CHERI_MEMCAP));
  DF->setContainerFixup(MemcapFixup);
  insert(DF);

  auto EmitComponent = [&](const MCExpr *Value, unsigned Kind, unsigned Size) {
    DF->getFixups().push_back(
        MCFixup::create(DF->getContents().size(), Value, MCFixupKind(Kind)));
    DF->getContents().resize(DF->getContents().size() + Size, 0);
  };

  EmitComponent(BaseExpr, Mips::fixup_CHERI_BASE64, 8);
  EmitComponent(OffsetExpr, Mips::fixup_CHERI_OFFSET64, 8);
  EmitComponent(SizeExpr, Mips::fixup_CHERI_SIZE64, 8);
  emitFill(8, 0); // TODO: Perms
}

void MipsELFStreamer::EmitMipsOptionRecords() {
  for (const auto &I : MipsOptionRecords)
    I->EmitMipsOptionRecord();
}

MCELFStreamer *llvm::createMipsELFStreamer(MCContext &Context,
                                           MCAsmBackend &MAB,
                                           raw_pwrite_stream &OS,
                                           MCCodeEmitter *Emitter,
                                           bool RelaxAll) {
  return new MipsELFStreamer(Context, MAB, OS, Emitter);
}
