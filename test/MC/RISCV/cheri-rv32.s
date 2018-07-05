# RUN: llvm-mc %s -triple=riscv32_cheri -show-encoding \
# RUN:     | FileCheck -check-prefixes=CHECK,CHECK32,CHECK-INST %s
# RUN: llvm-mc %s -triple=riscv64_cheri -show-encoding \
# RUN:     | FileCheck -check-prefixes=CHECK,CHECK64,CHECK-INST %s
# RUN: llvm-mc -filetype=obj -triple riscv32_cheri < %s \
# RUN:     | llvm-objdump -d - \
# RUN:     | FileCheck -check-prefix=CHECK-INST %s
# RUN: llvm-mc -filetype=obj -triple riscv64_cheri < %s \
# RUN:     | llvm-objdump -d - \
# RUN:     | FileCheck -check-prefix=CHECK-INST %s

# CHECK-INST: cgetperm ra, csp
# CHECK: encoding: [0xdb,0x00,0x01,0xfe]
cgetperm x1, c2
# CHECK-INST: cgettype ra, csp
# CHECK: encoding: [0xdb,0x00,0x11,0xfe]
cgettype x1, c2
# CHECK-INST: cgetbase ra, csp
# CHECK: encoding: [0xdb,0x00,0x21,0xfe]
cgetbase x1, c2
# CHECK-INST: cgetlen ra, csp
# CHECK: encoding: [0xdb,0x00,0x31,0xfe]
cgetlen x1, c2
# CHECK-INST: cgettag ra, csp
# CHECK: encoding: [0xdb,0x00,0x41,0xfe]
cgettag x1, c2
# CHECK-INST: cgetsealed ra, csp
# CHECK: encoding: [0xdb,0x00,0x51,0xfe]
cgetsealed x1, c2
# CHECK-INST: cgetoffset ra, csp
# CHECK: encoding: [0xdb,0x00,0x61,0xfe]
cgetoffset x1, c2
# CHECK-INST: cgetaddr ra, csp
# CHECK: encoding: [0xdb,0x00,0xf1,0xfe]
cgetaddr x1, c2

# CHECK-INST: cseal cra, csp, cgp
# CHECK: encoding: [0xdb,0x00,0x31,0x16]
cseal c1, c2, c3
# CHECK-INST: cunseal cra, csp, cgp
# CHECK: encoding: [0xdb,0x00,0x31,0x18]
cunseal c1, c2, c3
# CHECK-INST: candperm cra, csp, gp
# CHECK: encoding: [0xdb,0x00,0x31,0x1a]
candperm c1, c2, x3
# CHECK-INST: csetoffset cra, csp, gp
# CHECK: encoding: [0xdb,0x00,0x31,0x1e]
csetoffset c1, c2, x3
# CHECK-INST: cincoffset cra, csp, gp
# CHECK: encoding: [0xdb,0x00,0x31,0x22]
cincoffset c1, c2, x3
# CHECK-INST: cincoffsetimm cra, csp, -173
# CHECK: encoding: [0xdb,0x10,0x31,0xf5]
cincoffset c1, c2, -173
# CHECK-INST: cincoffsetimm cra, csp, -173
# CHECK: encoding: [0xdb,0x10,0x31,0xf5]
cincoffsetimm c1, c2, -173
# CHECK-INST: csetbounds cra, csp, gp
# CHECK: encoding: [0xdb,0x00,0x31,0x10]
csetbounds c1, c2, x3
# CHECK-INST: csetboundsexact cra, csp, gp
# CHECK: encoding: [0xdb,0x00,0x31,0x12]
csetboundsexact c1, c2, x3
# CHECK-INST: csetboundsimm cra, csp, 3029
# CHECK: encoding: [0xdb,0x20,0x51,0xbd]
csetbounds c1, c2, 0xbd5
# CHECK-INST: csetboundsimm cra, csp, 3029
# CHECK: encoding: [0xdb,0x20,0x51,0xbd]
csetboundsimm c1, c2, 0xbd5
# TODO: ccleartag goes here once defined
# CHECK-INST: cbuildcap cra, csp, cgp
# CHECK: encoding: [0xdb,0x00,0x31,0x3a]
cbuildcap c1, c2, c3
# CHECK-INST: ccopytype cra, csp, cgp
# CHECK: encoding: [0xdb,0x00,0x31,0x3c]
ccopytype c1, c2, c3
# CHECK-INST: ccseal cra, csp, cgp
# CHECK: encoding: [0xdb,0x00,0x31,0x3e]
ccseal c1, c2, c3

# CHECK-INST: ctoptr ra, csp, cgp
# CHECK: encoding: [0xdb,0x00,0x31,0x24]
ctoptr x1, c2, c3
# CHECK-INST: cfromptr cra, csp, gp
# CHECK: encoding: [0xdb,0x00,0x31,0x26]
cfromptr c1, c2, x3
# CHECK-INST: cmove cra, csp
# CHECK: encoding: [0xdb,0x00,0xa1,0xfe]
cmove c1, c2
# CHECK-INST: cspecialrw cra, csp, UScratchC
# CHECK: encoding: [0xdb,0x00,0x61,0x02]
cspecialrw c1, c2, UScratchC

