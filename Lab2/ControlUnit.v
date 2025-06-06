module ControlUnit (
    input [6:0] opcode,     // Opcode da instrução
    input [2:0] funct3,     // Funct3 (campo da instrução)
    input funct7,           // Funct7 (para operações como add/sub)
    output reg regWrite,    // Sinal para controle do banco de registradores
    output reg [4:0] iControl  // Sinal de controle da ALU
);


	// Definir os valores de controle da ULA
	localparam OPADD = 5'b00011;
	localparam OPSUB = 5'b00100;
	localparam OPAND = 5'b00000;
	localparam OPOR  = 5'b00001;
	localparam OPSLT = 5'b00101;
	localparam OPZERO = 5'b11111;

	 // Controle para instruções do tipo R
	always_comb begin
		  // Inicializa todos os sinais
		  regWrite <= 0;
		  iControl <= OPZERO;  // Default para 'zero'

		  case (opcode)
				7'b0110011: begin  // Tipo R (funções add, sub, and, or, slt)
					 regWrite <= 1;  // Habilita a escrita no registrador
					 case (funct3)
						  3'b000: begin
								if (funct7) begin
									iControl <= OPADD;  // ADD
								end else begin
									iControl <= OPSUB; // SUB
								end
						  end
						  3'b111: iControl <= OPAND; // AND
						  3'b110: iControl <= OPOR;  // OR
						  3'b010: iControl <= OPSLT; // SLT
						  default: iControl <= OPZERO; // Default
					 endcase
				end
				default: begin
					 regWrite <= 0;
					 iControl <= OPZERO;  // Default para 'zero'
				end
		  endcase
	end
endmodule