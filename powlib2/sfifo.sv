
interface flow (valid, data);
  parameter integer WIDTH;
  logic valid;
  logic[WIDTH-1] data;
  modport sender(output data, output valid);
  modport receiver(input data, input valid);
endinterface;

module stage(clock, reset, receive, send);
  input logic clock, reset;
  flow.receiver receive;
  flow.sender send;

  always @(posedge clock)
  begin
    send.data <= receive.data;
    send.valid <= receive.valid;
  end
endmodule;


module stage_imp(clock, reset, send_data, send_valid, receive_data, receive_valid);
  parameter integer WIDTH = 16;
  input logic clock, reset;
  input logic[WIDTH-1:0] receive_data;
  input logic receive_valid;
  output logic[WIDTH-1:0] send_data;
  output logic send_valid;

  assign receive.valid = receive_valid;
  assign receive.data = receive_data;
  assign send_data = send.data;
  assign send_valid = send.valid;

  flow #(.WIDTH(WIDTH)) send();
  flow #(.WIDTH(WIDTH)) receive();
  stage dut(.clock(clock), .reset(reset), .receive(receive), .send(send));

endmodule;