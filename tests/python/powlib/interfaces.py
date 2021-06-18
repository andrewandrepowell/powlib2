from pyvertb import SynchDriver, Transaction, Interface, Process, Channel
from .utilities import Future
from typing import TypeVar, Type
from dataclasses import fields
from cocotb.handle import SimHandleBase
from cocotb.triggers import RisingEdge, Event, ReadWrite


SendTransaction = TypeVar("DataTransaction", bound=Transaction)
ReceiveTransaction = TypeVar("ReceiveTransaction", bound=Transaction)


class StreamInterface(Interface):
    clock: SimHandleBase
    valid: SimHandleBase
    ready: SimHandleBase


def _write(interface: Interface, transaction: SendTransaction, in_transaction_type: Type[SendTransaction]) -> None:
    for field in fields(in_transaction_type):
        getattr(interface, field.name).value = getattr(transaction, field.name)


def _read(interface: Interface, out_transaction_type: Type[ReceiveTransaction]) -> ReceiveTransaction:
    transaction_as_dictionary = {}
    for field in fields(out_transaction_type):
        transaction_as_dictionary[field.name] = getattr(interface, field.name).value
    return out_transaction_type(**transaction_as_dictionary)


class StreamWriteSynchDriver(Process, SynchDriver[StreamInterface, SendTransaction, None]):
    out_transaction_type = None

    def __init__(self, interface: StreamInterface, in_transaction_type: Type[SendTransaction]):
        self.interface = interface
        self.in_transaction_type = in_transaction_type
        self._run_channel = Channel[T]()
        self._run_event = Event()

    async def write(self, transaction: SendTransaction) -> None:
        await RisingEdge(self.interface.clock)
        self._run_channel.try_send(transaction)
        await self._run_event.wait()
        self._run_event.clear()

    async def run(self) -> None:
        while True:
            self.interface.valid.value = 0
            transaction = await self._run_channel.recv()
            self.interface.valid.value = 1
            _write(interface=self.interface, transaction=transaction, in_transaction_type=self.in_transaction_type)
            await ReadWrite()
            while self.interface.ready.value == 0:
                await RisingEdge(self.interface.ready)
                await ReadWrite()
            self._run_event.set()
            await RisingEdge(self.interface.clock)


class StreamReadSynchDriver(Process, SynchDriver[StreamInterface, None, ReceiveTransaction]):
    in_transaction_type = None

    def __init__(self, interface: StreamInterface, out_transaction_type: Type[ReceiveTransaction]) -> None:
        self.interface = interface
        self.out_transaction_type = out_transaction_type
        self._run_event = Event()
        self._run_future = Future[T]()

    async def read(self, transaction=None) -> ReceiveTransaction:
        await RisingEdge(self.interface.clock)
        self._run_event.set()
        return await self._run_future

    async def run(self) -> None:
        while True:
            self.interface.ready.value = 0
            await self._run_event.wait()
            self._run_event.clear()
            self.interface.ready.value = 1
            await ReadWrite()
            while self.interface.valid.value == 0:
                await RisingEdge(self.interface.valid)
                await ReadWrite()
            transaction = _read(interface=self.interface, out_transaction_type=self.out_transaction_type)
            self._run_future.set(transaction)
            await RisingEdge(self.interface.clock)
