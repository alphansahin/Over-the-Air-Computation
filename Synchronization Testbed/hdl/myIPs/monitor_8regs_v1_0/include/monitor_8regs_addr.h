/*
 * File Name:         hdl_prj\ipcore\monitor_8regs_v1_0\include\monitor_8regs_addr.h
 * Description:       C Header File
 * Created:           2024-12-24 12:15:31
*/

#ifndef MONITOR_8REGS_H_
#define MONITOR_8REGS_H_

#define  IPCore_Reset_monitor_8regs         0x0  //write 0x1 to bit 0 to reset IP core
#define  IPCore_Enable_monitor_8regs        0x4  //enabled (by default) when bit 0 is 0x1
#define  IPCore_Timestamp_monitor_8regs     0x8  //contains unique IP timestamp (yymmddHHMM): 2412241214: 2412241215
#define  dataWriteAXI0_Data_monitor_8regs   0x100  //data register for Inport dataWriteAXI0
#define  dataWriteAXI1_Data_monitor_8regs   0x104  //data register for Inport dataWriteAXI1
#define  dataWriteAXI2_Data_monitor_8regs   0x108  //data register for Inport dataWriteAXI2
#define  dataWriteAXI3_Data_monitor_8regs   0x10C  //data register for Inport dataWriteAXI3
#define  dataWriteAXI4_Data_monitor_8regs   0x110  //data register for Inport dataWriteAXI4
#define  dataWriteAXI5_Data_monitor_8regs   0x114  //data register for Inport dataWriteAXI5
#define  dataWriteAXI6_Data_monitor_8regs   0x118  //data register for Inport dataWriteAXI6
#define  dataWriteAXI7_Data_monitor_8regs   0x11C  //data register for Inport dataWriteAXI7
#define  dataReadAXI0_Data_monitor_8regs    0x200  //data register for Outport dataReadAXI0
#define  dataReadAXI1_Data_monitor_8regs    0x204  //data register for Outport dataReadAXI1
#define  dataReadAXI2_Data_monitor_8regs    0x208  //data register for Outport dataReadAXI2
#define  dataReadAXI3_Data_monitor_8regs    0x20C  //data register for Outport dataReadAXI3
#define  dataReadAXI4_Data_monitor_8regs    0x210  //data register for Outport dataReadAXI4
#define  dataReadAXI5_Data_monitor_8regs    0x214  //data register for Outport dataReadAXI5
#define  dataReadAXI6_Data_monitor_8regs    0x218  //data register for Outport dataReadAXI6
#define  dataReadAXI7_Data_monitor_8regs    0x21C  //data register for Outport dataReadAXI7

#endif /* MONITOR_8REGS_H_ */
