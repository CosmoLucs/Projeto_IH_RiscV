`timescale 1ns / 1ps

module ALUController (
    //Inputs
    input logic [1:0] ALUOp,  // 2-bit opcode field from the Controller--
    //00: LW/SW/AUIPC; 
    //01:Branch; 
    //10: R-type/I-type; 
    //11:JAL/LUI
    input logic [6:0] Funct7,  // bits 25 to 31 of the instruction
    input logic [2:0] Funct3,  // bits 12 to 14 of the instruction

    //Output
    output logic [3:0] Operation  // operation selection for ALU
);

  /* Nosso código começa aqui */

  assign Operation[0] =
    // R\I - OR 
    ((ALUOp == 2'b10) && (Funct3 == 3'b110) && (Funct7 == 7'b0000000)) ||     
    // R\I - SUB
    ((ALUOp == 2'b10) && (Funct3 == 3'b000) && (Funct7 == 7'b0100000)) ||
    // R/I - SRAI
    ((ALUOp == 2'b10) && (Funct3 == 3'b101) && (Funct7 == 7'b0100000)) ||
    // R\I - SRLI
    ((ALUOp == 2'b10) && (Funct3 == 3'b101) && (Funct7 == 7'b0000000)) ||
    // R\I - SLT
    ((ALUOp == 2'b10) && (Funct3 == 3'b010))||
    // Branch - BLT
    ((ALUOp == 2'b01) && (Funct3 == 100));         

////////////////////////////////////////////////////////////////////////////////////////////////

  assign Operation[1] = 
    // LW\SW
    (ALUOp == 2'b00) ||  
    // R\I - ADD
    ((ALUOp == 2'b10) && (Funct3 == 3'b000))||  
    // R\I - SUB
    ((ALUOp == 2'b10) && (Funct3 == 3'b000) && (Funct7 == 7'b0100000)) ||
    // R\I - SLLI
    ((ALUOp == 2'b10) && (Funct3 == 3'b001) && (Funct7 == 7'b0000000)) ||
    // R\I - SRLI
    ((ALUOp == 2'b10) && (Funct3 == 3'b101) && (Funct7 == 7'b0000000)) ||
    // Branch - BNE
    ((ALUOp == 2'b01) && (Funct3 == 001))||
    // Branch - BLT
    ((ALUOp == 2'b01) && (Funct3 == 100)); 

////////////////////////////////////////////////////////////////////////////////////////////////

  assign Operation[2] =  
    // R\I - Xor
    ((ALUOp == 2'b10) && (Funct3 == 3'b100) && (Funct7 == 7'b0000000)) ||
    // R/I - SRAI
    ((ALUOp == 2'b10) && (Funct3 == 3'b101) && (Funct7 == 7'b0100000)) ||
    // R\I - SLLI
    ((ALUOp == 2'b10) && (Funct3 == 3'b001) && (Funct7 == 7'b0000000)) ||
    // R\I - SRLI
    ((ALUOp == 2'b10) && (Funct3 == 3'b101) && (Funct7 == 7'b0000000)) ||
    // Branch - BGE
    ((ALUOp == 2'b01) && (Funct3 == 101));
    
////////////////////////////////////////////////////////////////////////////////////////////////

  assign Operation[3] = 
    // BEQ
    ((ALUOp == 2'b01) && (Funct3 == 3'b000)) ||
    // R\I - SLT/I
    ((ALUOp == 2'b10) && (Funct3 == 3'b010)) ||
    // Branch - BNE
    ((ALUOp == 2'b01) && (Funct3 == 001)) ||
    // Branch - BLT
    ((ALUOp == 2'b01) && (Funct3 == 100)) ||
    // Branch - BGE
    ((ALUOp == 2'b01) && (Funct3 == 101));

    /*Nosso código termina aqui */
endmodule
