from cocotb.decorators import test
from cocotb.triggers import Timer
from pyvertb import SynchDriver


@test()
async def basic_test(dut):
    await Timer(100, "ns")
    pass