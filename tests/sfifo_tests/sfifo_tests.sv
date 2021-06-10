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


  initial begin
    $dumpfile("waveform.vcd");
    $dumpvars(3, sfifo_imp_17D91);
  end

  stream #(.T(T)) receiver();
  stream #(.T(T)) sender();
  sfifo #(.T(T),.DEPTH(DEPTH)) inst (.clock(clock),.reset(reset),.receiver(receiver),.sender(sender));
endmodule
