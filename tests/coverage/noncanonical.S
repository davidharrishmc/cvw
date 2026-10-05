///////////////////////////////////////////
// noncanonical.S
//
// Written David_Harris@hmc.edu 10/5/26
//
// Purpose: Sv39 non-canonical virtual addresses must page fault without walking the page table, even when
//          the walk of the truncated (aliased) address would take an access fault
//
// A component of the CORE-V-WALLY configurable RISC-V project.
// https://github.com/openhwfoundation/cvw
//
// Copyright (C) 2021-23 Harvey Mudd College & Oklahoma State University
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

// A non-canonical Sv39 VA (bits 63:39 not all equal to bit 38) must raise a page fault (12/13/15) before any
// page table access.  The page table makes the walk of each truncated address fault on a PTE read:
//   VPN2=3     (0xC0000000):  non-leaf PTE pointing to nonexistent memory (PA 0x40000000)
//   VPN2=4     (0x100000000): non-leaf PTE pointing to pt_deny, which PMP entry 0 denies to S mode
//   VPN2=0x100 (0x4000000000, the alias of the second half of the spilled fetch): nonexistent memory
// The canonical addresses take the access fault (1/5/7) as controls.

#include "WALLY-init-lib.h"
#include "WALLY-selfcheck.h"

// TRY insn, adr, cause, tval, idx: execute insn with s0 = adr and expect a trap with mcause = cause and
// mtval = tval.  nc_trap_handler records mcause in s8 and mtval in s9 and resumes at s11.
.macro TRY insn, adr, cause, tval, idx
    li s0, \adr
    li s8, -1
    li s9, -1
    la s11, 1f
    \insn
1:
    li t2, \cause
    SC_CHECK_EQ s8, t2, \idx
    li t2, \tval
    SC_CHECK_EQ s9, t2, \idx+1
.endm

main:
    # PMP: entry 0 denies S/U access to pt_deny, entry 1 allows everything else
    li t0, -1
    csrw pmpaddr1, t0               # NAPOT, whole address space
    la t0, pt_deny
    srli t0, t0, 2
    ori t0, t0, 0x1FF               # NAPOT 4 KiB
    csrw pmpaddr0, t0
    li t0, 0x1F18                   # entry 0 NAPOT no permissions, entry 1 NAPOT RWX
    csrw pmpcfg0, t0

    li t0, 1
    slli t0, t0, 61
    csrs menvcfg, t0                # menvcfg.ADUE = 1: hardware A/D updates

    # First half of a 32-bit nop at the last halfword of the megapage that VA 0x3FFFFFF000 maps
    li t0, 0x801FFFFE
    li t1, 0x0013
    sh t1, 0(t0)
    fence.i

    # Non-leaf PTEs that need link-time addresses
    la t0, pt_root
    la t1, pt_deny
    srli t1, t1, 12
    slli t1, t1, 10
    ori t1, t1, 1
    sd t1, 4*8(t0)                  # VPN2=4 -> pt_deny
    la t1, pt_spill
    srli t1, t1, 12
    slli t1, t1, 10
    ori t1, t1, 1
    sd t1, 0xFF*8(t0)               # VPN2=0xFF -> pt_spill

    srli t0, t0, 12
    li t1, 8
    slli t1, t1, 60
    or t0, t0, t1
    csrw satp, t0                   # Sv39, root pt_root
    sfence.vma

    la t0, nc_trap_handler
    csrw mtvec, t0
    li a0, 1
    ecall                           # S mode

    # Walk of the truncated address reaches a PTE in nonexistent memory
    TRY "ld s1, 0(s0)",             0x00000000C0000000,  5, 0x00000000C0000000, 0x10
    TRY "ld s1, 0(s0)",             0x00000080C0000000, 13, 0x00000080C0000000, 0x12
    TRY "ld s1, 0(s0)",             0xFFFFFF80C0000000, 13, 0xFFFFFF80C0000000, 0x14
    TRY "sd s1, 0(s0)",             0x00000000C0000000,  7, 0x00000000C0000000, 0x16
    TRY "sd s1, 0(s0)",             0x00000080C0000000, 15, 0x00000080C0000000, 0x18
    TRY "amoadd.d s1, s1, (s0)",    0x00000000C0000000,  7, 0x00000000C0000000, 0x1A
    TRY "amoadd.d s1, s1, (s0)",    0x00000080C0000000, 15, 0x00000080C0000000, 0x1C
    TRY "lw s1, 0(s0)",             0x00000000C0000001,  5, 0x00000000C0000001, 0x1E
    TRY "lw s1, 0(s0)",             0x00000080C0000001, 13, 0x00000080C0000001, 0x20
    TRY "sw s1, 0(s0)",             0x00000080C0000001, 15, 0x00000080C0000001, 0x22
    TRY "jalr zero, 0(s0)",         0x00000000C0000000,  1, 0x00000000C0000000, 0x24
    TRY "jalr zero, 0(s0)",         0x00000080C0000000, 12, 0x00000080C0000000, 0x26
    TRY "jalr zero, 0(s0)",         0xFFFFFF80C0000000, 12, 0xFFFFFF80C0000000, 0x28

    # Walk of the truncated address reaches a PMP-denied PTE
    TRY "ld s1, 0(s0)",             0x0000000100000000,  5, 0x0000000100000000, 0x30
    TRY "ld s1, 0(s0)",             0x0000008100000000, 13, 0x0000008100000000, 0x32
    TRY "sd s1, 0(s0)",             0x0000000100000000,  7, 0x0000000100000000, 0x34
    TRY "sd s1, 0(s0)",             0x0000008100000000, 15, 0x0000008100000000, 0x36
    TRY "jalr zero, 0(s0)",         0x0000000100000000,  1, 0x0000000100000000, 0x38
    TRY "jalr zero, 0(s0)",         0x0000008100000000, 12, 0x0000008100000000, 0x3A

    # Spilled fetch: first half at the top of the canonical range, second half at non-canonical 0x4000000000
    TRY "jalr zero, 0(s0)",         0x0000003FFFFFFFFE, 12, 0x0000004000000000, 0x40

    # Non-canonical alias of a mapping already in the TLB (hit path)
    li t0, 0x80000000
    ld s1, 0(t0)                    # DTLB holds the identity gigapage
    TRY "ld s1, 0(s0)",             0x0000008080000000, 13, 0x0000008080000000, 0x42
    TRY "jalr zero, 0(s0)",         0x0000008080000000, 12, 0x0000008080000000, 0x44

    # A non-canonical store must not set A/D in the PTE of its alias (VPN2=5 gigapage, A=D=0)
    la s2, scratch
    li t0, 0x80000000
    sub s2, s2, t0                  # offset of scratch within the gigapage
    li t0, 0x0000008140000000
    add s0, s2, t0                  # non-canonical alias of 0x140000000 + offset
    li s8, -1
    li s9, -1
    la s11, 1f
    sd s1, 0(s0)
