PREFIX := riscv64-unknown-elf-
CC := $(PREFIX)gcc
OBJDUMP := $(PREFIX)objdump
CFLAGS := -march=rv32im -mabi=ilp32 -std=c99 -g3
QEMU := qemu-riscv32-static
QEMU_FLAGS := 
INC := ./inc
EXE := lab

.PHONY: clean
.PHONY: help
.PHONY: port
.PHONY: kill

# Run the lab, kill to ensure only one instance of qemu running
run: lab kill
	@$(QEMU) $(QEMU_FLAGS) $(EXE)

# Debug the lab
debug: lab port kill
	@echo "target remote localhost:`sed -n '1 p' port.env`" > ./qemu_riscv32.gdbinit
	@echo "Debug session started"
	@echo "Waiting for gdb connection on port `sed -n '1 p' port.env`"
	@$(QEMU) $(QEMU_FLAGS) -g `sed -n '1 p' port.env` $(EXE)

# Kill qemu, ignore if none is presented
kill:
	@killall -s KILL -q $(QEMU) -u ${USER} || :

# Obtain an unused port
port:
	@ruby -e 'require "socket"; puts Addrinfo.tcp("", 0).bind {|s| s.local_address.ip_port }' > ./port.env

%.o: %.c
	@$(CC) -o $@ -c $^ -I$(INC) $(CFLAGS)

lab: lab.S autograder.o
	@$(CC) -o $(EXE) $^ -I$(INC) $(CFLAGS)

lab.dump: $(EXE)
	@$(OBJDUMP) -D $^ > $@

clean:
	@rm -f *.o $(EXE) port.env qemu_riscv32.gdbinit

help:
	@echo "-----------------------------------------------------"
	@echo "| Help section for ECE 362 RISCV QEMU               |"
	@echo "-----------------------------------------------------"
	@echo "| make: compile and run the lab on qemu             |"
	@echo "|                                                   |"
	@echo "| make run: same as 'make'                          |"
	@echo "|                                                   |"
	@echo "| make debug: compile and launch executable waiting |"
	@echo "|             for VSCode connection                 |"
	@echo "|                                                   |"
	@echo "| make kill: kill all qemu instance belong to       |"
	@echo "|            the user. Automatically executed with  |"
	@echo "|            'make run' and 'make debug'            |"
	@echo "|                                                   |"
	@echo "| make port: get an unused port for gdb connection  |"
	@echo "|            used internally for 'debug'            |"
	@echo "|                                                   |"
	@echo "| make lab: compile lab with autograder             |"
	@echo "|                                                   |"
	@echo "| make clean: clean up object file and executable   |"
	@echo "|                                                   |"
	@echo "| make help: print this message                     |"
	@echo "|                                                   |"
	@echo "-----------------------------------------------------"
