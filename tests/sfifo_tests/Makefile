
TOPLEVEL_LANG = verilog
ROOTLIB = $(shell pwd)/../..
POWLIB = $(shell pwd)/../../powlib
VERILOG_SOURCES = $(shell pwd)/sfifo_tests.v
PYTHONPATH := ${ROOTLIB}/tests/python:$(PYTHONPATH)
TOPLEVEL = sfifo_imp_17D91
MODULE = sfifo_tests
SIM = icarus

$(shell sv2v $(POWLIB)/powlib.sv sfifo_tests.sv > sfifo_tests.v)

include $(shell cocotb-config --makefiles)/Makefile.sim