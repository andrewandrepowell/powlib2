interface flow (valid, data);
  parameter type T;
  logic valid;
  T data;
  modport send(output data, output valid);
  modport receive(input data, input valid);
endinterface;

interface stream (valid, ready, data);
  parameter type T;
  logic valid, ready;
  T data;
  modport send(output data, output valid, input ready);
  modport receive(input data, input valid, output ready);
endinterface;

module sfifo(clock, reset, receiver, sender);
  parameter type T;
  parameter integer DEPTH;
  localparam type index = logic[$clog2(DEPTH)-1:0];
  input logic clock, reset;
  stream.receive receiver;
  stream.send sender;
  T memory [0: DEPTH-1];
  index write_pointer, write_plus1_pointer, read_pointer;
  logic write_data, read_data, full, empty;

  assign full = write_plus1_pointer==read_pointer;
  assign empty = write_pointer==read_pointer;

  always_ff @(posedge clock) begin: write_counter_process
    if (reset!=0) begin
      write_pointer <= 0;
      write_plus1_pointer <= 1;
    end else begin
      if (write_data) begin
        write_plus1_pointer <= (write_plus1_pointer==(DEPTH-1)) ? 0 : write_plus1_pointer+1;
        write_pointer <= write_plus1_pointer;
      end;
    end;
  end;

  always_ff @(posedge clock) begin: read_counter_process
    if (reset!=0) begin
      read_pointer <= 0;
    end else begin
      if (read_data) begin
        read_pointer <= (read_pointer==(DEPTH-1)) ? 0 : read_pointer+1;
      end;
    end;
  end;

  always_ff @(posedge clock) begin: memory_process
    if (write_data) begin
      memory[write_pointer] <= receiver.data;
    end;
    if (read_data) begin
      sender.data <= memory[read_pointer];
    end;
  end;
endmodule;

module sfifo_imp;
  parameter type T = logic[3:0];
  logic clock, reset;
  stream #(.T(T)) receiver();
  stream #(.T(T)) sender();
  sfifo #(.T(T),.DEPTH(4)) inst(.clock(clock),.reset(reset),.receiver(receiver),.sender(sender));
endmodule;


