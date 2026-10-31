///////////////////////////////////////////
// amoread.sv
//
// Purpose: Select an AMO operand without general load formatting
//
// A component of the CORE-V-WALLY configurable RISC-V project.
// https://github.com/openhwfoundation/cvw
//
// SPDX-License-Identifier: Apache-2.0 WITH SHL-2.1
//
// Licensed under the Solderpad Hardware License v 2.1 (the "License"); you may not use this file
// except in compliance with the License, or, at your option, the Apache License version 2.0. You
// may obtain a copy of the License at
//
// https://solderpad.org/licenses/SHL-2.1/
//
// Unless required by applicable law or agreed to in writing, any work distributed under the
// License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND,
// either express or implied. See the License for the specific language governing permissions
// and limitations under the License.
////////////////////////////////////////////////////////////////////////////////////////////////

module amoread import cvw::*; #(parameter cvw_t P, parameter MINWIDTH = 32) (
  input  logic [P.LLEN-1:0] ReadDataWordM, // Data already byte-swapped for big endian
  input  logic [3:0]        PAdrM,
  input  logic              BigEndianM,
  input  logic [1:0]        SizeM,         // log2(operand size in bytes)
  output logic [P.XLEN-1:0] AMOReadDataM
);

  localparam ADRBITS = $clog2(P.LLEN/8);
  localparam NUMWIDTHS = $clog2(P.XLEN/MINWIDTH)+1;
  logic [ADRBITS-1:0] LaneAdrM;
  logic [P.XLEN-1:0] Operands [NUMWIDTHS];

  // Match subwordread's lane convention after the LSU endian swap.
  if (P.BIGENDIAN_SUPPORTED) assign LaneAdrM = PAdrM[ADRBITS-1:0] ^ {ADRBITS{BigEndianM}};
  else                       assign LaneAdrM = PAdrM[ADRBITS-1:0];

  for (genvar i = 0; i < NUMWIDTHS; i++) begin : widths
    localparam WIDTH = MINWIDTH << i;
    localparam SIZE = $clog2(WIDTH/8);
    logic [WIDTH-1:0] Operand;

    // Each width selects directly from the input, independently of other widths.
    if (WIDTH == P.LLEN) assign Operand = ReadDataWordM;
    else assign Operand = ReadDataWordM[WIDTH*LaneAdrM[ADRBITS-1:SIZE] +: WIDTH];
    assign Operands[i] = {P.XLEN{SizeM == 2'(SIZE)}} & {{P.XLEN-WIDTH{1'b0}}, Operand};
  end

  // Parallel width decode and OR selection; unsupported widths produce zero.
  always_comb begin
    AMOReadDataM = '0;
    for (int i = 0; i < NUMWIDTHS; i++) AMOReadDataM |= Operands[i];
  end
endmodule
