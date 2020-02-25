
module ask_rcv(
	input wire clk,
	input wire[7:0] idata,
	input wire[7:0] qdata,
	input wire serialin,
	output wire[15:0] odata ,
	output reg preamble_lock,
	output reg syncwrd_lock,
	output wire enabled_symbclk
	);
	
	reg[15:0] odatareg, phase_acc;
	wire[15:0] sinsig, cossig;
	
	wire symbclk;
	
	initial
	begin
		preamble_lock = 0;
		syncwrd_lock = 0;
	end
	
	assign odata = odatareg;
	
	assign enabled_symbclk = symbclk & preamble_lock;
	
	wire preamble_sync;
	wire syncwrd_sync;
	
	correlator #(32, 32'hF0F0F0F0, 31)prmbl(clk, serialin, preamble_sync); 
	correlator #(8, 8'b10100111, 7) syncwrd(symbclk & preamble_lock, serialin, syncwrd_sync);
	syncgen symbgen(clk, preamble_sync, symbclk);
	
	always @(posedge clk)
	begin
		odatareg <= idata * idata + qdata * qdata;
		phase_acc <= phase_acc + 1;
	end 
	
	always @(posedge preamble_sync)
		preamble_lock <= 1;
		
	always @(posedge syncwrd_sync)
		syncwrd_lock <= 1;
	
endmodule

module serial_rcv(input wire symbclk, input wire ser_data, output rcvsync, output wire[7:0] data);
	reg[7:0] datareg;
	reg[2:0] bitcount;
	reg state;
	always @(negedge ser_data)
	begin
		state <= 1;
	end
endmodule

module correlator(sampleclk, serdata, decision);
	parameter WIDTH = 32;
	parameter TEMPLATE = 32'hFF00FF00;
	parameter BORDER = 31;
	input sampleclk;
	input serdata;
	output reg decision;
	
	reg[WIDTH-1 : 0] shreg;
	wire[WIDTH-1 : 0] corres = shreg ^ TEMPLATE;
	wire[WIDTH-1 : 0] in;
	assign in[WIDTH-1] = serdata;
	
	reg[$clog2(WIDTH) : 0] acc;
	
	initial acc = 0;
	initial shreg = 0;
	
	always @(posedge sampleclk)
	begin
		shreg <= (shreg >> 1) | in;
		decision <= acc > BORDER;
	end
	
	integer i;
	always @(shreg)
	begin
		acc = 0;
		for(i = 0; i < WIDTH; i = i + 1)
		begin
			acc = acc + corres[i];
		end
	end
endmodule

module syncgen(input wire clk, input wire sync, output reg syncclk);
	parameter PRESCALER = 2;
	reg[$clog2(PRESCALER) : 0] counter;
	
	initial counter = 0;
	
	always @(posedge clk or posedge sync)
	begin
		if(sync)
		begin
			counter <= 0;
			syncclk <= 0;
		end
		else
		begin
			counter <= counter == PRESCALER-1 ? 0 : counter + 1;
			if(counter == PRESCALER-1) syncclk <= !syncclk;
		end
		
	end
	
endmodule
















