
module ask_rcv(
	input wire clk,
	input wire[7:0] idata,
	input wire[7:0] qdata,
	output wire[15:0] odata 
	);
	
	reg[15:0] odatareg, phase_acc;
	wire[15:0] sinsig, cossig;
	wire nco_out_valid;
	
	assign odata = odatareg;
	
	always @(posedge clk)
	begin
		odatareg <= idata * idata + qdata * qdata;
		phase_acc <= phase_acc + 1;
	end 
endmodule

module serial_rcv(input wire symbclk, input wire ser_data, output rcvsync, output wire[7:0] data);
	reg[7:0] datareg;
	reg[2:0] bitcount;
	reg state;
	always @(negedge ser_data)
	begin
		state <= 1;
	end
	always
endmodule
	