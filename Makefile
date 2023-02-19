# -*- Makefile -*-
### Makefile - VHDL Makefile generated by Emacs VHDL Mode 3.38.1

# Directory : "~/server/school/jaar4/digitale_techniek/wekker/liftbesturing/verdieping"
# Platform  : GHDL
# Generated : 2020-09-25 11:35:00 harm


# Define compilation command and options

analyse: 
	ghdl -a  --workdir=work --ieee=standard -fsynopsys -fexplicit --std=93 \
	kooi/SR_flipflop.vhdl kooi/liftkooi.vhdl \
	verdieping/level.vhdl \
	liftbesturing/liftbesturing_arch.vhdl \
	liftschacht.vhdl lift_control_tb.vhdl

#	ghdl -i --workdir=work */*.vhdl

elaborate:
#	ghdl -e --workdir=work -fsynopsys -fexplicit --std=93 -o elevator_cage elevator_control level_entity  liftschacht elevator_tb
#	ghdl -e --workdir=work -fsynopsys -fexplicit --std=93 -o test_bench

sim:
#	./work/liftkooi_tb --wave=wave.ghw
#	ghdl --elab-run -fsynopsys -fexplicit --std=93  cage_tb --wave=wave.ghw
	ghdl -r  --workdir=work -fsynopsys -fexplicit -Wbinding --std=93  elevator_tb --wave=wave.ghw

all: analyse elaborate sim

clean: 
	rm -r work/*
	
test: clean
	ghdl -a  --workdir=work --ieee=standard -fsynopsys -fexplicit --std=93 \
		test_arch.vhdl 
	
	ghdl -r  --workdir=work -fsynopsys -fexplicit -Wbinding --std=93  elevator_tb --wave=wave.ghw

#	ghdl -r  --workdir=work level_sim --wave=wave.ghw

### Makefile ends here
