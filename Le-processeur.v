module processador (DIN, Resetn, Clock, Run, Done, BusWires);
	input [15:0] DIN; //dado de entrada
	input Resetn, Clock, Run;
	output Done; //sinal que informa se a instruçao ja terminou
	output [15:0] BusWires;
	
	wire [15:0]Rdata[7:0];//dados dos registradores
	wire [15:0]Gdata;//dado do registrador G
	wire [15:0]Adata;//dado do registrador A
	wire [15:0]saida_ula;//valor calculado pela ULA
	wire [1:0]estagio_atual;//estagio do processamento da instrução
	reg [7:0]Rout;//sinal de controle do mux. De qual registrador virá a saida do mux
	reg [7:0]Rin;// sinal de controle dos registradores. Condiciona se ocorrerá a escrita neles
	wire [3:0]I;// armazena a instrução(4 primeiros bits)
	wire [0:9]IR;//instrução
	reg IRin;
	reg DINout;
	reg Ain;
	reg Gout;
	reg Gin;

	wire Clear = Done | ~Resetn | ~Run ;
	contador estagio(Clear, Clock,estagio_atual);
	assign I = IR[0:3];
	dec3to8 decX (IR[4:6], 1'b1, registradorX);
	dec3to8 decY (IR[7:9], 1'b1, registradorY);
	
	always @(estagio_atual or I or registrador1 or registrador2) begin
			//... specify initial values
			case (estagio_atual)
				2'b00: // busca instrução na memória
				begin
					IRin = 1'b1;
				end
				2'b01: //define signals in time step 1
				case (I)
					4'b0000: //mv
					begin
						Done = 1'b1;
						Rout = registradorY;
						Rin = registradorX;
					end
					
					4'b0001: //mvi
					begin
						Done = 1'b1;
						DINout = 1'b1;
						Rin = registradorX;
					end
					
					4'b0010: //add
					begin
						Done = 1'b0;

					end
					4'b0100: //mv
					begin
						Done = 1'b0;

					end
					4'b0101: //mv
					begin
						Done = 1'b0;

					end
					4'b0110: //mv
					begin
						Done = 1'b0;

					end
					4'b0111: //mv
					begin
						Done = 1'b0;

					end
					4'b0000: //mv
					begin
						Done = 1'b0;

					end
					4'b0000: //mv
					begin
						Done = 1'b0;

					end
					4'b0000: //mv
					begin
						Done = 1'b0;

					end
					4'b0000: //mv
					begin
						Done = 1'b0;

					end
				endcase
				2'b10: //define signals in time step 2
				case (I)
					
				
				endcase
				2'b11: //define signals in time step 3
				case (I)
				
				endcase
			endcase
	end
	regn reg_0 (BusWires, Rin[0], Clock, R0);
	regn reg_1 (BusWires, Rin[1], Clock, R1);
	//... instantiate other registers and the adder/subtracter unit
	//... define the bus
endmodule

module contador(Clear, Clock, Q);
	input Clear, Clock;
	output reg [1:0] Q;
	
	always @(posedge Clock)begin
		if (Clear)
			Q <= 2’b0;
		else
			Q <= Q + 1’b1;
	end 
	
endmodule

module dec3to8(W, En, Y);
	input [2:0] W;
	input En;
	output [0:7] Y;
	reg [0:7] Y;
	
	always @(W or En) begin
		if (En == 1)
			case (W)
			3'b000: Y = 8'b10000000;
			3'b001: Y = 8'b01000000;
			3'b010: Y = 8'b00100000;
			3'b011: Y = 8'b00010000;
			3'b100: Y = 8'b00001000;
			3'b101: Y = 8'b00000100;
			3'b110: Y = 8'b00000010;
			3'b111: Y = 8'b00000001;
			endcase
		else
			Y = 8'b00000000;
		end
endmodule

module regn(R, Rin, Clock, Q);
	parameter n = 16;
	input [n-1:0] R;
	input Rin, Clock;
	output [n-1:0] Q;
	reg [n-1:0] Q;
	
	always @(posedge Clock)
		if (Rin)
			Q <= R;

endmodule