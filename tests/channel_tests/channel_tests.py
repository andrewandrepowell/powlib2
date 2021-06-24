from cocotb import fork, log
from cocotb.clock import Clock
from cocotb.decorators import test
from cocotb.triggers import Timer, RisingEdge
from powlib.interfaces import StreamSender, StreamReceiver, StreamInterface
from pyvertb.cocotb_compat import LogicArrayHandle, LogicValue, ScopeHandle
from pyvertb import Transaction
from random import randint


@test()
async def basic_test(dut: ScopeHandle) -> None:
    pass