from cocotb.decorators import test
from cocotb.triggers import Timer
from powlib.interfaces import StreamWriteSynchDriver


@test()
async def basic_test(dut):
    await Timer(100, "ns")
    pass