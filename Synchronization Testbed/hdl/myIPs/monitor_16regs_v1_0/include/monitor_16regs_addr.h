/*
 * File Name:         hdl_prj\ipcore\monitor_16regs_v1_0\include\monitor_16regs_addr.h
 * Description:       C Header File
 * Created:           2024-12-24 12:13:39
*/

#ifndef MONITOR_16REGS_H_
#define MONITOR_16REGS_H_

#define  IPCore_Reset_monitor_16regs          0x0  //write 0x1 to bit 0 to reset IP core
#define  IPCore_Enable_monitor_16regs         0x4  //enabled (by default) when bit 0 is 0x1
#define  IPCore_Timestamp_monitor_16regs      0x8  //contains unique IP timestamp (yymmddHHMM): 2412241212: 2412241213
#define  dataWriteAXI0_Data_monitor_16regs    0x100  //data register for Inport dataWriteAXI0
#define  dataWriteAXI1_Data_monitor_16regs    0x104  //data register for Inport dataWriteAXI1
#define  dataWriteAXI2_Data_monitor_16regs    0x108  //data register for Inport dataWriteAXI2
#define  dataWriteAXI3_Data_monitor_16regs    0x10C  //data register for Inport dataWriteAXI3
#define  dataWriteAXI4_Data_monitor_16regs    0x110  //data register for Inport dataWriteAXI4
#define  dataWriteAXI5_Data_monitor_16regs    0x114  //data register for Inport dataWriteAXI5
#define  dataWriteAXI6_Data_monitor_16regs    0x118  //data register for Inport dataWriteAXI6
#define  dataWriteAXI7_Data_monitor_16regs    0x11C  //data register for Inport dataWriteAXI7
#define  dataWriteAXI8_Data_monitor_16regs    0x120  //data register for Inport dataWriteAXI8
#define  dataWriteAXI9_Data_monitor_16regs    0x124  //data register for Inport dataWriteAXI9
#define  dataWriteAXI10_Data_monitor_16regs   0x128  //data register for Inport dataWriteAXI10
#define  dataWriteAXI11_Data_monitor_16regs   0x12C  //data register for Inport dataWriteAXI11
#define  dataWriteAXI12_Data_monitor_16regs   0x130  //data register for Inport dataWriteAXI12
#define  dataWriteAXI13_Data_monitor_16regs   0x134  //data register for Inport dataWriteAXI13
#define  dataWriteAXI14_Data_monitor_16regs   0x138  //data register for Inport dataWriteAXI14
#define  dataWriteAXI15_Data_monitor_16regs   0x13C  //data register for Inport dataWriteAXI15
#define  dataReadAXI0_Data_monitor_16regs     0x200  //data register for Outport dataReadAXI0
#define  dataReadAXI1_Data_monitor_16regs     0x204  //data register for Outport dataReadAXI1
#define  dataReadAXI2_Data_monitor_16regs     0x208  //data register for Outport dataReadAXI2
#define  dataReadAXI3_Data_monitor_16regs     0x20C  //data register for Outport dataReadAXI3
#define  dataReadAXI4_Data_monitor_16regs     0x210  //data register for Outport dataReadAXI4
#define  dataReadAXI5_Data_monitor_16regs     0x214  //data register for Outport dataReadAXI5
#define  dataReadAXI6_Data_monitor_16regs     0x218  //data register for Outport dataReadAXI6
#define  dataReadAXI7_Data_monitor_16regs     0x21C  //data register for Outport dataReadAXI7
#define  dataReadAXI8_Data_monitor_16regs     0x220  //data register for Outport dataReadAXI8
#define  dataReadAXI9_Data_monitor_16regs     0x224  //data register for Outport dataReadAXI9
#define  dataReadAXI10_Data_monitor_16regs    0x228  //data register for Outport dataReadAXI10
#define  dataReadAXI11_Data_monitor_16regs    0x22C  //data register for Outport dataReadAXI11
#define  dataReadAXI12_Data_monitor_16regs    0x230  //data register for Outport dataReadAXI12
#define  dataReadAXI13_Data_monitor_16regs    0x234  //data register for Outport dataReadAXI13
#define  dataReadAXI14_Data_monitor_16regs    0x238  //data register for Outport dataReadAXI14
#define  dataReadAXI15_Data_monitor_16regs    0x23C  //data register for Outport dataReadAXI15

#endif /* MONITOR_16REGS_H_ */
