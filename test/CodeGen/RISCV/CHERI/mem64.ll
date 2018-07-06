; RUN: llc -mtriple=riscv64 -mattr=+cheri -verify-machineinstrs < %s \
; RUN:   | FileCheck %s --check-prefixes=RV,RV64

@G64 = external dso_local global i64 addrspace(200)*

define i64 @ld_global_cap() nounwind {
; RV-LABEL: ld_global_cap:
; RV:       # %bb.0:
; RV-NEXT:    lui a0, %hi(G64)
; RV-NEXT:    addi a0, a0, %lo(G64)
; RV-NEXT:    lc.ddc ca0, a0
; RV-NEXT:    ld.cap a0, ca0
; RV-NEXT:    ret
  %1 = load i64 addrspace(200)*, i64 addrspace(200)** @G64
  %2 = load i64, i64 addrspace(200)* %1
  ret i64 %2
}

define void @sd_global_cap() nounwind {
; RV-LABEL: sd_global_cap:
; RV:       # %bb.0:
; RV-NEXT:    lui a0, %hi(G64)
; RV-NEXT:    addi a0, a0, %lo(G64)
; RV-NEXT:    lc.ddc ca0, a0
; RV-NEXT:    sd.cap zero, ca0
; RV-NEXT:    ret
  %1 = load i64 addrspace(200)*, i64 addrspace(200)** @G64
  store i64 0, i64 addrspace(200)* %1
  ret void
}
