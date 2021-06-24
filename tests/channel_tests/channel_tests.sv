class adder #(
  parameter type T = logic[31:0]);
  static function T operate(T operand0, T operand1);
    return operand0+operand1;
  endfunction
endclass

module reduce(clock, reset, operand0, operand1, result);
  parameter type T = logic[31:0];
  parameter type OPERATION = adder;

  input logic clock, reset;
  flow.receive operand0, operand1;
  flow.send result;

  always_ff @(posedge clock) begin
    if (reset) begin
      result.valid <= 0;
    end else begin
      result.valid <= operand0.valid&&operand1.valid;
    end;
    result.data <= OPERATION#(.T(T))::operate(operand0.data, operand1.data);
  end;

endmodule

module channel_tests();
  logic clock, reset;
  flow operand0();
  flow operand1();
  flow result();
  reduce inst(.clock(clock),.reset(reset),.operand0(operand0),.operand1(operand1),.result(result));

endmodule