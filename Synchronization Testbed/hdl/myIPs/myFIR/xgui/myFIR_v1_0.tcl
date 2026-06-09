# Definitional proc to organize widgets for parameters.
proc init_gui { IPINST } {
  ipgui::add_param $IPINST -name "Component_Name"
  #Adding Page
  set Page_0 [ipgui::add_page $IPINST -name "Page 0"]
  ipgui::add_param $IPINST -name "CLOG2_NUMBER_OF_TAPS" -parent ${Page_0}
  ipgui::add_param $IPINST -name "COEFF_WIDTH" -parent ${Page_0}
  ipgui::add_param $IPINST -name "FIR_ARCHITECTURE" -parent ${Page_0}
  ipgui::add_param $IPINST -name "INPUT_DATA_WIDTH" -parent ${Page_0}
  ipgui::add_param $IPINST -name "NUMBER_OF_TAPS" -parent ${Page_0}
  ipgui::add_param $IPINST -name "TDM_RATE" -parent ${Page_0}


}

proc update_PARAM_VALUE.CLOG2_NUMBER_OF_TAPS { PARAM_VALUE.CLOG2_NUMBER_OF_TAPS } {
	# Procedure called to update CLOG2_NUMBER_OF_TAPS when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.CLOG2_NUMBER_OF_TAPS { PARAM_VALUE.CLOG2_NUMBER_OF_TAPS } {
	# Procedure called to validate CLOG2_NUMBER_OF_TAPS
	return true
}

proc update_PARAM_VALUE.COEFF_WIDTH { PARAM_VALUE.COEFF_WIDTH } {
	# Procedure called to update COEFF_WIDTH when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.COEFF_WIDTH { PARAM_VALUE.COEFF_WIDTH } {
	# Procedure called to validate COEFF_WIDTH
	return true
}

proc update_PARAM_VALUE.FIR_ARCHITECTURE { PARAM_VALUE.FIR_ARCHITECTURE } {
	# Procedure called to update FIR_ARCHITECTURE when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.FIR_ARCHITECTURE { PARAM_VALUE.FIR_ARCHITECTURE } {
	# Procedure called to validate FIR_ARCHITECTURE
	return true
}

proc update_PARAM_VALUE.INPUT_DATA_WIDTH { PARAM_VALUE.INPUT_DATA_WIDTH } {
	# Procedure called to update INPUT_DATA_WIDTH when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.INPUT_DATA_WIDTH { PARAM_VALUE.INPUT_DATA_WIDTH } {
	# Procedure called to validate INPUT_DATA_WIDTH
	return true
}

proc update_PARAM_VALUE.NUMBER_OF_TAPS { PARAM_VALUE.NUMBER_OF_TAPS } {
	# Procedure called to update NUMBER_OF_TAPS when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.NUMBER_OF_TAPS { PARAM_VALUE.NUMBER_OF_TAPS } {
	# Procedure called to validate NUMBER_OF_TAPS
	return true
}

proc update_PARAM_VALUE.TDM_RATE { PARAM_VALUE.TDM_RATE } {
	# Procedure called to update TDM_RATE when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.TDM_RATE { PARAM_VALUE.TDM_RATE } {
	# Procedure called to validate TDM_RATE
	return true
}


proc update_MODELPARAM_VALUE.FIR_ARCHITECTURE { MODELPARAM_VALUE.FIR_ARCHITECTURE PARAM_VALUE.FIR_ARCHITECTURE } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.FIR_ARCHITECTURE}] ${MODELPARAM_VALUE.FIR_ARCHITECTURE}
}

proc update_MODELPARAM_VALUE.TDM_RATE { MODELPARAM_VALUE.TDM_RATE PARAM_VALUE.TDM_RATE } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.TDM_RATE}] ${MODELPARAM_VALUE.TDM_RATE}
}

proc update_MODELPARAM_VALUE.INPUT_DATA_WIDTH { MODELPARAM_VALUE.INPUT_DATA_WIDTH PARAM_VALUE.INPUT_DATA_WIDTH } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.INPUT_DATA_WIDTH}] ${MODELPARAM_VALUE.INPUT_DATA_WIDTH}
}

proc update_MODELPARAM_VALUE.COEFF_WIDTH { MODELPARAM_VALUE.COEFF_WIDTH PARAM_VALUE.COEFF_WIDTH } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.COEFF_WIDTH}] ${MODELPARAM_VALUE.COEFF_WIDTH}
}

proc update_MODELPARAM_VALUE.NUMBER_OF_TAPS { MODELPARAM_VALUE.NUMBER_OF_TAPS PARAM_VALUE.NUMBER_OF_TAPS } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.NUMBER_OF_TAPS}] ${MODELPARAM_VALUE.NUMBER_OF_TAPS}
}

proc update_MODELPARAM_VALUE.CLOG2_NUMBER_OF_TAPS { MODELPARAM_VALUE.CLOG2_NUMBER_OF_TAPS PARAM_VALUE.CLOG2_NUMBER_OF_TAPS } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.CLOG2_NUMBER_OF_TAPS}] ${MODELPARAM_VALUE.CLOG2_NUMBER_OF_TAPS}
}

