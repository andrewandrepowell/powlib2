
TOPLEVEL_LANG = verilog
ROOTLIB = $(shell pwd)/../..
VERILOG_SOURCES = $(shell pwd)/channel_tests.v
export PYTHONPATH := ${ROOTLIB}/tests/python
TOPLEVEL = channel_tests
MODULE = channel_tests
SIM = icarus

$(shell sv2v $(ROOTLIB)/powlib/powlib.sv channel_tests.sv > channel_tests.v)
include $(shell cocotb-config --makefiles)/Makefile.sim