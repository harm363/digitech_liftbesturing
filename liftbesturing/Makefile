# -*- Makefile -*-
### Makefile - VHDL Makefile generated by Emacs VHDL Mode 3.38.1

# Directory : "~/server/school/jaar4/digitale_techniek/wekker/liftbesturing/verdieping"
# Platform  : GHDL
# Generated : 2020-09-25 11:35:00 harm


# Define compilation command and options

analyse:
	ghdl -a  --workdir=work --ieee=standard -fsynopsys -fexplicit --std=93 liftbesturing_arch.vhdl
elaborate:
#	ghdl -e --workdir=work -fsynopsys -fexplicit --std=93 -o build/liftbesturing_sim
	
sim:
#	./work/liftkooi_tb --wave=wave.ghw
#	ghdl --elab-run -fsynopsys -fexplicit --std=93  cage_tb --wave=wave.ghw
	ghdl -r  --workdir=work -fsynopsys -fexplicit -Wbinding --std=93  test_tb  --wave=wave.ghw

all: analyse elaborate sim

clean: 
	rm -r build

#	ghdl -r  --workdir=work level_sim --wave=wave.ghw

### Makefile ends here
