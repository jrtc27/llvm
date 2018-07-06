; RUN: llc -mtriple=riscv32 -mattr=+cheri -verify-machineinstrs < %s \
; RUN:   | FileCheck %s --check-prefixes=RV,RV32
; RUN: llc -mtriple=riscv64 -mattr=+cheri -verify-machineinstrs < %s \
; RUN:   | FileCheck %s --check-prefixes=RV,RV64

@G8 = external dso_local global i8 addrspace(200)*
@G16 = external dso_local global i16 addrspace(200)*
@G32 = external dso_local global i32 addrspace(200)*

define signext i8 @lb_global_cap() nounwind {
; RV-LABEL: lb_global_cap:
; RV:       # %bb.0:
; RV-NEXT:    lui a0, %hi(G8)
; RV-NEXT:    addi a0, a0, %lo(G8)
; RV-NEXT:    lc.ddc ca0, a0
; RV-NEXT:    lb.cap a0, ca0
; RV-NEXT:    ret
  %1 = load i8 addrspace(200)*, i8 addrspace(200)** @G8
  %2 = load i8, i8 addrspace(200)* %1
  ret i8 %2
}

define signext i16 @lh_global_cap() nounwind {
; RV-LABEL: lh_global_cap:
; RV:       # %bb.0:
; RV-NEXT:    lui a0, %hi(G16)
; RV-NEXT:    addi a0, a0, %lo(G16)
; RV-NEXT:    lc.ddc ca0, a0
; RV-NEXT:    lh.cap a0, ca0
; RV-NEXT:    ret
  %1 = load i16 addrspace(200)*, i16 addrspace(200)** @G16
  %2 = load i16, i16 addrspace(200)* %1
  ret i16 %2
}

define signext i32 @lw_global_cap() nounwind {
; RV-LABEL: lw_global_cap:
; RV:       # %bb.0:
; RV-NEXT:    lui a0, %hi(G32)
; RV-NEXT:    addi a0, a0, %lo(G32)
; RV-NEXT:    lc.ddc ca0, a0
; RV-NEXT:    lw.cap a0, ca0
; RV-NEXT:    ret
  %1 = load i32 addrspace(200)*, i32 addrspace(200)** @G32
  %2 = load i32, i32 addrspace(200)* %1
  ret i32 %2
}

define zeroext i8 @lbu_global_cap() nounwind {
; RV-LABEL: lbu_global_cap:
; RV:       # %bb.0:
; RV-NEXT:    lui a0, %hi(G8)
; RV-NEXT:    addi a0, a0, %lo(G8)
; RV-NEXT:    lc.ddc ca0, a0
; RV-NEXT:    lbu.cap a0, ca0
; RV-NEXT:    ret
  %1 = load i8 addrspace(200)*, i8 addrspace(200)** @G8
  %2 = load i8, i8 addrspace(200)* %1
  ret i8 %2
}

define zeroext i16 @lhu_global_cap() nounwind {
; RV-LABEL: lhu_global_cap:
; RV:       # %bb.0:
; RV-NEXT:    lui a0, %hi(G16)
; RV-NEXT:    addi a0, a0, %lo(G16)
; RV-NEXT:    lc.ddc ca0, a0
; RV-NEXT:    lhu.cap a0, ca0
; RV-NEXT:    ret
  %1 = load i16 addrspace(200)*, i16 addrspace(200)** @G16
  %2 = load i16, i16 addrspace(200)* %1
  ret i16 %2
}

define zeroext i32 @lwu_global_cap() nounwind {
; RV-LABEL: lwu_global_cap:
; RV:       # %bb.0:
; RV-NEXT:    lui a0, %hi(G32)
; RV-NEXT:    addi a0, a0, %lo(G32)
; RV-NEXT:    lc.ddc ca0, a0
; RV32-NEXT:  lw.cap a0, ca0
; RV64-NEXT:  lwu.cap a0, ca0
; RV-NEXT:    ret
  %1 = load i32 addrspace(200)*, i32 addrspace(200)** @G32
  %2 = load i32, i32 addrspace(200)* %1
  ret i32 %2
}

define void @sb_global_cap() nounwind {
; RV-LABEL: sb_global_cap:
; RV:       # %bb.0:
; RV-NEXT:    lui a0, %hi(G8)
; RV-NEXT:    addi a0, a0, %lo(G8)
; RV-NEXT:    lc.ddc ca0, a0
; RV-NEXT:    sb.cap zero, ca0
; RV-NEXT:    ret
  %1 = load i8 addrspace(200)*, i8 addrspace(200)** @G8
  store i8 0, i8 addrspace(200)* %1
  ret void
}

define void @sh_global_cap() nounwind {
; RV-LABEL: sh_global_cap:
; RV:       # %bb.0:
; RV-NEXT:    lui a0, %hi(G16)
; RV-NEXT:    addi a0, a0, %lo(G16)
; RV-NEXT:    lc.ddc ca0, a0
; RV-NEXT:    sh.cap zero, ca0
; RV-NEXT:    ret
  %1 = load i16 addrspace(200)*, i16 addrspace(200)** @G16
  store i16 0, i16 addrspace(200)* %1
  ret void
}

define void @sw_global_cap() nounwind {
; RV-LABEL: sw_global_cap:
; RV:       # %bb.0:
; RV-NEXT:    lui a0, %hi(G32)
; RV-NEXT:    addi a0, a0, %lo(G32)
; RV-NEXT:    lc.ddc ca0, a0
; RV-NEXT:    sw.cap zero, ca0
; RV-NEXT:    ret
  %1 = load i32 addrspace(200)*, i32 addrspace(200)** @G32
  store i32 0, i32 addrspace(200)* %1
  ret void
}
