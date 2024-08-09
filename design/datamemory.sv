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

/* Nosso código começa aqui */

  always_ff @(*) begin
    raddress <= {23'b0, a};
    waddress <= {23'b0, a[8:2], 2'b0};
    Datain <= wd;
    Wr <= 4'b0000;

    //============================== LOAD ======================================
    if (MemRead) begin
      /* 
        - Em rd escreve valor de saída do Dataout, se valor lido tem tamanho menor,
        preenche os bits que sobram com o bit de sinal (isso preserva o sinal na re
        presentação de negativos com complemento a 2)
          - No LBU preenche os 24 bits com 0 pois o sinal é implicitamente positivo
        - Em raddress escreve o endereço a ser lido, aproximando para baixo quando 
        se tenta ler um endereço que não é múltiplo do tamanho do tipo lido (lw no
        endereço 5 vai para o endereço 4, lh no endereço 15 vai pra 14)
      */
      case (Funct3)
        3'b000: begin  //LB
          Wr <= 4'b0001;
          rd[31:0] <= {{24{Dataout[7]}}, Dataout[7:0]};
          raddress[31:0] <= {23'b0, a};
        end
        3'b001: begin  //LH
          Wr <= 4'b0011;
          rd[31:0] <= {{16{Dataout[15]}}, Dataout[15:0]};
          raddress[31:0] <= {23'b0, a[8:1], 1'b0};
        end
        3'b100: begin  //LBU
          Wr <= 4'b0001;
          rd[31:0] <= {24'b0, Dataout[7:0]};
          raddress[31:0] <= {23'b0, a};
        end
        default: begin // por default, trata como LW
          Wr <= 4'b1111;
          rd[31:0] <= Dataout[31:0];
          raddress[31:0] <= {23'b0, a[8:2], 2'b00};
          
        end
      endcase
    //============================== READ ======================================
    end else if (MemWrite) begin
      case (Funct3)
      /*
        - Em Wr se representa quais blocos de memória se poderá editar
          - ex: sb só escreve no primeiro byte [x] [x] [x] [s]
            então Wr fica 0001 para que não se alterem os endereços adjacentes
        - Em Datain se escreve o valor em wd para ser escrito na memória, se 
          valor lido tem tamanho menor, preenche os bits que sobram com o bit 
          de sinal (isso preserva o sinal na representação de negativos com com
          plemento a 2) (mas preencher isso meio q não importa, já q esses bits
          q sobram n serão escritos)
        - Em wadress escreve onde se vai escrever, aproximando para baixo quando 
          se tenta esrcever num endereço que não é múltiplo do tamanho do tipo 
          (sw no endereço 5 vai para o endereço 4, sh no endereço 15 vai pra 14)
      */
        3'b000: begin  //SB
          Wr <= 4'b0001;
          Datain[31:0] <= {{24{wd[7]}}, wd[7:0]};
          waddress[31:0] <= {23'b0, a};
        end
        3'b001: begin  //SH
          Wr <= 4'b0011;
          Datain[31:0] <= {{16{wd[15]}}, wd[15:0]};
          waddress[31:0] <= {23'b0, a[8:1], 1'b0};
        end
        default: begin // por default, trata como SW
          Wr <= 4'b1111;
          Datain[31:0] <= wd[31:0];
          waddress[31:0] <= {23'b0, a[8:2], 2'b00};
        end
      endcase
    end
    //==========================================================================
  end

/*Nosso código termina aqui */

endmodule
