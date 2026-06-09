from libraryUtility import *
import numpy as np
from paramiko import SSHClient
import adi
import iio
import time
from fxpmath import Fxp 
import threading
import numpy as np
from functools import wraps
def synchronized(method):
    @wraps(method)
    def wrapper(self, *args, **kwargs):
        with self._lock:
            return method(self, *args, **kwargs)
    return wrapper

def lock_all_methods(cls):
    for name, value in cls.__dict__.items():
        if callable(value) and not name.startswith("__"):
            setattr(cls, name, synchronized(value))
    return cls



class objSDR():
    def __init__(self, **kwargs):
        self.isSDRavailable = 0
        self.IP = 'N/A'
        self.timeout = 10 * 60 * 1000 # ms, 0 means no timeout
        self.hostKeysPath = 'N/A'
        self.ctx = None
        self.sdr = None
        self.quadrature_tracking_en = 0
        self.rf_dc_offset_tracking_en = 0
        self.bb_dc_offset_tracking_en = 0
        self.isIIOorADI = 1

        overwriteParameters(self, **kwargs)
                
        if self.isSDRavailable == 1:    

            # Create radio
            if self.isIIOorADI ==1:
                self.sdr = adi.ad9364(uri='ip:'+self.IP)
                self.sdr.ctx.set_timeout(self.timeout)
                self.ctx = self.sdr.ctx
            else:
                self.sdr = None
                self.ctx = iio.Context(('ip:'+self.IP))
                self.ctx.set_timeout(self.timeout)
            
        self.parametersSDRcontroller = dict([
            ('ctx', self.ctx),
            ('sdr', self.sdr),
            ('isSDRavailable', self.isSDRavailable),
            ('isIIOorADI', self.isIIOorADI),
            ('IP', '192.168.2.1'), 
            ('hostKeysPath', self.hostKeysPath), 
            ('quadrature_tracking_en', self.quadrature_tracking_en), 
            ('rf_dc_offset_tracking_en', self.rf_dc_offset_tracking_en), 
            ('bb_dc_offset_tracking_en', self.bb_dc_offset_tracking_en)
            ])           
        self.parametersSDRtransceiver = dict([
            ('ctx', self.ctx),
            ('sdr', self.sdr),
            ('isSDRavailable', self.isSDRavailable),
            ('isIIOorADI', self.isIIOorADI),
            ('IP', '192.168.2.1'), 
            ('timeout', self.timeout), 
            ])           

        self.transceiver = objSDR_transceiver(**self.parametersSDRtransceiver)
        self.controller = objSDR_controller(**self.parametersSDRcontroller)


@lock_all_methods    
class objSDR_transceiver():
    def __init__(self, **kwargs):
        self._lock = threading.RLock()
        self.isSDRavailable = 0
        self.IP = 'N/A'
        self.timeout = 10 * 60 * 1000 # ms, 0 means no timeout
        self.ctx = None
        self.sdr = None
        self.isIIOorADI = 0
        
        overwriteParameters(self, **kwargs)     
        
        # SDR definitions
        if self.isSDRavailable == 1:
            if self.isIIOorADI ==1:
                self.rxadc = self.sdr.ctx.find_device("cf-ad9361-lpc")
                self.rxadc.set_kernel_buffers_count(1) # don't use set_kernel_buffers_count=1, use set_kernel_buffers_count(1), https://ez.analog.com/linux-software-drivers/f/q-a/117300/how-to-set-number-of-buffers-in-iio-py
                self.txdac = self.sdr.ctx.find_device("cf-ad9361-dds-core-lpc")     
                self.txdac.set_kernel_buffers_count(1) 
            else:
                self.rxadc = self.ctx.find_device("cf-ad9361-lpc")
                self.rxadc.find_channel("voltage0").enabled = True
                self.rxadc.find_channel("voltage1").enabled = True
                self.rxadc.set_kernel_buffers_count(1) # don't use set_kernel_buffers_count=1, use set_kernel_buffers_count(1), https://ez.analog.com/linux-software-drivers/f/q-a/117300/how-to-set-number-of-buffers-in-iio-py

                self.txdac = self.ctx.find_device("cf-ad9361-dds-core-lpc")
                self.txdac.find_channel("voltage0",True).enabled = True
                self.txdac.find_channel("voltage1",True).enabled = True
                self.txdac.find_channel('TX1_I_F1',True).attrs['raw'].value = str(0)        # Force DAC to use DMA not DDS
                self.txdac.find_channel('TX1_Q_F1',True).attrs['raw'].value = str(0)        # Force DAC to use DMA not DDS
                self.txdac.find_channel('TX1_I_F2',True).attrs['raw'].value = str(0)        # Force DAC to use DMA not DDS
                self.txdac.find_channel('TX1_Q_F2',True).attrs['raw'].value = str(0)        # Force DAC to use DMA not DDS
                self.txdac.set_kernel_buffers_count(1) # don't use set_kernel_buffers_count=1, use set_kernel_buffers_count(1), https://ez.analog.com/linux-software-drivers/f/q-a/117300/how-to-set-number-of-buffers-in-iio-py
            
    def receiveIQdata(self, numberOfSamplesAcquire):  # DMA limitations "Software must program the X_LENGTH register to be multiple of the widest data bus." https://wiki.analog.com/resources/fpga/docs/axi_dmac#limitations
        if self.isSDRavailable == 1:
            # WARNING: The number of samples to acquire should not be larger than the maximum number of samples that can be acquired based on the configuration (self.numberOfSamplesToAcquire) unless FIFO is flushed.
            #          The RX FIFO size in the SDR is 2^14-1 samples.
            try:
                if self.isIIOorADI == 1:
                    self.sdr.rx_destroy_buffer()
                    self.sdr.rx_buffer_size = int(numberOfSamplesAcquire)
                    iqRX = self.sdr.rx()
                    no_bits = 12
                    iqRX = 2**-(no_bits-1)*iqRX.astype(np.complex128)
                    IQdataRX = iqRX.view(np.complex128)
                    return IQdataRX
                else:
                    rxbuf = iio.Buffer(self.rxadc, numberOfSamplesAcquire, False)
                    rxbuf.set_blocking_mode(False)
                    rxbuf.refill()
                    iqRXbuf = rxbuf.read()
                    

                    iqRX = np.frombuffer(iqRXbuf,dtype=np.int16)
                    no_bits = 12
                    iqRX = 2**-(no_bits-1)*iqRX.astype(np.float64)
                    IQdataRX = iqRX.view(np.complex128)
                    rxbuf.cancel()
                    return IQdataRX
            except OSError as e:
                print(f"IIO connection timed out. It will be initiated again") # timeouts are good because it closes the connections.
                return np.zeros(2, dtype=complex ) 
        else:
            return np.zeros(2, dtype=complex)
    def transmitIQdata(self, IQdataTX, bufferSize=None): # DMA limitations "Software must program the X_LENGTH register to be multiple of the widest data bus." https://wiki.analog.com/resources/fpga/docs/axi_dmac#limitations
        if self.isSDRavailable == 1:
            try:
                if self.isIIOorADI == 1:
                    self.sdr.tx_destroy_buffer()
                    self.sdr.tx((IQdataTX*(2**15-1)).astype(np.complex128))
                else:
                    inphase = (IQdataTX.real*(2**15-1))
                    inphase = inphase.astype('int16')
                    quadrature = (IQdataTX.imag*(2**15-1))
                    quadrature = quadrature.astype('int16')

                    iqTXbuf = np.empty((inphase.size + quadrature.size,), dtype=np.int16)
                    iqTXbuf[0::2] = inphase
                    iqTXbuf[1::2] = quadrature

                    NtxbufferSize = len(inphase)
                    txbuf = iio.Buffer(self.txdac, NtxbufferSize, False)
                    txbuf.set_blocking_mode(True)

                    txbuf.write(bytearray(iqTXbuf)) 
                    txbuf.push()
                    txbuf.cancel()
            except OSError as e:
                print(f"IIO connection timed out: {e}")

