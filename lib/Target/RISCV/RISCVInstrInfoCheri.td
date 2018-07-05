//===-- RISCVInstrInfoCheri.td - Cheri RISCV instructions -*- tblgen-*-----===//
//
//                     The LLVM Compiler Infrastructure
//
// This file is distributed under the University of Illinois Open Source
// License. See LICENSE.TXT for details.
//
//===----------------------------------------------------------------------===//

include "RISCVInstrFormatsCheri.td"

//===----------------------------------------------------------------------===//
// Capability-Inspection Instructions
//===----------------------------------------------------------------------===//

def CGetPerm   : Cheri_rc<0x7f, 0x0, "cgetperm">;
def CGetType   : Cheri_rc<0x7f, 0x1, "cgettype">;
def CGetBase   : Cheri_rc<0x7f, 0x2, "cgetbase">;
def CGetLen    : Cheri_rc<0x7f, 0x3, "cgetlen">;
def CGetTag    : Cheri_rc<0x7f, 0x4, "cgettag">;
def CGetSealed : Cheri_rc<0x7f, 0x5, "cgetsealed">;
def CGetOffset : Cheri_rc<0x7f, 0x6, "cgetoffset">;
def CGetAddr   : Cheri_rc<0x7f, 0xf, "cgetaddr">;

//===----------------------------------------------------------------------===//
// Capability-Modification Instructions
//===----------------------------------------------------------------------===//

def CSeal           : Cheri_ccc<0xb, "cseal">;
def CUnseal         : Cheri_ccc<0xc, "cunseal">;
def CAndPerm        : Cheri_ccr<0xd, "candperm">;
def CSetOffset      : Cheri_ccr<0xf, "csetoffset">;
def CIncOffset      : Cheri_ccr<0x11, "cincoffset">;
def CIncOffsetImm   : Cheri_cci<0x1, "cincoffset", 1>;
def CSetBounds      : Cheri_ccr<0x8, "csetbounds">;
def CSetBoundsExact : Cheri_ccr<0x9, "csetboundsexact">;
def CSetBoundsImm   : Cheri_cci<0x2, "csetbounds", 0>;
// Currently collides with Clear
//def CClearTag       : Cheri_cc<0x7f, 0xb, "ccleartag">;
def CBuildCap       : Cheri_ccc<0x1d, "cbuildcap">;
def CCopyType       : Cheri_ccc<0x1e, "ccopytype">;
def CCSeal          : Cheri_ccc<0x1f, "ccseal">;

def : InstAlias<"cincoffsetimm $cd, $cb, $imm",
                (CIncOffsetImm GPCR:$cd, GPCR:$cb, simm12:$imm)>;
def : InstAlias<"csetboundsimm $cd, $cb, $imm",
                (CSetBoundsImm GPCR:$cd, GPCR:$cb, uimm12:$imm)>;

//===----------------------------------------------------------------------===//
// Pointer-Arithmetic Instructions
//===----------------------------------------------------------------------===//

def CToPtr      : Cheri_rcc<0x12, "ctoptr">;
def CFromPtr    : Cheri_ccr<0x13, "cfromptr">;
def CMove       : Cheri_cc<0x7f, 0xa, "cmove">;
def CSpecialRW  : Cheri_ccs<0x1, "cspecialrw">;

//===----------------------------------------------------------------------===//
// Control-Flow Instructions
//===----------------------------------------------------------------------===//

let isCall = 1, hasSideEffects = 0, mayLoad = 0, mayStore = 0 in
def CJALR : RVInstCheriRR<0x7f, 0xc, 0, OPC_CHERI, (outs GPCR:$rd),
                          (ins GPCR:$rs1), "cjalr", "$rd, $rs1">;

let isCall = 1, hasSideEffects = 0, mayLoad = 0, mayStore = 0 in
def CCall : RVInstCheriCCall<0x7e, 0, OPC_CHERI, (outs),
                             (ins GPCR:$rs1, GPCR:$rs2, uimm5:$imm5),
                             "ccall", "$rs1, $rs2, $imm5">;

def : InstAlias<"creturn", (CCall C0, C0, 0)>;
def : InstAlias<"ccall $cs, $cb", (CCall GPCR:$cs, GPCR:$cb, 0)>;

//===----------------------------------------------------------------------===//
// Assertion Instructions
//===----------------------------------------------------------------------===//

let hasSideEffects = 1, mayLoad = 0, mayStore = 0 in
def CCheckPerm : RVInstCheriZRR<0x7f, 0x8, 0, OPC_CHERI, (outs),
                                (ins GPCR:$rs1, GPR:$rs2),
                                "ccheckperm", "$rs1, $rs2">;

let hasSideEffects = 1, mayLoad = 0, mayStore = 0 in
def CCheckType : RVInstCheriZRR<0x7f, 0x9, 0, OPC_CHERI, (outs),
                                (ins GPCR:$rs1, GPCR:$rs2),
                                "cchecktype", "$rs1, $rs2">;