# CHECK-INST: cjalr cra, csp
# CHECK: encoding: [0xdb,0x00,0xc1,0xfe]
cjalr c1, c2
# CHECK-INST: ccall cra, csp
# CHECK: encoding: [0xdb,0x00,0x01,0xfc]
ccall c1, c2
# CHECK-INST: ccall cra, csp, 3
# CHECK: encoding: [0xdb,0x00,0x31,0xfc]
ccall c1, c2, 3
# CHECK-INST: creturn
# CHECK: encoding: [0x5b,0x00,0x00,0xfc]
creturn

# CHECK-INST: ccheckperm cra, sp
# CHECK: encoding: [0xdb,0x00,0x81,0xfe]
ccheckperm c1, x2
# CHECK-INST: cchecktype cra, csp
# CHECK: encoding: [0xdb,0x00,0x91,0xfe]
cchecktype c1, c2
# CHECK-INST: ctestsubset ra, csp, cgp
# CHECK: encoding: [0xdb,0x00,0x31,0x40]
ctestsubset x1, c2, c3

# CHECK-INST: clear 1, 66
# CHECK: encoding: [0x5b,0x01,0xb5,0xfe]
clear 1, 0x42
# CHECK-INST: fpclear 1, 66
# CHECK: encoding: [0x5b,0x01,0x05,0xff]
fpclear 1, 0x42

# CHECK-INST: lb.ddc ra, sp
# CHECK: encoding: [0xdb,0x00,0x01,0x00]
lb.ddc x1, x2
# CHECK-INST: lh.ddc ra, sp
# CHECK: encoding: [0xdb,0x00,0x11,0x00]
lh.ddc x1, x2
# CHECK-INST: lw.ddc ra, sp
# CHECK: encoding: [0xdb,0x00,0x21,0x00]
lw.ddc x1, x2
# CHECK-INST: lbu.ddc ra, sp
# CHECK: encoding: [0xdb,0x00,0x41,0x00]
lbu.ddc x1, x2
# CHECK-INST: lhu.ddc ra, sp
# CHECK: encoding: [0xdb,0x00,0x51,0x00]
lhu.ddc x1, x2
# CHECK-INST: lc.ddc cra, sp
# CHECK32: encoding: [0xdb,0x00,0x31,0x00]
# CHECK64: encoding: [0xdb,0x00,0xd1,0x00]
lc.ddc c1, x2

# CHECK-INST: sb.ddc ra, sp
# CHECK: encoding: [0xdb,0x00,0x81,0x00]
sb.ddc x1, x2
# CHECK-INST: sh.ddc ra, sp
# CHECK: encoding: [0xdb,0x00,0x91,0x00]
sh.ddc x1, x2
# CHECK-INST: sw.ddc ra, sp
# CHECK: encoding: [0xdb,0x00,0xa1,0x00]
sw.ddc x1, x2
# CHECK-INST: sc.ddc cra, sp
# CHECK32: encoding: [0xdb,0x00,0xb1,0x00]
# CHECK64: encoding: [0xdb,0x00,0xc1,0x00]
sc.ddc c1, x2

# CHECK-INST: lb.cap ra, csp
# CHECK: encoding: [0xdb,0x00,0x01,0x01]
lb.cap x1, c2
# CHECK-INST: lh.cap ra, csp
# CHECK: encoding: [0xdb,0x00,0x11,0x01]
lh.cap x1, c2
# CHECK-INST: lw.cap ra, csp
# CHECK: encoding: [0xdb,0x00,0x21,0x01]
lw.cap x1, c2
# CHECK-INST: lbu.cap ra, csp
# CHECK: encoding: [0xdb,0x00,0x41,0x01]
lbu.cap x1, c2
# CHECK-INST: lhu.cap ra, csp
# CHECK: encoding: [0xdb,0x00,0x51,0x01]
lhu.cap x1, c2
# CHECK-INST: lc.cap cra, csp
# CHECK32: encoding: [0xdb,0x00,0x31,0x01]
# CHECK64: encoding: [0xdb,0x00,0xd1,0x01]
lc.cap c1, c2

# CHECK-INST: sb.cap ra, csp
# CHECK: encoding: [0xdb,0x00,0x81,0x01]
sb.cap x1, c2
# CHECK-INST: sh.cap ra, csp
# CHECK: encoding: [0xdb,0x00,0x91,0x01]
sh.cap x1, c2
# CHECK-INST: sw.cap ra, csp
# CHECK: encoding: [0xdb,0x00,0xa1,0x01]
sw.cap x1, c2
# CHECK-INST: sc.cap cra, csp
# CHECK32: encoding: [0xdb,0x00,0xb1,0x01]
# CHECK64: encoding: [0xdb,0x00,0xc1,0x01]
sc.cap c1, c2
