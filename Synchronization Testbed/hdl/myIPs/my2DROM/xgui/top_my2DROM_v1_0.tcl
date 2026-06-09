# Definitional proc to organize widgets for parameters.
proc init_gui { IPINST } {
  ipgui::add_param $IPINST -name "Component_Name"
  #Adding Page
  set Page_0 [ipgui::add_page $IPINST -name "Page 0"]
  ipgui::add_param $IPINST -name "COLS_BITWIDTH" -parent ${Page_0}
  ipgui::add_param $IPINST -name "DATA_BITWIDTH" -parent ${Page_0}
  ipgui::add_param $IPINST -name "INITFILE" -parent ${Page_0}
  ipgui::add_param $IPINST -name "ROWS_BITWIDTH" -parent ${Page_0}


}

proc update_PARAM_VALUE.COLS_BITWIDTH { PARAM_VALUE.COLS_BITWIDTH } {
	# Procedure called to update COLS_BITWIDTH when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.COLS_BITWIDTH { PARAM_VALUE.COLS_BITWIDTH } {
	# Procedure called to validate COLS_BITWIDTH
	return true
}

proc update_PARAM_VALUE.DATA_BITWIDTH { PARAM_VALUE.DATA_BITWIDTH } {
	# Procedure called to update DATA_BITWIDTH when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.DATA_BITWIDTH { PARAM_VALUE.DATA_BITWIDTH } {
	# Procedure called to validate DATA_BITWIDTH
	return true
}

proc update_PARAM_VALUE.INITFILE { PARAM_VALUE.INITFILE } {
	# Procedure called to update INITFILE when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.INITFILE { PARAM_VALUE.INITFILE } {
	# Procedure called to validate INITFILE
	return true
}

proc update_PARAM_VALUE.ROWS_BITWIDTH { PARAM_VALUE.ROWS_BITWIDTH } {
	# Procedure called to update ROWS_BITWIDTH when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.ROWS_BITWIDTH { PARAM_VALUE.ROWS_BITWIDTH } {
	# Procedure called to validate ROWS_BITWIDTH
	return true
}


proc update_MODELPARAM_VALUE.INITFILE { MODELPARAM_VALUE.INITFILE PARAM_VALUE.INITFILE } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.INITFILE}] ${MODELPARAM_VALUE.INITFILE}
}

proc update_MODELPARAM_VALUE.ROWS_BITWIDTH { MODELPARAM_VALUE.ROWS_BITWIDTH PARAM_VALUE.ROWS_BITWIDTH } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.ROWS_BITWIDTH}] ${MODELPARAM_VALUE.ROWS_BITWIDTH}
}

proc update_MODELPARAM_VALUE.COLS_BITWIDTH { MODELPARAM_VALUE.COLS_BITWIDTH PARAM_VALUE.COLS_BITWIDTH } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.COLS_BITWIDTH}] ${MODELPARAM_VALUE.COLS_BITWIDTH}
}

proc update_MODELPARAM_VALUE.DATA_BITWIDTH { MODELPARAM_VALUE.DATA_BITWIDTH PARAM_VALUE.DATA_BITWIDTH } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.DATA_BITWIDTH}] ${MODELPARAM_VALUE.DATA_BITWIDTH}
}

