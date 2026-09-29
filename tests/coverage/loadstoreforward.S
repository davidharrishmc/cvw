///////////////////////////////////////////
// loadstoreforward.S
//
// Written: David_Harris@hmc.edu 29 September 2026
//
// Purpose: Self-checking test of forwarding load and SC/AMO results to the data operand of a dependent
//          store without a load-use stall, across load and store widths, cache hits and misses,
//          an uncached store, compressed forms, and a store whose address also depends on the load.
//
// A component of the CORE-V-WALLY configurable RISC-V project.
// https://github.com/openhwfoundation/cvw
//
// Copyright (C) 2021-26 Harvey Mudd College & Oklahoma State University
//
// SPDX-License-Identifier: Apache-2.0 WITH SHL-2.1
//
// Licensed under the Solderpad Hardware License v 2.1 (the “License”); you may not use this file
// except in compliance with the License, or, at your option, the Apache License version 2.0. You
// may obtain a copy of the License at
//
// https://solderpad.org/licenses/SHL-2.1/
//
// Unless required by applicable law or agreed to in writing, any work distributed under the
// License is distributed on an “AS IS” BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND,
// either express or implied. See the License for the specific language governing permissions
// and limitations under the License.
////////////////////////////////////////////////////////////////////////////////////////////////

#include "WALLY-init-lib.h"
#include "WALLY-selfcheck.h"

