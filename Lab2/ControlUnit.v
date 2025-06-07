`include "Parametros.v"

module ControlUnit (
    input [6:0] opcode,     // Opcode da instrução
    input [2:0] funct3,     // Funct3 (campo da instrução)
    input funct7,           // Funct7 (bit 5, para operações como add/sub)
    output reg regWrite,    // Sinal para escrita no banco de registradores
    output reg [4:0] iControl, // Sinal de controle da ALU
    output reg memRead,     // Leitura de memória (lw)
    output reg memWrite,    // Escrita na memória (sw)
    output reg memToReg,    // Seleciona dado da memória vs. ULA
    output reg aluSrc,      // Seleciona registrador vs. imediato (2ª entrada ULA)
    output reg branch,      // Instrução de branch (beq)
    output reg jump,        // Instrução de jump (jal/jalr)
    output reg jalr         // Instrução jalr (diferente de jal)
);

// Usar parâmetros definidos em Parametros.v
always_comb begin
    // Valores padrão (sinais desativados)
    regWrite = 0;
    iControl = OPNULL;  // 5'd31 (valor seguro)
    memRead  = 0;
    memWrite = 0;
    memToReg = 0;
    aluSrc   = 0;
    branch   = 0;
    jump     = 0;
    jalr     = 0;

    case (opcode)
        OPC_RTYPE: begin // Instruções tipo R (add, sub, and, or, slt)
            regWrite = 1; // Habilita escrita no registrador
            case (funct3)
                3'b000: iControl = (funct7) ? OPSUB : OPADD; // ADD/SUB
                3'b111: iControl = OPAND;  // AND
                3'b110: iControl = OPOR;   // OR
                3'b010: iControl = OPSLT;  // SLT
                default: iControl = OPNULL; // Instrução inválida
            endcase
        end

        OPC_LOAD: begin // lw
            regWrite = 1;   // Escreve no registrador
            memRead  = 1;   // Habilita leitura da memória
            memToReg = 1;   // Seleciona dado da memória
            aluSrc   = 1;   // Usa imediato na ULA
            iControl = OPADD; // Calcula endereço (base + offset)
        end

        OPC_STORE: begin // sw
            memWrite = 1;   // Habilita escrita na memória
            aluSrc   = 1;   // Usa imediato na ULA
            iControl = OPADD; // Calcula endereço (base + offset)
        end

        OPC_BRANCH: begin // beq
            branch   = 1;   // Habilita branch
            iControl = OPSUB; // Subtrai para comparação (rs1 - rs2)
        end

        OPC_JAL: begin // jal
            regWrite = 1;   // Escreve PC+4 em rd
            jump     = 1;   // Habilita jump
            iControl = OPNULL; // ULA não usada
        end

        OPC_JALR: begin // jalr
            regWrite = 1;   // Escreve PC+4 em rd
            aluSrc   = 1;   // Usa imediato na ULA
				jump		= 1;	 // Habilita jump
            iControl = OPADD; // Calcula destino (rs1 + imm)
        end

        OPC_OPIMM: begin // addi
            regWrite = 1;   // Escreve no registrador
            aluSrc   = 1;   // Usa imediato na ULA
            if (funct3 == FUNCT3_ADD) begin
                iControl = OPADD; // ADD imediato
            end
        end

        default: ;
    endcase
end
endmodule