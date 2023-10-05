#!/bin/csh

source /apps/design_environment.csh
vcs +incdir+../ +v2k -sverilog ../tb.sv #$argv[*]
./simv +ntb_random_seed_automatic | tee log
