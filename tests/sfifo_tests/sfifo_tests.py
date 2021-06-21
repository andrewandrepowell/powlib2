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

    # Declare structures.
    class SFIFOInterface(StreamInterface):
        data: LogicArrayHandle

    class SFIFOTransaction(Transaction):
        data: LogicValue

    # Construct drivers.
    sender_interface = SFIFOInterface(
        clock=dut.clock,
        valid=dut.stream0.valid,
        ready=dut.stream0.ready,
        data=dut.stream0.data)
    sender = StreamSender(sender_interface, SFIFOTransaction)
    receiver_interface = SFIFOInterface(
        clock=dut.clock,
        valid=dut.stream1.valid,
        ready=dut.stream1.ready,
        data=dut.stream1.data)
    receiver = StreamReceiver(receiver_interface, SFIFOTransaction)

    # Put system through reset.
    dut.reset.value = 1
    fork(Clock(dut.clock, 10, "ns").start())
    for _ in range(3):
        await RisingEdge(dut.clock)
    dut.reset.value = 0

    # Start the drivers.
    sender.start()
    receiver.start()

    # Create task for sending data.
    mask = (1 << len(dut.stream0.data)) - 1
    datas = [value & mask for value in range(256)]
    async def send_data() -> None:
        for data in datas:
            await Timer(max(randint(-30, 30), 0), "ns")
            await sender.send(SFIFOTransaction(data))
    fork(send_data())

    # Receive data and check it for errors.
    for expected_data in datas:
        await Timer(max(randint(-30, 60), 0), "ns")
        transaction = await receiver.receive()
        actual_data = int(transaction.data)
        passed = expected_data == actual_data
        log.info(f"Expected: {hex(expected_data)}. Actual: {hex(actual_data)}. Passed: {passed}.")
        assert passed

    # Test implementation.
    await Timer(100, "ns")
    pass