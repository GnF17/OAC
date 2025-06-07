`include "Parametros.v"

module ULAControl (
    input logic [6:0] opcode,   // OpCode da instrução
    input logic [2:0] funct3,   // Funct3 da instrução
    input logic funct7,         // Bit 5 do funct7 (para sub)
    output logic [4:0] iControl // Sinal de controle para a ULA
);

// Definir valores de controle da ULA (consistentes com Parametros.v)
localparam 
    OPADD  = 5'd3,  // 5'b00011
    OPSUB  = 5'd4,  // 5'b00100
    OPAND  = 5'd0,  // 5'b00000
    OPOR   = 5'd1,  // 5'b00001
    OPSLT  = 5'd5,  // 5'b00101
    OPZERO = 5'd31; // 5'b11111 (OPNULL)

always_comb begin
    iControl <= OPZERO; // Valor padrão (saída zero)

    case (opcode)
        OPC_RTYPE: begin // Tipo R (add, sub, and, or, slt)
            case (funct3)
                3'b000: iControl <= (funct7) ? OPSUB : OPADD;
                3'b111: iControl <= OPAND;
                3'b110: iControl <= OPOR;
                3'b010: iControl <= OPSLT;
                default: iControl <= OPZERO;
            endcase
        end

        OPC_LOAD:  iControl <= OPADD;  // lw (cálculo de endereço)
        OPC_STORE: iControl <= OPADD;  // sw (cálculo de endereço)

        OPC_BRANCH: begin // beq (subtração para comparação)
            if (funct3 == FUNCT3_BEQ) iControl <= OPSUB;
            else iControl <= OPZERO;
        end

        OPC_JALR: begin // jalr (adição: rs1 + imm)
            if (funct3 == FUNCT3_JALR) iControl <= OPADD;
            else iControl <= OPZERO;
        end

        OPC_JAL:   iControl <= OPZERO; // jal (não usa ULA)

        OPC_OPIMM: begin // addi (adição: rs1 + imm)
            if (funct3 == FUNCT3_ADD) iControl <= OPADD;
            else iControl <= OPZERO;
        end

        default: iControl <= OPZERO; // Instrução não suportada
    endcase
end
endmodule