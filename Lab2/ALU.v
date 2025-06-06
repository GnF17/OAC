/*
 * ULA simplificada para apenas add, sub, and, or, slt, zero
 * por Gustavo Falcomer 190042800
 */

 `ifndef PARAM
	`include "Parametros.v"
`endif

`define RV32IM;
 
module ALU (
	input 		 [4:0]  iControl,
	input signed [31:0] iA, 
	input signed [31:0] iB,
	output logic [31:0] oResult,
	output OutZero	
	);

assign OutZero = (oResult ==32'b0);


always @(*)
begin
    case (iControl)
		OPAND:
			oResult  <= iA & iB;
		OPOR:
			oResult  <= iA | iB;
		OPADD:
			oResult  <= iA + iB;
		OPSUB:
			oResult  <= iA - iB;
		OPSLT:
			oResult  <= iA < iB;			
		default:
			oResult  <= 32'b0;
    endcase
end
endmodule
