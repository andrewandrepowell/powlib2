module sfifo_imp_17D91;
	parameter integer DEPTH = 16;
	wire clock;
	wire reset;
	initial begin
		$dumpfile("waveform.vcd");
		$dumpvars(3, sfifo_imp_17D91);
	end
	generate
		begin : stream0
			wire valid;
			wire ready;
			wire [31:0] data;
		end
	endgenerate
	generate
		begin : stream1
			reg valid;
			wire ready;
			reg [31:0] data;
		end
	endgenerate
	generate
		localparam integer _param_ABEF6_DEPTH = DEPTH;
		begin : inst
			localparam integer DEPTH = _param_ABEF6_DEPTH;
			localparam integer RESERVED = 0;
			wire clock;
			wire reset;
			wire available;
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
			assign write_data = sfifo_imp_17D91.stream0.valid && !full;
			assign read_data = (!sfifo_imp_17D91.stream1.valid || sfifo_imp_17D91.stream1.ready) && !empty;
			assign sfifo_imp_17D91.stream0.ready = !full;
			assign available = fill_counter < (DEPTH - RESERVED);
			always @(posedge clock)
				if (reset)
					sfifo_imp_17D91.stream1.valid <= 0;
				else if (read_data)
					sfifo_imp_17D91.stream1.valid <= 1;
				else if (sfifo_imp_17D91.stream1.ready)
					sfifo_imp_17D91.stream1.valid <= 0;
			always @(posedge clock)
				if (reset)
					write_pointer <= 0;
				else if (write_data)
					write_pointer <= (write_pointer == (DEPTH - 1) ? 0 : write_pointer + 1);
			always @(posedge clock)
				if (reset)
					read_pointer <= 0;
				else if (read_data)
					read_pointer <= (read_pointer == (DEPTH - 1) ? 0 : read_pointer + 1);
			always @(posedge clock)
				if (reset)
					fill_counter <= 0;
				else if (write_data && !read_data)
					fill_counter <= fill_counter + 1;
				else if (!write_data && read_data)
					fill_counter <= fill_counter - 1;
			always @(posedge clock) begin
				if (write_data)
					memory[write_pointer] <= sfifo_imp_17D91.stream0.data;
				if (read_data)
					sfifo_imp_17D91.stream1.data <= memory[read_pointer];
			end
		end
		assign inst.clock = clock;
		assign inst.reset = reset;
	endgenerate
endmodule
