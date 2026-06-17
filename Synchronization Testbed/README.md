# Synchronization Testbed
There are so many details for the structure of the testbed. So there may be many unanswered questions at this time... I have submitted some papers about the testbed and a new OAC scheme. I will try to share more details over time.

The most comprehensive discussion at the moment is available at https://arxiv.org/abs/2606.18085


![Testbed structure](https://github.com/alphansahin/Over-the-Air-Computation/blob/main/Synchronization%20Testbed/testbedStructure.jpg?raw=true)

however, briefly...

The platform hosts twenty Adalm Pluto (Rev. C) SDRs mounted on the ceiling, each representing a node (or an edge device (ED)), and one SDR as the fusion node (or edge server (ES)). On the platform, each SDR has a dedicated host computer: NVIDIA Jetson Nano computers for the EDs and an Intel NUC for the ES. We also use an unmanaged network switch to enable communication between the host computers and to upload Python code to the EDs from the ES side. We use a specific user interface, shown below, running on the ES side. Through the user interface, we dynamically interact with the ES to initiate the protocol for coherent aggregation and its subroutines, observe the results, and monitor the SDR parameters. The user interface also allows us to read the parameters of the EDs’ SDRs over a local area network (LAN). However, we do not manually set the parameters for measurement plausibility.

![User Interface](https://github.com/alphansahin/Over-the-Air-Computation/blob/main/Synchronization%20Testbed/userInterface.jpg?raw=true)


The time and phase synchronization capability along with the ability to transmit and/or receive IQ data flexibly with low-cost SDRs is the unique aspect of the platform. Time synchronization fundamentally relies on a trigger mechanism and extends the strategies used in our previous experiments. In the testbed, the FPGA of each SDR is modified to continuously cross-correlate a 64-sample trigger waveform with the IQ samples (either on the transmitter or receiver path). Once the configured trigger waveform is detected, the FPGA starts counting down four configurable timers (i.e., C1, C2, C3, and C4) in units of samples, sequentially. During these countdowns, it enables or disables transmitter and receiver paths based on a configuration. For example, in one configuration, upon the detection instant of the trigger waveform, an ED’s SDR may be configured to acquire the IQ samples from the transceiver (i.e., AD9363) to a buffer in the FPGA (i.e., maximum 16384 samples) in the countdown C1, push the IQ data samples from Pluto’s random access memory (RAM) to the transceiver via directmemory access (DMA) in the countdown C2, and wait idle in the countdowns C3 and C4. In this work, we define two configurable trigger signals, denoted as T0 and T1, whose corresponding coefficients can be loaded into the correlator to switch the trigger waveform during the countdowns.


Another essential aspect is that the correlator can be configured to listen to the transmitter path, enabling dual use of the trigger signal. With this feature, a trigger signal from the ES can be utilized to trigger both the EDs in the network and the ES’s SDR to start IQ data acquisition. Therefore, the ES can obtain the relevant IQ data when the EDs transmit their signals after being triggered. The carefully chosen timer values, along with zero-padded IQ data to adjust the position of the actual IQ data, and the dual use of a trigger enable us to maintain time synchronization in the network and timely IQ data acquisition, where we leverage them for both UL multiple-access and signal superposition. For instance, the EDs’ sounding for measuring impairments and test waveforms (i.e., a triangle function for visual inspection) are received back-toback based on time-domain multiple access (TDMA), and the OAC signals are superposed with this strategy, as can be seen from the user interface.

For phase synchronization, we adopt the PCP strategy (https://arxiv.org/abs/2506.22252). The PCP is a low-complexity analog feedback method that corrects the total UL and downlink (DL) phase mismatch and does not rely on channel reciprocity. In our implementation, we treat the trigger waveform as a preamble and use the aforementioned cross-correlator to estimate the phase rotation in the channel. Whenever the configured trigger waveform is detected, the FPGA registers the correlation output as the channel estimate (i.e., narrowband assumption) and calculates its angle. During the countdowns, the FPGA then rotates the IQ data on the transmitter path by the estimated angle (or its negated value, if configured) to provide feedback or correct the total phase mismatch during aggregation. Since the PCP strategy is implemented in the FPGA and independent of the transmitted IQ data, it is resilient to changes in the propagation environment while retaining the flexibility of SDR.


# Signaling
The EDs and ES communicate with each other using a custom orthogonal frequency-division multiplexing (OFDM)- based physical-layer protocol data unit (PPDU) at 920 MHz in both UL and DL. The PPDU has 192 active subcarriers, uses an inverse discrete Fourier transform (IDFT) size of 256 and a cyclic prefix (CP) length of 64, and is based on BPSK and a 1/2-rate polar code. We refer the reader to (https://ieeexplore.ieee.org/document/10773829/) for further details on the PPDU structure and modulation/coding parameters. We set the sample rate to 5 Msps for all SDRs.


By using measurements from the testbed, we can now obtain an impairment model for coherent OAC, which can be used for the simulation of any OAC scheme (or things like interference alignment, etc.). The impairment model is shown in the following figure.
![Impairment model](https://github.com/alphansahin/Over-the-Air-Computation/blob/main/Synchronization%20Testbed/resultsImpairment.png?raw=true)

# Pluto Firmwares
The compiled pluto.frm files are also available above for Pluto and Pluto+. I primarily support Pluto, not Pluto+.

# HDL
There are so many things to discuss about the HDL design (maybe over time). However, there are several things to note. I used a polyphase filter implementation for the correlator. It works 4 times faster than the sample rate (because there are 80 DSP48 blocks in Pluto!). I don't go above or below 5 msps for the example Python codes. 10 Msps and 20 Msps are okay; however, I haven't run many tests on them.
