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
	reg [0:15] InstructionMemory [15:0];
	reg [0:15] RegisterBank [7:0];
	reg [0:15] DataMemory[7:0];
	reg [3:0]pc;
	reg [15:0]instruction;
	reg [3:0] instructionIndex;
	reg [2:0] registerA;
	reg [2:0] registerB;
	reg [5:0] imediate;
	reg [15:0] tmpreg;
	reg [15:0] Gtmp;
	reg [8:0] imd;

	initial begin
		
		InstructionMemory[0] = 16'b0000001000000001;
		InstructionMemory[i] =
		InstructionMemory[i] =
		InstructionMemory[i] =
		InstructionMemory[i] =
		InstructionMemory[i] =
		InstructionMemory[i] =
		InstructionMemory[i] =
		InstructionMemory[i] =
		InstructionMemory[i] =
		InstructionMemory[i] =
		InstructionMemory[i] =
		InstructionMemory[i] =
		InstructionMemory[i] =
		InstructionMemory[i] =
		InstructionMemory[i] =
		pc = 0; 

		for(i=0;i<8;i=i+1) begin
			RegisterBank[i] = i;
		end
		
	end

	wire Clear = Done | ~Resetn | ~Run ;
	contador estagio(Clear, Clock,estagio_atual);
	assign I = IR[0:3];
	dec3to8 decX (IR[4:6], 1'b1, registradorX);
	dec3to8 decY (IR[7:9], 1'b1, registradorY);
	
	always @(/*estagio_atual or I or registrador1 or registrador2*/Clock or Done) begin
			//... specify initial values

			if(Done) begin
				pc = pc + 1'b0;
			end

			case (estagio_atual)
				2'b00: // busca instrução na memória
				begin
					//IRin = 1'b1;
					instruction = InstructionMemory[pc];
					instructionIndex = instruction[0:3];
					registerA = instruction[4:6];
					registerB = instruction[7:9];
					imediate = instruction[10:15];
				end
				2'b01: //define signals in time step 1
				case (I)
					4'b0000: //mv
					begin
						RegisterBank[registerA] = RegisterBank[registerB];
						Done = 1'b1;
					end
					
					4'b0001: //mvi
					begin
						RegisterBank[registerA] = {registerB,imediate};
						Done = 1'b1;
					end
					
					4'b0010: //add
					begin
						tmpreg = RegisterBank[registerA];
					end

					4'b0100: // sub 
					begin
						tmpreg = RegisterBank[registerA];
					end

					4'b0101: 
					begin
						Done = 1'b0;

					end
					4'b0110: 
					begin
						Done = 1'b0;

					end
					4'b0111: 
					begin
						Done = 1'b0;

					end
					4'b0000: 
					begin
						Done = 1'b0;

					end
					4'b0000: 
					begin
						Done = 1'b0;

					end
					4'b0000: 
					begin
						Done = 1'b0;

					end
					4'b0000: 
					begin
						Done = 1'b0;

					end
				endcase
				2'b10: //define signals in time step 2
				case (I)
					4'b0010:
					begin
						Gtmp = tmpreg + RegisterBank[registerB];
					end

					4'b0100:
					begin
						Gtmp = tmpreg - RegisterBank[registerB];
					end

				
				endcase
				2'b11: //define signals in time step 3
				case (I)
					4'b0010:
					begin
						RegisterBank[registerA] = Gtmp;
						Done = 1'b1;
					end

					4'b0100:
					begin
						RegisterBank[registerA] = Gtmp;
						Done = 1'b1;
					end

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