1:  li t2, 15
    SC_CHECK_EQ s8, t2, 0x50
    SC_CHECK_EQ s9, s0, 0x51
    la t2, pt_root
    ld s3, 5*8(t2)
    li t2, 0x20000007               # A and D still 0
    SC_CHECK_EQ s3, t2, 0x52
    li t0, 0x0000000140000000
    add s0, s2, t0                  # canonical: the walk sets A and D
    li s8, -1
    sd s1, 0(s0)
    li t2, -1
    SC_CHECK_EQ s8, t2, 0x53        # no trap
    la t2, pt_root
    ld s3, 5*8(t2)
    li t2, 0x200000C7
    SC_CHECK_EQ s3, t2, 0x54

    SC_PASS
    j done

// Record mcause/mtval and resume at s11; forward interrupts and ecalls to the WALLY-init-lib.h handler
.align 4
nc_trap_handler:
    csrr s8, mcause
    bltz s8, nc_forward
    addi s10, s8, -8
    beqz s10, nc_forward            # ecall from U
    addi s10, s8, -9
    beqz s10, nc_forward            # ecall from S
    addi s10, s8, -11
    beqz s10, nc_forward            # ecall from M
    csrr s9, mtval
    csrw mepc, s11
    mret
nc_forward:
    j trap_handler

.data
.align 12
pt_root:
    .dword 0, 0
    .dword 0x200000CF               # VPN2=2:     identity gigapage 0x80000000, V R W X A D
    .dword 0x10000001               # VPN2=3:     non-leaf -> PA 0x40000000 (nonexistent)
    .dword 0                        # VPN2=4:     non-leaf -> pt_deny, filled in at run time
    .dword 0x20000007               # VPN2=5:     gigapage 0x80000000, V R W, A=D=0
    .fill 0xFF-6, 8, 0
    .dword 0                        # VPN2=0xFF:  non-leaf -> pt_spill, filled in at run time
    .dword 0x10000001               # VPN2=0x100: non-leaf -> PA 0x40000000 (nonexistent)
    .fill 0x1FF-0x100, 8, 0
pt_spill:
    .fill 0x1FF, 8, 0
    .dword 0x200000CB               # VPN1=0x1FF: megapage 0x80000000, V R X A D
pt_deny:
    .fill 512, 8, 0
scratch:
    .dword 0
