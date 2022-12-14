# Type ghdl -s some_design.vhd testbench.vhd to check the syntax. This step step is optional.
# Type ghdl -a some_design.vhd testbench.vhd to analyze the design.
# Type ghdl -e testbench_entity_name to build an executable for the testbench.
# Type ghdl -r testbench_entity_name --vcd=file_name.vcd to simulate the design and dump the waveform to a file.
GHDL=ghdl
#GHDLFLAGS=
#MODULES=\
#    sccb.o \
#    alu.o \
#    full_adder.o \
#    alu_testbench \
#    carry_ripple_adder_testbench \
#    full_adder_testbenc

all: cam sccb case1

case1: elab
	ghdl -a --std=08 tb/case1_stimuli.vhdl
	ghdl -a --std=08 tb/tb_top.vhdl	
	ghdl -e --std=08 tb_top
	ghdl -r --std=08 tb_top --wave=case1_tb.ghw

cam: elab
	ghdl -a --std=08 tb/cam_stimuli.vhdl
	ghdl -a --std=08 tb/tb_top.vhdl	
	ghdl -e --std=08 tb_top
	ghdl -r --std=08 tb_top --wave=axi_cam_tb.ghw

sccb: elab
	ghdl -a --std=08 tb/sccb_stimuli.vhdl	
	ghdl -a --std=08 tb/tb_top.vhdl	
	ghdl -e --std=08 tb_top
	ghdl -r --std=08 tb_top --wave=axi_sccb_tb.ghw

elab: axi_cam_pkg.vhdl tri_out.vhdl bi_dir.vhdl sccb_sender.vhdl sccb.vhdl axi_lite.vhdl fifo_write.vhdl fifo_read.vhdl RAM.vhdl reset_sync.vhdl synchronizer.vhdl synchronizer_vector.vhdl fifo.vhdl cam_capture.vhdl cam_test.vhdl clk_mux.vhdl axi_hp.vhdl int_ctrl.vhdl clk_check.vhdl axi_cam.vhdl tb/tb_top_pkg.vhdl tb/axi_lite_pkg.vhdl check
	ghdl -a --std=08 axi_cam_pkg.vhdl
	ghdl -a --std=08 tri_out.vhdl
	ghdl -a --std=08 bi_dir.vhdl
	ghdl -a --std=08 sccb_sender.vhdl
	ghdl -a --std=08 sccb.vhdl
	ghdl -a --std=08 axi_lite.vhdl
	ghdl -a --std=08 RAM.vhdl
	ghdl -a --std=08 reset_sync.vhdl
	ghdl -a --std=08 fifo_write.vhdl
	ghdl -a --std=08 fifo_read.vhdl
	ghdl -a --std=08 synchronizer.vhdl
	ghdl -a --std=08 fifo.vhdl
	ghdl -a --std=08 synchronizer_vector.vhdl
	ghdl -a --std=08 cam_capture.vhdl
	ghdl -a --std=08 cam_test.vhdl
	ghdl -a --std=08 no_synth/clk_mux.vhdl
	ghdl -a --std=08 axi_hp.vhdl
	ghdl -a --std=08 int_ctrl.vhdl
	ghdl -a --std=08 clk_check.vhdl	
	ghdl -a --std=08 axi_cam.vhdl
	ghdl -a --std=08 tb/tb_top_pkg.vhdl
	ghdl -a --std=08 tb/axi_lite_pkg.vhdl		


check: axi_cam_pkg.vhdl tri_out.vhdl bi_dir.vhdl sccb_sender.vhdl sccb.vhdl axi_lite.vhdl fifo_write.vhdl fifo_read.vhdl RAM.vhdl reset_sync.vhdl synchronizer.vhdl synchronizer_vector.vhdl fifo.vhdl cam_capture.vhdl int_ctrl.vhdl clk_check.vhdl cam_test.vhdl clk_mux.vhdl axi_hp.vhdl axi_cam.vhdl
	ghdl -s --std=08 axi_cam_pkg.vhdl
	ghdl -s --std=08 tri_out.vhdl
	ghdl -s --std=08 bi_dir.vhdl
	ghdl -s --std=08 sccb_sender.vhdl
	ghdl -s --std=08 sccb.vhdl
#	ghdl -s --std=08 axi_lite.vhdl -- there is not axi_cam_pkg at this of check....
	ghdl -s --std=08 fifo_write.vhdl
	ghdl -s --std=08 fifo_read.vhdl
	ghdl -s --std=08 RAM.vhdl
	ghdl -s --std=08 reset_sync.vhdl
	ghdl -s --std=08 synchronizer.vhdl
	ghdl -s --std=08 fifo.vhdl
	ghdl -s --std=08 synchronizer_vector.vhdl
#	ghdl -s --std=08 cam_capture.vhdl
	ghdl -s --std=08 int_ctrl.vhdl
	ghdl -s --std=08 clk_check.vhdl
#	ghdl -s --std=08 cam_test.vhdl
	ghdl -s --std=08 no_synth/clk_mux.vhdl
#	ghdl -s --std=08 axi_hp.vhdl
#	ghdl -s --std=08 axi_cam.vhdl

#fifo: RAM.vhdl fifo_write.vhdl fifo_read.vhdl fifo.vhdl
#	ghdl -a --std=08 RAM.vhdl
#	ghdl -a --std=08 fifo_write.vhdl
#	ghdl -a --std=08 fifo_read.vhdl
#	ghdl -a --std=08 synchronizer.vhd
#	ghdl -a --std=08 fifo.vhdl
#	ghdl -a --std=08 fifo_tb.vhdl
#	ghdl -e --std=08 fifo_tb
#	ghdl -r --std=08 fifo_tb --wave=fifo_tb.ghw

clean:
	rm -f *.ghw *.cf
