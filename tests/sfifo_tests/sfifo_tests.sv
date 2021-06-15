module sfifo_imp();
  parameter type T = logic[31:0];
  parameter integer DEPTH = 256;
  logic clock, reset;

  initial begin
    $dumpfile("waveform.vcd");
    $dumpvars(3, sfifo_imp_17D91);
  end

  stream #(.T(T)) receiver();
  stream #(.T(T)) sender();
  sfifo #(.T(T),.DEPTH(DEPTH)) inst (.clock(clock),.reset(reset),.receiver(receiver),.sender(sender));
endmodule
