module processor(DIN, Resetn, Clock, Run, Done);
	input [15:0] DIN; //dado de entrada
	input Resetn, Clock, Run;
	output Done; //sinal que informa se a instruçao ja terminou
	
	reg [15:0] InstructionMemory [15:0]; //Memória de instruções
	reg [15:0] RegisterBank [7:0]; // Banco de registradores
	reg [15:0] DataMemory [7:0]; // Memória de dados
	reg [3:0]  pc; // index da memória de instruções
	reg [1:0]  curr_stage; // estagio da instrução
	reg [15:0] instruction; // instrução 16 bits
	reg [3:0]  instructionIndex;// índice da instrução a ser executada
	reg [2:0]  reg_A;
	reg [2:0]  reg_B;
	reg [5:0]  imediate;
	reg [15:0] tmpreg;
	reg [15:0] Gtmp;
	reg [15:0] memory_data;

	output reg [15:0]out;

	initial begin
		
		InstructionMemory[0]  = 16'b0000_001_010_000000;//mv  R1,R2  | R.E = 2
		InstructionMemory[1]  = 16'b0001_010_000_000101;//mvi R2,5	 | R.E = 5
		InstructionMemory[2]  = 16'b0010_010_011_000000;//add R2,R3  | R.E = 8
		InstructionMemory[3]  = 16'b0000_001_000_000001;//sub
		InstructionMemory[4]  = 16'b0000_001_000_000001;//and
		InstructionMemory[5]  = 16'b0000_001_000_000001;//slt
		InstructionMemory[6]  = 16'b0000_001_000_000001;//sll
		InstructionMemory[7]  = 16'b0000_001_000_000001;//srl
		InstructionMemory[8]  = 16'b0000_001_000_000001;//mvnz
		InstructionMemory[9]  = 16'b0000_001_000_000001;//ld
		InstructionMemory[10] = 16'b0000_001_000_000001;//sd
		InstructionMemory[11] = 16'b0000_001_000_000001;
		InstructionMemory[12] = 16'b0000_001_000_000001;
		InstructionMemory[13] = 16'b0000_001_000_000001;
		InstructionMemory[14] = 16'b0000_001_000_000001;
		InstructionMemory[15] = 16'b0000_001_000_000001;	

		for(i=0;i<16;i=i+1) begin
			RegisterBank[i] = i;
			DataMemory[i] = i;
		end	
		
		pc = 4'b0000; 
		Done = 1'b0;
		curr_stage = 2'b00;
	end

	wire Clear = Done | ~Resetn | ~Run ;
	contador stage(Clear, Clock,curr_stage);
	
	always @(posedge Clock or Done) begin
			//Adicionar Run

			if(Done) begin
				pc = pc + 1'b0;
				Done = 1'b0;
				if (pc == 4'b1111) begin
					pc = 4'b0000;
				end
			end

			case (curr_stage)
				2'b00: // busca instrução na memória
				begin
					instruction = InstructionMemory[pc];
					instructionIndex = instruction[15:12];
					reg_A = instruction[11:9];
					reg_B = instruction[8:6];
					imediate = instruction[5:0];
				end

				2'b01: //define signals in time step 1
				case (instructionIndex)
					4'b0000: //mv
					begin
						RegisterBank[reg_A] = RegisterBank[reg_B];
						Done = 1'b1;
						out = RegisterBank[reg_A];
					end
					
					4'b0001: //mvi
					begin
						RegisterBank[reg_A] = {reg_B,imediate};
						Done = 1'b1;
						out = RegisterBank[reg_A];
					end
					
					4'b0010: //add
					begin
						tmpreg = RegisterBank[reg_A];
					end

					4'b0011: // sub 
					begin
						tmpreg = RegisterBank[reg_A];
					end

					4'b0100: //and 
					begin
						RegisterBank[reg_A] = RegisterBank[reg_A] & RegisterBank[reg_B];
						Done = 1'b1;
						out = RegisterBank[reg_A];
					end

					4'b0101: //slt
					begin
						if (RegisterBank[reg_A] < RegisterBank[reg_B])
							RegisterBank[reg_A] = 1;
						else 
							RegisterBank[reg_A] = 0;

						Done = 1'b1;
						out = RegisterBank[reg_A];
					end

					4'b0110: //sll 
					begin
						RegisterBank[reg_A] = RegisterBank[reg_A] << RegisterBank[reg_B];
						Done = 1'b1;
						out = RegisterBank[reg_A];
					end

					4'b0111: //srl
					begin
						RegisterBank[reg_A] = RegisterBank[reg_A] >> RegisterBank[reg_B];
						Done = 1'b1;
						out = RegisterBank[reg_A];
					end

					4'b1000: //mvnz
					begin
					//TODO	

					end

					4'b1001: //ld 
					begin
						tmpreg = RegisterBank[reg_B];
					end

					4'b1010: //sd 
					begin
						tmpreg = RegisterBank[reg_A];

					end
				endcase
				2'b10: //define signals in time step 2
				case (instructionIndex)
					4'b0010: //add
					begin
						Gtmp = tmpreg + RegisterBank[registerB];
					end

					4'b0011://sub
					begin
						Gtmp = tmpreg - RegisterBank[registerB];
					end

					4'b1001: //ld
					begin
						RegisterBank[reg_A] = DataMemory[tmpreg];
						Done = 1'b1;
						out = RegisterBank[reg_A];
					end

					4'b1010: //sd
					begin
						RegisterBank[reg_A] = DataMemory[tmpreg];
						Done = 1'b1;
						out = RegisterBank[reg_A];
					end
				
				endcase

				2'b11: //define signals in time step 3
				case (instructionIndex)
					4'b0010://add
					begin
						RegisterBank[reg_A] = Gtmp;
						Done = 1'b1;
						out = RegisterBank[reg_A];
					end

					4'b0011://sub
					begin
						RegisterBank[reg_A] = Gtmp;
						Done = 1'b1;
						out = RegisterBank[reg_A];
					end
				endcase
			endcase
	end	
endmodule

module contador(Clear, Clock,out);
	input Clear, Clock;
	output reg [1:0] out;
	
	always @(posedge Clock)begin
		if (Clear)
			out <= 2'b00;
		else
			out <= out + 1'b1;
	end 
	
endmodule

module toplevel(SW,LEDR,HEX0);


endmodule