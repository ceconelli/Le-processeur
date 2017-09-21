module display(a,b,c,d,s0,s1,s2,s3,s4,s5,s6);

	input a,b,c,d;
	output s0,s1,s2,s3,s4,s5,s6;
	assign s0= !((!a&c) | (a&!d) | (!b&!d) | (b&c) | (a&!b&!c) | (!a&b&d));
	assign s1= !((!a&!b) | (!b&!c) | (!b&!d) | (!a&c&d) | (!a&!c&!d) | (a&!c&d));
	assign s2= !((!a&b) | (!c&d) | (a&!b) | (!b&!c) | (!b&d));
	assign s3= !((a&!c) | (!b&!c&!d) | (b&!c&d) | (a&!b&d) | (!a&!b&c) | (!a&c&!d) | (b&c&!d));
	assign s4= !((a&b) | (c&!d) | (a&c) | (!b&!d));
	 
	assign s5= !((!c&!d) | (a&!b) | (a&c) | (!a&b&!c) | (b&c&!d));
	 
	assign s6= !((a&!b) | (c&!d) | (a&c) | (!b&c) | (!a&b&!c) | (b&!c&d));

endmodule

module proc(Clock,Reset,Run,Done,reg_A,reg_B,curr_stage,out);

	input Reset, Clock, Run;
	output reg Done; //sinal que informa se a instruçao ja terminou
	
	output reg [2:0]  reg_A;
	output reg [2:0]  reg_B;
	output reg [1:0]  curr_stage; // estagio da instrução
	output reg [15:0]out;
	reg [15:0] InstructionMemory [15:0]; //Memória de instruções
	reg [15:0] RegisterBank [7:0]; // Banco de registradores
	reg [15:0] DataMemory [7:0]; // Memória de dados
	reg [15:0] instruction; // instrução 16 bits
	reg [3:0]  instructionIndex;// índice da instrução a ser executada
	reg [3:0]  pc; // index da memória de instruções
	reg [5:0]  imediate;
	reg [15:0] tmpreg;
	reg [15:0] Gtmp;
	reg [15:0] memory_data; // registrador temporário, armazena dado que vem da memória de dados
	integer i;
	reg Clear;
	
	initial begin
		
		InstructionMemory[0]  = 16'b0000_001_010_000000;//mv  R1,R2  | R.E = 2
		InstructionMemory[1]  = 16'b0001_010_000_000101;//mvi R2,5	 | R.E = 5
		InstructionMemory[2]  = 16'b0010_010_011_000000;//add R2,R3  | R.E = 8
		InstructionMemory[3]  = 16'b0011_100_011_000000;//sub R4,R3  | R.E = 1
		InstructionMemory[4]  = 16'b0100_001_001_000000;//and R1,R1
		InstructionMemory[5]  = 16'b0101_000_100_000001;//slt R0,R4  | R.E = 1
		InstructionMemory[6]  = 16'b0101_111_011_000001;//slt R7,R3  | R.E = 0
		InstructionMemory[7]  = 16'b1001_000_100_000000;//ld  R0,R4  | R.E = 1 
		InstructionMemory[8]  = 16'b0001_001_000_000001;//mvi R1,1	 | R.E = 1 
		InstructionMemory[9]  = 16'b1010_011_001_000000;//sd  R3,R1  | R.E = 1
		InstructionMemory[10] = 16'b0000_001_000_000001;//add R6,R0
		InstructionMemory[11] = 16'b0000_001_000_000001;//add R6,R1
		InstructionMemory[12] = 16'b0000_001_000_000001;//
		InstructionMemory[13] = 16'b0000_001_000_000001;
		InstructionMemory[14] = 16'b0000_001_000_000001;
		InstructionMemory[15] = 16'b0000_001_000_000001;	

		for(i=0;i<8;i=i+1) begin
			RegisterBank[i] = i;
			DataMemory[i] = i;
		end	
		
		pc = 4'b0000; 
		Done = 1'b0;
		curr_stage = 2'b00;
		Gtmp = 0;
		tmpreg = 0;
	end
	
	
	//wire Clear = Done | Reset | ~Run ;
	//contador stage(Clear, Clock,curr_stage);
	
	
	
	always @(posedge Clock) begin
		if (Run) begin
			if (Reset) begin
				for(i=0;i<8;i=i+1) begin
					RegisterBank[i] = i;
					DataMemory[i] = i;
				end
				pc = 4'b0000; 
				Done = 1'b0;
				curr_stage = 2'b00;
				Gtmp = 0;
				tmpreg = 0;
			end
			
			curr_stage = curr_stage + 1'b1;
				
			if(Done) begin
				pc = pc + 1'b1;
				Done = 1'b0;
				curr_stage = 2'b00;
				if (pc == 4'b1111) begin
					pc = 4'b0000;
				end
			end

			case (curr_stage)
				2'b00: // busca instrução na memória
				begin
					//instruction = DIN;
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
						if (Gtmp != 0) begin
							RegisterBank[reg_A] = RegisterBank[reg_B];
						end
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
						Gtmp = tmpreg + RegisterBank[reg_B];
					end

					4'b0011://sub
					begin
						Gtmp = tmpreg - RegisterBank[reg_B];
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
	end	
endmodule

module toplevel(SW,LEDR,HEX3,HEX2,HEX1);

	input [17:0]SW;
	input [17:0]LEDR;
	output [6:0]HEX1;
	output [6:0]HEX2;
	output [6:0]HEX3;
	wire Done;
	wire [2:0]reg_A;
	wire [2:0]reg_B;
	wire [1:0]curr_stage;
	wire [15:0]out;


	proc processor(SW[17],SW[16],SW[15],Done,reg_A,reg_B,curr_stage,out);
	assign LEDR[0] = Done;
	display result(out[3],out[2],out[1],out[0],HEX1[0],HEX1[1],HEX1[2],HEX1[3],HEX1[4],HEX1[5],HEX1[6]);
	display regB(1'b0,reg_B[2],reg_B[1],reg_B[0],HEX2[0],HEX2[1],HEX2[2],HEX2[3],HEX2[4],HEX2[5],HEX2[6]);
	display regA(1'b0,reg_A[2],reg_A[1],reg_A[0],HEX3[0],HEX3[1],HEX3[2],HEX3[3],HEX3[4],HEX3[5],HEX3[6]);
endmodule