main:
    li t0, 0x2000
    csrs mstatus, t0            # mstatus.FS = initial, for the fdiv.d case
    SC_STRICT_TRAPS
    .option push
    .option norvc
    # ---- hit ----
    la t3, dst_hit
    ld zero, 0(t3)
    ld zero, 64(t3)
    ld zero, 128(t3)
    ld zero, 192(t3)
    ld zero, 256(t3)
    la t3, src_hit
    ld zero, 0(t3)
    # 1: hit: ld -> sd
    la a0, src_hit+0
    la a3, dst_hit+0
    ld a1, 0(a0)
    sd a1, 0(a3)   # data depends only on the load
    la t3, dst_hit+0
    ld t4, 0(t3)
    li t5, -1
    and t6, a1, t5
    SC_CHECK_EQ_ADR t4, t6, t3, 1
    # 2: hit: ld -> sw
    la a0, src_hit+0
    la a3, dst_hit+8
    ld a1, 0(a0)
    sw a1, 0(a3)   # data depends only on the load
    la t3, dst_hit+8
    ld t4, 0(t3)
    li t5, 4294967295
    and t6, a1, t5
    SC_CHECK_EQ_ADR t4, t6, t3, 2
    # 3: hit: ld -> sh
    la a0, src_hit+0
    la a3, dst_hit+16
    ld a1, 0(a0)
    sh a1, 0(a3)   # data depends only on the load
    la t3, dst_hit+16
    ld t4, 0(t3)
    li t5, 65535
    and t6, a1, t5
    SC_CHECK_EQ_ADR t4, t6, t3, 3
    # 4: hit: ld -> sb
    la a0, src_hit+0
    la a3, dst_hit+24
    ld a1, 0(a0)
    sb a1, 0(a3)   # data depends only on the load
    la t3, dst_hit+24
    ld t4, 0(t3)
    li t5, 255
    and t6, a1, t5
    SC_CHECK_EQ_ADR t4, t6, t3, 4
    # 5: hit: lw -> sd
    la a0, src_hit+0
    la a3, dst_hit+32
    lw a1, 0(a0)
    sd a1, 0(a3)   # data depends only on the load
    la t3, dst_hit+32
    ld t4, 0(t3)
    li t5, -1
    and t6, a1, t5
    SC_CHECK_EQ_ADR t4, t6, t3, 5
    # 6: hit: lw -> sw
    la a0, src_hit+0
    la a3, dst_hit+40
    lw a1, 0(a0)
    sw a1, 0(a3)   # data depends only on the load
    la t3, dst_hit+40
    ld t4, 0(t3)
    li t5, 4294967295
    and t6, a1, t5
    SC_CHECK_EQ_ADR t4, t6, t3, 6
    # 7: hit: lw -> sh
    la a0, src_hit+0
    la a3, dst_hit+48
    lw a1, 0(a0)
    sh a1, 0(a3)   # data depends only on the load
    la t3, dst_hit+48
    ld t4, 0(t3)
    li t5, 65535
    and t6, a1, t5
    SC_CHECK_EQ_ADR t4, t6, t3, 7
    # 8: hit: lw -> sb
    la a0, src_hit+0
    la a3, dst_hit+56
    lw a1, 0(a0)
    sb a1, 0(a3)   # data depends only on the load
    la t3, dst_hit+56
    ld t4, 0(t3)
    li t5, 255
    and t6, a1, t5
    SC_CHECK_EQ_ADR t4, t6, t3, 8
    # 9: hit: lwu -> sd
    la a0, src_hit+0
    la a3, dst_hit+64
    lwu a1, 0(a0)
    sd a1, 0(a3)   # data depends only on the load
    la t3, dst_hit+64
    ld t4, 0(t3)
    li t5, -1
    and t6, a1, t5
    SC_CHECK_EQ_ADR t4, t6, t3, 9
    # 10: hit: lwu -> sw
    la a0, src_hit+0
    la a3, dst_hit+72
    lwu a1, 0(a0)
    sw a1, 0(a3)   # data depends only on the load
    la t3, dst_hit+72
    ld t4, 0(t3)
    li t5, 4294967295
    and t6, a1, t5
    SC_CHECK_EQ_ADR t4, t6, t3, 10
    # 11: hit: lwu -> sh
    la a0, src_hit+0
    la a3, dst_hit+80
    lwu a1, 0(a0)
    sh a1, 0(a3)   # data depends only on the load
    la t3, dst_hit+80
    ld t4, 0(t3)
    li t5, 65535
    and t6, a1, t5
    SC_CHECK_EQ_ADR t4, t6, t3, 11
    # 12: hit: lwu -> sb
    la a0, src_hit+0
    la a3, dst_hit+88
    lwu a1, 0(a0)
    sb a1, 0(a3)   # data depends only on the load
    la t3, dst_hit+88
    ld t4, 0(t3)
    li t5, 255
    and t6, a1, t5
    SC_CHECK_EQ_ADR t4, t6, t3, 12
    # 13: hit: lh -> sd
    la a0, src_hit+0
    la a3, dst_hit+96
    lh a1, 0(a0)
    sd a1, 0(a3)   # data depends only on the load
    la t3, dst_hit+96
    ld t4, 0(t3)
    li t5, -1
    and t6, a1, t5
    SC_CHECK_EQ_ADR t4, t6, t3, 13
    # 14: hit: lh -> sw
    la a0, src_hit+0
    la a3, dst_hit+104
    lh a1, 0(a0)
    sw a1, 0(a3)   # data depends only on the load
    la t3, dst_hit+104
    ld t4, 0(t3)
    li t5, 4294967295
    and t6, a1, t5
    SC_CHECK_EQ_ADR t4, t6, t3, 14
    # 15: hit: lh -> sh
    la a0, src_hit+0
    la a3, dst_hit+112
    lh a1, 0(a0)
    sh a1, 0(a3)   # data depends only on the load
    la t3, dst_hit+112
    ld t4, 0(t3)
    li t5, 65535
    and t6, a1, t5
    SC_CHECK_EQ_ADR t4, t6, t3, 15
    # 16: hit: lh -> sb
    la a0, src_hit+0
    la a3, dst_hit+120
    lh a1, 0(a0)
    sb a1, 0(a3)   # data depends only on the load
    la t3, dst_hit+120
    ld t4, 0(t3)
    li t5, 255
    and t6, a1, t5
    SC_CHECK_EQ_ADR t4, t6, t3, 16
    # 17: hit: lhu -> sd
    la a0, src_hit+0
    la a3, dst_hit+128
    lhu a1, 0(a0)
    sd a1, 0(a3)   # data depends only on the load
    la t3, dst_hit+128
    ld t4, 0(t3)
    li t5, -1
    and t6, a1, t5
    SC_CHECK_EQ_ADR t4, t6, t3, 17
    # 18: hit: lhu -> sw
    la a0, src_hit+0
    la a3, dst_hit+136
    lhu a1, 0(a0)
    sw a1, 0(a3)   # data depends only on the load
    la t3, dst_hit+136
    ld t4, 0(t3)
    li t5, 4294967295
    and t6, a1, t5
    SC_CHECK_EQ_ADR t4, t6, t3, 18
    # 19: hit: lhu -> sh
    la a0, src_hit+0
    la a3, dst_hit+144
    lhu a1, 0(a0)
    sh a1, 0(a3)   # data depends only on the load
    la t3, dst_hit+144
    ld t4, 0(t3)
    li t5, 65535
    and t6, a1, t5
    SC_CHECK_EQ_ADR t4, t6, t3, 19
    # 20: hit: lhu -> sb
    la a0, src_hit+0
    la a3, dst_hit+152
    lhu a1, 0(a0)
    sb a1, 0(a3)   # data depends only on the load
    la t3, dst_hit+152
    ld t4, 0(t3)
    li t5, 255
    and t6, a1, t5
    SC_CHECK_EQ_ADR t4, t6, t3, 20
    # 21: hit: lb -> sd
    la a0, src_hit+0
    la a3, dst_hit+160
    lb a1, 0(a0)
    sd a1, 0(a3)   # data depends only on the load
    la t3, dst_hit+160
    ld t4, 0(t3)
    li t5, -1
    and t6, a1, t5
    SC_CHECK_EQ_ADR t4, t6, t3, 21
    # 22: hit: lb -> sw
    la a0, src_hit+0
    la a3, dst_hit+168
    lb a1, 0(a0)
    sw a1, 0(a3)   # data depends only on the load
    la t3, dst_hit+168
    ld t4, 0(t3)
    li t5, 4294967295
    and t6, a1, t5
    SC_CHECK_EQ_ADR t4, t6, t3, 22
    # 23: hit: lb -> sh
    la a0, src_hit+0
    la a3, dst_hit+176
    lb a1, 0(a0)
    sh a1, 0(a3)   # data depends only on the load
    la t3, dst_hit+176
    ld t4, 0(t3)
    li t5, 65535
    and t6, a1, t5
    SC_CHECK_EQ_ADR t4, t6, t3, 23
    # 24: hit: lb -> sb
    la a0, src_hit+0
    la a3, dst_hit+184
    lb a1, 0(a0)
    sb a1, 0(a3)   # data depends only on the load
    la t3, dst_hit+184
    ld t4, 0(t3)
    li t5, 255
    and t6, a1, t5
    SC_CHECK_EQ_ADR t4, t6, t3, 24
    # 25: hit: lbu -> sd
    la a0, src_hit+0
    la a3, dst_hit+192
    lbu a1, 0(a0)
    sd a1, 0(a3)   # data depends only on the load
    la t3, dst_hit+192
    ld t4, 0(t3)
    li t5, -1
    and t6, a1, t5
    SC_CHECK_EQ_ADR t4, t6, t3, 25
    # 26: hit: lbu -> sw
    la a0, src_hit+0
    la a3, dst_hit+200
    lbu a1, 0(a0)
    sw a1, 0(a3)   # data depends only on the load
    la t3, dst_hit+200
    ld t4, 0(t3)
    li t5, 4294967295
    and t6, a1, t5
    SC_CHECK_EQ_ADR t4, t6, t3, 26
    # 27: hit: lbu -> sh
    la a0, src_hit+0
    la a3, dst_hit+208
    lbu a1, 0(a0)
    sh a1, 0(a3)   # data depends only on the load
    la t3, dst_hit+208
    ld t4, 0(t3)
    li t5, 65535
    and t6, a1, t5
    SC_CHECK_EQ_ADR t4, t6, t3, 27
    # 28: hit: lbu -> sb
    la a0, src_hit+0
    la a3, dst_hit+216
    lbu a1, 0(a0)
    sb a1, 0(a3)   # data depends only on the load
    la t3, dst_hit+216
    ld t4, 0(t3)
    li t5, 255
    and t6, a1, t5
    SC_CHECK_EQ_ADR t4, t6, t3, 28
    # ---- store miss ----
    la t3, src_hit
    ld zero, 0(t3)
    # 29: store miss: ld -> sd
    la a0, src_hit+0
    la a3, dst_smiss+0
    ld a1, 0(a0)
    sd a1, 0(a3)   # data depends only on the load
    la t3, dst_smiss+0
    ld t4, 0(t3)
    li t5, -1
    and t6, a1, t5
    SC_CHECK_EQ_ADR t4, t6, t3, 29
    # 30: store miss: ld -> sw
    la a0, src_hit+0
    la a3, dst_smiss+64
    ld a1, 0(a0)
    sw a1, 0(a3)   # data depends only on the load
    la t3, dst_smiss+64
    ld t4, 0(t3)
    li t5, 4294967295
    and t6, a1, t5
    SC_CHECK_EQ_ADR t4, t6, t3, 30
    # 31: store miss: ld -> sh
    la a0, src_hit+0
    la a3, dst_smiss+128
    ld a1, 0(a0)
    sh a1, 0(a3)   # data depends only on the load
    la t3, dst_smiss+128
    ld t4, 0(t3)
    li t5, 65535
    and t6, a1, t5
    SC_CHECK_EQ_ADR t4, t6, t3, 31
    # 32: store miss: ld -> sb
    la a0, src_hit+0
    la a3, dst_smiss+192
    ld a1, 0(a0)
    sb a1, 0(a3)   # data depends only on the load
    la t3, dst_smiss+192
    ld t4, 0(t3)
    li t5, 255
    and t6, a1, t5
    SC_CHECK_EQ_ADR t4, t6, t3, 32
    # 33: store miss: lw -> sd
    la a0, src_hit+0
    la a3, dst_smiss+256
    lw a1, 0(a0)
    sd a1, 0(a3)   # data depends only on the load
    la t3, dst_smiss+256
    ld t4, 0(t3)
    li t5, -1
    and t6, a1, t5
    SC_CHECK_EQ_ADR t4, t6, t3, 33
    # 34: store miss: lw -> sw
    la a0, src_hit+0
    la a3, dst_smiss+320
    lw a1, 0(a0)
    sw a1, 0(a3)   # data depends only on the load
    la t3, dst_smiss+320
    ld t4, 0(t3)
    li t5, 4294967295
    and t6, a1, t5
    SC_CHECK_EQ_ADR t4, t6, t3, 34
    # 35: store miss: lw -> sh
    la a0, src_hit+0
    la a3, dst_smiss+384
    lw a1, 0(a0)
    sh a1, 0(a3)   # data depends only on the load
    la t3, dst_smiss+384
    ld t4, 0(t3)
    li t5, 65535
    and t6, a1, t5
    SC_CHECK_EQ_ADR t4, t6, t3, 35
    # 36: store miss: lw -> sb
    la a0, src_hit+0
    la a3, dst_smiss+448
    lw a1, 0(a0)
    sb a1, 0(a3)   # data depends only on the load
    la t3, dst_smiss+448
    ld t4, 0(t3)
    li t5, 255
    and t6, a1, t5
    SC_CHECK_EQ_ADR t4, t6, t3, 36
    # 37: store miss: lwu -> sd
    la a0, src_hit+0
    la a3, dst_smiss+512
    lwu a1, 0(a0)
    sd a1, 0(a3)   # data depends only on the load
    la t3, dst_smiss+512
    ld t4, 0(t3)
    li t5, -1
    and t6, a1, t5
    SC_CHECK_EQ_ADR t4, t6, t3, 37
    # 38: store miss: lwu -> sw
    la a0, src_hit+0
    la a3, dst_smiss+576
    lwu a1, 0(a0)
    sw a1, 0(a3)   # data depends only on the load
    la t3, dst_smiss+576
    ld t4, 0(t3)
    li t5, 4294967295
    and t6, a1, t5
    SC_CHECK_EQ_ADR t4, t6, t3, 38
    # 39: store miss: lwu -> sh
    la a0, src_hit+0
    la a3, dst_smiss+640
    lwu a1, 0(a0)
    sh a1, 0(a3)   # data depends only on the load
    la t3, dst_smiss+640
    ld t4, 0(t3)
    li t5, 65535
    and t6, a1, t5
    SC_CHECK_EQ_ADR t4, t6, t3, 39
    # 40: store miss: lwu -> sb
    la a0, src_hit+0
    la a3, dst_smiss+704
    lwu a1, 0(a0)
    sb a1, 0(a3)   # data depends only on the load
    la t3, dst_smiss+704
    ld t4, 0(t3)
    li t5, 255
    and t6, a1, t5
    SC_CHECK_EQ_ADR t4, t6, t3, 40
    # 41: store miss: lh -> sd
    la a0, src_hit+0
    la a3, dst_smiss+768
    lh a1, 0(a0)
    sd a1, 0(a3)   # data depends only on the load
    la t3, dst_smiss+768
    ld t4, 0(t3)
    li t5, -1
    and t6, a1, t5
    SC_CHECK_EQ_ADR t4, t6, t3, 41
    # 42: store miss: lh -> sw
    la a0, src_hit+0
    la a3, dst_smiss+832
    lh a1, 0(a0)
    sw a1, 0(a3)   # data depends only on the load
    la t3, dst_smiss+832
    ld t4, 0(t3)
    li t5, 4294967295
    and t6, a1, t5
    SC_CHECK_EQ_ADR t4, t6, t3, 42
    # 43: store miss: lh -> sh
    la a0, src_hit+0
    la a3, dst_smiss+896
    lh a1, 0(a0)
    sh a1, 0(a3)   # data depends only on the load
    la t3, dst_smiss+896
    ld t4, 0(t3)
    li t5, 65535
    and t6, a1, t5
    SC_CHECK_EQ_ADR t4, t6, t3, 43
    # 44: store miss: lh -> sb
    la a0, src_hit+0
    la a3, dst_smiss+960
    lh a1, 0(a0)
    sb a1, 0(a3)   # data depends only on the load
    la t3, dst_smiss+960
    ld t4, 0(t3)
    li t5, 255
    and t6, a1, t5
    SC_CHECK_EQ_ADR t4, t6, t3, 44
    # 45: store miss: lhu -> sd
    la a0, src_hit+0
    la a3, dst_smiss+1024
    lhu a1, 0(a0)
    sd a1, 0(a3)   # data depends only on the load
    la t3, dst_smiss+1024
    ld t4, 0(t3)
    li t5, -1
    and t6, a1, t5
    SC_CHECK_EQ_ADR t4, t6, t3, 45
    # 46: store miss: lhu -> sw
    la a0, src_hit+0
    la a3, dst_smiss+1088
    lhu a1, 0(a0)
    sw a1, 0(a3)   # data depends only on the load
    la t3, dst_smiss+1088
    ld t4, 0(t3)
    li t5, 4294967295
    and t6, a1, t5
    SC_CHECK_EQ_ADR t4, t6, t3, 46
    # 47: store miss: lhu -> sh
    la a0, src_hit+0
    la a3, dst_smiss+1152
    lhu a1, 0(a0)
    sh a1, 0(a3)   # data depends only on the load
    la t3, dst_smiss+1152
    ld t4, 0(t3)
    li t5, 65535
    and t6, a1, t5
    SC_CHECK_EQ_ADR t4, t6, t3, 47
    # 48: store miss: lhu -> sb
    la a0, src_hit+0
    la a3, dst_smiss+1216
    lhu a1, 0(a0)
    sb a1, 0(a3)   # data depends only on the load
    la t3, dst_smiss+1216
    ld t4, 0(t3)
    li t5, 255
    and t6, a1, t5
    SC_CHECK_EQ_ADR t4, t6, t3, 48
    # 49: store miss: lb -> sd
    la a0, src_hit+0
    la a3, dst_smiss+1280
    lb a1, 0(a0)
    sd a1, 0(a3)   # data depends only on the load
    la t3, dst_smiss+1280
    ld t4, 0(t3)
    li t5, -1
    and t6, a1, t5
    SC_CHECK_EQ_ADR t4, t6, t3, 49
    # 50: store miss: lb -> sw
    la a0, src_hit+0
    la a3, dst_smiss+1344
    lb a1, 0(a0)
    sw a1, 0(a3)   # data depends only on the load
    la t3, dst_smiss+1344
    ld t4, 0(t3)
    li t5, 4294967295
    and t6, a1, t5
    SC_CHECK_EQ_ADR t4, t6, t3, 50
    # 51: store miss: lb -> sh
    la a0, src_hit+0
    la a3, dst_smiss+1408
    lb a1, 0(a0)
    sh a1, 0(a3)   # data depends only on the load
    la t3, dst_smiss+1408
    ld t4, 0(t3)
    li t5, 65535
    and t6, a1, t5
    SC_CHECK_EQ_ADR t4, t6, t3, 51
    # 52: store miss: lb -> sb
    la a0, src_hit+0
    la a3, dst_smiss+1472
    lb a1, 0(a0)
    sb a1, 0(a3)   # data depends only on the load
    la t3, dst_smiss+1472
    ld t4, 0(t3)
    li t5, 255
    and t6, a1, t5
    SC_CHECK_EQ_ADR t4, t6, t3, 52
    # 53: store miss: lbu -> sd
    la a0, src_hit+0
    la a3, dst_smiss+1536
    lbu a1, 0(a0)
    sd a1, 0(a3)   # data depends only on the load
    la t3, dst_smiss+1536
    ld t4, 0(t3)
    li t5, -1
    and t6, a1, t5
    SC_CHECK_EQ_ADR t4, t6, t3, 53
    # 54: store miss: lbu -> sw
    la a0, src_hit+0
    la a3, dst_smiss+1600
    lbu a1, 0(a0)
    sw a1, 0(a3)   # data depends only on the load
    la t3, dst_smiss+1600
    ld t4, 0(t3)
    li t5, 4294967295
    and t6, a1, t5
    SC_CHECK_EQ_ADR t4, t6, t3, 54
    # 55: store miss: lbu -> sh
    la a0, src_hit+0
    la a3, dst_smiss+1664
    lbu a1, 0(a0)
    sh a1, 0(a3)   # data depends only on the load
    la t3, dst_smiss+1664
    ld t4, 0(t3)
    li t5, 65535
    and t6, a1, t5
    SC_CHECK_EQ_ADR t4, t6, t3, 55
    # 56: store miss: lbu -> sb
    la a0, src_hit+0
    la a3, dst_smiss+1728
    lbu a1, 0(a0)
    sb a1, 0(a3)   # data depends only on the load
    la t3, dst_smiss+1728
    ld t4, 0(t3)
    li t5, 255
    and t6, a1, t5
    SC_CHECK_EQ_ADR t4, t6, t3, 56
    # ---- load miss ----
    la t3, dst_hit2
    ld zero, 0(t3)
    ld zero, 64(t3)
    ld zero, 128(t3)
    ld zero, 192(t3)
    ld zero, 256(t3)
    # 57: load miss: ld -> sd
    la a0, src_lmiss+0
    la a3, dst_hit2+0
    ld a1, 0(a0)
    sd a1, 0(a3)   # data depends only on the load
    la t3, dst_hit2+0
    ld t4, 0(t3)
    li t5, -1
    and t6, a1, t5
    SC_CHECK_EQ_ADR t4, t6, t3, 57
    # 58: load miss: ld -> sw
    la a0, src_lmiss+64
    la a3, dst_hit2+8
    ld a1, 0(a0)
    sw a1, 0(a3)   # data depends only on the load
    la t3, dst_hit2+8
    ld t4, 0(t3)
    li t5, 4294967295
    and t6, a1, t5
    SC_CHECK_EQ_ADR t4, t6, t3, 58
    # 59: load miss: ld -> sh
    la a0, src_lmiss+128
    la a3, dst_hit2+16
    ld a1, 0(a0)
    sh a1, 0(a3)   # data depends only on the load
    la t3, dst_hit2+16
    ld t4, 0(t3)
    li t5, 65535
    and t6, a1, t5
    SC_CHECK_EQ_ADR t4, t6, t3, 59
    # 60: load miss: ld -> sb
    la a0, src_lmiss+192
    la a3, dst_hit2+24
    ld a1, 0(a0)
    sb a1, 0(a3)   # data depends only on the load
    la t3, dst_hit2+24
    ld t4, 0(t3)
    li t5, 255
    and t6, a1, t5
    SC_CHECK_EQ_ADR t4, t6, t3, 60
    # 61: load miss: lw -> sd
    la a0, src_lmiss+256
    la a3, dst_hit2+32
    lw a1, 0(a0)
    sd a1, 0(a3)   # data depends only on the load
    la t3, dst_hit2+32
    ld t4, 0(t3)
    li t5, -1
    and t6, a1, t5
    SC_CHECK_EQ_ADR t4, t6, t3, 61
    # 62: load miss: lw -> sw
    la a0, src_lmiss+320
    la a3, dst_hit2+40
    lw a1, 0(a0)
    sw a1, 0(a3)   # data depends only on the load
    la t3, dst_hit2+40
    ld t4, 0(t3)
    li t5, 4294967295
    and t6, a1, t5
    SC_CHECK_EQ_ADR t4, t6, t3, 62
    # 63: load miss: lw -> sh
    la a0, src_lmiss+384
    la a3, dst_hit2+48
    lw a1, 0(a0)
    sh a1, 0(a3)   # data depends only on the load
    la t3, dst_hit2+48
    ld t4, 0(t3)
    li t5, 65535
    and t6, a1, t5
    SC_CHECK_EQ_ADR t4, t6, t3, 63
    # 64: load miss: lw -> sb
    la a0, src_lmiss+448
    la a3, dst_hit2+56
    lw a1, 0(a0)
    sb a1, 0(a3)   # data depends only on the load
    la t3, dst_hit2+56
    ld t4, 0(t3)
    li t5, 255
    and t6, a1, t5
    SC_CHECK_EQ_ADR t4, t6, t3, 64
    # 65: load miss: lwu -> sd
    la a0, src_lmiss+512
    la a3, dst_hit2+64
    lwu a1, 0(a0)
    sd a1, 0(a3)   # data depends only on the load
    la t3, dst_hit2+64
    ld t4, 0(t3)
    li t5, -1
    and t6, a1, t5
    SC_CHECK_EQ_ADR t4, t6, t3, 65
    # 66: load miss: lwu -> sw
    la a0, src_lmiss+576
    la a3, dst_hit2+72
    lwu a1, 0(a0)
    sw a1, 0(a3)   # data depends only on the load
    la t3, dst_hit2+72
    ld t4, 0(t3)
    li t5, 4294967295
    and t6, a1, t5
    SC_CHECK_EQ_ADR t4, t6, t3, 66
    # 67: load miss: lwu -> sh
    la a0, src_lmiss+640
    la a3, dst_hit2+80
    lwu a1, 0(a0)
    sh a1, 0(a3)   # data depends only on the load
    la t3, dst_hit2+80
    ld t4, 0(t3)
    li t5, 65535
    and t6, a1, t5
    SC_CHECK_EQ_ADR t4, t6, t3, 67
    # 68: load miss: lwu -> sb
    la a0, src_lmiss+704
    la a3, dst_hit2+88
    lwu a1, 0(a0)
    sb a1, 0(a3)   # data depends only on the load
    la t3, dst_hit2+88
    ld t4, 0(t3)
    li t5, 255
    and t6, a1, t5
    SC_CHECK_EQ_ADR t4, t6, t3, 68
    # 69: load miss: lh -> sd
    la a0, src_lmiss+768
    la a3, dst_hit2+96
    lh a1, 0(a0)
    sd a1, 0(a3)   # data depends only on the load
    la t3, dst_hit2+96
    ld t4, 0(t3)
    li t5, -1
    and t6, a1, t5
    SC_CHECK_EQ_ADR t4, t6, t3, 69
    # 70: load miss: lh -> sw
    la a0, src_lmiss+832
    la a3, dst_hit2+104
    lh a1, 0(a0)
    sw a1, 0(a3)   # data depends only on the load
    la t3, dst_hit2+104
    ld t4, 0(t3)
    li t5, 4294967295
    and t6, a1, t5
    SC_CHECK_EQ_ADR t4, t6, t3, 70
    # 71: load miss: lh -> sh
    la a0, src_lmiss+896
    la a3, dst_hit2+112
    lh a1, 0(a0)
    sh a1, 0(a3)   # data depends only on the load
    la t3, dst_hit2+112
    ld t4, 0(t3)
    li t5, 65535
    and t6, a1, t5
    SC_CHECK_EQ_ADR t4, t6, t3, 71
    # 72: load miss: lh -> sb
    la a0, src_lmiss+960
    la a3, dst_hit2+120
    lh a1, 0(a0)
    sb a1, 0(a3)   # data depends only on the load
    la t3, dst_hit2+120
    ld t4, 0(t3)
    li t5, 255
    and t6, a1, t5
    SC_CHECK_EQ_ADR t4, t6, t3, 72
    # 73: load miss: lhu -> sd
    la a0, src_lmiss+1024
    la a3, dst_hit2+128
    lhu a1, 0(a0)
    sd a1, 0(a3)   # data depends only on the load
    la t3, dst_hit2+128
    ld t4, 0(t3)
    li t5, -1
    and t6, a1, t5
    SC_CHECK_EQ_ADR t4, t6, t3, 73
    # 74: load miss: lhu -> sw
    la a0, src_lmiss+1088
    la a3, dst_hit2+136
    lhu a1, 0(a0)
    sw a1, 0(a3)   # data depends only on the load
    la t3, dst_hit2+136
    ld t4, 0(t3)
    li t5, 4294967295
    and t6, a1, t5
    SC_CHECK_EQ_ADR t4, t6, t3, 74
    # 75: load miss: lhu -> sh
    la a0, src_lmiss+1152
    la a3, dst_hit2+144
    lhu a1, 0(a0)
    sh a1, 0(a3)   # data depends only on the load
    la t3, dst_hit2+144
    ld t4, 0(t3)
    li t5, 65535
    and t6, a1, t5
    SC_CHECK_EQ_ADR t4, t6, t3, 75
    # 76: load miss: lhu -> sb
    la a0, src_lmiss+1216
    la a3, dst_hit2+152
    lhu a1, 0(a0)
    sb a1, 0(a3)   # data depends only on the load
    la t3, dst_hit2+152
    ld t4, 0(t3)
    li t5, 255
    and t6, a1, t5
    SC_CHECK_EQ_ADR t4, t6, t3, 76
    # 77: load miss: lb -> sd
    la a0, src_lmiss+1280
    la a3, dst_hit2+160
    lb a1, 0(a0)
    sd a1, 0(a3)   # data depends only on the load
    la t3, dst_hit2+160
    ld t4, 0(t3)
    li t5, -1
    and t6, a1, t5
    SC_CHECK_EQ_ADR t4, t6, t3, 77
    # 78: load miss: lb -> sw
    la a0, src_lmiss+1344
    la a3, dst_hit2+168
    lb a1, 0(a0)
    sw a1, 0(a3)   # data depends only on the load
    la t3, dst_hit2+168
    ld t4, 0(t3)
    li t5, 4294967295
    and t6, a1, t5
    SC_CHECK_EQ_ADR t4, t6, t3, 78
    # 79: load miss: lb -> sh
    la a0, src_lmiss+1408
    la a3, dst_hit2+176
    lb a1, 0(a0)
    sh a1, 0(a3)   # data depends only on the load
    la t3, dst_hit2+176
    ld t4, 0(t3)
    li t5, 65535
    and t6, a1, t5
    SC_CHECK_EQ_ADR t4, t6, t3, 79
    # 80: load miss: lb -> sb
    la a0, src_lmiss+1472
    la a3, dst_hit2+184
    lb a1, 0(a0)
    sb a1, 0(a3)   # data depends only on the load
    la t3, dst_hit2+184
    ld t4, 0(t3)
    li t5, 255
    and t6, a1, t5
    SC_CHECK_EQ_ADR t4, t6, t3, 80
    # 81: load miss: lbu -> sd
    la a0, src_lmiss+1536
    la a3, dst_hit2+192
    lbu a1, 0(a0)
    sd a1, 0(a3)   # data depends only on the load
    la t3, dst_hit2+192
    ld t4, 0(t3)
    li t5, -1
    and t6, a1, t5
    SC_CHECK_EQ_ADR t4, t6, t3, 81
    # 82: load miss: lbu -> sw
    la a0, src_lmiss+1600
    la a3, dst_hit2+200
    lbu a1, 0(a0)
    sw a1, 0(a3)   # data depends only on the load
    la t3, dst_hit2+200
    ld t4, 0(t3)
    li t5, 4294967295
    and t6, a1, t5
    SC_CHECK_EQ_ADR t4, t6, t3, 82
    # 83: load miss: lbu -> sh
    la a0, src_lmiss+1664
    la a3, dst_hit2+208
    lbu a1, 0(a0)
    sh a1, 0(a3)   # data depends only on the load
    la t3, dst_hit2+208
    ld t4, 0(t3)
    li t5, 65535
    and t6, a1, t5
    SC_CHECK_EQ_ADR t4, t6, t3, 83
    # 84: load miss: lbu -> sb
    la a0, src_lmiss+1728
    la a3, dst_hit2+216
    lbu a1, 0(a0)
    sb a1, 0(a3)   # data depends only on the load
    la t3, dst_hit2+216
    ld t4, 0(t3)
    li t5, 255
    and t6, a1, t5
    SC_CHECK_EQ_ADR t4, t6, t3, 84
    # ---- both miss ----
    # 85: both miss: ld -> sd
    la a0, src_bmiss+0
    la a3, dst_bmiss+0
    ld a1, 0(a0)
    sd a1, 0(a3)   # data depends only on the load
    la t3, dst_bmiss+0
    ld t4, 0(t3)
    li t5, -1
    and t6, a1, t5
    SC_CHECK_EQ_ADR t4, t6, t3, 85
    # 86: both miss: ld -> sw
    la a0, src_bmiss+64
    la a3, dst_bmiss+64
    ld a1, 0(a0)
    sw a1, 0(a3)   # data depends only on the load
    la t3, dst_bmiss+64
    ld t4, 0(t3)
    li t5, 4294967295
    and t6, a1, t5
    SC_CHECK_EQ_ADR t4, t6, t3, 86
    # 87: both miss: ld -> sh
    la a0, src_bmiss+128
    la a3, dst_bmiss+128
    ld a1, 0(a0)
    sh a1, 0(a3)   # data depends only on the load
    la t3, dst_bmiss+128
    ld t4, 0(t3)
    li t5, 65535
    and t6, a1, t5
    SC_CHECK_EQ_ADR t4, t6, t3, 87
    # 88: both miss: ld -> sb
    la a0, src_bmiss+192
    la a3, dst_bmiss+192
    ld a1, 0(a0)
    sb a1, 0(a3)   # data depends only on the load
    la t3, dst_bmiss+192
    ld t4, 0(t3)
    li t5, 255
    and t6, a1, t5
    SC_CHECK_EQ_ADR t4, t6, t3, 88
    # 89: both miss: lw -> sd
    la a0, src_bmiss+256
    la a3, dst_bmiss+256
    lw a1, 0(a0)
    sd a1, 0(a3)   # data depends only on the load
    la t3, dst_bmiss+256
    ld t4, 0(t3)
    li t5, -1
    and t6, a1, t5
    SC_CHECK_EQ_ADR t4, t6, t3, 89
    # 90: both miss: lw -> sw
    la a0, src_bmiss+320
    la a3, dst_bmiss+320
    lw a1, 0(a0)
    sw a1, 0(a3)   # data depends only on the load
    la t3, dst_bmiss+320
    ld t4, 0(t3)
    li t5, 4294967295
    and t6, a1, t5
    SC_CHECK_EQ_ADR t4, t6, t3, 90
    # 91: both miss: lw -> sh
    la a0, src_bmiss+384
    la a3, dst_bmiss+384
    lw a1, 0(a0)
    sh a1, 0(a3)   # data depends only on the load
    la t3, dst_bmiss+384
    ld t4, 0(t3)
    li t5, 65535
    and t6, a1, t5
    SC_CHECK_EQ_ADR t4, t6, t3, 91
    # 92: both miss: lw -> sb
    la a0, src_bmiss+448
    la a3, dst_bmiss+448
    lw a1, 0(a0)
    sb a1, 0(a3)   # data depends only on the load
    la t3, dst_bmiss+448
    ld t4, 0(t3)
    li t5, 255
    and t6, a1, t5
    SC_CHECK_EQ_ADR t4, t6, t3, 92
    # 93: both miss: lwu -> sd
    la a0, src_bmiss+512
    la a3, dst_bmiss+512
    lwu a1, 0(a0)
    sd a1, 0(a3)   # data depends only on the load
    la t3, dst_bmiss+512
    ld t4, 0(t3)
    li t5, -1
    and t6, a1, t5
    SC_CHECK_EQ_ADR t4, t6, t3, 93
    # 94: both miss: lwu -> sw
    la a0, src_bmiss+576
    la a3, dst_bmiss+576
    lwu a1, 0(a0)
    sw a1, 0(a3)   # data depends only on the load
    la t3, dst_bmiss+576
    ld t4, 0(t3)
    li t5, 4294967295
    and t6, a1, t5
    SC_CHECK_EQ_ADR t4, t6, t3, 94
    # 95: both miss: lwu -> sh
    la a0, src_bmiss+640
    la a3, dst_bmiss+640
    lwu a1, 0(a0)
    sh a1, 0(a3)   # data depends only on the load
    la t3, dst_bmiss+640
    ld t4, 0(t3)
    li t5, 65535
    and t6, a1, t5
    SC_CHECK_EQ_ADR t4, t6, t3, 95
    # 96: both miss: lwu -> sb
    la a0, src_bmiss+704
    la a3, dst_bmiss+704
    lwu a1, 0(a0)
    sb a1, 0(a3)   # data depends only on the load
    la t3, dst_bmiss+704
    ld t4, 0(t3)
    li t5, 255
    and t6, a1, t5
    SC_CHECK_EQ_ADR t4, t6, t3, 96
    # 97: both miss: lh -> sd
    la a0, src_bmiss+768
    la a3, dst_bmiss+768
    lh a1, 0(a0)
    sd a1, 0(a3)   # data depends only on the load
    la t3, dst_bmiss+768
    ld t4, 0(t3)
    li t5, -1
    and t6, a1, t5
    SC_CHECK_EQ_ADR t4, t6, t3, 97
    # 98: both miss: lh -> sw
    la a0, src_bmiss+832
    la a3, dst_bmiss+832
    lh a1, 0(a0)
    sw a1, 0(a3)   # data depends only on the load
    la t3, dst_bmiss+832
    ld t4, 0(t3)
    li t5, 4294967295
    and t6, a1, t5
    SC_CHECK_EQ_ADR t4, t6, t3, 98
    # 99: both miss: lh -> sh
    la a0, src_bmiss+896
    la a3, dst_bmiss+896
    lh a1, 0(a0)
    sh a1, 0(a3)   # data depends only on the load
    la t3, dst_bmiss+896
    ld t4, 0(t3)
    li t5, 65535
    and t6, a1, t5
    SC_CHECK_EQ_ADR t4, t6, t3, 99
    # 100: both miss: lh -> sb
    la a0, src_bmiss+960
    la a3, dst_bmiss+960
    lh a1, 0(a0)
    sb a1, 0(a3)   # data depends only on the load
    la t3, dst_bmiss+960
    ld t4, 0(t3)
    li t5, 255
    and t6, a1, t5
    SC_CHECK_EQ_ADR t4, t6, t3, 100
    # 101: both miss: lhu -> sd
    la a0, src_bmiss+1024
    la a3, dst_bmiss+1024
    lhu a1, 0(a0)
    sd a1, 0(a3)   # data depends only on the load
    la t3, dst_bmiss+1024
    ld t4, 0(t3)
    li t5, -1
    and t6, a1, t5
    SC_CHECK_EQ_ADR t4, t6, t3, 101
    # 102: both miss: lhu -> sw
    la a0, src_bmiss+1088
    la a3, dst_bmiss+1088
    lhu a1, 0(a0)
    sw a1, 0(a3)   # data depends only on the load
    la t3, dst_bmiss+1088
    ld t4, 0(t3)
    li t5, 4294967295
    and t6, a1, t5
    SC_CHECK_EQ_ADR t4, t6, t3, 102
    # 103: both miss: lhu -> sh
    la a0, src_bmiss+1152
    la a3, dst_bmiss+1152
    lhu a1, 0(a0)
    sh a1, 0(a3)   # data depends only on the load
    la t3, dst_bmiss+1152
    ld t4, 0(t3)
    li t5, 65535
    and t6, a1, t5
    SC_CHECK_EQ_ADR t4, t6, t3, 103
    # 104: both miss: lhu -> sb
    la a0, src_bmiss+1216
    la a3, dst_bmiss+1216
    lhu a1, 0(a0)
    sb a1, 0(a3)   # data depends only on the load
    la t3, dst_bmiss+1216
    ld t4, 0(t3)
    li t5, 255
    and t6, a1, t5
    SC_CHECK_EQ_ADR t4, t6, t3, 104
    # 105: both miss: lb -> sd
    la a0, src_bmiss+1280
    la a3, dst_bmiss+1280
    lb a1, 0(a0)
    sd a1, 0(a3)   # data depends only on the load
    la t3, dst_bmiss+1280
    ld t4, 0(t3)
    li t5, -1
    and t6, a1, t5
    SC_CHECK_EQ_ADR t4, t6, t3, 105
    # 106: both miss: lb -> sw
    la a0, src_bmiss+1344
    la a3, dst_bmiss+1344
    lb a1, 0(a0)
    sw a1, 0(a3)   # data depends only on the load
    la t3, dst_bmiss+1344
    ld t4, 0(t3)
    li t5, 4294967295
    and t6, a1, t5
    SC_CHECK_EQ_ADR t4, t6, t3, 106
    # 107: both miss: lb -> sh
    la a0, src_bmiss+1408
    la a3, dst_bmiss+1408
    lb a1, 0(a0)
    sh a1, 0(a3)   # data depends only on the load
    la t3, dst_bmiss+1408
    ld t4, 0(t3)
    li t5, 65535
    and t6, a1, t5
    SC_CHECK_EQ_ADR t4, t6, t3, 107
    # 108: both miss: lb -> sb
    la a0, src_bmiss+1472
    la a3, dst_bmiss+1472
    lb a1, 0(a0)
    sb a1, 0(a3)   # data depends only on the load
    la t3, dst_bmiss+1472
    ld t4, 0(t3)
    li t5, 255
    and t6, a1, t5
    SC_CHECK_EQ_ADR t4, t6, t3, 108
    # 109: both miss: lbu -> sd
    la a0, src_bmiss+1536
    la a3, dst_bmiss+1536
    lbu a1, 0(a0)
    sd a1, 0(a3)   # data depends only on the load
    la t3, dst_bmiss+1536
    ld t4, 0(t3)
    li t5, -1
    and t6, a1, t5
    SC_CHECK_EQ_ADR t4, t6, t3, 109
    # 110: both miss: lbu -> sw
    la a0, src_bmiss+1600
    la a3, dst_bmiss+1600
    lbu a1, 0(a0)
    sw a1, 0(a3)   # data depends only on the load
    la t3, dst_bmiss+1600
    ld t4, 0(t3)
    li t5, 4294967295
    and t6, a1, t5
    SC_CHECK_EQ_ADR t4, t6, t3, 110
    # 111: both miss: lbu -> sh
    la a0, src_bmiss+1664
    la a3, dst_bmiss+1664
    lbu a1, 0(a0)
    sh a1, 0(a3)   # data depends only on the load
    la t3, dst_bmiss+1664
    ld t4, 0(t3)
    li t5, 65535
    and t6, a1, t5
    SC_CHECK_EQ_ADR t4, t6, t3, 111
    # 112: both miss: lbu -> sb
    la a0, src_bmiss+1728
    la a3, dst_bmiss+1728
    lbu a1, 0(a0)
    sb a1, 0(a3)   # data depends only on the load
    la t3, dst_bmiss+1728
    ld t4, 0(t3)
    li t5, 255
    and t6, a1, t5
    SC_CHECK_EQ_ADR t4, t6, t3, 112
    # 113: uncached: lbu -> sb to the UART scratch register
    la a0, src_hit
    li a4, 0x10000000
    lbu a1, 0(a0)
    sb a1, 7(a4)
    lbu t4, 7(a4)
    andi t6, a1, 0xFF
    SC_CHECK_EQ t4, t6, 113
    # 114: address also depends on the load: must stall, not forward
    la a0, ptr_cell
    ld a1, 0(a0)
    sd a1, 0(a1)   # a1 is both address and data
    ld t4, 0(a1)
    SC_CHECK_EQ t4, a1, 114
    # 115: sc.d result -> sd
    la a0, lrsc_cell
    la a3, dst_misc
    li t2, 0x1234
    lr.d t1, (a0)
    sc.d a1, t2, (a0)
    sd a1, 0(a3)
    ld t4, 0(a3)
    SC_CHECK_EQ t4, a1, 115
    # 116: amoadd.d result -> sd
    la a0, amo_cell
    la a3, dst_misc+8
    li t2, 5
    amoadd.d a1, t2, (a0)
    sd a1, 0(a3)
    ld t4, 0(a3)
    SC_CHECK_EQ t4, a1, 116
    # 117: compressed c.ld -> c.sd
    la a0, src_hit
    la a3, dst_misc+16
    .option push
    .option rvc
    c.ld a2, 0(a0)
    c.sd a2, 0(a3)
    .option pop
    ld t4, 0(a3)
    SC_CHECK_EQ t4, a2, 117
    # 118: back-to-back pairs, then a store of the first value from Writeback
    la a0, src_hit
    la a3, dst_misc+24
    ld a1, 0(a0)
    sd a1, 0(a3)
    lw a2, 4(a0)
    sw a2, 8(a3)
    sd a1, 16(a3)
    ld t4, 0(a3)
    SC_CHECK_EQ t4, a1, 118
    lw t4, 8(a3)
    SC_CHECK_EQ t4, a2, 119
    ld t4, 16(a3)
    SC_CHECK_EQ t4, a1, 120
    # 121: load to x0 -> store of x0
    la a0, src_hit
    la a3, dst_misc+48
    li t1, -1
    sd t1, 0(a3)
    ld zero, 0(a0)
    sd zero, 0(a3)
    ld t4, 0(a3)
    SC_CHECK_EQ t4, zero, 121
    # 122: load -> store while a long fdiv.d is in flight
    la a0, src_hit
    la a3, dst_misc+56
    li t1, 0x4008000000000000
    fmv.d.x f1, t1
    fdiv.d f2, f1, f1
    ld a1, 0(a0)
    sd a1, 0(a3)
    fadd.d f3, f2, f2
    ld t4, 0(a3)
    SC_CHECK_EQ t4, a1, 122
    .option pop
    SC_PASS
    j done

.data
.align 6
src_hit:    .dword 0x8badf00dcafe8182, 0x0123456789abcdef
.align 6
ptr_cell:   .dword ptr_cell
.align 6
lrsc_cell:  .dword 0
amo_cell:   .dword 7
.align 6
dst_misc:   .fill 8, 8, 0
.align 6
dst_hit:    .fill 28, 8, 0
.align 6
dst_hit2:   .fill 28, 8, 0
.align 6
dst_smiss:  .fill 28*8, 8, 0
.align 6
dst_bmiss:  .fill 28*8, 8, 0
.align 6
src_lmiss:
.rept 28
    .dword 0x8badf00dcafe8182
    .fill 7, 8, 0
.endr
.align 6
src_bmiss:
.rept 28
    .dword 0x8badf00dcafe8182
    .fill 7, 8, 0
.endr