@lock_all_methods
class objSDR_controller():
    def __init__(self, **kwargs):
        self._lock = threading.RLock()
        self.isSDRavailable = 0
        self.IP = 'N/A'
        self.hostKeysPath = 'N/A'
        self.ctx = None
        self.sdr = None        
        self.quadrature_tracking_en = 0
        self.rf_dc_offset_tracking_en = 0
        self.bb_dc_offset_tracking_en = 0
        self.numberOfSamplesToReceiveAfterTrigger = 0
        self.numberOfSamplesToTransmitAfterTrigger = 0
        self.isIIOorADI = 0

        overwriteParameters(self, **kwargs)   
        
        # SDR definitions
        if self.isSDRavailable == 1:
            if self.isIIOorADI == 1:
                self.ctrl = self.sdr.ctx.find_device("ad9361-phy")
            else:
                self.ctrl = self.ctx.find_device("ad9361-phy")
                
            self.ctrl.attrs['calib_mode'].value = 'manual'
            self.rxLO = self.ctrl.find_channel("altvoltage0", True)
            self.txLO = self.ctrl.find_channel("altvoltage1", True)
            self.rx = self.ctrl.find_channel("voltage0")
            self.tx = self.ctrl.find_channel("voltage0",True)
            self.rx.attrs["quadrature_tracking_en"].value = str(self.quadrature_tracking_en)
            self.rx.attrs["rf_dc_offset_tracking_en"].value = str(self.rf_dc_offset_tracking_en)
            self.rx.attrs["bb_dc_offset_tracking_en"].value = str(self.bb_dc_offset_tracking_en )
            
            self.addrBase = 0x43c00000
            
            lengthAdd = 31
            startAdd = 0
            integer_array = self.addrBase +(np.arange(lengthAdd)+startAdd)*4
            self.addrWrite = [hex(i) for i in integer_array]
            
            lengthAdd = 1
            startAdd = 31
            integer_array = self.addrBase +(np.arange(lengthAdd)+startAdd)*4
            self.addrToggle = [hex(i) for i in integer_array]        
            
            lengthAdd = 32
            startAdd = 32
            integer_array = self.addrBase +(np.arange(lengthAdd)+startAdd)*4
            self.addrRead = [hex(i) for i in integer_array]

            self.username = 'root'
            self.password = 'analog'

            self.client = SSHClient()
            time.sleep(0.25)
            self.client.load_host_keys(self.hostKeysPath)
            time.sleep(0.25)
            self.client.connect(self.IP, username=self.username, password=self.password)
            time.sleep(0.25)


    def sendCMDtoIP(self, cmd):
        if self.isSDRavailable == 1:
            ssh_stdin, ssh_stdout, ssh_stderr = self.client.exec_command(cmd)
            while not ssh_stdout.channel.exit_status_ready():
                time.sleep(0.01)        
            output = []
            for each_line in ssh_stdout:
                output.append(each_line.strip('\n'))
            return output
        else:
            return 'None'

    def getSDRIPStatus(self):
        if self.isSDRavailable == 1:
            cmd = ""
            for addr in self.addrRead:
                cmd = cmd + "devmem " + addr + "; " 
            output = self.sendCMDtoIP(cmd)

            # reg 0 
            flags = Fxp(output[0], True, 32, 0)
            flags_bin = flags.bin()
            start = 0   # 0 included
            length = 16 # larger than 1
            size = 32   # bit string size
            flagsSliced = flags_bin[(size-start-length):(size-start):]
            cntDetection = int(flagsSliced,2)
            
            
            flags_bin = flags.bin()
            start = 16   # 0 included
            length = 8 # larger than 1
            size = 32   # bit string size
            flagsSliced = flags_bin[(size-start-length):(size-start):]
            status_sSel_isTX_enTX_enRX = flagsSliced      
            
            print('> # of detections                                           : ' + str(cntDetection) + ' (R0:' + output[0] + ')')
            print('> addBias, isConj, enCorr, enEst, seqSel, isTX, enTX, enRX  : ' + str(status_sSel_isTX_enTX_enRX) + ' (R0:' + output[0] + ')')

            # reg 1 
            print('> FIFO cnt                                                  : ' + str(int(output[1], 0)) + ' (R1:' + output[1] + ')')
            
            # reg 2 
            print('> I and Q samples                                           : ' + str(int(output[2], 0)) + ' (R2:' + output[2] + ')')
            
            # reg 3 
            flags = Fxp(output[3], True, 32, 0)
            flags_bin = flags.bin()
            start = 0   # 0 included
            length = 4 # larger than 1
            size = 32   # bit string size
            flagsSliced = flags_bin[(size-start-length):(size-start):]
            status_adc_qEn_qVal_iEn_iVal = flagsSliced            
            
            print('> axi9361_adc_qEnable_qValid_iEnable_iValid                 : ' + str(status_adc_qEn_qVal_iEn_iVal) + ' (R3:' + output[3] + ')')
            
            # reg 4
            print('> # of phaEst operations                                    : ' + str(int(output[4], 0)) + ' (R4:' + output[4] + ')')
            
            # reg 5
            print('> FIR coef real at addr                                     : ' + str(int(output[5], 0)) + ' (R5:' + output[5] + ')')
            
            # reg 6 
            print('> FIR coef imag at addr                                     : ' + str(int(output[6], 0)) + ' (R6:' + output[6] + ')')

            # reg 7
            val_fir = Fxp(None, signed=True, n_word=27, n_frac=0, overflow='wrap')
            val_32 = Fxp(output[7], True, 32, 0)
            val_fir.set_val(val_32.get_val())
            print('> Detector   (FIR real in)                                  : ' + str(val_fir) + ' (R8:' + output[7] + ')')
            
            # reg 8
            val_fir = Fxp(None, signed=True, n_word=27, n_frac=0, overflow='wrap')
            val_32 = Fxp(output[8], True, 32, 0)
            val_fir.set_val(val_32.get_val())
            print('> Detector   (FIR imag in)                                  : ' + str(val_fir) + ' (R9:' + output[8] + ')')
            
            # reg 9
            val_fir = Fxp(None, signed=True, n_word=27, n_frac=0, overflow='wrap')
            val_32 = Fxp(output[9], True, 32, 0)
            val_fir.set_val(val_32.get_val())         
            print('> Detector   (FIR real reg)                                 : ' + str(val_fir) + ' (R10:' + output[9] + ')')
            
            # reg 10
            val_fir = Fxp(None, signed=True, n_word=27, n_frac=0, overflow='wrap')
            val_32 = Fxp(output[10], True, 32, 0)
            val_fir.set_val(val_32.get_val())           
            print('> Detector   (FIR imag reg)                                 : ' + str(val_fir) + ' (R11:' + output[10] + ')')
            
            # reg 11
            print('> Detector   (Norm square reg)                              : ' + str(int(output[11], 0)) + ' (R12:' + output[11] + ')')
            
            # reg 12 & 13

            flags = Fxp(output[13] + output[12], False, 64, 0)
            print('> Detector   (Xcorr square reg divided)                     : ' + str(flags.val) + ' (R13:' + output[13] + ', R12:' + output[12] + ')')
            
            # reg 14
            flags = Fxp(output[14], True, 32, 0)
            flags_bin = flags.bin()
            start = 0   # 0 included
            length = 16 # larger than 1
            size = 32   # bit string size
            flagsSliced = flags_bin[(size-start-length):(size-start):]
            cndDetector = int(flagsSliced,2) 
            
            flags = Fxp(output[14], True, 32, 0)
            flags_bin = flags.bin()
            start = 16   # 0 included
            length = 1 # larger than 1
            size = 32   # bit string size
            flagsSliced = flags_bin[(size-start-length):(size-start):]
            stateDetector = flagsSliced   
            print('> Detector   (cnt detector)                                 : ' + str(cndDetector) + ' (R14:' + output[14] + ')')
            print('> Detector   (state)                                        : ' + str(stateDetector) + ' (R14:' + output[14] + ')')
            
            
            # reg 15
            flags = Fxp(output[15], True, 32, 0)
            flags_bin = flags.bin()
            start = 0   # 0 included
            length = 32 # larger than 1
            size = 32   # bit string size
            flagsSliced = flags_bin[(size-start-length):(size-start):]
            status_FIRrealOut = int(flagsSliced,2)
            print('> Detector   (slow counter)                                 : ' + str(status_FIRrealOut) + ' (R15:' + output[15] + ')')        
            
            # reg 16
            flags = Fxp(output[16], True, 32, 0)
            flags_bin = flags.bin()
            start = 0   # 0 included
            length = 32 # larger than 1
            size = 32   # bit string size
            flagsSliced = flags_bin[(size-start-length):(size-start):]
            status_FIRrealOut = int(flagsSliced,2)
            print('> Detector   (fast counter)                                 : ' + str(status_FIRrealOut) + ' (R16:' + output[16] + ')')        
            print("---")    
            
            # reg 17
            print('> Detector   (Norm square in)                               : ' + str(int(output[17], 0)) + ' (R17:' + output[17] + ')')
            
    def getDetectionCount(self):
        if self.isSDRavailable == 1:
            cmd = ""
            for addr in self.addrRead:
                cmd = cmd + "devmem " + self.addrRead[0] + "; " + "devmem " + self.addrRead[4] + "; " + "devmem " + self.addrRead[14] + "; " 
            output = self.sendCMDtoIP(cmd)

            # reg 0 
            flags = Fxp(output[0], True, 32, 0)
            flags_bin = flags.bin()
            start = 0   # 0 included
            length = 16 # larger than 1
            size = 32   # bit string size
            flagsSliced = flags_bin[(size-start-length):(size-start):]
            cntDetection = int(flagsSliced,2)
            print('> # of detections (for timers)       : ' + str(cntDetection) + ' (R0:' + output[0] + ')')
            
            # reg 14
            flags = Fxp(output[1], True, 32, 0)
            flags_bin = flags.bin()
            start = 0   # 0 included
            length = 32 # larger than 1
            size = 32   # bit string size
            flagsSliced = flags_bin[(size-start-length):(size-start):]
            cndDetector = int(flagsSliced,2) 
            print('> # of phase estimation operation    : ' + str(cndDetector) + ' (R4:' + output[1] + ')')     
            
            # reg 14
            flags = Fxp(output[2], True, 32, 0)
            flags_bin = flags.bin()
            start = 0   # 0 included
            length = 16 # larger than 1
            size = 32   # bit string size
            flagsSliced = flags_bin[(size-start-length):(size-start):]
            cndDetector = int(flagsSliced,2) 
            print('> # of detections (at the detector)  : ' + str(cndDetector) + ' (R14:' + output[14] + ')')        
        
    def setSDRIPCounters(self, S0Counter, S1Counter, S2Counter, S3Counter):
        self.S0Counter = S0Counter
        self.S1Counter = S1Counter
        self.S2Counter = S2Counter
        self.S3Counter = S3Counter
        
        if self.isSDRavailable == 1:
            S0CounterHex = hex(S0Counter)
            S1CounterHex = hex(S1Counter)
            S2CounterHex = hex(S2Counter)
            S3CounterHex = hex(S3Counter)
            cmd = (
                "devmem " + self.addrWrite[0] + " w "+ str(S0CounterHex)+"; "+
                "devmem " + self.addrWrite[1] + " w "+ str(S1CounterHex)+"; "+
                "devmem " + self.addrWrite[2] + " w "+ str(S2CounterHex)+"; "+
                "devmem " + self.addrWrite[3] + " w "+ str(S3CounterHex)
                )
            output = self.sendCMDtoIP(cmd)        
            
            cmd = (
                "devmem " + self.addrWrite[0] + "; "+ 
                "devmem " + self.addrWrite[1] + "; "+
                "devmem " + self.addrWrite[2] + "; "+
                "devmem " + self.addrWrite[3] + "; "
                )            
            output = self.sendCMDtoIP(cmd)
                    
            print('> S0 Counter: ' + str(Fxp(output[0], True, 32, 0)) + ' samples (W0:' + output[0] + ')')
            print('> S1 Counter: ' + str(Fxp(output[1], True, 32, 0)) + ' samples (W1:' + output[1] + ')')
            print('> S2 Counter: ' + str(Fxp(output[2], True, 32, 0)) + ' samples (W2:' + output[2] + ')')
            print('> S3 Counter: ' + str(Fxp(output[3], True, 32, 0)) + ' samples (W3:' + output[3] + ')')

    def setSDRIPconfiguration(self, modeInput):
        if self.isSDRavailable == 1:
            self.mode = modeInput
                
            if modeInput == 0:      # Always on,            # A typical SDR
                isTXpathConf    = np.array([0, 0, 0, 0, 0])
                enableRXConf    = np.array([1, 1, 1, 1, 1])
                enableTXConf    = np.array([1, 1, 1, 1, 1])
                sequenceSelConf = np.array([0, 0, 0, 0, 0])
                enablePhCorConf = np.array([0, 0, 0, 0, 0])
                enablePhEstConf = np.array([0, 0, 0, 0, 0])
                isConjugateConf = np.array([0, 0, 0, 0, 0])
                addPhaseBiasConf= np.array([0, 0, 0, 0, 0])   
                
            # ES modes
            elif modeInput == 1:    # Correlator listens TX, TX: Always enabled, RX: don't receive
                                    # A typical edge server behaviour to broadcast data or preamble for calibration purposes
                isTXpathConf    = np.array([1, 1, 1, 1, 1])
                enableRXConf    = np.array([0, 0, 0, 0, 0])
                enableTXConf    = np.array([1, 1, 1, 1, 1])
                sequenceSelConf = np.array([0, 0, 0, 0, 0])  
                isConjugateConf = np.array([0, 0, 0, 0, 0])
                enablePhCorConf = np.array([0, 0, 0, 0, 0])
                enablePhEstConf = np.array([0, 0, 0, 0, 0])
                addPhaseBiasConf= np.array([0, 0, 0, 0, 0])
            elif modeInput == 2:    # Correlator listens TX, TX: Always enabled, RX: Receive after transmit
                                    # A typical edge server behaviour to broadcast for CMD purposes and receive responses
                isTXpathConf    = np.array([1, 1, 1, 1, 1])
                enableRXConf    = np.array([0, 1, 1, 1, 1]) # during RX all enabled after syn TX - but (2nd 3rd bits are important 0, 1, 1, 1, 1)
                enableTXConf    = np.array([1, 1, 1, 1, 1])
                sequenceSelConf = np.array([0, 0, 0, 0, 0])       
                isConjugateConf = np.array([0, 0, 0, 0, 0])
                enablePhCorConf = np.array([0, 0, 0, 0, 0])
                enablePhEstConf = np.array([0, 0, 0, 0, 0])
                addPhaseBiasConf= np.array([0, 0, 0, 0, 0])   
            elif modeInput == 3:    # Correlator listens TX, Phase correction
                isTXpathConf    = np.array([1, 0, 0, 0, 1]) # during S1,S2,S3: RX path
                enableRXConf    = np.array([0, 1, 1, 1, 1]) # during RX all enabled after TX - but (2nd 3rd bits are important 0, 1, 1, 1, 1)
                enableTXConf    = np.array([1, 1, 1, 1, 1])
                sequenceSelConf = np.array([0, 1, 1, 1, 0]) # during RX, all EDs will use ES call sign 
                isConjugateConf = np.array([0, 1, 1, 1, 0])
                enablePhCorConf = np.array([0, 1, 1, 1, 0])
                enablePhEstConf = np.array([0, 1, 1, 1, 0])
                addPhaseBiasConf= np.array([0, 0, 0, 0, 0]) 
            elif modeInput == 4:    # Correlator listens TX, Phase correction with phase bias
                isTXpathConf    = np.array([1, 0, 0, 0, 1]) # during S1,S2,S3: RX path
                enableRXConf    = np.array([0, 1, 1, 1, 1]) # during RX all enabled after TX - but 
                enableTXConf    = np.array([1, 1, 1, 1, 1])
                sequenceSelConf = np.array([0, 1, 1, 1, 0]) # during RX, all EDs will use ES call sign 
                isConjugateConf = np.array([0, 1, 1, 1, 0])
                enablePhCorConf = np.array([0, 1, 1, 1, 0])
                enablePhEstConf = np.array([0, 1, 1, 1, 0])
                addPhaseBiasConf= np.array([0, 1, 1, 1, 0]) 
                    
            # ED modes
            elif modeInput == 11:   # Correlator listens RX, RX: Fill FIFO, TX: don't transmit
                                    # A typical edge device behaviour to receive CMD for control loops but not respond
                isTXpathConf    = np.array([0, 0, 0, 0, 0])
                enableRXConf    = np.array([0, 1, 1, 1, 1])
                enableTXConf    = np.array([0, 0, 0, 0, 0])
                sequenceSelConf = np.array([0, 0, 0, 0, 0])  
                isConjugateConf = np.array([0, 0, 0, 0, 0])
                enablePhCorConf = np.array([0, 0, 0, 0, 0])
                enablePhEstConf = np.array([0, 0, 0, 0, 0])
                addPhaseBiasConf= np.array([0, 0, 0, 0, 0])   
            # respond the command
            elif modeInput == 12:   # Correlator listens RX, RX: Fill FIFO, TX: don't transmit
                                    # A typical edge device behaviour to receive CMD for control loops with response
                isTXpathConf     = np.array([0, 0, 0, 0, 0])
                enableRXConf     = np.array([0, 0, 0, 0, 0])
                enableTXConf     = np.array([0, 1, 1, 1, 1])
                sequenceSelConf  = np.array([0, 0, 0, 0, 0])  
                isConjugateConf  = np.array([0, 0, 0, 0, 0])
                enablePhCorConf  = np.array([0, 0, 0, 0, 0])
                enablePhEstConf  = np.array([0, 0, 0, 0, 0])
                addPhaseBiasConf = np.array([0, 0, 0, 0, 0])   
            elif modeInput == 13:    # Correlator listens RX, phase-wait-transmit for aggregation
                isTXpathConf      = np.array([0, 1, 0, 1, 1])
                enableRXConf      = np.array([0, 0, 0, 0, 0])
                enableTXConf      = np.array([0, 1, 1, 1, 1])
                sequenceSelConf   = np.array([0, 0, 0, 0, 0])
                isConjugateConf   = np.array([0, 0, 0, 0, 0])
                enablePhCorConf   = np.array([0, 1, 1, 1, 1])
                enablePhEstConf   = np.array([1, 0, 1, 1, 0])
                addPhaseBiasConf  = np.array([0, 0, 0, 0, 0])
    


            numberOfTimers = 4
            enableRXconfInt = np.dot(enableRXConf,2**np.arange(enableRXConf.size))
            enableTXConfInt = np.dot(enableTXConf,2**np.arange(enableTXConf.size))
            isTXpathConfInt = np.dot(isTXpathConf,2**np.arange(isTXpathConf.size))
            sequenceSelConfInt = np.dot(sequenceSelConf,2**np.arange(sequenceSelConf.size))
            
            SDRIPConfHex1 = hex(np.dot(2**((numberOfTimers+1)*np.arange(4)), np.array([enableRXconfInt, enableTXConfInt, isTXpathConfInt, sequenceSelConfInt])))
            
            enablePhEstConfInt = np.dot(enablePhEstConf,2**np.arange(enablePhEstConf.size))
            enablePhCorConfInt = np.dot(enablePhCorConf,2**np.arange(enablePhCorConf.size))
            isConjugateConfInt = np.dot(isConjugateConf,2**np.arange(isConjugateConf.size))
            addPhaseBiasConfInt = np.dot(addPhaseBiasConf,2**np.arange(addPhaseBiasConf.size))
    
            SDRIPConfHex2 = hex(np.dot(2**((numberOfTimers+1)*np.arange(4)), np.array([enablePhEstConfInt, enablePhCorConfInt, isConjugateConfInt, addPhaseBiasConfInt])))

            cmd = (
                "devmem " + self.addrWrite[4] + " w "+ str(SDRIPConfHex1)+";" + 
                "devmem " + self.addrWrite[5] + " w "+ str(SDRIPConfHex2)+";"
                )
            output = self.sendCMDtoIP(cmd)    

            self.numberOfSamplesToReceiveAfterTrigger =  self.S0Counter*enableRXConf[1] + self.S1Counter*enableRXConf[2] + self.S2Counter*enableRXConf[3] + self.S3Counter*enableRXConf[4]
            self.numberOfSamplesToTransmitAfterTrigger =  self.S0Counter*enableTXConf[1] + self.S1Counter*enableTXConf[2] + self.S2Counter*enableTXConf[3] + self.S3Counter*enableTXConf[4]         
                
            if False:
                cmd = (
                    "devmem " + self.addrWrite[4] + "; " +
                    "devmem " + self.addrWrite[5] + ";"
                    )            
                output = self.sendCMDtoIP(cmd)    
                    
                print('> Conf 1: ' + str(Fxp(output[0], True, 32, 0)) + ' (W4:' + output[0] + ')')
                print('> Conf 2: ' + str(Fxp(output[1], True, 32, 0)) + ' (W5:' + output[1] + ')')
    
    def setSequenceFilter(self, FIRcoef0RealHex, FIRcoef0ImagHex, FIRcoef1RealHex, FIRcoef1ImagHex):
        if self.isSDRavailable == 1:
            numberOfCoefs = len(FIRcoef0RealHex)

            print('> Uploading the FIR coefficients for Waveform 0...') 
            # for indCoef in range(numberOfCoefs):
            #     addrHex = hex(indCoef)
            #     realDataHex = FIRcoef0RealHex[indCoef]
            #     imagDataHex = FIRcoef0ImagHex[indCoef]
            #     cmd = (
            #         "devmem " + self.addrWrite[8] + " w "+ str(addrHex)+"; " 
            #         "devmem " + self.addrWrite[9] + " w "+ str(realDataHex)+"; " 
            #         "devmem " + self.addrWrite[10] + " w "+ str(imagDataHex)+"; " 
            #         )  
            #     output = self.sendCMDtoIP(cmd)                                  # set the address and data to write
            #     cmd = "devmem " + self.addrToggle[0] + " w "+ str(hex(1))+";"   # toggle the write register to write the data 
            #     output = self.sendCMDtoIP(cmd)      
            
            cmd = ""  
            for indCoef in range(numberOfCoefs):
                addrHex = hex(indCoef)
                realDataHex = FIRcoef0RealHex[indCoef]
                imagDataHex = FIRcoef0ImagHex[indCoef]
                cmd = cmd + (
                    "devmem " + self.addrWrite[8] + " w "+ str(addrHex)+"; " 
                    "devmem " + self.addrWrite[9] + " w "+ str(realDataHex)+"; " 
                    "devmem " + self.addrWrite[10] + " w "+ str(imagDataHex)+"; " 
                    "sleep 0.001; " +
                    "devmem " + self.addrToggle[0] + " w "+ str(hex(1))+";"   # toggle the write register to write the data 
                    "sleep 0.001; "
                    )  
            output = self.sendCMDtoIP(cmd)    
                                
            print('> Done. The coefficients are set')              
        
            print('> Uploading the FIR coefficients for Waveform 1...') 
            # for indCoef in range(numberOfCoefs):
            #     addrHex = hex(indCoef+numberOfCoefs)
            #     realDataHex = FIRcoef1RealHex[indCoef]
            #     imagDataHex = FIRcoef1ImagHex[indCoef]
            #     cmd = (
            #         "devmem " + self.addrWrite[8] + " w "+ str(addrHex)+"; " 
            #         "devmem " + self.addrWrite[9] + " w "+ str(realDataHex)+"; " 
            #         "devmem " + self.addrWrite[10] + " w "+ str(imagDataHex)+"; " 
            #         )  
            #     output = self.sendCMDtoIP(cmd)                                  # set the address and data to write
            #     cmd = "devmem " + self.addrToggle[0] + " w "+ str(hex(1))+";"   # toggle the write register to write the data 
            #     output = self.sendCMDtoIP(cmd)      
            
            cmd = ""
            for indCoef in range(numberOfCoefs):
                addrHex = hex(indCoef+numberOfCoefs)
                realDataHex = FIRcoef1RealHex[indCoef]
                imagDataHex = FIRcoef1ImagHex[indCoef]
                cmd = cmd +  (
                    "devmem " + self.addrWrite[8] + " w "+ str(addrHex)+"; " 
                    "devmem " + self.addrWrite[9] + " w "+ str(realDataHex)+"; " 
                    "devmem " + self.addrWrite[10] + " w "+ str(imagDataHex)+"; " 
                    "sleep 0.001; " +
                    "devmem " + self.addrToggle[0] + " w "+ str(hex(1))+";"   # toggle the write register to write the data 
                    "sleep 0.001; "
                    )  
            output = self.sendCMDtoIP(cmd)            
                        
            print('> Done. The coefficients are set')            
            FIRcoef0RealHexRead, FIRcoef0ImagHexRead, FIRcoef1RealHexRead, FIRcoef1ImagHexRead = self.getSequenceFilter(printInfo=False)
            
    def getSequenceFilter(self, numberOfCoefs=64,numberOfBits=8, printInfo=True, howManyCoefsToPrint=4):
        if self.isSDRavailable == 1:
            cmd = ""
            for indCoef in range(numberOfCoefs):
                cmd = cmd + (
                    "devmem " + self.addrWrite[8] + " w " + str(hex(indCoef))+"; " 
                    "sleep 0.001; " +
                    "devmem " + self.addrRead[5] + "; " 
                    "devmem " + self.addrRead[6] + "; "
                    ) 
            output = self.sendCMDtoIP(cmd) 
            
            output_int = [(int(s,16)) for s in output]
            
            if printInfo:
                print('> Only ' + str(howManyCoefsToPrint) + ' coefficients out of ' + str(numberOfCoefs) + ' will be shown.')
            
            outputFXP = Fxp(output_int, signed=False, n_word=numberOfBits, n_frac=0)
            FIRcoef0RealHex = []    
            FIRcoef0ImagHex = []    
            for indCoef in range(numberOfCoefs):
                FIRcoef0RealHex.append(outputFXP[2*indCoef].hex())
                FIRcoef0ImagHex.append(outputFXP[2*indCoef+1].hex())
                if printInfo:
                    if indCoef<howManyCoefsToPrint:
                        print('> Waveform 0 - FIR coefficient ' + str(indCoef) + ': Real: ' +  FIRcoef0RealHex[indCoef] + ', Imag: '  + FIRcoef0ImagHex[indCoef] )                    
    
            cmd = ""
            for indCoef in range(numberOfCoefs):
                cmd = cmd + (
                    "devmem " + self.addrWrite[8] + " w " + str(hex(indCoef+numberOfCoefs))+"; " +
                    "sleep 0.001; " +
                    "devmem " + self.addrRead[5] + "; " +
                    "devmem " + self.addrRead[6] + "; ") 
            output = self.sendCMDtoIP(cmd)   
            
            output_int = [int(s,16) for s in output]
            outputFXP = Fxp(output_int, signed=False, n_word=numberOfBits, n_frac=0)
            FIRcoef1RealHex = []    
            FIRcoef1ImagHex = []
            for indCoef in range(numberOfCoefs):
                FIRcoef1RealHex.append(outputFXP[2*indCoef].hex())
                FIRcoef1ImagHex.append(outputFXP[2*indCoef+1].hex())
                if printInfo:
                    if indCoef<howManyCoefsToPrint:
                        print('> Waveform 1 - FIR coefficient ' + str(indCoef) + ': Real:  ' + FIRcoef1RealHex[indCoef] + ', Imag: ' + FIRcoef1ImagHex[indCoef])                
            return FIRcoef0RealHex, FIRcoef0ImagHex, FIRcoef1RealHex, FIRcoef1ImagHex
        else:
            return 'None', 'None', 'None', 'None'
        
    def getRXFIFOcnt(self):
        if self.isSDRavailable == 1:
            cmd = (
                "devmem " + self.addrRead[1] + "; "
                )
            output = self.sendCMDtoIP(cmd)  
            fifoCnt = int(output[0], 0)
            return fifoCnt
        else:
            return 'None'

    def setPhaseScaling(self, ampDesired):
        if self.isSDRavailable == 1:
            ampDesiredHex = hex(ampDesired & 0xffffffff)
            
            cmd ="devmem " + self.addrWrite[6] + " w "+ str(ampDesiredHex)+"; "
            output = self.sendCMDtoIP(cmd)          
            
            cmd ="devmem " + self.addrWrite[6] + "; "
            output = self.sendCMDtoIP(cmd)         
            print('> ampDesired: ' + str(Fxp(output[0], True, 32, 0)) + ' (' + output[0] + ')')  

    def upgradeSDR(self):
        if self.isSDRavailable == 1:        
            cmd = (
                "fw_setenv attr_name compatible; "+
                "fw_setenv attr_val ad9364; "+                     
                "device_reboot reset"
                )
            output = self.sendCMDtoIP(cmd)  

    def rebootSDR(self):
        if self.isSDRavailable == 1:        
            cmd = (
                "reboot"
                )
            output = self.sendCMDtoIP(cmd)              
      
    def waitRXFIFO(self, numberOfSamplesAcquire):
        
        if self.isSDRavailable == 1:    
            fifoCnt = self.getRXFIFOcnt()
            while fifoCnt < numberOfSamplesAcquire:
                fifoCnt = self.getRXFIFOcnt()                    
                
    def getAXI9361Settings(self):
        if self.isSDRavailable == 1:        
            cmd = (
                "devmem 0x79020000; "+ 
                "devmem 0x79020004; "+
                "devmem 0x79020008; "+
                "devmem 0x7902000C; "+
                "devmem 0x7902001C; "
                )
            output = self.sendCMDtoIP(cmd)    
        
            print('> (' + output[0] + ')')
            print('> (' + output[1] + ')')
            print('> (' + output[2] + ')')
            print('> (' + output[3] + ')')
            print('> (' + output[4] + ')')

    def setTXRXcarrierFrequency(self,TXRXLO):
        if self.isSDRavailable == 1:        
            self.rxLO.attrs["frequency"].value = str(int(TXRXLO))
            self.txLO.attrs["frequency"].value = str(int(TXRXLO))

            if False:
                print("--- SET TX/RX Fc (", str(self.IP), "): ---")
                print("RX LO: ", self.rxLO.attrs["frequency"].value)
                print("TX LO: ", self.txLO.attrs["frequency"].value)
                print("---")

    def getTXRXcarrierFrequency(self):
        fcRX = self.rxLO.attrs["frequency"].value
        fcTX = self.txLO.attrs["frequency"].value
        return int(fcRX), int(fcTX)
    
    def setRXcarrierFrequency(self,RXLO):
        if self.isSDRavailable == 1:
            self.rxLO.attrs["frequency"].value = str(int(RXLO))

            if False:
                print("--- SET RX Fc (", str(self.IP), "): ---")
                print("RX LO: ", self.rxLO.attrs["frequency"].value)
                print("---")            

    def setTXcarrierFrequency(self,TXLO):
        if self.isSDRavailable == 1:        
            self.txLO.attrs["frequency"].value = str(int(TXLO))

            if False:
                print("--- SET TX Fc (", str(self.IP), "): ---")
                print("TX LO: ", self.txLO.attrs["frequency"].value)
                print("---")            

    def setTXattn(self,TXATTN):
        if self.isSDRavailable == 1:        
            self.tx.attrs['hardwaregain'].value = str(-TXATTN)
            print('> Set TX attenuation to ' + str(TXATTN) + ' dB (R14:' + str(self.tx.attrs['hardwaregain'].value) + ')')

    def getTXattn(self):
        if self.isSDRavailable == 1:        
            TXATTN = self.tx.attrs['hardwaregain'].value
            TXATTN = TXATTN.split()[0] # to remove the "dB" part
            return -float(TXATTN)
        else:
            return None         
            
    def setRXgain(self,RXGAIN):
        if self.isSDRavailable == 1:        
            self.rx.attrs['hardwaregain'].value = str(RXGAIN)
            print('> Set RX gain to ' + str(RXGAIN) + ' dB (R13:' + str(self.rx.attrs['hardwaregain'].value) + ')')
    def getRXgain(self):
        if self.isSDRavailable == 1:        
            RXGAIN = self.rx.attrs['hardwaregain'].value
            RXGAIN = RXGAIN.split()[0] # to remove the "dB" part
            return float(RXGAIN)
        else:
            return None         
            
    def setRXparams(self,RXLO,RXBW,RXFS,RXGAIN,RXGAINMODE):
        if self.isSDRavailable == 1:        
            self.rx.attrs["sampling_frequency"].value = str(int(RXFS))
            self.rx.attrs["rf_bandwidth"].value = str(int(RXBW))
            self.rx.attrs['gain_control_mode'].value = RXGAINMODE
            self.rxLO.attrs["frequency"].value = str(int(RXLO))

            if RXGAINMODE == 'manual': # 'fast_attack', 'slow_attack', 'hybrid'
                self.rx.attrs['hardwaregain'].value = str(RXGAIN)

            if True:
                print("RX LO: ", self.rxLO.attrs["frequency"].value)
                print("RX BW: ", self.rx.attrs["rf_bandwidth"].value)
                print("RX FS: ", self.rx.attrs["sampling_frequency"].value)
                print("RX Gain control: ", self.rx.attrs["gain_control_mode"].value)
                print("RX Gain: ", self.rx.attrs["hardwaregain"].value)
                print("---")
            
    def setTXparams(self,TXLO,TXBW,TXFS,TXATTN):
        if self.isSDRavailable == 1:
            self.tx.attrs["rf_bandwidth"].value = str(int(TXBW))
            self.tx.attrs["sampling_frequency"].value = str(int(TXFS))
            self.tx.attrs['hardwaregain'].value = str(-TXATTN)
            self.txLO.attrs["frequency"].value = str(int(TXLO))
        
            if True:
                print("TX LO: ", self.txLO.attrs["frequency"].value)
                print("TX BW: ", self.tx.attrs["rf_bandwidth"].value)
                print("TX FS: ", self.tx.attrs["sampling_frequency"].value)
                print("TX Gain: ", self.tx.attrs["hardwaregain"].value)
                print("---")

    def setRXCorrections(self, quadrature_tracking_en, rf_dc_offset_tracking_en, bb_dc_offset_tracking_en):
        if self.isSDRavailable == 1: 
            self.quadrature_tracking_en = quadrature_tracking_en
            self.rf_dc_offset_tracking_en = rf_dc_offset_tracking_en
            self.bb_dc_offset_tracking_en = bb_dc_offset_tracking_en
            self.rx.attrs['quadrature_tracking_en'].value = str(quadrature_tracking_en)
            self.rx.attrs['rf_dc_offset_tracking_en'].value = str(rf_dc_offset_tracking_en)
            self.rx.attrs['bb_dc_offset_tracking_en'].value = str(bb_dc_offset_tracking_en)

    def calculateFIRCoefficientsForMatchedFilter(self, waveformCore, numberOfBitsForCoef=8):
        # Calculate the FIR coefficients based on the waveform core
        sequenceComplex = np.conj(np.flip(waveformCore))
        numberOfBitsForRegs = 8
        sequenceComplex = sequenceComplex/np.max(np.abs(sequenceComplex))
        sequenceReal = sequenceComplex.real
        sequenceImag = sequenceComplex.imag    
        sequenceRealInt = np.round(sequenceReal*(2**(numberOfBitsForCoef-1)-1))
        sequenceImagInt = np.round(sequenceImag*(2**(numberOfBitsForCoef-1)-1))

        sequenceRealFi = Fxp(sequenceRealInt, True, numberOfBitsForCoef, 0)
        sequenceRealConcatenatedString = "".join(sequenceRealFi[::-1].bin())
        sequenceRealConcatenatedString_divived = ["".join(chunk) for chunk in zip(*[iter(sequenceRealConcatenatedString)]*numberOfBitsForRegs)]
        sequenceRealHex = [hex(int(sequenceRealConcatenatedString_divived[i], 2)) for i in range(sequenceRealConcatenatedString_divived.__len__())]
        sequenceRealHex = sequenceRealHex[::-1]

        sequenceImagFi = Fxp(sequenceImagInt, True, numberOfBitsForCoef, 0)
        sequenceImagConcatenatedString = "".join(sequenceImagFi[::-1].bin())
        sequenceImagConcatenatedString_divived = ["".join(chunk) for chunk in zip(*[iter(sequenceImagConcatenatedString)]*numberOfBitsForRegs)]
        sequenceImagHex = [hex(int(sequenceImagConcatenatedString_divived[i], 2)) for i in range(sequenceImagConcatenatedString_divived.__len__())]
        sequenceImagHex = sequenceImagHex[::-1]  
        return sequenceRealHex, sequenceImagHex, sequenceRealInt, sequenceImagInt         