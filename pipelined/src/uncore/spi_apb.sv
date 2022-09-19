///////////////////////////////////////////
// gpio_apb.sv
//
// Written: Nicholas Lucio 18. Sep. 2022
// Modified:
//
// Purpose: Serial Peripheral Interface peripheral
//   See FE310-G002-Manual-v19p05 for specifications
// 
// A component of the Wally configurable RISC-V project.
// 
// Copyright (C) 2021 Harvey Mudd College & Oklahoma State University
//
// MIT LICENSE
// Permission is hereby granted, free of charge, to any person obtaining a copy of this 
// software and associated documentation files (the "Software"), to deal in the Software 
// without restriction, including without limitation the rights to use, copy, modify, merge, 
// publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons 
// to whom the Software is furnished to do so, subject to the following conditions:
//
//   The above copyright notice and this permission notice shall be included in all copies or 
//   substantial portions of the Software.
//
//   THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, 
//   INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR 
//   PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS 
//   BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, 
//   TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE 
//   OR OTHER DEALINGS IN THE SOFTWARE.
////////////////////////////////////////////////////////////////////////////////////////////////

`include "wally-config.vh"

module spi_apb (
  input  logic             PCLK, PRESETn,
  input  logic             PSEL,
  input  logic [7:0]       PADDR, 
  input  logic [`XLEN-1:0] PWDATA,
  input  logic [`XLEN/8-1:0] PSTRB,
  input  logic             PWRITE,
  input  logic             PENABLE,
  output logic [`XLEN-1:0] PRDATA,
  output logic             PREADY,
  input  logic [31:0]      iof0, iof1,
  input  logic [31:0]      GPIOPinsIn,
  output logic [31:0]      GPIOPinsOut, GPIOPinsEn,
  output logic             GPIOIntr);

  logic [11:0]  sckdiv;
  logic [1:0]   sckmode;
  logic [31:0]  csid, csdef, csmode;
  logic [23:0]  delay0, delay1;
  logic [19:0]  fmt;
  logic [31:0]  txdata, rxdata;
  logic [2:0]   txmark, rxmark;
  logic [1:0]   ie, ip;
  logic         fctrl;
  logic [31:0]  ffmt;


  logic [7:0] entry;
  logic [31:0] Din, Dout;
  logic memwrite;
  
  // APB I/O
  assign entry = {PADDR[7:2],2'b00};  // 32-bit word-aligned accesses
  assign memwrite = PWRITE & PENABLE & PSEL;  // only write in access phase
  assign PREADY = 1'b1; // GPIO never takes >1 cycle to respond

  // account for subword read/write circuitry
  // -- Note SPI registers are 32 bits no matter what; access them with LW SW.
  //    (At least that's what I think when FE310 spec says "only naturally aligned 32-bit accesses are supported")
  if (`XLEN == 64) begin
    assign Din =    entry[2] ? PWDATA[63:32] : PWDATA[31:0];
    assign PRDATA = entry[2] ? {Dout,32'b0}  : {32'b0,Dout};
  end else begin // 32-bit
    assign Din = PWDATA[31:0];
    assign PRDATA = Dout;
  end



endmodule

