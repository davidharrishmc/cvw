///////////////////////////////////////////
// fma.sv
//
// Written:  6/23/2021 me@KatherineParry.com, David_Harris@hmc.edu
// Modified:
//
// Purpose: Floating point multiply-accumulate of configurable size
//
// Documentation: RISC-V System on Chip Design
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

module fma import cvw::*;  #(parameter cvw_t P) (
  input  logic                         Xs, Ys, Zs,             // input's signs
  input  logic [P.NE-1:0]              Xe, Ye, Ze,             // input's biased exponents in B(NE.0) format
  input  logic [P.NF:0]                Xm, Ym, Zm,             // input's significands in U(0.NF) format
  input  logic                         XZero, YZero, ZZero,    // is the input zero
  input  logic [2:0]                   OpCtrl,                 // operation control
  output logic                         ASticky,                // sticky bit that is calculated during alignment
  output logic [P.FMALEN-1:0]          Sm,                     // the positive sum's significand
  output logic                         InvA,                   // Was A inverted for effective subtraction (P-A or -P+A)
  output logic                         As,                     // the aligned addend's sign (modified Z sign for other operations)
  output logic                         Ps,                     // the product's sign
  output logic                         Ss,                     // the sum's sign
  output logic [P.NE+1:0]              Se,                     // the sum's exponent
  output logic [$clog2(P.FMALEN+1)-1:0] SCnt                    // normalization shift count
);

  //  OpCtrl:
  //    Fma: {not multiply-add?, negate prod?, negate Z?}
  //        000 - fmadd
  //        001 - fmsub
  //        010 - fnmsub
  //        011 - fnmadd
  //        100 - mul
  //        110 - add
  //        111 - sub

  logic [2*P.NF+1:0]   Pm;         // the product's significand in U(2.2Nf) format
  logic [P.FMALEN-1:0] Am;         // addend aligned's mantissa for addition in U(NF+4.2NF+1)
  logic [P.FMALEN-1:0] AmInv;      // aligned addend's mantissa possibly inverted
  logic [2*P.NF+1:0]   PmKilled;   // the product's mantissa possibly killed U(2.2Nf)
  logic                KillProd;   // set the product to zero before addition if the product is too small to matter
  logic [P.NE+1:0]     Pe;         // the product's exponent B(NE+2.0) format; adds 2 bits to allow for size of number and negative sign
  logic                XMinSub, YMinSub; // multiplicand is the smallest subnormal
  logic [P.NE-1:0]     XeM, YeM;   // multiplicand exponents
  logic [P.NF:0]       XmM, YmM;   // multiplicand significands

  // Present the smallest subnormal multiplicand as 2^-(NF-1) with biased exponent 0 rather than 2^-NF with exponent 1,
  // so the product has at most NF-1 leading zeros and the adder needs only one bit below the product (issue #970).
  assign XMinSub = ~Xm[P.NF] & ~|Xm[P.NF-1:1] & Xm[0];
  assign YMinSub = ~Ym[P.NF] & ~|Ym[P.NF-1:1] & Ym[0];
  assign XmM = {Xm[P.NF:2], Xm[1] | XMinSub, Xm[0] & ~XMinSub};
  assign YmM = {Ym[P.NF:2], Ym[1] | YMinSub, Ym[0] & ~YMinSub};
  assign XeM = {Xe[P.NE-1:1], Xe[0] & ~XMinSub};
  assign YeM = {Ye[P.NE-1:1], Ye[0] & ~YMinSub};

  ///////////////////////////////////////////////////////////////////////////////
  // Calculate the product
  //      - When multipliying two fp numbers, add the exponents
  //      - Subtract the bias (XExp + YExp has two biases, one from each exponent)
  //      - If the product is zero then kill the exponent
  //      - Multiply the mantissas
  ///////////////////////////////////////////////////////////////////////////////

  // calculate the product's exponent
  fmaexpadd #(P) expadd(.Xe(XeM), .Ye(YeM), .XZero, .YZero, .Pe);

  // multiplication of the mantissa's
  fmamult #(P) mult(.Xm(XmM), .Ym(YmM), .Pm);

  // calculate the signs and take the operation into account
  fmasign sign(.OpCtrl, .Xs, .Ys, .Zs, .Ps, .As, .InvA);

  ///////////////////////////////////////////////////////////////////////////////
  // Alignment shifter
  ///////////////////////////////////////////////////////////////////////////////

  fmaalign #(P) align(.Ze, .Zm, .XZero, .YZero, .ZZero, .Xe(XeM), .Ye(YeM), .Am, .ASticky, .KillProd);

  // ///////////////////////////////////////////////////////////////////////////////
  // // Addition/LZA
  // ///////////////////////////////////////////////////////////////////////////////

  fmaadd #(P) add(.Am, .Pm, .Ze, .Pe, .Ps, .KillProd, .ASticky, .AmInv, .PmKilled, .InvA, .Sm, .Se, .Ss);

  fmalza #(P.FMALEN, P.NF) lza(.A(AmInv), .Pm(PmKilled), .Cin(InvA & (~ASticky | KillProd)), .sub(InvA), .SCnt);

endmodule
