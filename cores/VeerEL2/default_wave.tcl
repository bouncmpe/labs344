gtkwave::setZoomFactor -12
gtkwave::setWindowStartTime 0

gtkwave::addSignalsFromList core_clk

gtkwave::addSignalsFromList tb_top.rvtop_wrapper.rvtop.veer.ifu.ifc_fetch_addr_f
gtkwave::addSignalsFromList tb_top.rvtop_wrapper.rvtop.veer.ifu.ifu_fetch_data_f
gtkwave::addSignalsFromList tb_top.rvtop_wrapper.rvtop.veer.dec.dec_i0_instr_d
gtkwave::addSignalsFromList tb_top.rvtop_wrapper.rvtop.veer.dec.decode.i0_inst_x
gtkwave::addSignalsFromList tb_top.rvtop_wrapper.rvtop.veer.dec.decode.i0_inst_r

# gtkwave::addSignalsFromList tb_top.rvtop_wrapper.rvtop.veer.exu.i_alu.pc_in;          # PC input to ALU
# gtkwave::addSignalsFromList tb_top.rvtop_wrapper.rvtop.veer.exu.i_alu.a_in;           # First input to ALU
# gtkwave::addSignalsFromList tb_top.rvtop_wrapper.rvtop.veer.exu.i_alu.b_in;           # Second input to ALU
# gtkwave::addSignalsFromList tb_top.rvtop_wrapper.rvtop.veer.exu.i_alu.result;         # ALU result

# gtkwave::addSignalsFromList tb_top.rvtop_wrapper.rvtop.veer.exu.exu_flush_final
# gtkwave::addSignalsFromList tb_top.rvtop_wrapper.rvtop.veer.exu.exu_flush_path_final
