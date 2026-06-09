create_project prj_ip {} -part xa7z010clg225-1I -force
set_property ip_repo_paths {../../} [current_fileset]

# Add HDL source files to project
add_files -norecurse {../hdl/phaseCorrectionCordic_src_Phase_Correction_Cordic_IP_DUT_pkg.vhd}
add_files -norecurse {../hdl/phaseCorrectionCordic_src_Cosine_HDL_Optimized.vhd}
add_files -norecurse {../hdl/phaseCorrectionCordic_src_Sine_HDL_Optimized.vhd}
add_files -norecurse {../hdl/phaseCorrectionCordic_src_Subsystem1.vhd}
add_files -norecurse {../hdl/phaseCorrectionCordic_src_fcn_IQconversion.vhd}
add_files -norecurse {../hdl/phaseCorrectionCordic_src_Quadrant_Mapper.vhd}
add_files -norecurse {../hdl/phaseCorrectionCordic_src_CordicKernelMag.vhd}
add_files -norecurse {../hdl/phaseCorrectionCordic_src_Quadrant_Correction.vhd}
add_files -norecurse {../hdl/phaseCorrectionCordic_src_HDL_CMA_core.vhd}
add_files -norecurse {../hdl/phaseCorrectionCordic_src_Phase_Correction_Cordic_IP_DUT.vhd}
add_files -norecurse {../hdl/phaseCorrectionCordic_reset_sync.vhd}
add_files -norecurse {../hdl/phaseCorrectionCordic_dut.vhd}
add_files -norecurse {../hdl/phaseCorrectionCordic.vhd}
set_property top phaseCorrectionCordic [get_filesets sources_1]
set_property top phaseCorrectionCordic [get_filesets sim_1]
update_compile_order -fileset sources_1
update_compile_order -fileset sim_1

# Package IP from project
ipx::package_project -root_dir {../} -force

# Set IP properties
set_property name phaseCorrectionCordic [ipx::current_core]
set_property display_name phaseCorrectionCordic [ipx::current_core]
set_property version {1.0} [ipx::current_core]
set_property library {ip} [ipx::current_core]
set Families [split [lsort -uniq [get_property C_FAMILY [get_parts]]]]
set IPSupportedFamily {}
foreach family $Families {append IPSupportedFamily "{$family} {Production} "}
set_property supported_families $IPSupportedFamily [ipx::current_core]
set_property taxonomy {{/HDL Coder Generated IP}} [ipx::current_core]
set_property description {HDL Coder generated IP} [ipx::current_core]
set_property core_revision 0001000000 [ipx::current_core]

