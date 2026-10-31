// Focused AMO operand, ALU, and store-format checks, including future narrow widths.
// SPDX-License-Identifier: Apache-2.0 WITH SHL-2.1
// Run from the repository root after sourcing setup.sh:
// $ verilator --binary --timing --top-module testbench_amo \
//   -Iconfig/shared --Mdir /tmp/wally-amo-test src/cvw.sv testbench/testbench_amo.sv \
//   src/lsu/{amoread,amoalu,subwordread,subwordwrite,endianswap}.sv src/ieu/comparator.sv \
//   src/generic/mux.sv
// /tmp/wally-amo-test/Vtestbench_amo

module amocheck import cvw::*; #(
  parameter int XLEN = 64, LLEN = 64, MINWIDTH = 32, BE = 1
)(output logic Done);
  function automatic cvw_t parameters();
    cvw_t p;
    p = '0;
    p.XLEN = XLEN;
    p.LLEN = LLEN;
    p.BIGENDIAN_SUPPORTED = 1'(BE);
    return p;
  endfunction
  localparam cvw_t P = parameters();
  localparam logic [4:0] OPS [9] = '{5'b00001, 5'b00000, 5'b00100, 5'b01100, 5'b01000,
                                           5'b10000, 5'b10100, 5'b11000, 5'b11100};
  logic [LLEN-1:0] RawData, WordData, LoadData, StoreData, ExtendedResult;
  logic [XLEN-1:0] Operand, B, Result;
  logic [3:0] Adr;
  logic [2:0] Funct3;
  logic [6:0] Funct7;
  logic BigEndian;
  logic [63:0] ARef, BRef, YRef, Mask;
  longint signed SA, SB;
  int Checks;

  endianswap #(LLEN) swap(BE != 0 && BigEndian, RawData, WordData);
  amoread #(P, MINWIDTH) readamo(WordData, Adr, BigEndian, Funct3[1:0], Operand);
  subwordread #(P) readload(WordData, Adr, Funct3, 1'b0, BigEndian, LoadData);
  amoalu #(P, MINWIDTH) alu(Operand, B, Funct7, Funct3, Result);
  assign ExtendedResult = {{LLEN-XLEN{1'b0}}, Result};
  subwordwrite #(LLEN) store(Funct3, ExtendedResult, StoreData);

  initial begin
    Done = 0;
    Checks = 0;
    // Random data plus zero, all-one, sign-boundary, and overflow operands.
    for (int trial = 0; trial < 40; trial++) begin
      for (int size = $clog2(MINWIDTH/8); size <= $clog2(XLEN/8); size++) begin
        for (int endian = 0; endian <= BE; endian++) begin
          for (int lane = 0; lane < LLEN/8; lane += (1 << size)) begin
            Funct3 = 3'(size);
            Adr = 4'(lane);
            BigEndian = 1'(endian);
            Mask = 64'hffffffffffffffff >> (64-(8 << size));
            for (int byteidx = 0; byteidx < LLEN/8; byteidx++)
              RawData[8*byteidx +: 8] = 8'($urandom);
            B = XLEN'({$urandom, $urandom});
            if (trial < 4) begin
              case (trial)
                0: begin ARef = 0; B = '1; end
                1: begin ARef = Mask; B = 1; end
                2: begin ARef = 64'h1 << ((8 << size)-1); B = XLEN'(ARef-1); end
                3: begin ARef = (64'h1 << ((8 << size)-1))-1; B = XLEN'(ARef+1); end
              endcase
              for (int j = 0; j < (1 << size); j++)
                RawData[8*(lane+j) +: 8] = endian != 0 ? ARef[8*((1 << size)-1-j) +: 8] : ARef[8*j +: 8];
            end

            // Independent byte-addressed memory model, before endian swapping.
            ARef = 0;
            for (int j = 0; j < (1 << size); j++) begin
              if (endian != 0) ARef = (ARef << 8) | 64'(RawData[8*(lane+j) +: 8]);
              else ARef |= 64'(RawData[8*(lane+j) +: 8]) << (8*j);
            end
            BRef = 64'(B) & Mask;
            SA = $signed(ARef << (64-(8 << size))) >>> (64-(8 << size));
            SB = $signed(BRef << (64-(8 << size))) >>> (64-(8 << size));

            for (int op = 0; op < 9; op++) begin
              Funct7 = {OPS[op], 2'b00};
              case (op)
                0: YRef = BRef;
                1: YRef = ARef+BRef;
                2: YRef = ARef^BRef;
                3: YRef = ARef&BRef;
                4: YRef = ARef|BRef;
                5: YRef = SA < SB ? ARef : BRef;
                6: YRef = SA > SB ? ARef : BRef;
                7: YRef = ARef < BRef ? ARef : BRef;
                8: YRef = ARef > BRef ? ARef : BRef;
              endcase
              YRef &= Mask;
              #1;
              if (64'(Operand) !== ARef || (64'(LoadData) & Mask) !== ARef)
                $fatal(1, "Operand mismatch XLEN=%0d LLEN=%0d MINWIDTH=%0d endian=%0d size=%0d lane=%0d",
                       XLEN, LLEN, MINWIDTH, endian, size, lane);
              if ((64'(Result) & Mask) !== YRef)
                $fatal(1, "ALU mismatch XLEN=%0d MINWIDTH=%0d size=%0d op=%0d a=%h b=%h got=%h expected=%h",
                       XLEN, MINWIDTH, size, op, ARef, BRef, Result, YRef);
              for (int j = 0; j < LLEN/8; j++)
                if (StoreData[8*j +: 8] !== YRef[8*(j % (1 << size)) +: 8])
                  $fatal(1, "Store replication mismatch size=%0d byte=%0d", size, j);
              Checks++;
            end
          end
        end
      end
    end
    $display("PASS XLEN=%0d LLEN=%0d MINWIDTH=%0d BE=%0d: %0d checks", XLEN, LLEN, MINWIDTH, BE, Checks);
    Done = 1;
  end
endmodule

module testbench_amo;
  wire [29:0] Done;
  for (genvar m = 0; m < 3; m++) begin : minwidths
    for (genvar b = 0; b < 2; b++) begin : endians
      amocheck #(32, 32, 8 << m, b) c32(Done[m*10+b*5]);
      amocheck #(32, 64, 8 << m, b) c32f(Done[m*10+b*5+1]);
      amocheck #(32, 128, 8 << m, b) c32q(Done[m*10+b*5+2]);
      amocheck #(64, 64, 8 << m, b) c64(Done[m*10+b*5+3]);
      amocheck #(64, 128, 8 << m, b) c64q(Done[m*10+b*5+4]);
    end
  end
  initial begin
    wait (&Done);
    $display("All AMO datapath checks passed");
    $finish;
  end
endmodule
