
module ask_rcv(
	input wire clk,
	input wire serialin,
	input wire reset,
	output wire syncronised,
	output wire[7:0] data,
	output wire ready
	);
	
	symbol_syncroniser sync(clk, serialin, ready, syncronised);
	serial_rcv rcv(syncronised, serialin, data, ready);
	
	
endmodule

module serial_rcv(symbclk, serialin, dataout, ready);
	parameter PACKLEN = 8;
	
	input wire symbclk;
	input wire serialin;
	output reg[PACKLEN - 1 : 0] dataout;
	output reg ready;
	
	reg[PACKLEN - 1: 0] rcvreg;
	reg[$clog2(PACKLEN + 1) : 0] counter;
	
	always @(posedge symbclk)
	begin
<<<<<<< HEAD
		rcvreg <= (rcvreg << 1) | serialin;
		counter <= counter == PACKLEN ? 0 : counter + 1;
=======
>>>>>>> 38a65153459fc010853102e33625ae1b7515ffd2
		if(counter == PACKLEN)
		begin
			ready <= 1;
			dataout <= rcvreg;
			counter <= 0;
		end
		else 
		begin
			ready <= 0;
			rcvreg <= (rcvreg << 1) | serialin;
			counter <= counter + 1;
		end
	end
endmodule

module correlator(sampleclk, serdata, decision, debug);
	parameter WIDTH = 32;
	parameter TEMPLATE = 32'hF0F0F0F0;
	parameter BORDER = 31;
	input sampleclk;
	input serdata;
	output reg decision;
	output wire[31:0] debug;
	
	reg[WIDTH-1 : 0] shreg;
	wire[WIDTH-1 : 0] corres = shreg ^ (~TEMPLATE);
	wire[WIDTH-1 : 0] in;
	assign in[0] = serdata;
	
	reg[$clog2(WIDTH) : 0] acc;
	
	initial acc = 0;
	initial shreg = 0;
	
	always @(posedge sampleclk)
	begin
		shreg = (shreg << 1) | in;
		decision = acc > BORDER;
	end
	
	integer i;
	always @(shreg or corres)
	begin
		acc = 0;
		for(i = 0; i < WIDTH; i = i + 1)
		begin
			acc = acc + corres[i];
		end
	end
endmodule

module syncgen(input wire clk, input wire sync, output reg syncclk);
	parameter PRESCALER = 4;
	reg[$clog2(PRESCALER) : 0] counter;
	
	initial counter = 0;
	
	always @(posedge clk or posedge sync)
	begin
		if(sync)
		begin
			counter <= 1;
			syncclk <= 0;
		end
		else
		begin
			counter <= counter == PRESCALER-1 ? 0 : counter + 1;
<<<<<<< HEAD
			syncclk <= counter == (PRESCALER / 2 - 1);
=======
			syncclk <= counter ? 0 : 1;
>>>>>>> 38a65153459fc010853102e33625ae1b7515ffd2
		end
		
	end
	
endmodule

module symbol_syncroniser(clk, serialin, reset, syncclk);
	parameter PREAMBLE_WIDTH = 32;
	parameter PREAMBLE = 32'hF0F0F0F0;
	parameter PREAMBLE_BORDER = 31;
	parameter SYNCWORD_WIDTH = 8;
	parameter SYNCWORD = 8'b11100101;
	parameter SYNCWORD_BORDER = 7;
	parameter SYMBCLK_PRESCALER = 4;
	
	input wire clk;
	input wire serialin;
	output wire syncclk;
	input wire reset;
	
	reg preamble_lock;
	reg syncwrd_lock;
	
	wire preamble_sync;
	wire syncwrd_sync;
	
	wire[31:0] abstract0, abstract1;
	wire abstract2 = symbclk;
	
	correlator #(PREAMBLE_WIDTH, PREAMBLE, PREAMBLE_BORDER) prmbl(clk, serialin, preamble_sync, abstract0);
	
	syncgen #(SYMBCLK_PRESCALER) symbgen(clk, preamble_sync, symbclk);
	
	correlator #(SYNCWORD_WIDTH, SYNCWORD, SYNCWORD_BORDER) syncwrd(symbclk & preamble_lock, serialin, syncwrd_sync, abstract1);
	
	assign syncclk = syncwrd_lock & preamble_lock & symbclk;

	always @(posedge preamble_sync or posedge reset)
		preamble_lock <= reset ? 1'b0 : 1'b1;
	
	always @(posedge syncwrd_sync or posedge reset)
		syncwrd_lock <= reset ? 1'b0 : 1'b1;
endmodule

module transmitter(clk, data, send, dataout, sent);
	parameter PREAMBLE_WIDTH = 8;
	parameter PREAMBLE = 8'h10101010;
	parameter SYNCWORD_WIDTH = 8;
	parameter SYNCWORD = 8'b11100101;
	parameter SYMBCLK_PRESCALER = 4;
	parameter DATA_WIDTH = 8;
	
	input wire clk;
	input wire[DATA_WIDTH - 1 : 0] data;
	input wire send;
	output reg sent;
	output wire dataout;
	
	reg[PREAMBLE_WIDTH + SYNCWORD_WIDTH + DATA_WIDTH - 1 : 0] outsr;
	wire[PREAMBLE_WIDTH + SYNCWORD_WIDTH + DATA_WIDTH - 1 : 0] outword;
	
	assign outword[PREAMBLE_WIDTH + SYNCWORD_WIDTH + DATA_WIDTH - 1 : SYNCWORD_WIDTH + DATA_WIDTH] = PREAMBLE;
	assign outword[SYNCWORD_WIDTH + DATA_WIDTH - 1 : DATA_WIDTH] = SYNCWORD;
	assign outword[DATA_WIDTH - 1 : 0] = data;
	
	assign dataout = outsr[PREAMBLE_WIDTH + SYNCWORD_WIDTH + DATA_WIDTH - 1];
	
	wire symbclk;
	reg[$clog2(PREAMBLE_WIDTH + SYNCWORD_WIDTH + DATA_WIDTH) : 0] sendcnt;

	syncgen #(SYMBCLK_PRESCALER) symbgen(clk, send, symbclk);
	
	always @(posedge symbclk or posedge send)
	begin
		if(send)
		begin
		 outsr <= outword;
		end
		else
		begin
		end
	end
	

	












