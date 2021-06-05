//`default nettype none (doesn't work)

interface flow;
  parameter type T = logic[31:0];
  logic valid;
  T data;
  modport send(output data, output valid);
  modport receive(input data, input valid);
endinterface


interface stream;
  parameter type T = logic[31:0];
  logic valid, ready;
  T data;
  modport send(output data, output valid, input ready);
  modport receive(input data, input valid, output ready);
endinterface

interface channel (clock, reset);
  parameter type T = logic[31:0];
  parameter integer DEPTH = 32;
  input logic clock;
  input logic reset;

  sfifo #(.T(T),.DEPTH(DEPTH)) inst (.clock(clock),.reset(reset),.receiver(receiver),.sender(sender));

endinterface


module sfifo(clock, reset, receiver, sender);
  parameter type T = logic[31:0];
  parameter integer DEPTH = 32;
  localparam type index = logic[$clog2(DEPTH)-1:0];
  input logic clock, reset;
  stream.receive receiver;
  stream.send sender;
  T memory [0: DEPTH-1];
  T data0, data1;
  index write_pointer, write_plus1_pointer, read_pointer;
  logic write_data, read_data, full, empty, valid0, valid1;

  assign full = write_plus1_pointer==read_pointer;
  assign empty = write_pointer==read_pointer;
  assign write_data = valid0&&!full;
  assign read_data = (!valid1||!sender.valid||sender.ready)&&!empty;
  assign receiver.ready = !full;

  // Implements the write counter.
  always_ff @(posedge clock) begin
    if (!reset) begin
      write_plus1_pointer <= 1;
      write_pointer <= 0;
    end else begin
      if (write_data) begin
        write_plus1_pointer <= (write_plus1_pointer==(DEPTH-1)) ? 0 : write_plus1_pointer+1;
        write_pointer <= write_plus1_pointer;
      end;
    end;
  end;

  // Implements the read counter.
  always_ff @(posedge clock) begin
    if (!reset) begin
      read_pointer <= 0;
    end else begin
      if (read_data) begin
        read_pointer <= (read_pointer==(DEPTH-1)) ? 0 : read_pointer+1;
      end;
    end;
  end;

  // Register input.
  always_ff @(posedge clock) begin
    if (!reset) begin
      valid0 <= 0;
    end else begin
      if (!full) begin
        valid0 <= receiver.valid;
      end;
    end;
    if (!full) begin
      data0 <= receiver.data;
    end;
  end;

  // Implements Simple Dual Port RAM. Taken from Vivado Template.
  // Please note this only becomes BRAM once its size is large enough.
  always_ff @(posedge clock) begin
    if (write_data) begin
      memory[write_pointer] <= data0;
    end;
    if (read_data) begin
      data1 <= memory[read_pointer];
    end;
  end;

  // Determine when the data is valid.
  always_ff @(posedge clock) begin
    if (!reset) begin
      valid1 <= 0;
    end else begin
      if (read_data) begin
        valid1 <= 1;
      end else if (sender.ready) begin
        valid1 <= 0;
      end;
    end;
  end;

  // Register output.
  always_ff @(posedge clock) begin
    if (!reset) begin
      sender.valid <= 0;
    end else begin
      if (sender.ready||read_data) begin
        sender.valid <= valid1;
      end;
    end;
    if (sender.ready||read_data) begin
      sender.data <= data1;
    end;
  end;

endmodule


module sfifo_imp(clock, reset, reciever_data, receiver_valid, receiver_ready, sender_data, sender_valid, sender_ready);
  parameter type T = logic[31:0];
  parameter integer DEPTH = 256;
  input logic clock, reset, receiver_valid, sender_ready;
  output logic receiver_ready, sender_valid;
  input T reciever_data;
  output T sender_data;

  assign receiver.data = reciever_data;
  assign receiver.valid = receiver_valid;
  assign receiver_ready = receiver.ready;
  assign sender_data = sender.data;
  assign sender_valid = sender.valid;
  assign sender.ready = sender_ready;

  stream #(.T(T)) receiver();
  stream #(.T(T)) sender();
  sfifo #(.T(T),.DEPTH(DEPTH)) inst (.clock(clock),.reset(reset),.receiver(receiver),.sender(sender));
endmodule
