# Makefile for compiling libbp_abstraction_layer.a

LIB=static
#LIB=dynamic
LIB_NAME_BASE=libal_bp
CC=gcc
DIR_BP_IMPL=./src/bp_implementations/
SUFFIX=

ifeq ($(or $(ION_DIR),$(DTN2_DIR)),)
# NOTHING
all: help
else 
all: lib
endif 

LIB_NAME=$(LIB_NAME_BASE)

ifeq ($(strip $(DTN2_DIR)),)
ifneq ($(strip $(ION_DIR)),)
# ION
LIB_NAME=$(LIB_NAME_BASE)_vION
INC=-I$(ION_DIR) -I$(ION_DIR)/bp/include -I$(ION_DIR)/bp/library
OPT=-DION_IMPLEMENTATION -fPIC
endif
else ifeq ($(strip $(ION_DIR)),)
ifneq ($(strip $(DTN2_DIR)),)
# DTN2
LIB_NAME=$(LIB_NAME_BASE)_vDTN2
INC=-I$(DTN2_DIR) -I$(DTN2_DIR)/applib/
OPT=-DDTN_IMPLEMENTATION -fPIC
endif
else ifneq ($(strip $(ION_DIR)),)
ifneq ($(strip $(DTN2_DIR)),)
# BOTH
LIB_NAME=$(LIB_NAME_BASE)
INC=-I$(DTN2_DIR) -I$(DTN2_DIR)/applib/ -I$(ION_DIR)/bp/include -I$(ION_DIR)/bp/library
OPT=-DION_IMPLEMENTATION -DDTN_IMPLEMENTATION -fPIC
endif
#else ifeq ($(and $(strip $(DTN2_DIR)), $(strip $(ION_DIR))),)
endif

ifeq ($(strip $(LIB)),static)
SUFFIX=.a
LIB_CC=ar crs
else
SUFFIX=.so
LIB_CC=gcc -shared -o
endif

INSTALLED=$(wildcard /usr/lib/$(LIB_NAME)*)

lib: objs
	$(LIB_CC) $(LIB_NAME)$(SUFFIX) *.o
	
install: 
	cp $(LIB_NAME)* /usr/lib/

uninstall:
	@if test `echo $(INSTALLED) | wc -w` -eq 1 -a -f "$(INSTALLED)"; then rm -rf $(INSTALLED); else if test -n "$(INSTALLED)"; then echo "MORE THAN 1 FILE, DELETE THEM MANUALLY: $(INSTALLED)"; else echo "NOT INSTALLED"; fi fi

objs:
	$(CC) -I$(DIR_BP_IMPL) $(INC) $(OPT) -c src/*.c
	$(CC) $(INC) $(OPT) -c src/bp_implementations/*.c

help:
	@echo "Usage:"
	@echo "For DTN2:	make DTN_DIR=<dtn2_dir>"
	@echo "For ION:	make ION_DIR=<ion_dir>"
	@echo "For both:	make DTN_DIR=<dtn2_dir> ION_DIR=<ion_dir>"

clean:
	@rm -rf *.o *.so *.a
