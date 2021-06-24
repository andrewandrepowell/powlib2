
TOPLEVEL_LANG = verilog
ROOTLIB = $(shell pwd)/../..
VERILOG_SOURCES = $(shell pwd)/sfifo_tests.v
export PYTHONPATH := ${ROOTLIB}/tests/python
TOPLEVEL = sfifo_imp_17D91
MODULE = sfifo_tests
SIM = icarus

$(shell sv2v $(ROOTLIB)/powlib/powlib.sv sfifo_tests.sv > sfifo_tests.v)
include $(shell cocotb-config --makefiles)/Makefile.sim