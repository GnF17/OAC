module ULAControl (
    input logic [6:0] opcode,   // OpCode da instrução
    input logic [2:0] funct3,    // Funct3 da instrução (para diferenciar as operações)
    input logic funct7,          // Funct7 para operações como add/sub (funct7[5] para a instrucao sub - 0100000)
    output logic [4:0] iControl  // Sinal de controle para a ULA
);

// Definir os valores de controle da ULA
localparam OPADD = 5'b00011;
localparam OPSUB = 5'b00100;
localparam OPAND = 5'b00000;
localparam OPOR  = 5'b00001;
localparam OPSLT = 5'b00101;
localparam OPZERO = 5'b11111;

always_comb begin
    // Valor padrão para iControl (ajuda a evitar 'XXXXX')
    iControl <= OPZERO;  // Valor padrão de segurança, garantindo que iControl sempre terá um valor válido

    case (opcode)
        7'b0110011:  // R-type
            case (funct3)
                3'b000: begin
                    if (funct7) begin // SUB
                        iControl <= OPSUB;
                    end else begin                 // ADD
                        iControl <= OPADD;
						  end
                end
                3'b111: iControl <= OPAND; // AND
                3'b110: iControl <= OPOR;  // OR
                3'b010: iControl <= OPSLT; // SLT				
                default: iControl <= OPZERO; // Default (caso não seja nenhuma operação válida)
            endcase
        default: iControl <= OPZERO; // OpCode inválido ou não suportado
    endcase
end

endmodule