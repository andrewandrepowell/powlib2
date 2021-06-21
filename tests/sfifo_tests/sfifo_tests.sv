module sfifo_imp();
  parameter type T = logic[31:0];
  parameter integer DEPTH = 16;
  logic clock, reset;

  initial begin
    $dumpfile("waveform.vcd");
    $dumpvars(3, sfifo_imp_17D91);
  end

  stream #(.T(T)) stream0();
  stream #(.T(T)) stream1();
  sfifo #(.T(T),.DEPTH(DEPTH)) inst (.clock(clock),.reset(reset),.receiver(stream0),.sender(stream1));
endmodule
