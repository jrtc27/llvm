; NOTE: Assertions have been autogenerated by utils/update_llc_test_checks.py
; Test that we use the CIncOffset with an immediate to set the offset on null
; instead of csetoffset which doesn't have an immediate version

; Run opt multiple times to simulate the llc pipeline:
; everything should be changed to incoffset instead of setoffset
; RUN: %cheri_opt -S -cheri-fold-intrisics -cheri-expand-intrinsics %s -o - | %cheri_opt -S -cheri-fold-intrisics - -o - | %cheri_opt -S -O3 - -o - | FileCheck %s -check-prefix IR -enable-var-scope
; RUN: %cheri_llc -O3 %s -filetype=asm -o - | FileCheck %s

declare i8 addrspace(200)* @llvm.cheri.cap.address.set(i8 addrspace(200)*, i64) #1
declare i8 addrspace(200)* @llvm.cheri.cap.offset.set(i8 addrspace(200)*, i64) #1
declare i8 addrspace(200)* @llvm.cheri.cap.offset.increment(i8 addrspace(200)*, i64) #1

define i8 addrspace(200)* @null_set_addr_const() {
; IR-LABEL: @null_set_addr_const(
; IR-NEXT:    [[TMP:%.*]] = tail call i8 addrspace(200)* @llvm.cheri.cap.offset.increment(i8 addrspace(200)* null, i64 42)
; IR-NEXT:    ret i8 addrspace(200)* [[TMP]]
; CHECK-LABEL: null_set_addr_const:
; CHECK:       # %bb.0:
; CHECK-NEXT:    cgetnull $c1
; CHECK-NEXT:    jr $ra
; CHECK-NEXT:    cincoffset $c3, $c1, 42
  %ret = call i8 addrspace(200)* @llvm.cheri.cap.address.set(i8 addrspace(200)* null, i64 42)
  ret i8 addrspace(200)* %ret
}

define i8 addrspace(200)* @null_set_addr_dynamic(i64 %arg) {
; IR-LABEL: @null_set_addr_dynamic(
; IR-NEXT:    [[TMP:%.*]] = tail call i8 addrspace(200)* @llvm.cheri.cap.offset.increment(i8 addrspace(200)* null, i64 %arg)
; IR-NEXT:    ret i8 addrspace(200)* [[TMP]]
; CHECK-LABEL: null_set_addr_dynamic:
; CHECK:       # %bb.0:
; CHECK-NEXT:    cgetnull $c1
; CHECK-NEXT:    jr $ra
; CHECK-NEXT:    cincoffset $c3, $c1, $4
  %ret = call i8 addrspace(200)* @llvm.cheri.cap.address.set(i8 addrspace(200)* null, i64 %arg)
  ret i8 addrspace(200)* %ret
}

define i8 addrspace(200)* @null_set_offset_const() {
; IR-LABEL: @null_set_offset_const(
; IR-NEXT:    [[RET:%.*]] = tail call i8 addrspace(200)* @llvm.cheri.cap.offset.increment(i8 addrspace(200)* null, i64 42)
; IR-NEXT:    ret i8 addrspace(200)* [[RET]]
; CHECK-LABEL: null_set_offset_const:
; CHECK:       # %bb.0:
; CHECK-NEXT:    cgetnull $c1
; CHECK-NEXT:    jr $ra
; CHECK-NEXT:    cincoffset $c3, $c1, 42
  %ret = call i8 addrspace(200)* @llvm.cheri.cap.offset.set(i8 addrspace(200)* null, i64 42)
  ret i8 addrspace(200)* %ret
}

define i8 addrspace(200)* @null_set_offset_dynamic(i64 %arg) {
; IR-LABEL: @null_set_offset_dynamic(
; IR-NEXT:    [[RET:%.*]] = tail call i8 addrspace(200)* @llvm.cheri.cap.offset.increment(i8 addrspace(200)* null, i64 %arg)
; IR-NEXT:    ret i8 addrspace(200)* [[RET]]
; CHECK-LABEL: null_set_offset_dynamic:
; CHECK:       # %bb.0:
; CHECK-NEXT:    cgetnull $c1
; CHECK-NEXT:    jr $ra
; CHECK-NEXT:    cincoffset $c3, $c1, $4
  %ret = call i8 addrspace(200)* @llvm.cheri.cap.offset.set(i8 addrspace(200)* null, i64 %arg)
  ret i8 addrspace(200)* %ret
}

define i8 addrspace(200)* @null_inc_offset_const() {
; IR-LABEL: @null_inc_offset_const(
; IR-NEXT:    [[RET:%.*]] = tail call i8 addrspace(200)* @llvm.cheri.cap.offset.increment(i8 addrspace(200)* null, i64 42)
; IR-NEXT:    ret i8 addrspace(200)* [[RET]]
;
; CHECK-LABEL: null_inc_offset_const:
; CHECK:       # %bb.0:
; CHECK-NEXT:    cgetnull $c1
; CHECK-NEXT:    jr $ra
; CHECK-NEXT:    cincoffset $c3, $c1, 42
  %ret = call i8 addrspace(200)* @llvm.cheri.cap.offset.increment(i8 addrspace(200)* null, i64 42)
  ret i8 addrspace(200)* %ret
}

define i8 addrspace(200)* @null_inc_offset_dynamic(i64 %arg) {
; IR-LABEL: @null_inc_offset_dynamic(
; IR-NEXT:    [[RET:%.*]] = tail call i8 addrspace(200)* @llvm.cheri.cap.offset.increment(i8 addrspace(200)* null, i64 %arg)
; IR-NEXT:    ret i8 addrspace(200)* [[RET]]
;
; CHECK-LABEL: null_inc_offset_dynamic:
; CHECK:       # %bb.0:
; CHECK-NEXT:    cgetnull $c1
; CHECK-NEXT:    jr $ra
; CHECK-NEXT:    cincoffset $c3, $c1, $4
  %ret = call i8 addrspace(200)* @llvm.cheri.cap.offset.increment(i8 addrspace(200)* null, i64 %arg)
  ret i8 addrspace(200)* %ret
}

attributes #0 = { nounwind }
attributes #1 = { nounwind readnone }
