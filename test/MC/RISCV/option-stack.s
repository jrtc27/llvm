# RUN: llvm-mc -triple riscv32 -show-encoding < %s \
# RUN: | FileCheck -check-prefixes=CHECK,CHECK-ALIAS %s
# RUN: llvm-mc -triple riscv32 -show-encoding \
# RUN: -riscv-no-aliases <%s | FileCheck -check-prefixes=CHECK,CHECK-INST %s
# RUN: llvm-mc -triple riscv32 -filetype=obj < %s \
# RUN: | llvm-objdump  -triple riscv32 -mattr=+c -d - \
# RUN: | FileCheck -check-prefixes=CHECK-BYTES,CHECK-ALIAS %s
# RUN: llvm-mc -triple riscv32 -filetype=obj < %s \
# RUN: | llvm-objdump  -triple riscv32 -mattr=+c -d -riscv-no-aliases - \
# RUN: | FileCheck -check-prefixes=CHECK-BYTES,CHECK-INST %s

# RUN: llvm-mc -triple riscv64 -show-encoding < %s \
# RUN: | FileCheck -check-prefixes=CHECK-ALIAS %s
# RUN: llvm-mc -triple riscv64 -show-encoding \
# RUN: -riscv-no-aliases <%s | FileCheck -check-prefixes=CHECK-INST %s
# RUN: llvm-mc -triple riscv64 -filetype=obj < %s \
# RUN: | llvm-objdump  -triple riscv64 -mattr=+c -d - \
# RUN: | FileCheck -check-prefixes=CHECK-BYTES,CHECK-ALIAS %s
# RUN: llvm-mc -triple riscv64 -filetype=obj < %s \
# RUN: | llvm-objdump  -triple riscv64 -mattr=+c -d -riscv-no-aliases - \
# RUN: | FileCheck -check-prefixes=CHECK-BYTES,CHECK-INST %s

# CHECK-BYTES: 13 85 05 00
# CHECK-ALIAS: mv a0, a1
# CHECK-INST: addi a0, a1, 0
# CHECK: # encoding:  [0x13,0x85,0x05,0x00]
addi a0, a1, 0

# CHECK: .option push
.option push
# CHECK: .option rvc
.option rvc
# CHECK-BYTES: 2e 85
# CHECK-ALIAS: add a0, zero, a1
# CHECK-INST: c.mv a0, a1
# CHECK: # encoding:  [0x2e,0x85]
addi a0, a1, 0

# CHECK: .option pop
.option pop
# CHECK-BYTES: 13 85 05 00
# CHECK-ALIAS: mv a0, a1
# CHECK-INST: addi a0, a1, 0
# CHECK: # encoding:  [0x13,0x85,0x05,0x00]
addi a0, a1, 0

# CHECK: .option rvc
.option rvc
# CHECK-BYTES: 2e 85
# CHECK-ALIAS: add a0, zero, a1
# CHECK-INST: c.mv a0, a1
# CHECK: # encoding:  [0x2e,0x85]
addi a0, a1, 0

# CHECK: .option push
.option push
# CHECK: .option norvc
.option norvc
# CHECK-BYTES: 13 85 05 00
# CHECK-ALIAS: mv a0, a1
# CHECK-INST: addi a0, a1, 0
# CHECK: # encoding:  [0x13,0x85,0x05,0x00]
addi a0, a1, 0

# CHECK: .option pop
.option pop
# CHECK-BYTES: 2e 85
# CHECK-ALIAS: add a0, zero, a1
# CHECK-INST: c.mv a0, a1
# CHECK: # encoding:  [0x2e,0x85]
addi a0, a1, 0
