///////////////////////////////////////////
// jtag_rbb.sv
//
// Written: David Harris David_Harris@hmc.edu with Claude, 8 November 2026
//
// Purpose: Lets a host debugger drive the DUT's JTAG pins live over the
//   remote_bitbang protocol (jtag_rbb.c), as it would drive Spike's --rbb-port.
//   Enabled by +RBB_PORT=<port> (0 picks a free port; the port is printed).
//   The simulation advances only while the host sends pin changes, and ends
//   when the host quits or disconnects.
//
// A component of the CORE-V-WALLY configurable RISC-V project.
// https://github.com/openhwfoundation/cvw
//
// Copyright (C) 2026 Harvey Mudd College & Oklahoma State University
//
// SPDX-License-Identifier: Apache-2.0 WITH SHL-2.1
////////////////////////////////////////////////////////////////////////////////////////////////

module jtag_rbb (
  output logic tck, tms, tdi,
  input  logic tdo,
  output logic Active        // a host drives the JTAG pins
);
  import "DPI-C" function int rbb_open(input int port);
  import "DPI-C" function int rbb_next(input int tdo);

  // Time between pin changes: half a TCK period, matching debugger.sv
  localparam int TCKHALF = 52;

  int port, listening, cmd;

  initial begin
    {tck, tms, tdi} = 3'b100;
    Active = 0;
    if ($value$plusargs("RBB_PORT=%d", port)) begin
      listening = rbb_open(port);
      if (listening < 0) $fatal(1, "jtag_rbb: cannot listen on port %0d", port);
      // The same words as Spike, so the same host tools can find the port
      $display("Listening for remote bitbang connection on port %0d.", listening);
      $fflush();
      Active = 1;
      forever begin
        cmd = rbb_next(int'(tdo === 1'b1));
        if (cmd < 0) begin
          $display("jtag_rbb: remote bitbang host disconnected; ending simulation");
          $finish;
        end
        {tck, tms, tdi} = cmd[2:0];
        #(TCKHALF);
      end
    end
  end
endmodule
