/*
 * File Name:         hdl_prj\ipcore\monitor_64regs_v1_0\include\monitor_64regs_addr.h
 * Description:       C Header File
 * Created:           2025-10-08 14:50:41
*/

#ifndef MONITOR_64REGS_H_
#define MONITOR_64REGS_H_

#define  IPCore_Reset_monitor_64regs          0x0  //write 0x1 to bit 0 to reset IP core
#define  IPCore_Enable_monitor_64regs         0x4  //enabled (by default) when bit 0 is 0x1
#define  IPCore_Timestamp_monitor_64regs      0x8  //contains unique IP timestamp (yymmddHHMM): 2510081449: 2510081450
#define  dataWriteAXI0_Data_monitor_64regs    0x100  //data register for Inport dataWriteAXI0
#define  dataWriteAXI1_Data_monitor_64regs    0x104  //data register for Inport dataWriteAXI1
#define  dataWriteAXI2_Data_monitor_64regs    0x108  //data register for Inport dataWriteAXI2
#define  dataWriteAXI3_Data_monitor_64regs    0x10C  //data register for Inport dataWriteAXI3
#define  dataWriteAXI4_Data_monitor_64regs    0x110  //data register for Inport dataWriteAXI4
#define  dataWriteAXI5_Data_monitor_64regs    0x114  //data register for Inport dataWriteAXI5
#define  dataWriteAXI6_Data_monitor_64regs    0x118  //data register for Inport dataWriteAXI6
#define  dataWriteAXI7_Data_monitor_64regs    0x11C  //data register for Inport dataWriteAXI7
#define  dataWriteAXI8_Data_monitor_64regs    0x120  //data register for Inport dataWriteAXI8
#define  dataWriteAXI9_Data_monitor_64regs    0x124  //data register for Inport dataWriteAXI9
#define  dataWriteAXI10_Data_monitor_64regs   0x128  //data register for Inport dataWriteAXI10
#define  dataWriteAXI11_Data_monitor_64regs   0x12C  //data register for Inport dataWriteAXI11
#define  dataWriteAXI12_Data_monitor_64regs   0x130  //data register for Inport dataWriteAXI12
#define  dataWriteAXI13_Data_monitor_64regs   0x134  //data register for Inport dataWriteAXI13
#define  dataWriteAXI14_Data_monitor_64regs   0x138  //data register for Inport dataWriteAXI14
#define  dataWriteAXI15_Data_monitor_64regs   0x13C  //data register for Inport dataWriteAXI15
#define  dataWriteAXI16_Data_monitor_64regs   0x140  //data register for Inport dataWriteAXI16
#define  dataWriteAXI17_Data_monitor_64regs   0x144  //data register for Inport dataWriteAXI17
#define  dataWriteAXI18_Data_monitor_64regs   0x148  //data register for Inport dataWriteAXI18
#define  dataWriteAXI19_Data_monitor_64regs   0x14C  //data register for Inport dataWriteAXI19
#define  dataWriteAXI20_Data_monitor_64regs   0x150  //data register for Inport dataWriteAXI20
#define  dataWriteAXI21_Data_monitor_64regs   0x154  //data register for Inport dataWriteAXI21
#define  dataWriteAXI22_Data_monitor_64regs   0x158  //data register for Inport dataWriteAXI22
#define  dataWriteAXI23_Data_monitor_64regs   0x15C  //data register for Inport dataWriteAXI23
#define  dataWriteAXI24_Data_monitor_64regs   0x160  //data register for Inport dataWriteAXI24
#define  dataWriteAXI25_Data_monitor_64regs   0x164  //data register for Inport dataWriteAXI25
#define  dataWriteAXI26_Data_monitor_64regs   0x168  //data register for Inport dataWriteAXI26
#define  dataWriteAXI27_Data_monitor_64regs   0x16C  //data register for Inport dataWriteAXI27
#define  dataWriteAXI28_Data_monitor_64regs   0x170  //data register for Inport dataWriteAXI28
#define  dataWriteAXI29_Data_monitor_64regs   0x174  //data register for Inport dataWriteAXI29
#define  dataWriteAXI30_Data_monitor_64regs   0x178  //data register for Inport dataWriteAXI30
#define  dataWriteAXI31_Data_monitor_64regs   0x17C  //data register for Inport dataWriteAXI31
#define  dataWriteAXI32_Data_monitor_64regs   0x180  //data register for Inport dataWriteAXI32
#define  dataWriteAXI33_Data_monitor_64regs   0x184  //data register for Inport dataWriteAXI33
#define  dataWriteAXI34_Data_monitor_64regs   0x188  //data register for Inport dataWriteAXI34
#define  dataWriteAXI35_Data_monitor_64regs   0x18C  //data register for Inport dataWriteAXI35
#define  dataWriteAXI36_Data_monitor_64regs   0x190  //data register for Inport dataWriteAXI36
#define  dataWriteAXI37_Data_monitor_64regs   0x194  //data register for Inport dataWriteAXI37
#define  dataWriteAXI38_Data_monitor_64regs   0x198  //data register for Inport dataWriteAXI38
#define  dataWriteAXI39_Data_monitor_64regs   0x19C  //data register for Inport dataWriteAXI39
#define  dataWriteAXI40_Data_monitor_64regs   0x1A0  //data register for Inport dataWriteAXI40
#define  dataWriteAXI41_Data_monitor_64regs   0x1A4  //data register for Inport dataWriteAXI41
#define  dataWriteAXI42_Data_monitor_64regs   0x1A8  //data register for Inport dataWriteAXI42
#define  dataWriteAXI43_Data_monitor_64regs   0x1AC  //data register for Inport dataWriteAXI43
#define  dataWriteAXI44_Data_monitor_64regs   0x1B0  //data register for Inport dataWriteAXI44
#define  dataWriteAXI45_Data_monitor_64regs   0x1B4  //data register for Inport dataWriteAXI45
#define  dataWriteAXI46_Data_monitor_64regs   0x1B8  //data register for Inport dataWriteAXI46
#define  dataWriteAXI47_Data_monitor_64regs   0x1BC  //data register for Inport dataWriteAXI47
#define  dataWriteAXI48_Data_monitor_64regs   0x1C0  //data register for Inport dataWriteAXI48
#define  dataWriteAXI49_Data_monitor_64regs   0x1C4  //data register for Inport dataWriteAXI49
#define  dataWriteAXI50_Data_monitor_64regs   0x1C8  //data register for Inport dataWriteAXI50
#define  dataWriteAXI51_Data_monitor_64regs   0x1CC  //data register for Inport dataWriteAXI51
#define  dataWriteAXI52_Data_monitor_64regs   0x1D0  //data register for Inport dataWriteAXI52
#define  dataWriteAXI53_Data_monitor_64regs   0x1D4  //data register for Inport dataWriteAXI53
#define  dataWriteAXI54_Data_monitor_64regs   0x1D8  //data register for Inport dataWriteAXI54
#define  dataWriteAXI55_Data_monitor_64regs   0x1DC  //data register for Inport dataWriteAXI55
#define  dataWriteAXI56_Data_monitor_64regs   0x1E0  //data register for Inport dataWriteAXI56
#define  dataWriteAXI57_Data_monitor_64regs   0x1E4  //data register for Inport dataWriteAXI57
#define  dataWriteAXI58_Data_monitor_64regs   0x1E8  //data register for Inport dataWriteAXI58
#define  dataWriteAXI59_Data_monitor_64regs   0x1EC  //data register for Inport dataWriteAXI59
#define  dataWriteAXI60_Data_monitor_64regs   0x1F0  //data register for Inport dataWriteAXI60
#define  dataWriteAXI61_Data_monitor_64regs   0x1F4  //data register for Inport dataWriteAXI61
#define  dataWriteAXI62_Data_monitor_64regs   0x1F8  //data register for Inport dataWriteAXI62
#define  dataWriteAXI63_Data_monitor_64regs   0x1FC  //data register for Inport dataWriteAXI63
#define  dataReadAXI0_Data_monitor_64regs     0x200  //data register for Outport dataReadAXI0
#define  dataReadAXI1_Data_monitor_64regs     0x204  //data register for Outport dataReadAXI1
#define  dataReadAXI2_Data_monitor_64regs     0x208  //data register for Outport dataReadAXI2
#define  dataReadAXI3_Data_monitor_64regs     0x20C  //data register for Outport dataReadAXI3
#define  dataReadAXI4_Data_monitor_64regs     0x210  //data register for Outport dataReadAXI4
#define  dataReadAXI5_Data_monitor_64regs     0x214  //data register for Outport dataReadAXI5
#define  dataReadAXI6_Data_monitor_64regs     0x218  //data register for Outport dataReadAXI6
#define  dataReadAXI7_Data_monitor_64regs     0x21C  //data register for Outport dataReadAXI7
#define  dataReadAXI8_Data_monitor_64regs     0x220  //data register for Outport dataReadAXI8
#define  dataReadAXI9_Data_monitor_64regs     0x224  //data register for Outport dataReadAXI9
#define  dataReadAXI10_Data_monitor_64regs    0x228  //data register for Outport dataReadAXI10
#define  dataReadAXI11_Data_monitor_64regs    0x22C  //data register for Outport dataReadAXI11
#define  dataReadAXI12_Data_monitor_64regs    0x230  //data register for Outport dataReadAXI12
#define  dataReadAXI13_Data_monitor_64regs    0x234  //data register for Outport dataReadAXI13
#define  dataReadAXI14_Data_monitor_64regs    0x238  //data register for Outport dataReadAXI14
#define  dataReadAXI15_Data_monitor_64regs    0x23C  //data register for Outport dataReadAXI15
#define  dataReadAXI16_Data_monitor_64regs    0x240  //data register for Outport dataReadAXI16
#define  dataReadAXI17_Data_monitor_64regs    0x244  //data register for Outport dataReadAXI17
#define  dataReadAXI18_Data_monitor_64regs    0x248  //data register for Outport dataReadAXI18
#define  dataReadAXI19_Data_monitor_64regs    0x24C  //data register for Outport dataReadAXI19
#define  dataReadAXI20_Data_monitor_64regs    0x250  //data register for Outport dataReadAXI20
#define  dataReadAXI21_Data_monitor_64regs    0x254  //data register for Outport dataReadAXI21
#define  dataReadAXI22_Data_monitor_64regs    0x258  //data register for Outport dataReadAXI22
#define  dataReadAXI23_Data_monitor_64regs    0x25C  //data register for Outport dataReadAXI23

#endif /* MONITOR_64REGS_H_ */
