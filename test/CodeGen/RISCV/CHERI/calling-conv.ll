; RUN: llc -mtriple=riscv32 -mattr=+cheri -verify-machineinstrs < %s \
; RUN:   | FileCheck %s
; RUN: llc -mtriple=riscv64 -mattr=+cheri -verify-machineinstrs < %s \
; RUN:   | FileCheck %s

define i32 @deref_pi32(i32 addrspace(200)* %p) nounwind {
; CHECK-LABEL: deref_pi32
; CHECK:       # %bb.0
; CHECK-NEXT:    lw.cap a0, ca0
; CHECK-NEXT:    ret
  %1 = load i32, i32 addrspace(200)* %p
  ret i32 %1
}
