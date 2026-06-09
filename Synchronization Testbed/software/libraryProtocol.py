from libraryBasicComm import *
from librarySDR_adi import *
from libraryPPDU import *
from libraryUtility import *
import numpy as np
import time
import sys
from threading import Thread, Event
import scipy.io

class objProtocol():
    def __init__(self, **kwargs):
        # Parsing
        self.nodeID = 0
        self.virtualID = 0
        self.nodeRole = "none"
        self.isSDRavailable = 0
        self.hostKeysPath = ""
        self.signatureInputForSaving = "none"
        
        overwriteParameters(self, **kwargs)

        self.SDRtimeout = 1 * 60 * 1000 # ms, 0 means no timeout
        self.numberOfEDs = 10 # e.g., 3 edge devices and 1 edge server, can be changed according to the testbed setup
        self.validEDs = np.arange(self.numberOfEDs)
        self.isAutomaticEdgeServerLoopEnabled = 0

        self.fs = 5e6
        self.flclk = self.fs # Adalm Pluto is CMOS (not LDVS), AXI_AD9361 is based on dual port interface
        
        
        self.isSingleCarrierFrequency = True
        if self.isSingleCarrierFrequency == False:
            self.fcUplink = 925e6
            self.fcDownlink = 905e6

            self.fcTXInitialED = self.fcUplink
            self.fcRXInitialED = self.fcDownlink
            self.fcTXInitialES = self.fcDownlink
            self.fcRXInitialES = self.fcUplink            
        else:
            self.fc = 920e6
           
            self.fcTXInitialED = self.fc
            self.fcRXInitialED = self.fc
            self.fcTXInitialES = self.fc            
            self.fcRXInitialES = self.fc  
            
                      
        self.fcfoOffsetED_UL = 0 
        self.fcfoOffsetED_DL = 0 
        
          


        self.isCFOFeedbackRecommended = False
        self.isTxAttnFeedbackRecommended = False

        self.bw = self.fs
        
        self.IQdataRX = np.zeros(100, dtype=complex ) # just for initialization, it will be updated later
        self.IQdataTX = np.zeros(100, dtype=complex ) # just for initialization, it will be updated later


        self.textSeparatorLevel1 = " >> "
        self.textSeparatorLevel2 = " | "

        self.gainModeES = 'manual'
        gainRXES = 55
        attnTXES = 6
        
        self.gainModeED = 'manual'
        gainRXED = 55
        attnTXED = 6        
        
        self.minGainRX = 25
        self.maxGainRX = 75
        self.resGainRX = 1    
       
        self.minAttnTX = 0
        self.maxAttnTX = 30
        self.resAttnTX = 0.25
        self.thresholdAttnTXMax = 0.75
        
        self.HabsTargetED = 0.25
        self.HabsTargetES = 0.2
        self.HabsCutoffES = self.HabsTargetES/4 
        
        self.fcfoThresholdED_UL = 20  # Hz
        self.fcfoThresholdED_DL = 10  # Hz        
        
        self.numberOfParameters = int(32) # subcarriers
        self.OACscalar = 1;# 1/np.sqrt(self.numberOfEDs)

        self.HratioReal2ImagES = 0.2
        self.OACsymbolLength = 8
        self.OACnumberOfDigits = 1
                

        # Message definitions over PPDU 
        self.lengthCmd = int(4) # bits for cmd
        self.lengthVirtualIDList = int(32) # bits for multiple access
        self.lengthFeedbackType = int(8) # bits: 
        self.lengthScalar = int(32) # bits

        self.indicesCmd = np.arange(0,self.lengthCmd,1, dtype=int)
        self.indicesvirtualIDList = self.lengthCmd+np.arange(0,self.lengthVirtualIDList,1, dtype=int)    
        self.indicesFeedbackType = self.lengthCmd+self.lengthVirtualIDList+np.arange(0,self.lengthFeedbackType,1, dtype=int)    
        
        self.cmdCalibration = int(0)
        self.cmdMeasurement = int(1)        
        self.cmdAggregation = int(3)
        self.cmdBroadcast = int(4)
        self.cmdSounding = int(5)
        self.cmdFeedback = int(6)


        self.numberOfBitsForScalars = 32        


        self.es_quadrature_tracking_en = [1]
        self.es_rf_dc_offset_tracking_en = [1]
        self.es_bb_dc_offset_tracking_en = [1]
        
        self.ed_quadrature_tracking_en = np.zeros(self.numberOfEDs, dtype=int)
        self.ed_rf_dc_offset_tracking_en = np.zeros(self.numberOfEDs, dtype=int)
        self.ed_bb_dc_offset_tracking_en = np.zeros(self.numberOfEDs, dtype=int)
        for indED in range(self.numberOfEDs):
            self.ed_quadrature_tracking_en[indED] = 1
            self.ed_rf_dc_offset_tracking_en[indED] = 1
            self.ed_bb_dc_offset_tracking_en[indED] = 1
                
        # Note: Common trigger waveform for ES and EDs
        # ES trigger waveforms
        SDRtriggerWaveformCommon = fcn_circularlyShiftedLinearChirp(indexCirc=0, dftSize=64, deviationInTones=48, idftSize=64, type="linear").astype(complex)
        SDRtriggerWaveformCommon = SDRtriggerWaveformCommon/max(abs(SDRtriggerWaveformCommon))
        SDRtriggerWaveformCommon = SDRtriggerWaveformCommon.astype(complex)        
        
        self.SDRtriggerWaveform0ES = SDRtriggerWaveformCommon
        self.SDRtriggerWaveform1ES = fcn_circularlyShiftedLinearChirp(indexCirc=32, dftSize=64, deviationInTones=48, idftSize=64, type="sin").astype(complex)
        self.SDRtriggerWaveform1ES = self.SDRtriggerWaveform1ES/max(abs(self.SDRtriggerWaveform1ES))        

        self.SDRtriggerWaveformLength = 64 # samples        
        # ED trigger waveforms
        self.SDRtriggerWaveform0ED = np.zeros((self.numberOfEDs,64), dtype=complex)
        for indED in range(self.numberOfEDs):
            self.SDRtriggerWaveform0ED[indED,:] = SDRtriggerWaveformCommon
                 
        self.SDRtriggerWaveform1ED = np.zeros((self.numberOfEDs,64), dtype=complex)
        for indED in range(self.numberOfEDs):
            self.SDRtriggerWaveform1ED[indED,:] = fcn_zcOFDMWaveform(53, rootZC=1+4*indED, idftSize=64).astype(complex) 
            self.SDRtriggerWaveform1ED[indED,:] = self.SDRtriggerWaveform1ED[indED,:]/max(abs(self.SDRtriggerWaveform1ED[indED,:]))

        self.cmd_calculateTimers(a=64, d=192, g=212, e=10000, xi=24, epsilon=116)


        



        self.numberOfSamplesAcquireES_minimum = 3000
        self.numberOfSamplesAcquireED_minimum = 12500 

        self.zeroGapAfterSynch = 40 
        self.timeSyncPointForPPDUProcessingAtED = 12  
             
        self.counterLoops = 0
        ####################################################
        self.parametersSDR = dict([
            ('isSDRavailable', self.isSDRavailable),
            ('IP', '192.168.2.1'), 
            ('hostKeysPath', self.hostKeysPath), 
            ('timeout', self.SDRtimeout), 
            ])      
        self.mySDR = objSDR(**self.parametersSDR)  
        
        self.parametersPPDU = dict([
            ('backOffPPDUdB_comm', 10), 
            ])   
        self.myPPDU = objPPDU(**self.parametersPPDU)
        
        self.parametersCalibration = dict([
            ('backOffPPDUdB_calibration', 3), 
            ])        
        self.myCalibration = objCalibration(**self.parametersCalibration)
        
        self.parametersSounding = dict([
            ('backOffPPDUdB_sounding', 3), 
            ('numberOfRadios', self.numberOfEDs), 
            ])          
        self.mySounding = objSounding(**self.parametersSounding)
        
        self.feedbackPowerIncrementExact = np.zeros((self.numberOfEDs,), dtype=float)
        self.feedbackCFOAllExact = np.zeros((self.numberOfEDs,), dtype=float)
        self.feedbackPowerIncrement = np.zeros((self.numberOfEDs,), dtype=float)
        self.feedbackCFOAll = np.zeros((self.numberOfEDs,), dtype=float)        

        self.parametersOAC = dict([
            ('backOffPPDUdB_OAC', 8), 
            ('numberOfRadios', self.numberOfEDs), 
            ('numberOfParameters', self.numberOfParameters), 
            ('OACmethod', 'multiDimOAC'),
            ('OACsymbolLength', self.OACsymbolLength),
            ('OACnumberOfDigits', self.OACnumberOfDigits),
            ('OACscalar', self.OACscalar),
            ('virtualID', self.virtualID),    
            ('debugFlag', 0),
            ('isEncoder', self.nodeRole == 'edgeServer')
            ])         
        self.myOAC = objOAC(**self.parametersOAC)
        
        rng = np.random.default_rng(seed=10)
        self.data = np.zeros((self.numberOfEDs,self.numberOfParameters), dtype=int)
        for indED in range(self.numberOfEDs):
            self.data[indED,:] = rng.integers(0,self.OACsymbolLength*self.OACnumberOfDigits,self.numberOfParameters)
        self.aggregatedData = np.sum(self.data, axis=0)        
        
 
        if self.nodeRole == 'edgeServer':
            self.protocol_loop = self._protocol_loop_EdgeServer
            self.textRadioName = "ES " + str(self.nodeID) + ", Pos: " + str(self.virtualID) + " "           
            
            print(self.textRadioName + ">> Timers are set to: " + str(self.S1TimerES) + ", " + str(self.S2TimerES) + ", " + str(self.S3TimerES) + ", " + str(self.S4TimerES))
            self.mySDR.controller.setSDRIPCounters(self.S1TimerES,self.S2TimerES,self.S3TimerES,self.S4TimerES)
            
            self.FIRcoef0Real, self.FIRcoef0Imag, self.FIRcoef0RealInt, self.FIRcoef0ImagInt = self.mySDR.controller.calculateFIRCoefficientsForMatchedFilter(self.SDRtriggerWaveform0ES, numberOfBitsForCoef=8)
            self.FIRcoef1Real, self.FIRcoef1Imag, self.FIRcoef1RealInt, self.FIRcoef1ImagInt = self.mySDR.controller.calculateFIRCoefficientsForMatchedFilter(self.SDRtriggerWaveform1ES, numberOfBitsForCoef=8)        
            
            self.mySDR.controller.setSequenceFilter(self.FIRcoef0Real, self.FIRcoef0Imag,self.FIRcoef1Real, self.FIRcoef1Imag)
            self.mySDR.controller.getSequenceFilter()
            self.mySDR.controller.setSDRIPconfiguration(0)
            
            self.mySDR.controller.setRXCorrections(self.es_quadrature_tracking_en[self.virtualID], self.es_rf_dc_offset_tracking_en[self.virtualID], self.es_bb_dc_offset_tracking_en[self.virtualID])
            self.mySDR.controller.setRXparams(self.fcRXInitialES, self.bw, self.fs, gainRXES, self.gainModeES)
            self.mySDR.controller.setTXparams(self.fcTXInitialES, self.bw, self.fs, attnTXES)

            self.mySDR.controller.getSDRIPStatus()

            self.mySDR.controller.setSDRIPconfiguration(1)
            self.emptyRXFIFO()
                
        elif self.nodeRole == 'edgeDevice':            
            self._protocol_loop = self._protocol_loop_EdgeDevice
            self.textRadioName = "ED " + str(self.nodeID) + ", Pos: " + str(self.virtualID)  + " "

            print(self.textRadioName + ">> Timers are set to: " + str(self.S1TimerED) + ", " + str(self.S2TimerED) + ", " + str(self.S3TimerED) + ", " + str(self.S4TimerED))
            self.mySDR.controller.setSDRIPCounters(self.S1TimerED,self.S2TimerED,self.S3TimerED,self.S4TimerED)
            self.FIRcoef0Real, self.FIRcoef0Imag, self.FIRcoef0RealInt, self.FIRcoef0ImagInt = self.mySDR.controller.calculateFIRCoefficientsForMatchedFilter(self.SDRtriggerWaveform0ED[self.virtualID,:], numberOfBitsForCoef=8)
            self.FIRcoef1Real, self.FIRcoef1Imag, self.FIRcoef1RealInt, self.FIRcoef1ImagInt = self.mySDR.controller.calculateFIRCoefficientsForMatchedFilter(self.SDRtriggerWaveform1ED[self.virtualID,:], numberOfBitsForCoef=8)        
            
            self.mySDR.controller.setSequenceFilter(self.FIRcoef0Real, self.FIRcoef0Imag,self.FIRcoef1Real, self.FIRcoef1Imag)
            self.mySDR.controller.getSequenceFilter()        
            self.mySDR.controller.setSDRIPconfiguration(0)
            
            self.mySDR.controller.setRXCorrections(self.ed_quadrature_tracking_en[self.virtualID], self.ed_rf_dc_offset_tracking_en[self.virtualID], self.ed_bb_dc_offset_tracking_en[self.virtualID])
            
            self.mySDR.controller.setRXparams(self.fcRXInitialED, self.bw, self.fs, gainRXED, self.gainModeED)
            self.mySDR.controller.setTXparams(self.fcTXInitialED, self.bw, self.fs, attnTXED)

            self.mySDR.controller.getSDRIPStatus()
            
            self.mySDR.controller.setSDRIPconfiguration(11)     
            self.emptyRXFIFO()
            

        self.isProtocolRunning = 0
        self.CER = float(-1)
        self.stopEventforProtocolLoop = Event()
        self.createDispatchTable()    
        
    def createDispatchTable(self):
        self.dispatchTable = {
            "TX_TRIGGER": self.cmd_trigger,
            "TX_TRIGGER_FOR_OAC": self.cmd_triggerForAggregation,
            "TX_SOUNDING": self.cmd_sounding,
            "TX_CALIBRATION": self.cmd_calibration,
            "TX_AGGREGATION": self.cmd_aggregation,
            "TX_FEEDBACK": self.cmd_feedback,
            "CALC_SOUNDING_RES": self.cmd_calculateSoundingResults,
            "CALC_TIMERS": self.cmd_calculateTimers,
            "CALC_OAC_RES": self.cmd_calculateAggregationResults,
            "GET_CER": self.cmd_getCER,
            "GET_TIMER_CONSTRUCTORS":  self.cmd_getTimerConstructors,
            "SET_TIMERS": self.cmd_setTimers,
            "GET_TIMERS": self.cmd_getTimers,
            "SET_TX_ATTN": self.cmd_setTxAttn,
            "GET_TX_ATTN": self.cmd_getTxAttn,
            "SET_RX_GAIN": self.cmd_setRXGain,
            "GET_RX_GAIN": self.cmd_getRXGain,
        }

    def protocol_loop(self, typeOfProtocol = None):
        if self.isProtocolRunning == 0:
            self._protocol_loop(typeOfProtocol)              
                
    def _protocol_loop_EdgeServer(self, typeOfProtocol):
                
        
        if typeOfProtocol == "Aggregation":
            self.recording = True
            self.recordingHedAll= []
            self.recordingCER = []
            self.recordingIsAggregationValid = []
                     
            self.counterLoops = 0
            self.isProtocolRunning = 1
            self.fcfoThresholdED_UL = 20
            self.thresholdAttnTXMax = 2       
            self.HabsTargetES = 0.2
            self.HabsCutoffES = self.HabsTargetES/4          
            while True:
                if self.stopEventforProtocolLoop.is_set() == True:
                    self.isProtocolRunning = 0

                    self.stopEventforProtocolLoop.clear()
                    return
                
                self.counterLoops = self.counterLoops + 1
                if self.mySDR.controller.getRXFIFOcnt() > 0: # not exactly sure this case may happen. It may be sleep times are too short.
                    self.emptyRXFIFO()
                    
                
                self._executeCommand("TX_CALIBRATION", 0.5)
                self._executeCommand("TX_SOUNDING", 0.5)
                self._executeCommand("TX_TRIGGER", 0.25)
                self._executeCommand("CALC_SOUNDING_RES", 0.5)
                while self.isTxAttnFeedbackRecommended == True:
                    if self.stopEventforProtocolLoop.is_set() == True:
                        self.isProtocolRunning = 0
                        self.stopEventforProtocolLoop.clear()
                        return                
                    
                    self._executeCommand("TX_FEEDBACK", 0.75, {"is_TXattn_Feedback": True, "is_CFO_Feedback": False})
                    self._executeCommand("TX_CALIBRATION", 0.75)
                    self._executeCommand("TX_SOUNDING", 0.75)
                    self._executeCommand("TX_TRIGGER", 0.25)
                    self._executeCommand("CALC_SOUNDING_RES", 0.75)
                self._executeCommand("TX_CALIBRATION", 0.75)
                self._executeCommand("TX_AGGREGATION", 0.75)
                self._executeCommand("TX_TRIGGER_FOR_OAC", 0.25)
                
                if self.recording == True:   
                    self.recordingHedAll.append(self.H_eds)
                    self.recordingCER.append(self.CER)
                    self.recordingIsAggregationValid.append(self.isAggregationValid)
                    scipy.io.savemat(self.signatureInputForSaving + '_csi' + '.mat', mdict={'Heds': self.recordingHedAll, 'CER': self.recordingCER,'isAggregationValid': self.recordingIsAggregationValid})


                
                
        elif typeOfProtocol == "Sounding":
            self.isProtocolRunning = 1
            while True:
                if self.stopEventforProtocolLoop.is_set() == True:
                    self.isProtocolRunning = 0
                    self.counterLoops = 0
                    self.stopEventforProtocolLoop.clear()
                    return
                
                self.counterLoops = self.counterLoops + 1
                self._executeCommand("TX_CALIBRATION", 0.5)
                self._executeCommand("TX_SOUNDING", 0.5)
                self._executeCommand("TX_TRIGGER", 0.25)
                self._executeCommand("CALC_SOUNDING_RES", 0.25)
                
        
    def _executeCommand(self, command, sleepTime, kwargs={}):
        if self.stopEventforProtocolLoop.is_set() == False:
            print('\n'+self.textRadioName + '(' + str(self.counterLoops) + ')' + self.textSeparatorLevel1 + command)
            time.sleep(sleepTime)
            self.dispatchTable[command](**kwargs)
                
    def _protocol_loop_EdgeDevice(self, typeOfProtocol=None):
        while True:
            self.counterLoops = self.counterLoops + 1
            try:
                # Receive-Process&TransmitOptional Cycle
                # Receive
                print('\n'+self.textRadioName + '(' + str(self.counterLoops) + ')' + self.textSeparatorLevel1 + 'Waiting for the next command...')
                self.mySDR.controller.setSDRIPconfiguration(11)
                self.emptyRXFIFO()
                    
                if self.mySDR.controller.isSDRavailable:                            
                    self.IQdataRX = self.mySDR.transceiver.receiveIQdata(self.mySDR.controller.numberOfSamplesToReceiveAfterTrigger)
                else:
                    self.IQdataRX = self.IQdataRX_argument        
                
                # Process & TransmitOptional
                if self.IQdataRX.size > 50:
                    print(self.textRadioName + '(' + str(self.counterLoops) + ')' + self.textSeparatorLevel1 + 'Received IQ data with ' + str(len(self.IQdataRX)) + ' samples.')
                    ppduInfo = self.myPPDU.decode(self.IQdataRX, self.fs, self.timeSyncPointForPPDUProcessingAtED)
                    if ppduInfo['isValid'] == 1:
                        triggerType = bin2dec(ppduInfo['dataBits'][self.indicesCmd],0)
                        virtualIDList = ppduInfo['dataBits'][self.indicesvirtualIDList]
                        print(self.textRadioName + '(' + str(self.counterLoops) + ')' + self.textSeparatorLevel1 + 'PPDU is valid (SNR:' + str(ppduInfo['SNRdBEst']) + 'dB)')
                        
                        if triggerType == self.cmdCalibration:
                            if virtualIDList[self.virtualID] == 1:
                                print(self.textRadioName + '(' + str(self.counterLoops) + ')' + self.textSeparatorLevel1 + 'Calibration CDM is received.')
                                self.fcfoOffsetED_DL = self.myCalibration.decode(self.IQdataRX,self.fs,self.timeSyncPointForPPDUProcessingAtED+1280)
                                fcRXCurrent, fcTXCurrent = self.mySDR.controller.getTXRXcarrierFrequency()
                                if abs(self.fcfoOffsetED_DL)>self.fcfoThresholdED_DL:
                                    if self.isSingleCarrierFrequency == False:
                                        print(self.textRadioName + '(' + str(self.counterLoops) + ')' + self.textSeparatorLevel1 +  'RX fc is ' + str(f"{fcRXCurrent:.3f}") + ', CFO estimate: ' + str(f"{self.fcfoOffsetED_DL:+3.2f}") + 'Hz')
                                        fcRXCurrentNew = fcRXCurrent+self.fcfoOffsetED_DL
                                        self.mySDR.controller.setRXcarrierFrequency(fcRXCurrentNew)
                                    else:
                                        print(self.textRadioName + '(' + str(self.counterLoops) + ')' + self.textSeparatorLevel1 +  'fc is ' + str(f"{fcRXCurrent:.3f}") + ', CFO estimate: ' + str(f"{self.fcfoOffsetED_DL:+3.2f}") + 'Hz')
                                        fcRXCurrentNew = fcRXCurrent+self.fcfoOffsetED_DL
                                        self.mySDR.controller.setTXRXcarrierFrequency(fcRXCurrentNew)                                        
                                else:
                                    print(self.textRadioName + '(' + str(self.counterLoops) + ')' + self.textSeparatorLevel1 + 'RX fc is ' + str(f"{fcRXCurrent:.3f}") + ', CFO estimate: ' + str(f"{self.fcfoOffsetED_DL:+3.2f}") + ' Hz (wont be updated)')

                                self.rxGainDecrement = 20*np.log10(ppduInfo['HabsAverage']/self.HabsTargetED)
                                self.rxGainDecrement = np.round(self.rxGainDecrement*self.resGainRX)/self.resGainRX                        
                                
                                currentGainRX = self.cmd_getRXGain()
                                if abs(self.rxGainDecrement) != 0:
                                    gainRXED = currentGainRX - self.rxGainDecrement
                                    gainRXED = np.clip(gainRXED, self.minGainRX, self.maxGainRX)
                                    print(self.textRadioName + '(' + str(self.counterLoops) + ')' + self.textSeparatorLevel1 +  'Current RX gain is ' + str(f"{currentGainRX:.3f}") + ' and will be decreasedby ' + str(self.rxGainDecrement) + ' ')
                                    self.mySDR.controller.setRXgain(gainRXED)
                                else:
                                    print(self.textRadioName + '(' + str(self.counterLoops) + ')' + self.textSeparatorLevel1 +  'Current RX gain is ' + str(f"{currentGainRX:.3f}") + ' (no change)')
                            self.IQdataTX = np.array([0]) 
                            
                        elif triggerType == self.cmdFeedback:
                            if virtualIDList[self.virtualID] == 1:
                                feedbackType = ppduInfo['dataBits'][self.indicesFeedbackType] 
                                print(self.textRadioName + '(' + str(self.counterLoops) + ')' + self.textSeparatorLevel1 + 'Feedback CDM is received.')
                                
                                if feedbackType[0]==1:
                                    offset = self.lengthCmd + self.lengthVirtualIDList + self.lengthFeedbackType
                                    bitsForTxPowerIncrement = ppduInfo['dataBits'][offset:offset+self.numberOfEDs*self.numberOfBitsForScalars].reshape((self.numberOfEDs,self.numberOfBitsForScalars))
                                    txPowerIncrement = convertBitsAsIntegersToFloat32s(bitsForTxPowerIncrement)
                                    self.txPowerIncrement = txPowerIncrement[self.virtualID]

                                    currentTXattn = self.cmd_getTxAttn()
                                    if self.txPowerIncrement!=0:
                                        attnTXED = currentTXattn - self.txPowerIncrement
                                        attnTXED = np.clip(attnTXED, self.minAttnTX, self.maxAttnTX)
                                        print(self.textRadioName + '(' + str(self.counterLoops) + ')' + self.textSeparatorLevel1 +  'TX attn is ' + str(f"{currentTXattn:.3f}") + ' and will be reduced by ' + str(self.txPowerIncrement) + ' to ' + str(f"{attnTXED:.3f}"))
                                        self.mySDR.controller.setTXattn(attnTXED)
                                    else:
                                        print(self.textRadioName + '(' + str(self.counterLoops) + ')' + self.textSeparatorLevel1 +  'TX attn is ' + str(f"{currentTXattn:.3f}") + ' (no change)')

                                if feedbackType[1]==1:
                                    if feedbackType[0]==1:
                                        offset = self.lengthCmd + self.lengthVirtualIDList  + self.lengthFeedbackType + self.numberOfEDs*self.numberOfBitsForScalars
                                    else:
                                        offset = self.lengthCmd + self.lengthVirtualIDList  + self.lengthFeedbackType
                                    bitsForCFO = ppduInfo['dataBits'][offset : offset+self.numberOfEDs*self.numberOfBitsForScalars].reshape((self.numberOfEDs,self.numberOfBitsForScalars))
                                    CFOs = convertBitsAsIntegersToFloat32s(bitsForCFO)
                                    self.fcfoOffsetED_UL = CFOs[self.virtualID]
                                    if self.fcfoOffsetED_UL!=0:
                                        fcRXCurrent, fcTXCurrent = self.mySDR.controller.getTXRXcarrierFrequency()
                                        if self.isSingleCarrierFrequency == False:
                                            print(self.textRadioName + '(' + str(self.counterLoops) + ')' + self.textSeparatorLevel1 +  'TX fc is ' + str(f"{fcTXCurrent:.3f}") + ', CFO feedback: ' + str(f"{self.fcfoOffsetED_UL:+3.2f}") + ' Hz')
                                            fcTXCurrentNew = fcTXCurrent-self.fcfoOffsetED_UL
                                            self.mySDR.controller.setTXcarrierFrequency(fcTXCurrentNew)
                                        else:
                                            print(self.textRadioName + '(' + str(self.counterLoops) + ')' + self.textSeparatorLevel1 +  'fc is ' + str(f"{fcTXCurrent:.3f}") + ', CFO feedback: ' + str(f"{self.fcfoOffsetED_UL:+3.2f}") + ' Hz')
                                            fcTXCurrentNew = fcTXCurrent-self.fcfoOffsetED_UL
                                            self.mySDR.controller.setTXRXcarrierFrequency(fcTXCurrentNew)
                                    else:
                                        print(self.textRadioName + '(' + str(self.counterLoops) + ')' + self.textSeparatorLevel1 +  'TX fc is ' + str(f"{fcTXCurrent:.3f}") + ', CFO feedback: ' + str(f"{self.fcfoOffsetED_UL:+3.2f}") + ' Hz (no change)')

                            self.IQdataTX = np.array([0]) 
                            
                        elif triggerType == self.cmdSounding:
                            if virtualIDList[self.virtualID] == 1:
                                print(self.textRadioName + '(' + str(self.counterLoops) + ')' + self.textSeparatorLevel1 + 'Sounding CDM is received.')
                                self.IQdataTX = np.hstack([self.mySounding.encode(self.virtualID)]) # Response to the sounding command

                                print(self.textRadioName + '(' + str(self.counterLoops) + ')' + self.textSeparatorLevel1 + 'Pushing the sounding waveform and waiting for the trigger...')
                                if len(self.IQdataTX) != 1:
                                    self.mySDR.controller.setSDRIPconfiguration(12)
                                    self.mySDR.transceiver.transmitIQdata(self.IQdataTX)
                                    print(self.textRadioName + '(' + str(self.counterLoops) + ')' + self.textSeparatorLevel1 + 'Trigger signal is detected.')
                            else:
                                self.IQdataTX = np.array([0])     
                                
                        elif triggerType == self.cmdAggregation:
                            if virtualIDList[self.virtualID] == 1:
                                print(self.textRadioName + '(' + str(self.counterLoops) + ')' + self.textSeparatorLevel1 + 'Aggregation CDM is received.')
                                syncES = self.SDRtriggerWaveform1ES.astype(complex)
                                zeroSamples1 = np.zeros(self.gapWait)      
                                zeroSamples2 = np.zeros(self.gapOAC)      
                                triangle = np.linspace(0,1,200).astype(complex) 
                                
                                trianglePadded = np.hstack([np.zeros(triangle.size*(self.virtualID)), triangle, np.zeros(triangle.size*(self.numberOfEDs-self.virtualID-1))])
                                
                                ppduOAC, msg = self.myOAC.encode(self.data[self.virtualID],  dataWeight = 1)
                                            
                                self.IQdataTX = np.hstack([zeroSamples1, np.tile(syncES,1), zeroSamples2, ppduOAC, trianglePadded])
                                
                                print(self.textRadioName + '(' + str(self.counterLoops) + ')' + self.textSeparatorLevel1 + 'Pushing the PCP and OAC and waiting for the trigger...')
                                if len(self.IQdataTX) != 1:
                                    self.mySDR.controller.setSDRIPconfiguration(13)
                                    self.mySDR.transceiver.transmitIQdata(self.IQdataTX)
                                    print(self.textRadioName + '(' + str(self.counterLoops) + ')' + self.textSeparatorLevel1 + 'Trigger signal is detected.')                                         

                    else:
                        print(self.textRadioName + '(' + str(self.counterLoops) + ')' + self.textSeparatorLevel1 + '--- ATTENTION: PPDU is NOT valid... SNR:' + str(ppduInfo['SNRdBEst']) + 'dB' )
                        self.IQdataTX = np.array([0]) 
                    
            except Exception as e:
                print(self.textRadioName + '(' + str(self.counterLoops) + ')' + self.textSeparatorLevel1 + 'Error in processing the received signal: ' + str(e))
                self.IQdataTX = np.array([0])
            
    def cmd_trigger(self): 
        syncCommon = self.SDRtriggerWaveform0ES
        zeroWave =  np.zeros(self.zeroGapAfterSynch)  
        self.IQdataTX = np.concatenate((syncCommon, zeroWave))
        self.mySDR.controller.setSDRIPconfiguration(2) # "transmitAndReceive"
        self.mySDR.transceiver.transmitIQdata(self.IQdataTX)
        self.mySDR.controller.waitRXFIFO(self.mySDR.controller.numberOfSamplesToReceiveAfterTrigger)    
        self.IQdataRX = self.mySDR.transceiver.receiveIQdata(self.mySDR.controller.numberOfSamplesToReceiveAfterTrigger)
        #self.mySDR.controller.getDetectionCount()
        
    def cmd_calibration(self):
        syncCommon = self.SDRtriggerWaveform0ES
        zeroWave =  np.zeros(self.zeroGapAfterSynch)     
        bitsType = np.array(dec2bin(self.cmdCalibration,self.lengthCmd))
        bitsvirtualIDList = np.zeros((self.lengthVirtualIDList,), dtype=int)
        bitsvirtualIDList[np.arange(self.numberOfEDs)] = 1

        bitsTX = np.concatenate((bitsType, bitsvirtualIDList))      
        ppdu, msg = self.myPPDU.encode(bitsTX)
        self.IQdataTX = np.concatenate((syncCommon, zeroWave, ppdu, self.myCalibration.encode()))
        self.mySDR.controller.setSDRIPconfiguration(1) # "transmitButNotReceive"
        self.mySDR.transceiver.transmitIQdata(self.IQdataTX)

    def cmd_sounding(self):
        syncCommon = self.SDRtriggerWaveform0ES
        zeroWave =  np.zeros(self.zeroGapAfterSynch)             
        bitsType = np.array(dec2bin(self.cmdSounding,self.lengthCmd))
        bitsvirtualIDList = np.zeros((self.lengthVirtualIDList,), dtype=int)
        bitsvirtualIDList[np.arange(self.numberOfEDs)] = 1
                
        bitsTX = np.concatenate((bitsType, bitsvirtualIDList))      
        ppdu, msg = self.myPPDU.encode(bitsTX)                        
        self.IQdataTX = np.concatenate((syncCommon, zeroWave, ppdu, self.myCalibration.encode()))
        
        
        self.mySDR.controller.setSDRIPconfiguration(1) # "transmitButNotReceive"
        self.mySDR.transceiver.transmitIQdata(self.IQdataTX)
    
    def cmd_feedback(self, is_TXattn_Feedback = False, is_CFO_Feedback = False): 
        syncCommon = self.SDRtriggerWaveform0ES
        zeroWave =  np.zeros(self.zeroGapAfterSynch)             
        bitsForTxPowerIncrement = []
        bitsForCFO = []
        
        for ind in range(self.numberOfEDs):
            bitsForTxPowerIncrement = np.hstack((bitsForTxPowerIncrement, convertFloat32sToBitsAsIntegers(self.feedbackPowerIncrement.astype(np.float32)[ind])))
            # if self.feedbackPowerIncrement[ind] != 0:
            #     print(self.textRadioName + '(' + str(self.counterLoops) + ')' + self.textSeparatorLevel1  + '--> Power increment for ED #' + str(ind) + ' is ' + str(self.feedbackPowerIncrement[ind]) + ' dB')

            bitsForCFO = np.hstack((bitsForCFO, convertFloat32sToBitsAsIntegers(self.feedbackCFOAll.astype(np.float32)[ind])))
            # if self.feedbackCFOAll[ind] != 0:
            #     print(self.textRadioName + '(' + str(self.counterLoops) + ')' + self.textSeparatorLevel1  + '--> CFO for ED #' + str(ind) + ' is ' + str(self.feedbackCFOAll[ind]) + ' Hz')


        bitsType = np.array(dec2bin(self.cmdFeedback,self.lengthCmd))
        bitsvirtualIDList = np.zeros((self.lengthVirtualIDList,), dtype=int)
        bitsvirtualIDList[np.arange(self.numberOfEDs)] = 1
                
        bitsFeedbackType = np.zeros((self.lengthFeedbackType,), dtype=int)
        if is_TXattn_Feedback == True and is_CFO_Feedback == True:
            bitsFeedbackType[0] = 1
            bitsFeedbackType[1] = 1
            bitsTX = np.concatenate((bitsType, bitsvirtualIDList, bitsFeedbackType,bitsForTxPowerIncrement, bitsForCFO)) 
        elif is_TXattn_Feedback == True and is_CFO_Feedback == False:
            bitsFeedbackType[0] = 1
            bitsTX = np.concatenate((bitsType, bitsvirtualIDList, bitsFeedbackType, bitsForTxPowerIncrement)) 
        elif is_TXattn_Feedback == False and is_CFO_Feedback == True:
            bitsFeedbackType[1] = 1
            bitsTX = np.concatenate((bitsType, bitsvirtualIDList, bitsFeedbackType, bitsForCFO))
        else:
            bitsTX = np.concatenate((bitsType, bitsvirtualIDList, bitsFeedbackType))
            
        bitsTX = bitsTX.astype(int)     
        ppdu, msg = self.myPPDU.encode(bitsTX)
        self.IQdataTX = np.concatenate((syncCommon, zeroWave, ppdu, self.myCalibration.encode()))

        self.mySDR.controller.setSDRIPconfiguration(1) # "transmitButNotReceive"
        self.mySDR.transceiver.transmitIQdata(self.IQdataTX)
    
    def cmd_aggregation(self):
        syncCommon = self.SDRtriggerWaveform0ES
        zeroWave =  np.zeros(self.zeroGapAfterSynch)      
        bitsType = np.array(dec2bin(self.cmdAggregation, self.lengthCmd))
        bitsvirtualIDList = np.zeros((self.lengthVirtualIDList,), dtype=int)
        bitsvirtualIDList[np.arange(self.numberOfEDs)] = 1
            
        bitsTX = np.concatenate((bitsType, bitsvirtualIDList))      
        ppdu, msg = self.myPPDU.encode(bitsTX)
        self.IQdataTX = np.concatenate((syncCommon, zeroWave, ppdu, self.myCalibration.encode()))
        self.mySDR.controller.setSDRIPconfiguration(1) # "transmitButNotReceive"
        self.mySDR.transceiver.transmitIQdata(self.IQdataTX)
    
    def cmd_setTxAttn(self, value):
        if type(value) == str:
            value = float(value)
        self.mySDR.controller.setTXattn(value)

    def cmd_getTxAttn(self):
        return self.mySDR.controller.getTXattn()

    def cmd_setRXGain(self, value):
        if type(value) == str:
            value = float(value)
        self.mySDR.controller.setRXgain(value)

    def cmd_getRXGain(self):
        return self.mySDR.controller.getRXgain()

    def cmd_calculateSoundingResults(self):
        self.mySounding.decode(self.IQdataRX, self.fs, 122) # Note: mySounding.indActiveSubcarriers is based on the original 64 subcarriers, not the reduced set for OAC. But it is fine because they are aligned and we only use the common ones for feedback calculation. The same applies to the following decoding for OAC;
        self.cmd_calculateFeedbackInformation()
        
    def cmd_calculateFeedbackInformation(self):
        HCFRpreambleAll = self.mySounding.HCFRpreambleAll.copy()
        HCFRoacAbs = abs(HCFRpreambleAll[:,self.myOAC.indActiveSubcarriersOAC])
        meanHCFRpreamble = np.mean(HCFRoacAbs, axis=1)
        


        print(f'Cuttoff: {self.HabsCutoffES}, CFO Threshold: {self.fcfoThresholdED_UL}, TX ATTN: {self.thresholdAttnTXMax}')

        self.feedbackCFOAllExact = self.mySounding.fcfoEstAll.copy()
        self.feedbackCFOAll = self.mySounding.fcfoEstAll.copy()
        self.feedbackCFOAll[abs(self.feedbackCFOAll)< self.fcfoThresholdED_UL] = 0
        self.feedbackCFOAll[abs(meanHCFRpreamble)<  self.HabsCutoffES] = 0
        self.isCFOFeedbackRecommended = any(self.feedbackCFOAll != 0)


        self.feedbackPowerIncrement = 20*np.log10(self.HabsTargetES/meanHCFRpreamble)        
        self.feedbackPowerIncrementExact = self.feedbackPowerIncrement.copy()      
        
        self.feedbackPowerIncrement[abs(meanHCFRpreamble)<  self.HabsCutoffES] = 0
        self.feedbackPowerIncrement[abs(self.feedbackPowerIncrement)<self.thresholdAttnTXMax] = 0   
        factor = 1/self.resAttnTX            
        self.feedbackPowerIncrement = np.round(self.feedbackPowerIncrement*factor)/factor    
        self.isTxAttnFeedbackRecommended = any(self.feedbackPowerIncrement != 0)
        
    def cmd_triggerForAggregation(self):
        syncCommon = self.SDRtriggerWaveform0ES
        self.IQdataTX = np.hstack([syncCommon, np.zeros(self.gap_xi)])
        for indED in range(self.numberOfEDs):
            syncED = self.SDRtriggerWaveform0ED[indED,:] 
            self.IQdataTX = np.hstack([self.IQdataTX, np.zeros(self.gap_c), syncED, np.zeros(self.gap_d)])


        self.mySDR.controller.setSDRIPconfiguration(3) # "phase correction with phase-coded pilots"
        self.mySDR.transceiver.transmitIQdata(self.IQdataTX)
        self.mySDR.controller.waitRXFIFO(self.mySDR.controller.numberOfSamplesToReceiveAfterTrigger)
        self.IQdataRX = self.mySDR.transceiver.receiveIQdata(self.mySDR.controller.numberOfSamplesToReceiveAfterTrigger)
        self.cmd_calculateAggregationResults()
        
    def cmd_calculateAggregationResults(self):        
        self.timeSyncPointForOACPPDUProcessingAtES = self.gapWait + self.SDRtriggerWaveformLength + self.gapOAC + 125#  - (self.S2TimerES + self.S1TimerES)
        self.fusedData, self.H_eds = self.myOAC.decode(self.IQdataRX, self.timeSyncPointForOACPPDUProcessingAtES)

        if np.all(self.H_eds[self.validEDs].real>self.HabsCutoffES) and np.all(self.H_eds[self.validEDs].real>self.HratioReal2ImagES*self.H_eds[self.validEDs].imag):
            print(self.textRadioName + '(' + str(self.counterLoops) + ')' + self.textSeparatorLevel1  + '--> Successful coherent aggregation')                    
            self.CER = np.sum((self.aggregatedData!=self.fusedData))/(self.numberOfParameters)*100
            self.isAggregationValid = 1
            print(self.textRadioName + '(' + str(self.counterLoops) + ')' + self.textSeparatorLevel1  + '--> Computation error rate: ' + str(f"{self.CER:.2f}") + '%')
        else:
            self.CER = -1
            self.isAggregationValid = 0
            print(self.textRadioName + '(' + str(self.counterLoops) + ')' + self.textSeparatorLevel1  + '--> Channel coefficients are not valid.')                    
            for ind in range(self.numberOfEDs):
                if self.H_eds[ind].real>self.HabsCutoffES and self.HratioReal2ImagES*self.H_eds[ind].real>self.H_eds[ind].imag:
                    textValid = ' (valid)'
                else:
                    if self.H_eds[ind].real<self.HabsCutoffES and self.HratioReal2ImagES*self.H_eds[ind].real<self.H_eds[ind].imag:
                        textValid = ' (invalid) --> Re <' + str(self.HabsCutoffES) + ' and Im < Re x ' + str(self.HratioReal2ImagES) 
                    else:
                        if self.H_eds[ind].real<self.HabsCutoffES:
                            textValid = ' (invalid) --> Re <' + str(self.HabsCutoffES)
                        
                        if self.HratioReal2ImagES*self.H_eds[ind].real<self.H_eds[ind].imag:
                            textValid = ' (invalid) --> Im < Re x ' + str(self.HratioReal2ImagES)    
                    print(self.textRadioName + '(' + str(self.counterLoops) + ')' + self.textSeparatorLevel1  + '----> H for ED #' + str(ind) + ': ' + str(f"{self.H_eds[ind]:.4f}" + textValid))
      
    def cmd_getTimerConstructors(self): 
        return {'gap_a': self.gap_a,
                'gap_d': self.gap_d,
                'gap_g': self.gap_g,
                'gap_e': self.gap_e,
                'gap_xi': self.gap_xi,
                'gap_epsilon': self.gap_epsilon,
                }     
        
    def cmd_calculateTimers(self, a=None, d=None, g=None, e=None, xi=None, epsilon=None):
        if a != None:
            if type(a) == str:
                a = int(a)
            self.gap_a = a      # in samples, should be integer multiple of 4 because of DMA
        if d != None:
            if type(d) == str:
                d = int(d)
            self.gap_d = d      # in samples, should be integer multiple of 4 because of DMA
        if g != None: 
            if type(g) == str:
                g = int(g)
            self.gap_g = g      # in samples, should be integer multiple of 4 because of DMA
        if e != None: 
            if type(e) == str:
                e = int(e)
            self.gap_e = e      # in samples, should be integer multiple of 4 because of DMA
        if epsilon != None: 
            if type(epsilon) == str:
                epsilon = int(epsilon)
            self.gap_epsilon = epsilon
        if xi != None: 
            if type(xi) == str:
                xi = int(xi)
            self.gap_xi = xi
       
        # Timing diagram explanation of parameters:
        # DoFs: a, d, g, e, ξ, ϵ
        # Not DoFs: L=a+b+g, b=g+s+d, c=a+s+g, s1, s2, s3, s4, p1, p2, p3, p4, s
        # Time →
        # -------------------------------------------------------------------------------------------------------------------------------------------->                               
        #                 ________________________L_____________________ ________________________L_____________________ 
        #                |                   _____________b_____________|                   _____________b_____________| 
        #                |                  |                           |                  |                           |
        #                |____________c_______________|                 |____________c_______________|                 |   __________e__________
        #                |                  |         |       |         |                  |         |       |         |  |                     |
        # ES TX:      | ξ|                  |          ■■■s■■■<----d--->|                  |          ■■■s■■■<----d--->|ϵ |                     |
        # ES Timers:  |s1|<-------------------------------------------- s2 ---------------------------------------------->|<------ s3 --------->|  (s4=0)                   
        #                |                  |         |                 |                  |         |                 |  |                     |                                                           
        #                |                  |         |                 |                  |         |                 |  |__________e__________|
        #                |                  |<---g--->|                 |                  |         |                 |  |                     |
        # ED1 TX:     | ξ|<----a---->■■■s■■■                            |                  |         |                 |ϵ |                     |
        # ED1 Timers: |p1|<-------------------- p2 -------------------->|<---------------------- p3 --------------------->|<------ p4 --------->|    
        #                |                                              |                  |         |                 |  |                     |
        #                |                                              |                  |         |                 |  |                     |   
        #                |                                              |                  |                           |  |__________e__________|                          
        #                |                                              |                  |                           |  |                     |  
        # ED2 TX:     | ξ|                                              |<----a---->■■■s■■■                            |ϵ |                     |
        # ED2 Timers: |<---------------------- p1 --------------------->|<-------------------- p2 -------------------->|p3|<------ p4 --------->|    

        self.gap_s = self.SDRtriggerWaveformLength

        self.gap_b = self.gap_g + self.gap_s + self.gap_d
        self.gap_c = self.gap_g + self.gap_s + self.gap_a  
        
        self.gap_L = self.gap_a+self.gap_b+self.gap_s
        s1 = self.gap_xi
        s2 = self.numberOfEDs*self.gap_L + self.gap_epsilon
        s3 = self.gap_e
        s4 = int(0)
        
        p1 = self.virtualID*self.gap_L + self.gap_xi
        p2 = self.gap_L
        p3 = (self.numberOfEDs-self.virtualID-1)*self.gap_L+self.gap_epsilon
        p4 = self.gap_e

        self.gapWait = self.virtualID*self.gap_L+self.gap_a+self.gap_xi
        self.gapOAC = p3 + self.gap_b
        
        self.S1TimerED = p1
        self.S2TimerED = p2
        self.S3TimerED = p3
        self.S4TimerED = p4
        
        self.S1TimerES = s1
        self.S2TimerES = s2
        self.S3TimerES = s3
        self.S4TimerES = s4
        
    def cmd_setTimers(self): 
        if self.nodeRole == "edgeServer":
            self.mySDR.controller.setSDRIPCounters(self.S1TimerES, self.S2TimerES, self.S3TimerES, self.S4TimerES)
        elif self.nodeRole == "edgeDevice":
            self.mySDR.controller.setSDRIPCounters(self.S1TimerED, self.S2TimerED, self.S3TimerED, self.S4TimerED)
        
    def cmd_getTimers(self):
        if self.nodeRole == "edgeServer":
            return {'T1': self.S1TimerES, 'T2': self.S2TimerES, 'T3': self.S3TimerES, 'T4':  self.S4TimerES}
        elif self.nodeRole == "edgeDevice":
            return {'T1': self.S1TimerED, 'T2': self.S2TimerED, 'T3': self.S3TimerED, 'T4':  self.S4TimerED}
   
    def cmd_getCER(self):
        if self.nodeRole == "edgeServer":
            return self.CER
        else:
            return -1
        
    def emptyRXFIFO(self):
        if self.isSDRavailable == 1:    
            fifoCnt = self.mySDR.controller.getRXFIFOcnt()
            while fifoCnt > 0:        
                self.mySDR.transceiver.receiveIQdata(fifoCnt)        
                fifoCnt = self.mySDR.controller.getRXFIFOcnt()   