# Add HDL source files to IP
ipx::add_file {hdl/phaseCorrectionCordic_src_Phase_Correction_Cordic_IP_DUT_pkg.vhd} [ipx::get_file_groups xilinx_anylanguagesynthesis -of_objects [ipx::current_core]]
set_property type {{vhdlSource}} [ipx::get_files {hdl/phaseCorrectionCordic_src_Phase_Correction_Cordic_IP_DUT_pkg.vhd} -of_objects [ipx::get_file_groups xilinx_anylanguagesynthesis -of_objects [ipx::current_core]]]
ipx::add_file {hdl/phaseCorrectionCordic_src_Phase_Correction_Cordic_IP_DUT_pkg.vhd} [ipx::get_file_groups xilinx_anylanguagebehavioralsimulation -of_objects [ipx::current_core]]
set_property type {{vhdlSource}} [ipx::get_files {hdl/phaseCorrectionCordic_src_Phase_Correction_Cordic_IP_DUT_pkg.vhd} -of_objects [ipx::get_file_groups xilinx_anylanguagebehavioralsimulation -of_objects [ipx::current_core]]]
ipx::add_file {hdl/phaseCorrectionCordic_src_Cosine_HDL_Optimized.vhd} [ipx::get_file_groups xilinx_anylanguagesynthesis -of_objects [ipx::current_core]]
set_property type {{vhdlSource}} [ipx::get_files {hdl/phaseCorrectionCordic_src_Cosine_HDL_Optimized.vhd} -of_objects [ipx::get_file_groups xilinx_anylanguagesynthesis -of_objects [ipx::current_core]]]
ipx::add_file {hdl/phaseCorrectionCordic_src_Cosine_HDL_Optimized.vhd} [ipx::get_file_groups xilinx_anylanguagebehavioralsimulation -of_objects [ipx::current_core]]
set_property type {{vhdlSource}} [ipx::get_files {hdl/phaseCorrectionCordic_src_Cosine_HDL_Optimized.vhd} -of_objects [ipx::get_file_groups xilinx_anylanguagebehavioralsimulation -of_objects [ipx::current_core]]]
ipx::add_file {hdl/phaseCorrectionCordic_src_Sine_HDL_Optimized.vhd} [ipx::get_file_groups xilinx_anylanguagesynthesis -of_objects [ipx::current_core]]
set_property type {{vhdlSource}} [ipx::get_files {hdl/phaseCorrectionCordic_src_Sine_HDL_Optimized.vhd} -of_objects [ipx::get_file_groups xilinx_anylanguagesynthesis -of_objects [ipx::current_core]]]
ipx::add_file {hdl/phaseCorrectionCordic_src_Sine_HDL_Optimized.vhd} [ipx::get_file_groups xilinx_anylanguagebehavioralsimulation -of_objects [ipx::current_core]]
set_property type {{vhdlSource}} [ipx::get_files {hdl/phaseCorrectionCordic_src_Sine_HDL_Optimized.vhd} -of_objects [ipx::get_file_groups xilinx_anylanguagebehavioralsimulation -of_objects [ipx::current_core]]]
ipx::add_file {hdl/phaseCorrectionCordic_src_Subsystem1.vhd} [ipx::get_file_groups xilinx_anylanguagesynthesis -of_objects [ipx::current_core]]
set_property type {{vhdlSource}} [ipx::get_files {hdl/phaseCorrectionCordic_src_Subsystem1.vhd} -of_objects [ipx::get_file_groups xilinx_anylanguagesynthesis -of_objects [ipx::current_core]]]
ipx::add_file {hdl/phaseCorrectionCordic_src_Subsystem1.vhd} [ipx::get_file_groups xilinx_anylanguagebehavioralsimulation -of_objects [ipx::current_core]]
set_property type {{vhdlSource}} [ipx::get_files {hdl/phaseCorrectionCordic_src_Subsystem1.vhd} -of_objects [ipx::get_file_groups xilinx_anylanguagebehavioralsimulation -of_objects [ipx::current_core]]]
ipx::add_file {hdl/phaseCorrectionCordic_src_fcn_IQconversion.vhd} [ipx::get_file_groups xilinx_anylanguagesynthesis -of_objects [ipx::current_core]]
set_property type {{vhdlSource}} [ipx::get_files {hdl/phaseCorrectionCordic_src_fcn_IQconversion.vhd} -of_objects [ipx::get_file_groups xilinx_anylanguagesynthesis -of_objects [ipx::current_core]]]
ipx::add_file {hdl/phaseCorrectionCordic_src_fcn_IQconversion.vhd} [ipx::get_file_groups xilinx_anylanguagebehavioralsimulation -of_objects [ipx::current_core]]
set_property type {{vhdlSource}} [ipx::get_files {hdl/phaseCorrectionCordic_src_fcn_IQconversion.vhd} -of_objects [ipx::get_file_groups xilinx_anylanguagebehavioralsimulation -of_objects [ipx::current_core]]]
ipx::add_file {hdl/phaseCorrectionCordic_src_Quadrant_Mapper.vhd} [ipx::get_file_groups xilinx_anylanguagesynthesis -of_objects [ipx::current_core]]
set_property type {{vhdlSource}} [ipx::get_files {hdl/phaseCorrectionCordic_src_Quadrant_Mapper.vhd} -of_objects [ipx::get_file_groups xilinx_anylanguagesynthesis -of_objects [ipx::current_core]]]
ipx::add_file {hdl/phaseCorrectionCordic_src_Quadrant_Mapper.vhd} [ipx::get_file_groups xilinx_anylanguagebehavioralsimulation -of_objects [ipx::current_core]]
set_property type {{vhdlSource}} [ipx::get_files {hdl/phaseCorrectionCordic_src_Quadrant_Mapper.vhd} -of_objects [ipx::get_file_groups xilinx_anylanguagebehavioralsimulation -of_objects [ipx::current_core]]]
ipx::add_file {hdl/phaseCorrectionCordic_src_CordicKernelMag.vhd} [ipx::get_file_groups xilinx_anylanguagesynthesis -of_objects [ipx::current_core]]
set_property type {{vhdlSource}} [ipx::get_files {hdl/phaseCorrectionCordic_src_CordicKernelMag.vhd} -of_objects [ipx::get_file_groups xilinx_anylanguagesynthesis -of_objects [ipx::current_core]]]
ipx::add_file {hdl/phaseCorrectionCordic_src_CordicKernelMag.vhd} [ipx::get_file_groups xilinx_anylanguagebehavioralsimulation -of_objects [ipx::current_core]]
set_property type {{vhdlSource}} [ipx::get_files {hdl/phaseCorrectionCordic_src_CordicKernelMag.vhd} -of_objects [ipx::get_file_groups xilinx_anylanguagebehavioralsimulation -of_objects [ipx::current_core]]]
ipx::add_file {hdl/phaseCorrectionCordic_src_Quadrant_Correction.vhd} [ipx::get_file_groups xilinx_anylanguagesynthesis -of_objects [ipx::current_core]]
set_property type {{vhdlSource}} [ipx::get_files {hdl/phaseCorrectionCordic_src_Quadrant_Correction.vhd} -of_objects [ipx::get_file_groups xilinx_anylanguagesynthesis -of_objects [ipx::current_core]]]
ipx::add_file {hdl/phaseCorrectionCordic_src_Quadrant_Correction.vhd} [ipx::get_file_groups xilinx_anylanguagebehavioralsimulation -of_objects [ipx::current_core]]
set_property type {{vhdlSource}} [ipx::get_files {hdl/phaseCorrectionCordic_src_Quadrant_Correction.vhd} -of_objects [ipx::get_file_groups xilinx_anylanguagebehavioralsimulation -of_objects [ipx::current_core]]]
ipx::add_file {hdl/phaseCorrectionCordic_src_HDL_CMA_core.vhd} [ipx::get_file_groups xilinx_anylanguagesynthesis -of_objects [ipx::current_core]]
set_property type {{vhdlSource}} [ipx::get_files {hdl/phaseCorrectionCordic_src_HDL_CMA_core.vhd} -of_objects [ipx::get_file_groups xilinx_anylanguagesynthesis -of_objects [ipx::current_core]]]
ipx::add_file {hdl/phaseCorrectionCordic_src_HDL_CMA_core.vhd} [ipx::get_file_groups xilinx_anylanguagebehavioralsimulation -of_objects [ipx::current_core]]
set_property type {{vhdlSource}} [ipx::get_files {hdl/phaseCorrectionCordic_src_HDL_CMA_core.vhd} -of_objects [ipx::get_file_groups xilinx_anylanguagebehavioralsimulation -of_objects [ipx::current_core]]]
ipx::add_file {hdl/phaseCorrectionCordic_src_Phase_Correction_Cordic_IP_DUT.vhd} [ipx::get_file_groups xilinx_anylanguagesynthesis -of_objects [ipx::current_core]]
set_property type {{vhdlSource}} [ipx::get_files {hdl/phaseCorrectionCordic_src_Phase_Correction_Cordic_IP_DUT.vhd} -of_objects [ipx::get_file_groups xilinx_anylanguagesynthesis -of_objects [ipx::current_core]]]
ipx::add_file {hdl/phaseCorrectionCordic_src_Phase_Correction_Cordic_IP_DUT.vhd} [ipx::get_file_groups xilinx_anylanguagebehavioralsimulation -of_objects [ipx::current_core]]
set_property type {{vhdlSource}} [ipx::get_files {hdl/phaseCorrectionCordic_src_Phase_Correction_Cordic_IP_DUT.vhd} -of_objects [ipx::get_file_groups xilinx_anylanguagebehavioralsimulation -of_objects [ipx::current_core]]]
ipx::add_file {hdl/phaseCorrectionCordic_reset_sync.vhd} [ipx::get_file_groups xilinx_anylanguagesynthesis -of_objects [ipx::current_core]]
set_property type {{vhdlSource}} [ipx::get_files {hdl/phaseCorrectionCordic_reset_sync.vhd} -of_objects [ipx::get_file_groups xilinx_anylanguagesynthesis -of_objects [ipx::current_core]]]
ipx::add_file {hdl/phaseCorrectionCordic_reset_sync.vhd} [ipx::get_file_groups xilinx_anylanguagebehavioralsimulation -of_objects [ipx::current_core]]
set_property type {{vhdlSource}} [ipx::get_files {hdl/phaseCorrectionCordic_reset_sync.vhd} -of_objects [ipx::get_file_groups xilinx_anylanguagebehavioralsimulation -of_objects [ipx::current_core]]]
ipx::add_file {hdl/phaseCorrectionCordic_dut.vhd} [ipx::get_file_groups xilinx_anylanguagesynthesis -of_objects [ipx::current_core]]
set_property type {{vhdlSource}} [ipx::get_files {hdl/phaseCorrectionCordic_dut.vhd} -of_objects [ipx::get_file_groups xilinx_anylanguagesynthesis -of_objects [ipx::current_core]]]
ipx::add_file {hdl/phaseCorrectionCordic_dut.vhd} [ipx::get_file_groups xilinx_anylanguagebehavioralsimulation -of_objects [ipx::current_core]]
set_property type {{vhdlSource}} [ipx::get_files {hdl/phaseCorrectionCordic_dut.vhd} -of_objects [ipx::get_file_groups xilinx_anylanguagebehavioralsimulation -of_objects [ipx::current_core]]]
ipx::add_file {hdl/phaseCorrectionCordic.vhd} [ipx::get_file_groups xilinx_anylanguagesynthesis -of_objects [ipx::current_core]]
set_property type {{vhdlSource}} [ipx::get_files {hdl/phaseCorrectionCordic.vhd} -of_objects [ipx::get_file_groups xilinx_anylanguagesynthesis -of_objects [ipx::current_core]]]
ipx::add_file {hdl/phaseCorrectionCordic.vhd} [ipx::get_file_groups xilinx_anylanguagebehavioralsimulation -of_objects [ipx::current_core]]
set_property type {{vhdlSource}} [ipx::get_files {hdl/phaseCorrectionCordic.vhd} -of_objects [ipx::get_file_groups xilinx_anylanguagebehavioralsimulation -of_objects [ipx::current_core]]]

