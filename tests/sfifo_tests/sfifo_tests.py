from cocotb.decorators import test
from cocotb.triggers import Timer

@test()
async def basic_test(dut):
    await Timer(100, "ns")
    pass