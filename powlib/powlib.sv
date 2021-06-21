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
  parameter integer RESERVED = 0;
  input logic clock;
  input logic reset;
  logic available;

  stream #(.T(T)) sender();
  stream #(.T(T)) receiver();
  sfifo #(.T(T),.DEPTH(DEPTH)) inst (.clock(clock),.reset(reset),.receiver(sender),.sender(receiver),.available(available));

endinterface


module sfifo(clock, reset, receiver, sender, available);
  /* It's worth pointing out the receiver.ready and
  available are not decoupled, which could lead to poor
  routing performance. This can be resolved externally with
  registering available and increasing RESERVED. */
  parameter type T = logic[31:0];
  parameter integer DEPTH = 32;
  parameter integer RESERVED = 0;
  localparam type index = logic[$clog2(DEPTH)-1:0];
  localparam type amount = logic[$clog2(DEPTH):0];
  input logic clock, reset, available;
  stream.receive receiver;
  stream.send sender;
  T memory [0: DEPTH-1];
  T data0, data1;
  index write_pointer, read_pointer;
  amount fill_counter;
  logic write_data, read_data, full, empty, valid0, valid1;

  assign full = fill_counter==DEPTH;
  assign empty = fill_counter==0;
  assign write_data = receiver.valid&&!full;
  assign read_data = (!sender.valid||sender.ready)&&!empty;
  assign receiver.ready = !full;
  assign available = fill_counter<(DEPTH-RESERVED);

  // Writes the sender valid.
  always_ff @(posedge clock) begin
    if (reset) begin
      sender.valid <= 0;
    end else begin
      if (read_data) begin
        sender.valid <= 1;
      end else if (sender.ready) begin
        sender.valid <= 0;
      end;
    end;
  end;

  // Implements the write counter.
  always_ff @(posedge clock) begin
    if (reset) begin
      write_pointer <= 0;
    end else begin
      if (write_data) begin
        write_pointer <= (write_pointer==(DEPTH-1)) ? 0 : write_pointer+1;
      end;
    end;
  end;

  // Implements the read counter.
  always_ff @(posedge clock) begin
    if (reset) begin
      read_pointer <= 0;
    end else begin
      if (read_data) begin
        read_pointer <= (read_pointer==(DEPTH-1)) ? 0 : read_pointer+1;
      end;
    end;
  end;

  // Implements the fill counter.
  always_ff @(posedge clock) begin
    if (reset) begin
      fill_counter <= 0;
    end else begin
      if (write_data&&!read_data) begin
        fill_counter <= fill_counter+1;
      end else if (!write_data&&read_data) begin
        fill_counter <= fill_counter-1;
      end;
    end;
  end;

  // Implements Simple Dual Port RAM. Taken from Vivado Template.
  // Please note this only becomes BRAM once its size is large enough.
  always_ff @(posedge clock) begin
    if (write_data) begin
      memory[write_pointer] <= receiver.data;
    end;
    if (read_data) begin
      sender.data <= memory[read_pointer];
    end;
  end;


endmodule