def CTestSubset : Cheri_rcc<0x20, "ctestsubset">;

//===----------------------------------------------------------------------===//
// Fast Register-Clearing Instructions
//===----------------------------------------------------------------------===//

def Clear   : Cheri_clear<0x7f, 0xb, "clear">;
def FPClear : Cheri_clear<0x7f, 0x10, "fpclear">;

//===----------------------------------------------------------------------===//
// Memory-Access with Explicit Address Type Instructions
//===----------------------------------------------------------------------===//

def LBddc  : CheriLoad_explicit<0b00000, "lb.ddc",  GPR, GPR>;
def LHddc  : CheriLoad_explicit<0b00001, "lh.ddc",  GPR, GPR>;
def LWddc  : CheriLoad_explicit<0b00010, "lw.ddc",  GPR, GPR>;
def LBUddc : CheriLoad_explicit<0b00100, "lbu.ddc", GPR, GPR>;
def LHUddc : CheriLoad_explicit<0b00101, "lhu.ddc", GPR, GPR>;

let Predicates = [IsRV64] in {
def LWUddc : CheriLoad_explicit<0b00110, "lwu.ddc", GPR, GPR>;
def LDddc  : CheriLoad_explicit<0b00011, "ld.ddc",  GPR, GPR>;
}

let Predicates = [IsCheri64] in {
def LCddc_64  : CheriLoad_explicit<0b00011, "lc.ddc",  GPCR, GPR> {
  let DecoderNamespace = "CHERI";
}
}
let Predicates = [IsCheri128] in {
def LCddc_128 : CheriLoad_explicit<0b01101, "lc.ddc",  GPCR, GPR> {
  let DecoderNamespace = "CHERI";
}
}

def SBddc  : CheriStore_explicit<0b01000, "sb.ddc",  GPR, GPR>;
def SHddc  : CheriStore_explicit<0b01001, "sh.ddc",  GPR, GPR>;
def SWddc  : CheriStore_explicit<0b01010, "sw.ddc",  GPR, GPR>;

let Predicates = [IsRV64] in {
def SDddc  : CheriStore_explicit<0b01011, "sd.ddc",  GPR, GPR>;
}

let Predicates = [IsCheri64] in {
def SCddc_64  : CheriStore_explicit<0b01011, "sc.ddc",  GPCR, GPR> {
  let DecoderNamespace = "CHERI";
}
}
let Predicates = [IsCheri128] in {
def SCddc_128 : CheriStore_explicit<0b01100, "sc.ddc",  GPCR, GPR> {
  let DecoderNamespace = "CHERI";
}
}

def LBcap  : CheriLoad_explicit<0b10000, "lb.cap",  GPR, GPCR>;
def LHcap  : CheriLoad_explicit<0b10001, "lh.cap",  GPR, GPCR>;
def LWcap  : CheriLoad_explicit<0b10010, "lw.cap",  GPR, GPCR>;
def LBUcap : CheriLoad_explicit<0b10100, "lbu.cap", GPR, GPCR>;
def LHUcap : CheriLoad_explicit<0b10101, "lhu.cap", GPR, GPCR>;

let Predicates = [IsRV64] in {
def LWUcap : CheriLoad_explicit<0b10110, "lwu.cap", GPR, GPCR>;
def LDcap  : CheriLoad_explicit<0b10011, "ld.cap",  GPR, GPCR>;
}

let Predicates = [IsCheri64] in {
def LCcap_64  : CheriLoad_explicit<0b10011, "lc.cap",  GPCR, GPCR> {
  let DecoderNamespace = "CHERI";
}
}
let Predicates = [IsCheri128] in {
def LCcap_128 : CheriLoad_explicit<0b11101, "lc.cap",  GPCR, GPCR> {
  let DecoderNamespace = "CHERI";
}
}

def SBcap  : CheriStore_explicit<0b11000, "sb.cap",  GPR, GPCR>;
def SHcap  : CheriStore_explicit<0b11001, "sh.cap",  GPR, GPCR>;
def SWcap  : CheriStore_explicit<0b11010, "sw.cap",  GPR, GPCR>;

let Predicates = [IsRV64] in {
def SDcap  : CheriStore_explicit<0b11011, "sd.cap",  GPR, GPCR>;
}

let Predicates = [IsCheri64] in {
def SCcap_64  : CheriStore_explicit<0b11011, "sc.cap",  GPCR, GPCR> {
  let DecoderNamespace = "CHERI";
}
}
let Predicates = [IsCheri128] in {
def SCcap_128 : CheriStore_explicit<0b11100, "sc.cap",  GPCR, GPCR> {
  let DecoderNamespace = "CHERI";
}
}

