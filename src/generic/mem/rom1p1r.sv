///////////////////////////////////////////
// rom1p1r
//
// Written: David_Harris@hmc.edu 8/24/22
//
// Purpose: Single-ported ROM
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

// This model actually works correctly with Vivado.

module rom1p1r #(parameter ADDR_WIDTH = 8, DATA_WIDTH = 32, PRELOAD_ENABLED = 0)
  (input  logic                  clk,
   input  logic                  ce,
   input  logic [ADDR_WIDTH-1:0] addr,
   output logic [DATA_WIDTH-1:0] dout
);

  // Core Memory
  bit [DATA_WIDTH-1:0]    ROM [(2**ADDR_WIDTH)-1:0];

  // dh 10/30/23 ROM macros are presently commented out
  // because they don't point to a generated ROM
  /* if ((`USE_SRAM == 1) & (ADDR_WIDTH == 7) & (DATA_WIDTH == 64)) begin
    rom1p1r_128x64 rom1 (.CLK(clk), .CEB(~ce), .A(addr[6:0]), .Q(dout));

  end else if ((`USE_SRAM == 1) & (ADDR_WIDTH == 7) & (DATA_WIDTH == 32)) begin
    rom1p1r_128x32 rom1 (.CLK(clk), .CEB(~ce), .A(addr[6:0]), .Q(dout));

  end else begin */

  `ifdef VERILATOR
    import "DPI-C" function string getenvval(input string env_name);
  `endif

  initial
    if (PRELOAD_ENABLED) begin
      if (DATA_WIDTH == 64) begin
        `ifdef VERILATOR
          // because Verilator doesn't automatically accept $WALLY from shell
          static string WALLY_DIR = getenvval("WALLY");
          $readmemh({WALLY_DIR, "/fpga/src/boot.mem"}, ROM, 0);  // load boot ROM for FPGA
        `else
          $readmemh({"$WALLY/fpga/src/boot.mem"}, ROM, 0);  // load boot ROM for FPGA
        `endif
      end else begin // put something in the ROM so it is not optimized away
        ROM[0] = 'h00002197;
      end
    end

  always_ff @(posedge clk)
    if (ce) dout <= ROM[addr];

  // end  // closes the commented-out USE_SRAM if/else above

endmodule
