from collections.abc import Awaitable
from typing import Generic, TypeVar, Iterator, Optional
from cocotb.triggers import Event


T = TypeVar("T")


class Future(Awaitable, Generic[T]):

    def __init__(self) -> None:
        self._event = Event()
        self._exception: Optional[BaseException] = None
        self._value: Optional[T] = None

    def set(self, value: Optional[T]=None, exception: Optional[BaseException]=None) -> None:
        self._value = value
        self._exception = exception
        if value is not None or exception is not None:
            self._event.set()

    async def get(self) -> T:
        while True:
            if self._exception is not None:
                exception = self._exception
                self._exception = None
                raise exception
            if self._value is not None:
                value = self._value
                self._value = None
                return value
            await self._event.wait()
            self._event.clear()

    def __await__(self) -> Iterator[T]:
        return self.get().__await__()