# Add bus interfaces
ipx::remove_all_bus_interface [ipx::current_core]
ipx::remove_all_memory_map [ipx::current_core]
ipx::remove_all_address_space [ipx::current_core]

# Add IP clock and reset definition
ipx::add_bus_interface {IPCORE_CLK} [ipx::current_core]
set_property abstraction_type_vlnv {xilinx.com:signal:clock_rtl:1.0} [ipx::get_bus_interfaces IPCORE_CLK -of_objects [ipx::current_core]]
set_property bus_type_vlnv {xilinx.com:signal:clock:1.0} [ipx::get_bus_interfaces IPCORE_CLK -of_objects [ipx::current_core]]
ipx::add_port_map {CLK} [ipx::get_bus_interfaces IPCORE_CLK -of_objects [ipx::current_core]]
set_property physical_name {IPCORE_CLK} [ipx::get_port_maps CLK -of_objects [ipx::get_bus_interfaces IPCORE_CLK -of_objects [ipx::current_core]]]
ipx::add_bus_interface {IPCORE_RESETN} [ipx::current_core]
set_property abstraction_type_vlnv {xilinx.com:signal:reset_rtl:1.0} [ipx::get_bus_interfaces IPCORE_RESETN -of_objects [ipx::current_core]]
set_property bus_type_vlnv {xilinx.com:signal:reset:1.0} [ipx::get_bus_interfaces IPCORE_RESETN -of_objects [ipx::current_core]]
ipx::add_port_map {RST} [ipx::get_bus_interfaces IPCORE_RESETN -of_objects [ipx::current_core]]
set_property physical_name {IPCORE_RESETN} [ipx::get_port_maps RST -of_objects [ipx::get_bus_interfaces IPCORE_RESETN -of_objects [ipx::current_core]]]
ipx::add_bus_parameter {ASSOCIATED_RESET} [ipx::get_bus_interfaces IPCORE_CLK -of_objects [ipx::current_core]]
set_property value {IPCORE_RESETN} [ipx::get_bus_parameters ASSOCIATED_RESET -of_objects [ipx::get_bus_interfaces IPCORE_CLK -of_objects [ipx::current_core]]]
ipx::add_bus_parameter {POLARITY} [ipx::get_bus_interfaces IPCORE_RESETN -of_objects [ipx::current_core]]
set_property value {ACTIVE_LOW} [ipx::get_bus_parameters POLARITY -of_objects [ipx::get_bus_interfaces IPCORE_RESETN -of_objects [ipx::current_core]]]


# Add report files
ipx::add_file_group -type {product_guide} {} [ipx::current_core]
ipx::add_file {doc/phaseCorrectionCordic_ip_core_report.html} [ipx::get_file_groups xilinx_productguide -of_objects [ipx::current_core]]
set_property type {{html}} [ipx::get_files {doc/phaseCorrectionCordic_ip_core_report.html} -of_objects [ipx::get_file_groups xilinx_productguide -of_objects [ipx::current_core]]]

# Package IP
ipx::create_xgui_files [ipx::current_core]
ipx::check_integrity -quiet [ipx::current_core]
ipx::save_core [ipx::current_core]
ipx::archive_core {../phaseCorrectionCordic_v1_0.zip} [ipx::current_core]
close_project
exit
