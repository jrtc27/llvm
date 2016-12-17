// RUN: clang -cc1 -triple cheri-unknown-bsd -cheri-linker -target-abi purecap -O2 -S -o - %s | FileCheck %s
// ModuleID = 'ocsp_cl.i'
// GVN was seen to unconditionally get the size of the underlying type for a
// pointer when it was unsized.
// This needs to be as C source rather than LLVM IR, since the assertion that
// was hit with this test case is reached when generating the IR itself.
typedef struct { void *qualifiers; } POLICYINFO;
struct SOMETHING_ELSE *fn2();
POLICYINFO *a;
POLICYINFO *b;
typedef struct stack_st stack_st;
void sk_push(stack_st *);
// CHECK-LABEL: fn1:
void fn1() {
  // Call fn2
  // CHECK: ld	[[FN2:\$[0-9]+]], %call16(fn2)($gp)
  // CHECK: cgetpccsetoffset	$c12, [[FN2]]
  // CHECK: cjalr	$c12, $c17
  // Load address of a
  // CHECK: ld	[[A:\$[0-9]+]], %got_disp(a)($gp)
  // CHECK: cfromptr	[[A_CAP:\$c[0-9]+]], $c0, [[A]]
  // Store in a
  // CHECK: csc	$c3, $zero, 0([[A_CAP]])
  a = (POLICYINFO *__capability)fn2();
  // Load address of b
  // CHECK: ld	[[B:\$[0-9]+]], %got_disp(b)($gp)
  // CHECK: cfromptr	[[B_CAP:\$c[0-9]+]], $c0, [[B]]
  // Store in b
  // CHECK: csc	$c3, $zero, 0([[B_CAP]])
  b = a;
  // Load qualifiers
  // CHECK: clc	[[QUAL_CAP:\$c[0-9]+]], $zero, 0($c3)
  // Create NULL capability
  // CHECK: cfromptr	[[NULL_CAP:\$c[0-9]+]], $c0, $zero
  // Check if qualifiers is NULL
  // CHECK: ceq	[[CMP:\$[0-9]+]], [[QUAL_CAP]], [[NULL_CAP]]
  // CHECK: bnez	[[CMP]], .LBB0_2
  if (b->qualifiers)
    // Store above NULL capability in qualifiers
    // CHECK: csc	[[NULL_CAP]], $zero, 0($c3)
    b->qualifiers = 0;
  // CHECK-LABEL: .LBB0_2:
  // Call sk_push
  // CHECK: ld	[[SK_PUSH:\$[0-9]+]], %call16(sk_push)($gp)
  // CHECK: cgetpccsetoffset	$c12, [[SK_PUSH]]
  // CHECK: cjalr	$c12, $c17
  sk_push((stack_st *)b->qualifiers);
}
