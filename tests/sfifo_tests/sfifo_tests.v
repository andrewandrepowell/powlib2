module sfifo_imp_17D91 (
	clock,
	reset,
	reciever_data,
	receiver_valid,
	receiver_ready,
	sender_data,
	sender_valid,
	sender_ready
);
	parameter integer DEPTH = 256;
	input wire clock;
	input wire reset;
	input wire receiver_valid;
	input wire sender_ready;
	output wire receiver_ready;
	output wire sender_valid;
	input wire [31:0] reciever_data;
	output wire [31:0] sender_data;
	assign receiver.data = reciever_data;
	assign receiver.valid = receiver_valid;
	assign receiver_ready = receiver.ready;
	assign sender_data = sender.data;
	assign sender_valid = sender.valid;
	assign sender.ready = sender_ready;
	initial begin
		$dumpfile("waveform.vcd");
		$dumpvars(3, sfifo_imp_17D91);
	end
	generate
		begin : receiver
			wire valid;
			reg ready;
			wire [31:0] data;
		end
	endgenerate
	generate
		begin : sender
			reg valid;
			wire ready;
			reg [31:0] data;
		end
	endgenerate
	generate
		localparam integer _param_ABEF6_DEPTH = DEPTH;
		begin : inst
			localparam integer DEPTH = _param_ABEF6_DEPTH;
			wire clock;
			wire reset;
			reg [31:0] memory [0:_param_ABEF6_DEPTH - 1];
			wire [31:0] data0;
			wire [31:0] data1;
			reg [$clog2(_param_ABEF6_DEPTH) - 1:0] write_pointer;
			reg [$clog2(_param_ABEF6_DEPTH) - 1:0] read_pointer;
			reg [$clog2(_param_ABEF6_DEPTH):0] fill_counter;
			wire write_data;
			wire read_data;
			wire full;
			wire empty;
			wire valid0;
			wire valid1;
			assign full = fill_counter == DEPTH;
			assign empty = fill_counter == 0;
			assign write_data = sfifo_imp_17D91.receiver.valid && !full;
			assign read_data = (!sfifo_imp_17D91.sender.valid || sfifo_imp_17D91.sender.ready) && !empty;
			always @(posedge clock)
				if (!reset)
					sfifo_imp_17D91.receiver.ready <= 1;
				else if (write_data || read_data)
					sfifo_imp_17D91.receiver.ready <= fill_counter < (DEPTH - 1);
			always @(posedge clock)
				if (!reset)
					sfifo_imp_17D91.sender.valid <= 0;
				else if (read_data)
					sfifo_imp_17D91.sender.valid <= 1;
				else if (sfifo_imp_17D91.sender.ready)
					sfifo_imp_17D91.sender.valid <= 0;
			always @(posedge clock)
				if (!reset)
					write_pointer <= 0;
				else if (write_data)
					write_pointer <= (write_pointer == (DEPTH - 1) ? 0 : write_pointer + 1);
			always @(posedge clock)
				if (!reset)
					read_pointer <= 0;
				else if (read_data)
					read_pointer <= (read_pointer == (DEPTH - 1) ? 0 : read_pointer + 1);
			always @(posedge clock)
				if (!reset)
					fill_counter <= 0;
				else if (write_data && !read_data)
					fill_counter <= fill_counter + 1;
				else if (!write_data && read_data)
					fill_counter <= fill_counter - 1;
			always @(posedge clock) begin
				if (write_data)
					memory[write_pointer] <= sfifo_imp_17D91.receiver.data;
				if (read_data)
					sfifo_imp_17D91.sender.data <= memory[read_pointer];
			end
		end
		assign inst.clock = clock;
		assign inst.reset = reset;
	endgenerate
endmodule
