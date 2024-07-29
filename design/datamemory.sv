`timescale 1ns / 1ps

module datamemory #(
    parameter DM_ADDRESS = 9,
    parameter DATA_W = 32
) (
    input logic clk,
    input logic MemRead,  // comes from control unit
    input logic MemWrite,  // Comes from control unit
    input logic [DM_ADDRESS - 1:0] a,  // Read / Write address - 9 LSB bits of the ALU output
    input logic [DATA_W - 1:0] wd,  // Write Data
    input logic [2:0] Funct3,  // bits 12 to 14 of the instruction
    output logic [DATA_W - 1:0] rd  // Read Data
);

  logic [31:0] raddress;
  logic [31:0] waddress;
  logic [31:0] Datain;
  logic [31:0] Dataout;
  logic [ 3:0] Wr;

  Memoria32Data mem32 (
      .raddress(raddress),
      .waddress(waddress),
      .Clk(~clk),
      .Datain(Datain),
      .Dataout(Dataout),
      .Wr(Wr)
  );

  always_ff @(*) begin
    Datain = wd;
    Wr = 4'b0000;

    //============================== LOAD ======================================
    if (MemRead) begin
      case (Funct3)
        3'b000: begin  //LB
          rd[31:0] <= {{24{Dataout[31]}}, Dataout[7:0]};
          raddress <= {{23{a[8]}}, a};
        end
        3'b001: begin  //LH
          rd[31:0] <= {{16{Dataout[31]}}, Dataout[15:0]};
          raddress <= {{23{a[8]}}, {a[8:1], {1{1'b0}}}};
        end
        3'b100: begin  //LBU
          rd[31:0] <= {{24{1'b0}}, Dataout[7:0]};
          raddress <= {{23{a[8]}}, a};
        end
        default: begin // por default, trata como LW
          rd[31:0] <= Dataout[31:0];
          raddress <= {{23{a[8]}}, {a[8:2], {2{1'b0}}}};
        end
      endcase
    //============================== READ ======================================
    end else if (MemWrite) begin
      case (Funct3)
        3'b000: begin  //SB
          Wr <= 4'b0001;         //???? o que é isso? o Wr?
          Datain[31:0] <= {{24{wd[31]}}, wd[7:0]};
          waddress <= {{23{a[8]}}, a};
        end
        3'b001: begin  //SH
          Wr <= 4'b0011;
          Datain[31:0] <= {{16{wd[31]}}, wd[15:0]};
          waddress <= {{23{a[8]}}, {a[8:1], {1{1'b0}}}};
        end
        default: begin // por default, trata como SW
          Wr <= 4'b1111;
          Datain[31:0] <= wd[31:0];
          waddress <= {{23{a[8]}}, {a[8:2], {2{1'b0}}}};
        end
      endcase
    end
    //==========================================================================
  end

endmodule