//===----------------------------------------------------------------------===//
// Pseudo-instructions and codegen patterns
//===----------------------------------------------------------------------===//

multiclass CheriLdPat<PatFrag LoadOp, RVInst Inst, RegisterClass AddrTy> {
  def : Pat<(LoadOp AddrTy:$rs1), (Inst AddrTy:$rs1)>;
}

multiclass CheriStPat<PatFrag StoreOp, RVInst Inst, RegisterClass StTy,
                      RegisterClass AddrTy> {
  def : Pat<(StoreOp StTy:$rs2, AddrTy:$rs1), (Inst StTy:$rs2, AddrTy:$rs1)>;
}

/// DDC-relative loads

let hasSideEffects = 0, mayLoad = 1, mayStore = 0 in
def LCddc  : Pseudo<(outs GPCR:$rd), (ins GPR:$rs1), [],
                    "lc.ddc", "$rd, $rs1">;

defm : CheriLdPat<sextloadi8, LBddc, GPR>;
defm : CheriLdPat<extloadi8, LBddc, GPR>;
defm : CheriLdPat<sextloadi16, LHddc, GPR>;
defm : CheriLdPat<extloadi16, LHddc, GPR>;
defm : CheriLdPat<load, LWddc, GPR>, Requires<[IsRV32]>;
defm : CheriLdPat<sextloadi32, LWddc, GPR>, Requires<[IsRV64]>;
defm : CheriLdPat<extloadi32, LWddc, GPR>, Requires<[IsRV64]>;
defm : CheriLdPat<load, LDddc, GPR>, Requires<[IsRV64]>;
defm : CheriLdPat<zextloadi8, LBUddc, GPR>;
defm : CheriLdPat<zextloadi16, LHUddc, GPR>;
defm : CheriLdPat<zextloadi32, LWUddc, GPR>, Requires<[IsRV64]>;
defm : CheriLdPat<load, LCddc, GPR>;

/// DDC-relative stores

let hasSideEffects = 0, mayLoad = 0, mayStore = 1 in
def SCddc  : Pseudo<(outs), (ins GPCR:$rs1, GPR:$rs2), [],
                    "sc.ddc", "$rs1, $rs2">;

defm : CheriStPat<truncstorei8, SBddc, GPR, GPR>;
defm : CheriStPat<truncstorei16, SHddc, GPR, GPR>;
defm : CheriStPat<store, SWddc, GPR, GPR>, Requires<[IsRV32]>;
defm : CheriStPat<truncstorei32, SWddc, GPR, GPR>, Requires<[IsRV64]>;
defm : CheriStPat<store, SDddc, GPR, GPR>, Requires<[IsRV64]>;
defm : CheriStPat<store, SCddc, GPCR, GPR>;

/// Capability loads

let hasSideEffects = 0, mayLoad = 1, mayStore = 0 in
def LCcap  : Pseudo<(outs GPCR:$rd), (ins GPCR:$rs1), [],
                    "lc.cap", "$rd, $rs1">;

defm : CheriLdPat<sextloadi8, LBcap, GPCR>;
defm : CheriLdPat<extloadi8, LBcap, GPCR>;
defm : CheriLdPat<sextloadi16, LHcap, GPCR>;
defm : CheriLdPat<extloadi16, LHcap, GPCR>;
defm : CheriLdPat<load, LWcap, GPCR>, Requires<[IsRV32]>;
defm : CheriLdPat<sextloadi32, LWcap, GPCR>, Requires<[IsRV64]>;
defm : CheriLdPat<extloadi32, LWcap, GPCR>, Requires<[IsRV64]>;
defm : CheriLdPat<load, LDcap, GPCR>, Requires<[IsRV64]>;
defm : CheriLdPat<zextloadi8, LBUcap, GPCR>;
defm : CheriLdPat<zextloadi16, LHUcap, GPCR>;
defm : CheriLdPat<zextloadi32, LWUcap, GPCR>, Requires<[IsRV64]>;
defm : CheriLdPat<load, LCcap, GPCR>;

/// Capability stores

let hasSideEffects = 0, mayLoad = 0, mayStore = 1 in
def SCcap  : Pseudo<(outs), (ins GPCR:$rs1, GPCR:$rs2), [],
                    "sc.cap", "$rs1, $rs2">;

defm : CheriStPat<truncstorei8, SBcap, GPR, GPCR>;
defm : CheriStPat<truncstorei16, SHcap, GPR, GPCR>;
defm : CheriStPat<store, SWcap, GPR, GPCR>, Requires<[IsRV32]>;
defm : CheriStPat<truncstorei32, SWcap, GPR, GPCR>, Requires<[IsRV64]>;
defm : CheriStPat<store, SDcap, GPR, GPCR>, Requires<[IsRV64]>;
defm : CheriStPat<store, SCcap, GPCR, GPCR>;
