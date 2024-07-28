`timescale 1ns / 1ps

module alu#(
        parameter DATA_WIDTH = 32,
        parameter OPCODE_LENGTH = 4
        )
        (
        input logic [DATA_WIDTH-1:0]    SrcA,
        input logic [DATA_WIDTH-1:0]    SrcB,

        input logic [OPCODE_LENGTH-1:0]    Operation,
        output logic[DATA_WIDTH-1:0] ALUResult
        );
    
        always_comb
        begin
            case(Operation)
                4'b0000:        // AND - 0
                        ALUResult = SrcA & SrcB;
                4'b0001:        // OR - 1
                        ALUResult = SrcA | SrcB;  
                4'b0010:        // ADD && ADDI - 2
                        ALUResult = $signed(SrcA) + $signed(SrcB);
                4'b0011:        // SUB - 3
                        ALUResult = SrcA - SrcB;
                4'b0100:        // XOR - 4
                        ALUResult = SrcA ^ SrcB;
                4'b0101:        // SRAI - 5
                        ALUResult = SrcA >>> $signed(SrcB[4:0]);
                4'b0110:        // SLLI - 6
                        ALUResult = SrcA << $signed(SrcB[4:0]);
                4'b0111:        // SRLI - 7
                        ALUResult = $signed(SrcA) >> $signed(SrcB[4:0]);
                4'b1000:        // BEQ - 8
                        ALUResult = (SrcA == SrcB) ? 1 : 0;
                4'b1001:        // SLT && SLTI - 9
                        ALUResult = ($signed(SrcA) < $signed(SrcB)) ? 1 : 0;
                4'b1010:       // BNE - 10
                        ALUResult = (SrcA != SrcB) ? 1 : 0;
                4'b1011:       // BLT - 11
                        ALUResult = ($signed(SrcA) < $signed(SrcB)) ? 1 : 0;
                4'b1100:       // BGE - 12
                        ALUResult = (($signed(SrcA) > $signed(SrcB)) || ($signed(SrcA) == $signed(SrcB))) ? 1 : 0;
                default:
                        ALUResult = 0;
            endcase
        end
endmodule

