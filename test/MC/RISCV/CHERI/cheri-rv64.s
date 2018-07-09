# RUN: llvm-mc %s -triple=riscv64 -mattr=+cheri -show-encoding \
# RUN:     | FileCheck -check-prefixes=CHECK,CHECK-INST %s
# RUN: llvm-mc -filetype=obj -triple riscv64 -mattr=+cheri < %s \
# RUN:     | llvm-objdump -mattr=+cheri -riscv-no-aliases -d - \
# RUN:     | FileCheck -check-prefix=CHECK-INST %s

# CHECK-INST: ld.ddc ra, sp
# CHECK: encoding: [0xdb,0x00,0x31,0x00]
ld.ddc x1, x2
# CHECK-INST: lwu.ddc ra, sp
# CHECK: encoding: [0xdb,0x00,0x61,0x00]
lwu.ddc x1, x2

# CHECK-INST: sd.ddc ra, sp
# CHECK: encoding: [0xdb,0x00,0xb1,0x00]
sd.ddc x1, x2

# CHECK-INST: ld.cap ra, csp
# CHECK: encoding: [0xdb,0x00,0x31,0x01]
ld.cap x1, c2
# CHECK-INST: lwu.cap ra, csp
# CHECK: encoding: [0xdb,0x00,0x61,0x01]
lwu.cap x1, c2

# CHECK-INST: sd.cap ra, csp
# CHECK: encoding: [0xdb,0x00,0xb1,0x01]
sd.cap x1, c2
