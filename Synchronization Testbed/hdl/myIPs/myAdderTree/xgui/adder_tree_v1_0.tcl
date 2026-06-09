# Definitional proc to organize widgets for parameters.
proc init_gui { IPINST } {
  ipgui::add_param $IPINST -name "Component_Name"
  #Adding Page
  set Page_0 [ipgui::add_page $IPINST -name "Page 0"]
  ipgui::add_param $IPINST -name "CLOG2_NUMBER_OF_SUMMANDS" -parent ${Page_0}
  ipgui::add_param $IPINST -name "INPUT_DATA_WIDTH" -parent ${Page_0}
  ipgui::add_param $IPINST -name "IS_PIPELINED" -parent ${Page_0}
  ipgui::add_param $IPINST -name "NUMBER_OF_SUMMANDS" -parent ${Page_0}


}

proc update_PARAM_VALUE.CLOG2_NUMBER_OF_SUMMANDS { PARAM_VALUE.CLOG2_NUMBER_OF_SUMMANDS } {
	# Procedure called to update CLOG2_NUMBER_OF_SUMMANDS when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.CLOG2_NUMBER_OF_SUMMANDS { PARAM_VALUE.CLOG2_NUMBER_OF_SUMMANDS } {
	# Procedure called to validate CLOG2_NUMBER_OF_SUMMANDS
	return true
}

proc update_PARAM_VALUE.INPUT_DATA_WIDTH { PARAM_VALUE.INPUT_DATA_WIDTH } {
	# Procedure called to update INPUT_DATA_WIDTH when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.INPUT_DATA_WIDTH { PARAM_VALUE.INPUT_DATA_WIDTH } {
	# Procedure called to validate INPUT_DATA_WIDTH
	return true
}

proc update_PARAM_VALUE.IS_PIPELINED { PARAM_VALUE.IS_PIPELINED } {
	# Procedure called to update IS_PIPELINED when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.IS_PIPELINED { PARAM_VALUE.IS_PIPELINED } {
	# Procedure called to validate IS_PIPELINED
	return true
}

proc update_PARAM_VALUE.NUMBER_OF_SUMMANDS { PARAM_VALUE.NUMBER_OF_SUMMANDS } {
	# Procedure called to update NUMBER_OF_SUMMANDS when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.NUMBER_OF_SUMMANDS { PARAM_VALUE.NUMBER_OF_SUMMANDS } {
	# Procedure called to validate NUMBER_OF_SUMMANDS
	return true
}


proc update_MODELPARAM_VALUE.IS_PIPELINED { MODELPARAM_VALUE.IS_PIPELINED PARAM_VALUE.IS_PIPELINED } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.IS_PIPELINED}] ${MODELPARAM_VALUE.IS_PIPELINED}
}

proc update_MODELPARAM_VALUE.INPUT_DATA_WIDTH { MODELPARAM_VALUE.INPUT_DATA_WIDTH PARAM_VALUE.INPUT_DATA_WIDTH } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.INPUT_DATA_WIDTH}] ${MODELPARAM_VALUE.INPUT_DATA_WIDTH}
}

proc update_MODELPARAM_VALUE.NUMBER_OF_SUMMANDS { MODELPARAM_VALUE.NUMBER_OF_SUMMANDS PARAM_VALUE.NUMBER_OF_SUMMANDS } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.NUMBER_OF_SUMMANDS}] ${MODELPARAM_VALUE.NUMBER_OF_SUMMANDS}
}

proc update_MODELPARAM_VALUE.CLOG2_NUMBER_OF_SUMMANDS { MODELPARAM_VALUE.CLOG2_NUMBER_OF_SUMMANDS PARAM_VALUE.CLOG2_NUMBER_OF_SUMMANDS } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.CLOG2_NUMBER_OF_SUMMANDS}] ${MODELPARAM_VALUE.CLOG2_NUMBER_OF_SUMMANDS}
}

