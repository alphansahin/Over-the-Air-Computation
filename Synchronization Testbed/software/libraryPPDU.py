from time import time
import numpy as np
import matplotlib.pyplot as plt

from numpy import pi
from numpy.fft import fft, ifft
from libraryBasicComm import *
import random as rand
import sys


class objDefinitions():
    def __init__(self):
        self.xPos = 150
        self.yPos = 150
        self.dx = 600
        self.dy = 450
        self.dye = 35
        self.dxe = 5

        self.Nidft = int(256)
        self.Ncp = int(64)

        self.NactiveLeft = int(96)
        self.NactiveRight = int(96)
        self.NdcLeft = int(0)
        self.NdcRight = int(0)

        self.indActiveSubcarriers =np.concatenate((np.arange(-self.NactiveLeft,0,1)-self.NdcLeft, self.NdcRight+1+np.arange(0,self.NactiveRight,1))) % self.Nidft
        self.indTrackingActive = np.arange(0,self.NactiveRight+self.NactiveLeft,3)
        self.indDataActive = np.arange(0,self.NactiveRight+self.NactiveLeft,1)
        self.indDataActive =  np.delete(self.indDataActive,self.indTrackingActive)

        self.indTrackingSubcarriers = self.indActiveSubcarriers[self.indTrackingActive]
        self.indDataSubcarriers = self.indActiveSubcarriers[self.indDataActive]
        self.indSynchSubcarriers =np.arange(-96,97,2) % self.Nidft
        self.indNoiseSubcarriers =np.arange(-95,97,2) % self.Nidft

        self.numberOfDataSubcarriers = int(self.indDataSubcarriers.size)
        self.numberOfActiveSubcarriers = int(self.indActiveSubcarriers.size)
        

        #Define SYNC and CHEST fields
        self.Ga = np.array([1 + 0j,0 - 1j,1 + 0j,1 + 0j,1 + 0j,-1 + 0j,-1 + 0j,0 + 1j,-1 + 0j,-1 + 0j,-1 + 0j,1 + 0j,-1 + 0j,0 + 1j,-1 + 0j,-1 + 0j,-1 + 0j,1 + 0j,-1 + 0j,0 + 1j,-1 + 0j,-1 + 0j,-1 + 0j,1 + 0j,-1 + 0j,0 + 1j,-1 + 0j,1 + 0j,1 + 0j,-1 + 0j,-1 + 0j,0 + 1j,-1 + 0j,1 + 0j,1 + 0j,-1 + 0j,1 + 0j,0 - 1j,1 + 0j,-1 + 0j,-1 + 0j,1 + 0j,-1 + 0j,0 + 1j,-1 + 0j,1 + 0j,1 + 0j,-1 + 0j,-1 + 0j,0 + 1j,-1 + 0j,-1 + 0j,-1 + 0j,1 + 0j,1 + 0j,0 - 1j,1 + 0j,1 + 0j,1 + 0j,-1 + 0j,-1 + 0j,0 + 1j,-1 + 0j,-1 + 0j,-1 + 0j,1 + 0j,-1 + 0j,0 + 1j,-1 + 0j,-1 + 0j,-1 + 0j,1 + 0j,1 + 0j,0 - 1j,1 + 0j,-1 + 0j,-1 + 0j,1 + 0j,1 + 0j,0 - 1j,1 + 0j,-1 + 0j,-1 + 0j,1 + 0j,1 + 0j,0 - 1j,1 + 0j,-1 + 0j,-1 + 0j,1 + 0j,-1 + 0j,0 + 1j,-1 + 0j,1 + 0j,1 + 0j,-1 + 0j])
        self.Gb = np.array([-1 + 0j,0 + 1j,-1 + 0j,-1 + 0j,-1 + 0j,1 + 0j,1 + 0j,0 - 1j,1 + 0j,1 + 0j,1 + 0j,-1 + 0j,1 + 0j,0 - 1j,1 + 0j,1 + 0j,1 + 0j,-1 + 0j,1 + 0j,0 - 1j,1 + 0j,1 + 0j,1 + 0j,-1 + 0j,1 + 0j,0 - 1j,1 + 0j,-1 + 0j,-1 + 0j,1 + 0j,1 + 0j,0 - 1j,1 + 0j,-1 + 0j,-1 + 0j,1 + 0j,-1 + 0j,0 + 1j,-1 + 0j,1 + 0j,1 + 0j,-1 + 0j,1 + 0j,0 - 1j,1 + 0j,-1 + 0j,-1 + 0j,1 + 0j,-1 + 0j,0 + 1j,-1 + 0j,-1 + 0j,-1 + 0j,1 + 0j,1 + 0j,0 - 1j,1 + 0j,1 + 0j,1 + 0j,-1 + 0j,-1 + 0j,0 + 1j,-1 + 0j,-1 + 0j,-1 + 0j,1 + 0j,-1 + 0j,0 + 1j,-1 + 0j,-1 + 0j,-1 + 0j,1 + 0j,1 + 0j,0 - 1j,1 + 0j,-1 + 0j,-1 + 0j,1 + 0j,1 + 0j,0 - 1j,1 + 0j,-1 + 0j,-1 + 0j,1 + 0j,1 + 0j,0 - 1j,1 + 0j,-1 + 0j,-1 + 0j,1 + 0j,-1 + 0j,0 + 1j,-1 + 0j,1 + 0j,1 + 0j,-1 + 0j])
        self.chestSymbols = np.concatenate((self.Ga, self.Gb))
        self.scrambleSymbols = np.concatenate((self.Ga[np.arange(0,64,1)], self.Gb[np.arange(0,64,1)]))
        

        self.trackingSymbols = self.Ga[np.arange(0,64,1)]
        sequenceTraining = zcsequence(1,  int(97), 0)
        self.synchSymbols = (sequenceTraining[np.arange(self.indSynchSubcarriers.size)])        
                
        self.firstSeed = 93482910475

class objPPDU(objDefinitions):
    def __init__(self, **kwargs):
        objDefinitions.__init__(self)
        self.debugFlag = 0
        self.backOffPPDUdB_comm = 10

        # Override defaults with provided keyword arguments
        # The provided dictionary is unpacked into kwargs when calling the constructor
        for key, value in kwargs.items():
            if hasattr(self, key):
                setattr(self, key, value)
            else:
                # Optional: handle extra keys if needed
                print(f"Warning: '{key}' is not a recognized attribute and will be ignored.")

        #Define modulation type & modulation information
        self.modulationType = "BPSK"
        self.modulationOrder = 2
        
        
        if self.modulationType == "BPSK":
            self.bitsPerSymbol = 1
        elif self.modulationType == "QAM":
            self.bitsPerSymbol = int(np.log2(self.modulationOrder))

        #Define codeword & message parameters
        self.crcLength = int(8)
        self.mPolar = int(7)
        self.ratePolar = 0.5

        self.codeWordLength = int(2**self.mPolar)
        self.messageLengthPolar = int(np.floor(self.codeWordLength*self.ratePolar))
        self.messageLength = int(self.messageLengthPolar)-self.crcLength
        self.codeRate = self.messageLength/self.codeWordLength
        self.polarCode = objPolarCode(self.mPolar,self.messageLengthPolar)

        #Define HEADER field parameters & information (NOTE: HEADER is always BPSK modulated)
        self.chestRefreshRate = int(16) # ofdm symbols
        self.maxNtotalOFDMSymbolsForData = int(100) # ofdm symbols
        self.maximumBitPerSymbol = 12
        
        self.headerSignature = [1,0,1,0,1,0,1,0]
        self.headerSignatureSize = len(self.headerSignature)


        self.headerNcodewordSize = int(np.ceil(np.log2(self.maxNtotalOFDMSymbolsForData*self.numberOfDataSubcarriers/self.codeWordLength))+1) # bits
        self.headerNprepadSize = int(np.ceil(np.log2(self.messageLength))+1) # bits
        self.headerNpostpadSize = int(np.ceil(np.log2(self.maximumBitPerSymbol*self.numberOfDataSubcarriers))+1) # bits

        self.headerReservedSize = int(self.numberOfDataSubcarriers*self.codeRate - self.headerSignatureSize - self.headerNcodewordSize - self.headerNprepadSize - self.headerNpostpadSize)

        self.headerSignatureIndices = np.arange(0,self.headerSignatureSize,1, dtype=int)
        self.headerNcodewordIndices = self.headerSignatureSize+np.arange(0,self.headerNcodewordSize,1, dtype=int)
        self.headerNprepadIndices = self.headerSignatureSize+self.headerNcodewordSize+np.arange(0,self.headerNprepadSize,1, dtype=int)
        self.headerNpostpadIndices = self.headerSignatureSize+self.headerNcodewordSize+self.headerNprepadSize+np.arange(0,self.headerNpostpadSize,1, dtype=int)
        self.headerReservedIndices = self.headerSignatureSize+self.headerNcodewordSize+self.headerNprepadSize+self.headerNpostpadSize+np.arange(0,self.headerReservedSize,1, dtype=int)
        self.headerCRCIndices = self.headerSignatureSize+self.headerNcodewordSize+self.headerNprepadSize+self.headerNpostpadSize+self.headerReservedSize+np.arange(0,self.crcLength,1, dtype=int)


        self.cntDecode = 0
    def encode(self, bitsTX):
        msg = ''
        Nbits = int(bitsTX.size)
        Ncodewords = int(np.ceil(Nbits/self.messageLength))
        Nprepadding = int(Ncodewords*self.messageLength-Nbits)

        NofdmData = int(np.ceil((Ncodewords*self.codeWordLength)/self.bitsPerSymbol/self.numberOfDataSubcarriers))
        Npostpadding = int(NofdmData*self.numberOfDataSubcarriers*self.bitsPerSymbol-(Ncodewords*self.codeWordLength))
        NchestExtra =  int(np.floor((NofdmData-1)/self.chestRefreshRate))
        symbolsMapped = np.zeros((3+NofdmData+NchestExtra,self.Nidft), dtype=complex)

        bitsSign = np.array(self.headerSignature)
        bitsNcodeword = np.array(dec2bin(Ncodewords,self.headerNcodewordSize))
   
        bitsNprepad = np.array(dec2bin(Nprepadding,self.headerNprepadSize))
        bitsNpostpad = np.array(dec2bin(Npostpadding,self.headerNpostpadSize))
        bitsReserved = np.array(dec2bin(0,self.headerReservedSize))
    
        headerBitsWithoutCRC = np.concatenate((bitsSign, bitsNcodeword, bitsNprepad, bitsNpostpad, bitsReserved))
        headerBits = np.concatenate((headerBitsWithoutCRC, calc_crc(headerBitsWithoutCRC)))
   
        # Preamble
        symbolsMapped[0,self.indSynchSubcarriers] = np.sqrt(2)*self.synchSymbols
        symbolsMapped[1,self.indActiveSubcarriers] = self.chestSymbols
        codedBits = self.polarCode.encode(headerBits)
        symbols = 2*codedBits-1
        symbolsMapped[2,self.indDataSubcarriers] = symbols*self.scrambleSymbols
        symbolsMapped[2,self.indTrackingSubcarriers] = self.trackingSymbols
        
        # Payload
        bitsprepadding = np.zeros(Nprepadding,dtype = int)
        dataBitsPadded = np.concatenate((bitsTX, bitsprepadding),dtype=int)

        # Scramble Bits
        dataBitsPadded = bitScrambler(dataBitsPadded,self.firstSeed)
        dataBitsPadded = np.reshape(dataBitsPadded,(Ncodewords,-1))
        codedData = np.empty((Ncodewords,self.codeWordLength),dtype=int)

        for indCodeword in range(Ncodewords):
            codedBits = self.polarCode.encode(np.concatenate((dataBitsPadded[indCodeword,:], calc_crc(dataBitsPadded[indCodeword,:]))))
            codedData[indCodeword,:] = codedBits

        
        # noiseVarPost = 0.02
        # llr_num = np.exp((-abs(symbols.real - 1) ** 2) / noiseVarPost)
        # llr_den = np.exp((-abs(symbols.real - -1) ** 2) / noiseVarPost)
        # W = np.concatenate((llr_den.reshape([1,-1]),llr_num.reshape([1,-1])),axis=0)
        # preambleMessage = self.polarCode.decode(W)



        S = NofdmData+NchestExtra
        indChest = np.arange(self.chestRefreshRate,S,self.chestRefreshRate+1,dtype=int)
        indData = np.arange(0,S,1,dtype=int)
        indData = np.delete(indData, indChest)

        if(self.modulationType == "QAM"):
            #Resize data array to work with QAM modulation function
            dataResized = np.resize(codedData,(1,int(np.size(codedData))))
            dataResized = np.array(dataResized[0])

            #postPadBits = np.zeros(int(Npostpadding),dtype = int)
            postPadBits = np.random.randint(2,size=int(Npostpadding),dtype = int)
            dataResized = np.concatenate((dataResized,postPadBits),axis = 0,dtype = int)
            
            #Use function to get TX symbols and then reshape to fit within all OFDM symbols
            symbolsTX, _ = QAM_modulation(dataResized, self.modulationOrder)
            symbolsTX = np.array(symbolsTX)
            symbolsTX = np.resize(symbolsTX,(int(len(symbolsTX)/self.numberOfDataSubcarriers),self.numberOfDataSubcarriers))

            #Map TX symbols
            symbolsMapped[np.ix_(3+indData,self.indDataSubcarriers)] = symbolsTX
            symbolsMapped[np.ix_(3+indChest,self.indActiveSubcarriers)] = np.tile(self.chestSymbols,(NchestExtra,1)) 
            symbolsMapped[np.ix_(3+indData,self.indTrackingSubcarriers)] = np.tile(self.trackingSymbols,(NofdmData,1))

        elif(self.modulationType == "BPSK"):
            symbolsMapped[np.ix_(3+indData,self.indDataSubcarriers)] = (2*codedData-1)
            symbolsMapped[np.ix_(3+indChest,self.indActiveSubcarriers)] = np.tile(self.chestSymbols,(NchestExtra,1)) 
            symbolsMapped[np.ix_(3+indData,self.indTrackingSubcarriers)] = np.tile(self.trackingSymbols,(NofdmData,1))


        # The default normalization is "backward", i.e, the forward transform (FFT) is unscaled and the inverse transform (IFFT) is scaled by 1/N (the number of points).
        # By multiplying IFFT result by N/sqrt(Nactive), the mean power of the time domain signal is expected to be 1 (without any back off)
        
        ppdu = ifft(symbolsMapped,self.Nidft,1)*self.Nidft/np.sqrt(len(self.indActiveSubcarriers)) 
        ppdu = ppdu[:,np.arange(-self.Ncp,self.Nidft)]   
        # np.mean(np.abs(ppdu[0])**2) 
        ppdu = np.reshape(ppdu,(1,-1))*10**(-self.backOffPPDUdB_comm/20)
        if max(abs(ppdu[0].real)) > 1:
            msg = ("Power backoff for communication PPDU is not sufficient. Real part will be clipped. Ratio: " + str(sum(abs(ppdu[0].real)>1)/ppdu[0].size * 100) + "%")
            np.clip(ppdu.real, -1, 1, out=ppdu.real)
        if max(abs(ppdu[0].imag)) > 1:
            msg =  ("Power backoff for communication PPDU is not sufficient. Imag part will be clipped. Ratio: " + str(sum(abs(ppdu[0].imag)>1)/ppdu[0].size * 100) + "%")
            np.clip(ppdu.imag, -1, 1, out=ppdu.imag)      
        if msg != '': print(['Warning: ' + msg])                
        return ppdu[0], msg
    def decode(self, IQdataRX, fs, Nstart):
        if self.debugFlag == True:
            if self.cntDecode == 0:
                plt.ion()
                self.figTime = plt.figure(30)
                ax = self.figTime.add_subplot(311)
                ax.grid()
                ax.set_ylim(0,2)
                ax.set_xlabel('Sample index')
                ax.set_ylabel('Magnitude')                

                ax2 = self.figTime.add_subplot(312)
                ax2.grid()
                ax2.set_ylim(-1.2,1.2)
                ax2.set_xlabel('Sample index')
                ax2.set_ylabel('Amplitude')                
                
                ax3 = self.figTime.add_subplot(313)
                ax3.grid()
                ax3.set_ylim(-1.2,1.2)
                ax3.set_xlabel('Sample index')
                ax3.set_ylabel('Amplitude')                           

                t = np.linspace(0,  IQdataRX.size-1,  IQdataRX.size);#/self.fs*1e+6
                self.lineAbs, = ax.plot(t,abs(IQdataRX), label='ABS')
                self.lineReal, = ax2.plot(t,IQdataRX.real, 'r-' ,label='I')
                self.lineImag, = ax3.plot(t,IQdataRX.imag, 'g-', label='Q')
                ax.legend()
                ax2.legend()
                ax3.legend()

                if sys.platform.startswith("win"):
                    mngr = plt.get_current_fig_manager()
                    mngr.window.setGeometry(self.xPos, self.yPos, self.dx, self.dy)  
                self.figTime.canvas.draw()
                self.figTime.canvas.flush_events()                                
            else:
                self.lineAbs.set_ydata(np.abs(IQdataRX)) 
                self.lineReal.set_ydata(IQdataRX.real) 
                self.lineImag.set_ydata(IQdataRX.imag) 
                self.figTime.canvas.draw()
                self.figTime.canvas.flush_events() 

        # Step 1: TO estimation
        Nchosen = self.Ncp+Nstart # Synch SDR enables time synch

        # Step 2: Remove DC offset
        if True:
            IQdataRX = IQdataRX - np.mean(IQdataRX)

         # Step 3: CFO estimation and correction
        L = self.Nidft//2
        m = np.arange(0,L,1) #[0:L-1];
        P = np.vdot((IQdataRX[Nchosen+m]), IQdataRX[Nchosen+L+m])
        fcfoEst = np.angle(P)/(2*pi*L)*fs
        rCorrected = IQdataRX * np.exp(-1j*2*pi*fcfoEst*np.arange(0,IQdataRX.size,1)/fs)
        if self.debugFlag == True:
            print(' > CFO [Hz]..........:' + str(fcfoEst)); 
            if self.cntDecode == 0:
                plt.ion()
                self.figCFO = plt.figure(31)
                ax = self.figCFO.add_subplot(311)
                ax.grid()
                ax.set_ylim(0,2)
                ax.set_xlabel('Sample index')
                ax.set_ylabel('Magnitude')                

                ax2 = self.figCFO.add_subplot(312)
                ax2.grid()
                ax2.set_ylim(-1.2,1.2)
                ax2.set_xlabel('Sample index')
                ax2.set_ylabel('Amplitude')                
                
                ax3 = self.figCFO.add_subplot(313)
                ax3.grid()
                ax3.set_ylim(-1.2,1.2)
                ax3.set_xlabel('Sample index')
                ax3.set_ylabel('Amplitude')                           

                t = np.linspace(0,  rCorrected.size-1,  rCorrected.size);#/self.fs*1e+6
                self.lineAbsCFO, = ax.plot(t,abs(rCorrected), label='ABS')
                self.lineRealCFO, = ax2.plot(t,rCorrected.real, 'r-' ,label='I')
                self.lineImagCFO, = ax3.plot(t,rCorrected.imag, 'g-', label='Q')
                ax.legend()
                ax2.legend()
                ax3.legend()

                if sys.platform.startswith("win"):
                    mngr = plt.get_current_fig_manager()
                    mngr.window.setGeometry(self.xPos+self.dx+self.dxe, self.yPos, self.dx, self.dy)  
                self.figCFO.canvas.draw()
                self.figCFO.canvas.flush_events()                                
            else:
                self.lineAbsCFO.set_ydata(np.abs(rCorrected)) 
                self.lineRealCFO.set_ydata(rCorrected.real) 
                self.lineImagCFO.set_ydata(rCorrected.imag) 
                self.figCFO.canvas.draw()
                self.figCFO.canvas.flush_events()             
            

        # Step 4: Noise Estimation
        Nsync = Nchosen-self.Ncp
        indices = np.arange(0,(self.Nidft+self.Ncp)*1,1, dtype=int)
        rOFDMwithCP = rCorrected[Nsync+indices]
        rOFDMwithCP = np.reshape(rOFDMwithCP,(-1,self.Nidft+self.Ncp))
        rOFDMwithoutCP = rOFDMwithCP[:,np.arange(self.Ncp,self.Nidft+self.Ncp)]
        symbolsWithoutEqualization = fft(rOFDMwithoutCP)/np.sqrt(self.Nidft)
        noiseSubcarriers = symbolsWithoutEqualization[:,self.indNoiseSubcarriers]
        synchSubcarriers = symbolsWithoutEqualization[:,self.indSynchSubcarriers]

        if self.debugFlag == True:
            if self.cntDecode == 0:
                self.figFreq = plt.figure(32)
                ax = self.figFreq.add_subplot(211)
                ax.set_ylim(0,2)
                ax.set_xlim(-self.Nidft/2,self.Nidft/2-1)
                ax.set_xlabel('Subcarrier indices')
                ax.set_ylabel('Magnitude')
                ax.grid()
                ax2 = self.figFreq.add_subplot(212)
                ax2.set_xlabel('Subcarrier indices')
                ax2.set_ylabel('Phase')
                ax2.grid()
                ax2.set_ylim(0,360)
                ax2.set_xlim(-self.Nidft/2,self.Nidft/2-1)  
                ind = np.arange(-self.Nidft/2,self.Nidft/2,1)
                self.lineSYNCabs, = ax.plot(ind,np.fft.fftshift(np.abs(symbolsWithoutEqualization[0,:])), 'b-', label='SYNC') # Returns a tuple of line objects, thus the comma
                self.lineSYNCangle, = ax2.plot(ind,np.fft.fftshift(np.angle(symbolsWithoutEqualization[0,:])), 'b-', label='SYNC') # Returns a tuple of line objects, thus the comma      
                ax.legend()
                ax2.legend()
                if sys.platform.startswith("win"):
                    mngr = plt.get_current_fig_manager()
                    mngr.window.setGeometry(self.xPos, self.yPos+self.dy+self.dye, self.dx, self.dy)                     
                self.figFreq.canvas.draw()
                self.figFreq.canvas.flush_events()                   
            else:
                self.lineSYNCabs.set_ydata(np.fft.fftshift(np.abs(symbolsWithoutEqualization[0,:]))) 
                self.lineSYNCangle.set_ydata(np.fft.fftshift(np.angle(symbolsWithoutEqualization[0,:])))    
                self.figFreq.canvas.draw()
                self.figFreq.canvas.flush_events() 

        noiseVarEst = np.mean(np.abs(noiseSubcarriers[0])**2)
        if noiseVarEst <1e-4:
            noiseVarEst = 1e-4

        signalVarEst = np.mean(np.abs(synchSubcarriers[0])**2)
        SNR = signalVarEst/noiseVarEst
        if self.debugFlag == True:
            print((' > Noise var.........:' + str(noiseVarEst)))
            print((' > Signal var........:' + str(signalVarEst)))
            print((' > SNR [dB]..........:' + str(10*np.log10(SNR))))

        # Step 5: Decode preamble
        indices = np.arange(0,(self.Nidft+self.Ncp)*2,1, dtype=int)
        rOFDMwithCP = rCorrected[Nsync+(self.Nidft+self.Ncp)*1+indices]
        rOFDMwithCP = np.reshape(rOFDMwithCP,(-1,self.Nidft+self.Ncp))
        rOFDMwithoutCP = rOFDMwithCP[:,np.arange(self.Ncp,self.Nidft+self.Ncp)]
        symbolsWithoutEqualization = fft(rOFDMwithoutCP)/np.sqrt(self.Nidft)
        HCFRpreamble = symbolsWithoutEqualization[0,self.indActiveSubcarriers]/self.chestSymbols
        HabsAverage = np.mean(np.abs(HCFRpreamble))
        
        enableDenoise = True
        levelDenoise = 0.01
        if enableDenoise:
            hCIR = ifft(HCFRpreamble)
            ind = np.abs(np.array(hCIR))<levelDenoise*np.max((np.abs(hCIR)))
            hCIR[ind]=0
            HCFRpreambleDenoised = fft(hCIR)  
            HCFRpreambleEQ = HCFRpreambleDenoised
        else:
            HCFRpreambleEQ = HCFRpreamble
            
        if self.debugFlag == True:
            cfrOnSubcarriers = np.zeros((1,self.Nidft), dtype=complex)
            cfrOnSubcarriers[0,self.indActiveSubcarriers] = HCFRpreamble
            
            cfrOnSubcarriersDenoised = np.zeros((1,self.Nidft), dtype=complex)
            cfrOnSubcarriersDenoised[0,self.indActiveSubcarriers] = HCFRpreambleDenoised
            
            if self.cntDecode == 0:
                self.figPreambleCFR = plt.figure(33)
                ax = self.figPreambleCFR.add_subplot(211)
                ax.set_ylim(0,2)
                ax.set_xlim(-self.Nidft/2,self.Nidft/2-1)
                ax.set_xlabel('Subcarrier indices')
                ax.set_ylabel('Magnitude')
                ax.grid()
                ax2 = self.figPreambleCFR.add_subplot(212)
                ax2.set_xlabel('Subcarrier indices')
                ax2.set_ylabel('Phase')
                ax2.grid()
                ax2.set_ylim(0,360)
                ax2.set_xlim(-self.Nidft/2,self.Nidft/2-1)  
                ind = np.arange(-self.Nidft/2,self.Nidft/2,1)
                self.linePreambleCFR, = ax.plot(ind,np.fft.fftshift(np.abs(cfrOnSubcarriers[0,:])), 'b-', label='CFR') # Returns a tuple of line objects, thus the comma
                self.linePreambleCFRangle, = ax2.plot(ind,np.fft.fftshift(np.angle(cfrOnSubcarriers[0,:])), 'b-', label='CFR') # Returns a tuple of line objects, thus the comma      
                self.linePreambleCFRdenoised, = ax.plot(ind,np.fft.fftshift(np.abs(cfrOnSubcarriersDenoised[0,:])), 'r-', label='CFR Denoised') # Returns a tuple of line objects, thus the comma
                self.linePreambleCFRdenoisedangle, = ax2.plot(ind,np.fft.fftshift(np.angle(cfrOnSubcarriersDenoised[0,:])), 'r-', label='CFR Denoised') # Returns a tuple of line objects, thus the comma      
                ax.legend()
                ax2.legend()
                if sys.platform.startswith("win"):
                    mngr = plt.get_current_fig_manager()
                    mngr.window.setGeometry(self.xPos+(self.dx+self.dxe), self.yPos+(self.dy+self.dye), self.dx, self.dy)                     
                self.figPreambleCFR.canvas.draw()
                self.figPreambleCFR.canvas.flush_events()                   
            else:
                self.linePreambleCFR.set_ydata(np.fft.fftshift(np.abs(cfrOnSubcarriers[0,:]))) 
                self.linePreambleCFRangle.set_ydata(np.fft.fftshift(np.angle(cfrOnSubcarriers[0,:])))    
                self.linePreambleCFRdenoised.set_ydata(np.fft.fftshift(np.abs(cfrOnSubcarriersDenoised[0,:]))) 
                self.linePreambleCFRdenoisedangle.set_ydata(np.fft.fftshift(np.angle(cfrOnSubcarriersDenoised[0,:])))    
                self.figPreambleCFR.canvas.draw()
                self.figPreambleCFR.canvas.flush_events()              

        preambleSymbolsAfterEqualization = (symbolsWithoutEqualization[1,self.indActiveSubcarriers]*np.conjugate(HCFRpreambleEQ)/(np.abs(HCFRpreambleEQ)**2+1/SNR))
        
        cpe = np.mean(preambleSymbolsAfterEqualization[self.indTrackingActive]/self.trackingSymbols)
        cpe = cpe/np.abs(cpe)

        preambleDataSymbolsAfterEqualization = preambleSymbolsAfterEqualization[self.indDataActive]/self.scrambleSymbols
        preambleDataSymbolsAfterEqualization = preambleDataSymbolsAfterEqualization/cpe

        #Validate RX constellation after equalization
        if self.debugFlag == True:
            if self.cntDecode == 0:
                plt.ion()
                self.figConstellationPreamble = plt.figure(34)
                ax = self.figConstellationPreamble.add_subplot(111)
                ax.grid()
                ax.set_xlabel('Real')
                ax.set_ylabel('Imaginary')
                ax.set_title("RX Payload Constellation After Channel Equalization ")
                ax.set_ylim([-2,2])
                ax.set_xlim([-2,2])
                self.lineConstellationPreamble, =ax.plot(preambleDataSymbolsAfterEqualization.real,preambleDataSymbolsAfterEqualization.imag, marker = 'x', ls = '')
                ax.set_aspect('equal', adjustable='box')
                self.figConstellationPreamble.canvas.draw()
                self.figConstellationPreamble.canvas.flush_events()     
                if sys.platform.startswith("win"):
                    mngr = plt.get_current_fig_manager()
                    mngr.window.setGeometry(self.xPos+2*(self.dx+self.dxe), self.yPos, self.dx, self.dy)     
                ax.legend()  
            else:
                self.lineConstellationPreamble.set_xdata(preambleDataSymbolsAfterEqualization.real)    
                self.lineConstellationPreamble.set_ydata(preambleDataSymbolsAfterEqualization.imag)    
                self.figConstellationPreamble.canvas.draw()
                self.figConstellationPreamble.canvas.flush_events()           


        noiseVarPost = noiseVarEst/(noiseVarEst+np.abs(HCFRpreamble[self.indDataActive])**2)
        
        llr_num = np.exp((-abs(preambleDataSymbolsAfterEqualization.real - 1) ** 2) / noiseVarPost)
        llr_den = np.exp((-abs(preambleDataSymbolsAfterEqualization.real - -1) ** 2) / noiseVarPost)
        W = np.concatenate((llr_den.reshape([1,-1]),llr_num.reshape([1,-1])),axis=0)
        preambleMessage = self.polarCode.decode(W)

        bitsSign = preambleMessage[self.headerSignatureIndices]
        bitsNcodeword = preambleMessage[self.headerNcodewordIndices]

        bitsNprepad = preambleMessage[self.headerNprepadIndices]
        bitsNpostpad = preambleMessage[self.headerNpostpadIndices]

        bitsReserved = preambleMessage[self.headerReservedIndices]
        bitsCRC = preambleMessage[self.headerCRCIndices]

        headerBitsWithoutCRC = np.concatenate((bitsSign, bitsNcodeword, bitsNprepad, bitsNpostpad, bitsReserved))
        bitsCRCRX = calc_crc(headerBitsWithoutCRC)

        # Step 5 : Decode payload
        if all(bitsCRC == bitsCRCRX):
            isValid = int(1)
            reason = 'None'

            Ncodewords = bin2dec(preambleMessage[self.headerNcodewordIndices],0)
            Nprepad = bin2dec(preambleMessage[self.headerNprepadIndices],0)
            Npostpad = bin2dec(preambleMessage[self.headerNpostpadIndices],0)

            Nofdm = int(np.ceil(Ncodewords*self.codeWordLength/self.numberOfDataSubcarriers/self.bitsPerSymbol))
            NchestExtra = int(np.floor((Nofdm-1)/self.chestRefreshRate))
            S = Nofdm + NchestExtra
            indChest = np.arange(self.chestRefreshRate,S,self.chestRefreshRate+1,dtype=int)
            indData = np.arange(0,S,1,dtype=int)
            indData = np.delete(indData, indChest)

            if Nsync+(self.Nidft+self.Ncp)*3 + (self.Nidft+self.Ncp)*S>len(rCorrected):
                isValid = int(0)
                dataBits = np.nan
                reason = 'Not enough samples acquired based on the header info'
            elif Ncodewords == 0:
                isValid = int(0)
                dataBits = np.nan
                reason = 'Number of codewords cannot be zero'
            else:
                indices = np.arange(0,(self.Nidft+self.Ncp)*S,1, dtype=int)
                rOFDMwithCP = rCorrected[Nsync+(self.Nidft+self.Ncp)*3+indices]
                rOFDMwithCP = np.reshape(rOFDMwithCP,(-1,self.Nidft+self.Ncp))
                rOFDMwithoutCP = rOFDMwithCP[:,np.arange(self.Ncp,self.Nidft+self.Ncp)]
                symbolsWithoutEqualization = fft(rOFDMwithoutCP)/np.sqrt(self.Nidft)

                if NchestExtra > 0:
                    extraChestSymbols = symbolsWithoutEqualization[indChest,:]
                    HCFRextra = extraChestSymbols[:,self.indActiveSubcarriers]/self.chestSymbols
                    HCFRextra = HCFRextra.reshape([NchestExtra, len(self.indActiveSubcarriers)])
                    HCFRextraLast = HCFRextra[-1,:].reshape([1,len(self.indActiveSubcarriers)])
                    HCFRextraFirst = HCFRextra[:-1,:].reshape([NchestExtra-1,len(self.indActiveSubcarriers)])
                    HCFRpreamble = HCFRpreamble.reshape([1,len(self.indActiveSubcarriers)])
                    Nbegin = min(self.chestRefreshRate,Nofdm)
                    Nrem = S-NchestExtra*(self.chestRefreshRate+1);
                    HCFRall = np.concatenate((np.tile(HCFRpreamble,(Nbegin,1)), np.repeat(HCFRextraFirst,self.chestRefreshRate,axis=0), np.tile(HCFRextraLast,(Nrem,1))),0)
                else:
                    HCFRall = np.repeat(HCFRpreamble.reshape(1,-1),Nofdm,axis=0)
                            
                if enableDenoise:
                    hCIRall = ifft(HCFRall)
                    ind = np.abs(np.array(hCIRall))<levelDenoise*np.max((np.abs(hCIRall)))
                    hCIRall[ind]=0
                    HCFRall = fft(hCIRall)                       

                payloadSymbols = symbolsWithoutEqualization[np.ix_(indData,self.indActiveSubcarriers)];
                payloadSymbolsAfterEqualization = payloadSymbols*np.conjugate(HCFRall)/(np.abs(HCFRall)**2+1/SNR)

                cpe = np.mean(payloadSymbolsAfterEqualization[:,self.indTrackingActive]/self.trackingSymbols,axis=1)
                cpe = cpe/np.abs(cpe)

                payloadDataSymbolsAfterEqualization = payloadSymbolsAfterEqualization[:,self.indDataActive]
                payloadDataSymbolsAfterEqualization = payloadDataSymbolsAfterEqualization/cpe.reshape(-1,1)

                #Validate RX constellation after equalization
                if self.debugFlag == True:
                    plottingSymbols = np.resize(payloadDataSymbolsAfterEqualization,(1,np.size(payloadDataSymbolsAfterEqualization)))
                    if self.cntDecode == 0:
                        plt.ion()
                        self.figConstellationPayload = plt.figure(35)
                        ax = self.figConstellationPayload.add_subplot(111)
                        ax.grid()
                        ax.set_xlabel('Real')
                        ax.set_ylabel('Imaginary')
                        ax.set_title("RX Preamble Constellation After Channel Equalization ")
                        ax.set_ylim([-2,2])
                        ax.set_xlim([-2,2])
                        self.lineConstellationPayload, =ax.plot(plottingSymbols[0].real,plottingSymbols[0].imag, marker = 'x', ls = '')
                        ax.set_aspect('equal', adjustable='box')
                        self.figConstellationPayload.canvas.draw()
                        self.figConstellationPayload.canvas.flush_events()  
                        if sys.platform.startswith("win"):   
                            mngr = plt.get_current_fig_manager()
                            mngr.window.setGeometry(self.xPos+2*(self.dx+self.dxe), self.yPos+1*(self.dy+self.dye), self.dx, self.dy)     
                        ax.legend()  
                    else:
                        self.lineConstellationPayload.set_xdata(plottingSymbols[0].real)    
                        self.lineConstellationPayload.set_ydata(plottingSymbols[0].imag)    
                        self.figConstellationPayload.canvas.draw()
                        self.figConstellationPayload.canvas.flush_events()                              
            
                noiseVarPost = noiseVarEst/(noiseVarEst+np.abs(HCFRall[:,self.indDataActive])**2)
                HabsAverage = np.mean(np.abs(HCFRall[:,self.indDataActive]))

                if(self.modulationType == "BPSK"):
                    symbolMapping = {'0':-1,'1': 1}
                else:
                    temp = []
                    for i in range(0,self.bitsPerSymbol):
                        temp.append(rand.randint(0,1))
                    _, symbolMapping = QAM_modulation(temp, self.modulationOrder)

                #Reshape for likelihood function
                symbolsRX = np.reshape(payloadDataSymbolsAfterEqualization,(1,np.size(payloadDataSymbolsAfterEqualization)))
                symbolsRX = symbolsRX[0]

                noise = np.reshape(noiseVarPost,(1,np.size(noiseVarPost)))
                noise = noise[0]

                llr_num_temp, llr_den_temp = likelihood(symbolMapping, symbolsRX, noise)
                
                x = []
                y = []

                for i in range(0,int(len(llr_num_temp))):
                    for j in llr_num_temp[i]:
                        x.append(j)
                    for k in llr_den_temp[i]:
                        y.append(k)

                messageData = np.zeros([Ncodewords,self.messageLength]);

                llr_num = x[0:(len(x)-Npostpad)]
                llr_den = y[0:(len(y)-Npostpad)]

                llr_num = np.reshape(llr_num, (Ncodewords, self.codeWordLength))
                llr_den = np.reshape(llr_den, (Ncodewords, self.codeWordLength))

                for indCodeword in range(Ncodewords):
                    W = np.concatenate((llr_den[indCodeword].reshape([1,-1]),llr_num[indCodeword].reshape([1,-1])),axis=0)
                    message = self.polarCode.decode(W)
                    bitsCRC = message[self.headerCRCIndices]
                    bitsCRCRX = calc_crc(message[:-self.crcLength])
                    if all(bitsCRC == bitsCRCRX):
                        messageData[indCodeword] =  message[:-self.crcLength]
                    else:
                        reason = 'One of the codewords cannot be decoded'
                        isValid = int(0)
                        break

                if isValid == 1:
                    dataBits = messageData.reshape([1,-1])
                    dataBits = dataBits[0][:-Nprepad or None]
                    dataBits = list(map(int,dataBits))
                    #Unscramble bits
                    dataBits = np.array(bitScrambler(dataBits, self.firstSeed))
                else:
                    dataBits = np.nan
        else:
            reason = 'Invalid preamble'
            isValid = int(0)
            dataBits = np.nan
            Ncodewords = np.nan
            Nprepad = np.nan
            Npostpad = np.nan


        ppduInfo = {
                'isValid': isValid, 
                'reason': reason, 
                'fcfoEst': fcfoEst,
                'HabsAverage': HabsAverage,
                'noiseVarEst': noiseVarEst,
                'SNRdBEst': 10*np.log10(SNR),
                'dataBits': dataBits, 
                }

        self.cntDecode = self.cntDecode + 1
        return ppduInfo

class objCalibration(objDefinitions):
    def __init__(self,  **kwargs):
        objDefinitions.__init__(self)
        self.debugFlag = 0
        self.backOffPPDUdB_calibration = 3
        self.numberOfCalibrationSymbols = 6
        
        
        # Override defaults with provided keyword arguments
        # The provided dictionary is unpacked into kwargs when calling the constructor
        for key, value in kwargs.items():
            if hasattr(self, key):
                setattr(self, key, value)
            else:
                # Optional: handle extra keys if needed
                print(f"Warning: '{key}' is not a recognized attribute and will be ignored.")
        
        symbolsMapped = np.zeros((self.numberOfCalibrationSymbols,self.Nidft), dtype=complex)
        symbolsMapped[:,self.indSynchSubcarriers] = self.synchSymbols


        # The default normalization is "backward", i.e, the forward transform (FFT) is unscaled and the inverse transform (IFFT) is scaled by 1/N (the number of points).
        # By multiplying IFFT result by N/sqrt(Nactive), the mean power of the time domain signal is expected to be 1 (without any back off)
        
        ppdu = ifft(symbolsMapped,self.Nidft,1)*self.Nidft/np.sqrt(len(self.synchSymbols))
        ppdu = ppdu[:,np.arange(-self.Ncp,self.Nidft)]   
        ppdu = np.reshape(ppdu,(1,-1))*10**(-self.backOffPPDUdB_calibration/20)
        # np.mean(np.abs(ppdu[0])**2)
        if max(abs(ppdu[0].real)) > 1:
            print("Power backoff for calibration PPDU is not sufficient. Real part will be clipped. Ratio: " + str(sum(abs(ppdu[0].real)>1)/ppdu[0].size * 100) + "%")
            np.clip(ppdu.real, -1, 1, out=ppdu.real)
        if max(abs(ppdu[0].imag)) > 1:
            print("Power backoff for calibration PPDU is not sufficient. Imag part will be clipped. Ratio: " + str(sum(abs(ppdu[0].imag)>1)/ppdu[0].size * 100) + "%")
            np.clip(ppdu.imag, -1, 1, out=ppdu.imag)          
        
        self.preamble = np.reshape(ppdu,(1,-1))    
        self.preamble = self.preamble[:,np.arange(-self.Ncp,self.numberOfCalibrationSymbols*self.Nidft)]   

        self.lengthOfPreamble = self.preamble.size       

        if self.debugFlag:
            IQdataRX = np.zeros((self.lengthOfPreamble + (self.Nidft+self.Ncp)*2), dtype=complex)
            plt.ion()
            self.figTime = plt.figure(40)
            ax = self.figTime.add_subplot(111)
            ax.grid()
            t = np.linspace(0,  IQdataRX.size-1,  IQdataRX.size);#/self.fs*1e+6
            self.lineAbs, = ax.plot(t,abs(IQdataRX))
            ax.set_xlabel('Sample index')
            ax.set_ylabel('Magnitude')
            ax.set_ylim(0,2)
            ax.legend()
            if sys.platform.startswith("win"):
                mngr = plt.get_current_fig_manager()
                mngr.window.setGeometry(self.xPos, self.yPos, self.dx, self.dy)                  
            self.figTime.canvas.draw()
            self.figTime.canvas.flush_events()                 
    def encode(self):
        return self.preamble[0]        
    def decode(self, IQdataRX, fs, Npadding):
        if self.debugFlag:
            t = np.linspace(0,  IQdataRX.size-1,  IQdataRX.size);#/self.fs*1e+6
            self.lineAbs.set_data(t,np.abs(IQdataRX)) 
            self.figTime.axes[0].set_xlim(0, max(t))
            self.figTime.canvas.draw()
            self.figTime.canvas.flush_events() 

        P = np.zeros(self.numberOfCalibrationSymbols, dtype=complex)
        for indSym in np.arange(self.numberOfCalibrationSymbols):
            L = self.Nidft//2
            # Step 1: TO estimation
            Nchosen = self.Ncp + Npadding  + indSym*(self.Nidft) # Synch SDR enables time synch 

            # # Step 2: CFO estimation
            m = np.arange(0,L,1) #[0:L-1];
            P[indSym] = np.vdot(IQdataRX[Nchosen+m], IQdataRX[Nchosen+L+m])
        self.fcfoEst = np.angle(np.mean(P))/(2*pi*L)*fs

        return self.fcfoEst

class objSounding(objDefinitions):
    def __init__(self,  **kwargs):
        objDefinitions.__init__(self)
        self.numberOfRadios = 1
        self.debugFlag = 0
        self.backOffPPDUdB_sounding = 3
        
        # Override defaults with provided keyword arguments
        # The provided dictionary is unpacked into kwargs when calling the constructor
        for key, value in kwargs.items():
            if hasattr(self, key):
                setattr(self, key, value)
            else:
                # Optional: handle extra keys if needed
                print(f"Warning: '{key}' is not a recognized attribute and will be ignored.")
                 
        # Preamble
        symbolsMapped = np.zeros((1,self.Nidft), dtype=complex)
        symbolsMapped[0,self.indActiveSubcarriers] = self.chestSymbols                
        

        # The default normalization is "backward", i.e, the forward transform (FFT) is unscaled and the inverse transform (IFFT) is scaled by 1/N (the number of points).
        # By multiplying IFFT result by N/sqrt(Nactive), the mean power of the time domain signal is expected to be 1 (without any back off)
        self.numberOfRepeat = 4
        ppdu = ifft(symbolsMapped,self.Nidft,1)*self.Nidft/np.sqrt(len(self.indActiveSubcarriers))
        ppdu = np.hstack([ppdu[:,np.arange(-self.Ncp,0)], np.tile(ppdu,self.numberOfRepeat)]) 
        ppdu = np.reshape(ppdu,(1,-1))*10**(-self.backOffPPDUdB_sounding/20)
        if max(abs(ppdu[0].real)) > 1:
            print("Power backoff for sounding PPDU is not sufficient. Real part will be clipped. Ratio: " + str(sum(abs(ppdu[0].real)>1)/ppdu[0].size * 100) + "%")
            np.clip(ppdu.real, -1, 1, out=ppdu.real)
        if max(abs(ppdu[0].imag)) > 1:
            print("Power backoff for sounding PPDU is not sufficient. Imag part will be clipped. Ratio: " + str(sum(abs(ppdu[0].imag)>1)/ppdu[0].size * 100) + "%")
            np.clip(ppdu.imag, -1, 1, out=ppdu.imag)           
        self.preamble = np.reshape(ppdu,(1,-1))
        self.lengthOfPreamble = self.preamble.size       
        
        # IQdataRX = np.zeros((self.lengthOfPreamble + (self.Nidft+self.Ncp)*2*self.numberOfRadios), dtype=complex)

        # self.iqTime_x_data = np.arange(0, IQdataRX.size, dtype=float)
        # self.iqTime_y_data = np.zeros(IQdataRX.size, dtype=float)
        self.HCFR_x_data = np.repeat([np.arange(-self.Nidft/2,self.Nidft/2)], self.numberOfRadios, axis=0)
        self.HCFR_y_data = np.repeat([np.zeros((self.Nidft), dtype=float)], self.numberOfRadios, axis=0)
  

    def encode(self,indexWaveform):
        prePad = np.zeros((self.lengthOfPreamble*indexWaveform),dtype=complex)
        return np.hstack([prePad,self.preamble[0]])        
    def decode(self, IQdataRX, fs, Npadding):
        #  t = np.linspace(0,  IQdataRX.size-1,  IQdataRX.size);#/self.fs*1e+6
        # self.iqTime_x_data = np.arange(0,IQdataRX.size, dtype=float)
        # self.iqTime_y_data = np.abs(IQdataRX, dtype=float)

            
        if False:
            L = self.Nidft//2
            # Step 1: TO estimation
            Nchosen = self.Ncp+Npadding # Synch SDR enables time synch 

            # # Step 2: CFO estimation
            m = np.arange(0,L,1) #[0:L-1];
            P = np.vdot(IQdataRX[Nchosen+m], IQdataRX[Nchosen+L+m])
            fcfoEst = np.angle(P)/(2*pi*L)*fs
            if False:
                print(' > CFO...: ' + str(fcfoEst) + ' Hz'); 

            # Step 3: Estimate the channel
            # Nsync = Nchosen-self.Ncp
            # Nofdm = self.Nidft+self.Ncp
            # indices = np.arange(0,Nofdm,1, dtype=int)
            # rOFDMwithCP = IQdataRX[Nsync+(Nofdm)*1+indices]
        # Step 3: Estimate the channel
        Nsync = Npadding
        Nofdm = self.Nidft+self.Ncp
        Npreamble = self.numberOfRepeat*self.Nidft+self.Ncp
        indices = np.arange(0,Npreamble,1, dtype=int)

        self.fcfoEstAll = np.zeros(self.numberOfRadios, dtype=float)
        self.HCFRpreambleAll = np.zeros((self.numberOfRadios,self.Nidft), dtype=complex)
        self.HCFRpreamble = np.zeros((self.numberOfRadios,self.indActiveSubcarriers.size), dtype=complex)   
        for indED in range(self.numberOfRadios):
            rOFDMwithCP = IQdataRX[Nsync+indices]
            rOFDMwithCP = np.reshape(rOFDMwithCP,(-1,Npreamble))
            rOFDMwithoutCP = rOFDMwithCP[:,np.arange(self.Ncp,Npreamble)]   
            rOFDMwithoutCP = np.reshape(rOFDMwithoutCP,(-1,self.Nidft))
            P = np.zeros(self.numberOfRepeat-1, dtype=complex)
            for ind in range(self.numberOfRepeat-1):
                P[ind] = np.vdot(rOFDMwithoutCP[ind], rOFDMwithoutCP[ind+1])
            self.fcfoEstAll[indED] = np.angle(np.mean(P))/(2*pi*self.Nidft)*fs
            if False:
                print(' > CFO...: ' + str(fcfoEstAll[indED] ) + ' Hz');             

            rOFDMwithoutCP_corrected = (rOFDMwithoutCP.reshape(1,-1) * np.exp(-1j*2*pi*self.fcfoEstAll[indED] *np.arange(0,self.Nidft*self.numberOfRepeat,1)/fs)).reshape(-1,self.Nidft)

            symbolsFreq = np.mean(fft(rOFDMwithoutCP_corrected)/np.sqrt(self.Nidft), axis=0).reshape(1,-1)
            self.HCFRpreamble[indED,:] = symbolsFreq[0,self.indActiveSubcarriers]/self.chestSymbols
            self.HCFRpreambleAll[indED,self.indActiveSubcarriers] = self.HCFRpreamble[indED,:]
            Nsync = Nsync + Npreamble

            magnitudeSubcarriers = np.zeros((self.Nidft), dtype=float)
            magnitudeSubcarriers[self.indActiveSubcarriers] = np.abs(self.HCFRpreamble[indED,:] )
            
            self.HCFR_y_data[indED] = np.fft.fftshift(magnitudeSubcarriers)

        return self.HCFRpreamble, self.HCFRpreambleAll, self.fcfoEstAll

#############################
#############################
#############################
#############################
    
class objOAC(objDefinitions):
    def __init__(self, **kwargs):
        objDefinitions.__init__(self)
        
        # Default parameters for OAC
        self.numberOfRadios = 1
        self.OACmethod = 'directMapping'
        self.OACscalar = 1
        self.numberOfParameters = 8     
        self.virtualID = 0
        self.debugFlag = 1
        self.OACsymbolLength = 4 
        self.OACnumberOfDigits = 1 
        self.backOffPPDUdB_OAC = 8 # in dB
        self.isEncoder = False # in dB
        
        # Override defaults with provided keyword arguments
        # The provided dictionary is unpacked into kwargs when calling the constructor
        for key, value in kwargs.items():
            if hasattr(self, key):
                setattr(self, key, value)
            else:
                # Optional: handle extra keys if needed
                print(f"Warning: '{key}' is not a recognized attribute and will be ignored.")
        
        self.useScrambler = 1
        self.NdftPrecoderOAC = int(32)
        self.NidftOAC= int(256)
        self.NcpOAC= int(64)
        self.NdcLeftOAC = int(0)
        self.NdcRightOAC = int(0)

        self.enableCenterOAC = 0
        self.NactiveLeftOAC = int(self.NdftPrecoderOAC/2)
        self.NactiveRightOAC = int(self.NdftPrecoderOAC/2)
        
        self.indLeftActiveSubcarriersOAC = np.arange(-self.NactiveLeftOAC,0,1)-self.NdcLeftOAC % self.NidftOAC
        if self.enableCenterOAC == 1:
            self.indRightActiveSubcarriersOAC = self.NdcRightOAC+1+np.arange(0,self.NactiveRightOAC,1) % self.NidftOAC
        else:
            self.indRightActiveSubcarriersOAC = self.NdcRightOAC+np.arange(0,self.NactiveRightOAC,1) % self.NidftOAC
            
        self.indActiveSubcarriersOAC = np.concatenate((self.indLeftActiveSubcarriersOAC, self.indRightActiveSubcarriersOAC))
        self.indDataSubcarriersOAC = self.indActiveSubcarriersOAC
        
        self.Ga = -np.array([1 + 0j,0 - 1j,1 + 0j,1 + 0j,1 + 0j,-1 + 0j,-1 + 0j,0 + 1j,-1 + 0j,-1 + 0j,-1 + 0j,1 + 0j,-1 + 0j,0 + 1j,-1 + 0j,-1 + 0j,-1 + 0j,1 + 0j,-1 + 0j,0 + 1j,-1 + 0j,-1 + 0j,-1 + 0j,1 + 0j,-1 + 0j,0 + 1j,-1 + 0j,1 + 0j,1 + 0j,-1 + 0j,-1 + 0j,0 + 1j,-1 + 0j,1 + 0j,1 + 0j,-1 + 0j,1 + 0j,0 - 1j,1 + 0j,-1 + 0j,-1 + 0j,1 + 0j,-1 + 0j,0 + 1j,-1 + 0j,1 + 0j,1 + 0j,-1 + 0j,-1 + 0j,0 + 1j,-1 + 0j,-1 + 0j,-1 + 0j,1 + 0j,1 + 0j,0 - 1j,1 + 0j,1 + 0j,1 + 0j,-1 + 0j,-1 + 0j,0 + 1j,-1 + 0j,-1 + 0j,-1 + 0j,1 + 0j,-1 + 0j,0 + 1j,-1 + 0j,-1 + 0j,-1 + 0j,1 + 0j,1 + 0j,0 - 1j,1 + 0j,-1 + 0j,-1 + 0j,1 + 0j,1 + 0j,0 - 1j,1 + 0j,-1 + 0j,-1 + 0j,1 + 0j,1 + 0j,0 - 1j,1 + 0j,-1 + 0j,-1 + 0j,1 + 0j,-1 + 0j,0 + 1j,-1 + 0j,1 + 0j,1 + 0j,-1 + 0j])
        self.Gb = np.array([-1 + 0j,0 + 1j,-1 + 0j,-1 + 0j,-1 + 0j,1 + 0j,1 + 0j,0 - 1j,1 + 0j,1 + 0j,1 + 0j,-1 + 0j,1 + 0j,0 - 1j,1 + 0j,1 + 0j,1 + 0j,-1 + 0j,1 + 0j,0 - 1j,1 + 0j,1 + 0j,1 + 0j,-1 + 0j,1 + 0j,0 - 1j,1 + 0j,-1 + 0j,-1 + 0j,1 + 0j,1 + 0j,0 - 1j,1 + 0j,-1 + 0j,-1 + 0j,1 + 0j,-1 + 0j,0 + 1j,-1 + 0j,1 + 0j,1 + 0j,-1 + 0j,1 + 0j,0 - 1j,1 + 0j,-1 + 0j,-1 + 0j,1 + 0j,-1 + 0j,0 + 1j,-1 + 0j,-1 + 0j,-1 + 0j,1 + 0j,1 + 0j,0 - 1j,1 + 0j,1 + 0j,1 + 0j,-1 + 0j,-1 + 0j,0 + 1j,-1 + 0j,-1 + 0j,-1 + 0j,1 + 0j,-1 + 0j,0 + 1j,-1 + 0j,-1 + 0j,-1 + 0j,1 + 0j,1 + 0j,0 - 1j,1 + 0j,-1 + 0j,-1 + 0j,1 + 0j,1 + 0j,0 - 1j,1 + 0j,-1 + 0j,-1 + 0j,1 + 0j,1 + 0j,0 - 1j,1 + 0j,-1 + 0j,-1 + 0j,1 + 0j,-1 + 0j,0 + 1j,-1 + 0j,1 + 0j,1 + 0j,-1 + 0j])
        self.chestSymbols = np.concatenate((self.Ga[np.arange(0,self.NactiveLeftOAC,1)], self.Gb[np.arange(0,self.NactiveRightOAC,1)]))#/np.sqrt(self.numberOfRadios)      
        self.scrambleSymbolsOAC = np.concatenate((self.Ga[np.arange(0,self.NactiveLeftOAC,1)], self.Gb[np.arange(0,self.NactiveRightOAC,1)]))      

        if self.OACmethod == 'directMapping': # Direct - coherent
            self.resourcesPerParameter = 1
        elif self.OACmethod == 'directSignMapping': # Sign of data - coherent
            self.resourcesPerParameter = 1
        elif self.OACmethod == 'signedBasedTBMA': # Sign of data
            self.resourcesPerParameter = 2
        elif self.OACmethod == 'multiDimOAC': # Multi-dimensional OAC symbols - coherent
            self.resourcesPerParameter = self.OACsymbolLength
            self.betaVector = np.array([1, 1j])
            self.OACconstellation = np.kron(np.eye(self.OACsymbolLength),self.betaVector)  
            mu = np.sum(self.betaVector,axis=0)/(self.OACsymbolLength*self.OACnumberOfDigits)
            alpha = np.sqrt((self.OACsymbolLength-1)*abs(mu)**2 + 1/self.OACnumberOfDigits*np.sum(np.abs(self.betaVector-mu)**2))
            self.OACconstellation = np.sqrt(self.OACsymbolLength)*(self.OACconstellation-mu)/alpha
            self.OACconstellation = np.transpose(self.OACconstellation)
            if self.isEncoder:
                self.M = self.fcn_enumerate(self.numberOfRadios,self.OACsymbolLength*self.OACnumberOfDigits)
                self.OACsuperpose = self.M @ self.OACconstellation[:self.OACsymbolLength*self.OACnumberOfDigits,:]
                self.OACsuperposeVals = self.M @ np.arange(self.OACsymbolLength*self.OACnumberOfDigits)

        self.numberOfOACOFDMsymbols = int(np.ceil(self.numberOfParameters*self.resourcesPerParameter/len(self.indActiveSubcarriersOAC)))      

        self.HCFR_x_data = np.repeat([np.arange(-self.Nidft/2,self.Nidft/2)], self.numberOfRadios, axis=0)
        self.HCFR_y_data = np.repeat([np.zeros((self.Nidft), dtype=float)], self.numberOfRadios, axis=0)
        
        if self.debugFlag:
            plt.ion()
            self.figTime = plt.figure(30)
            ax = self.figTime.add_subplot(311)
            ax.grid()
            ax.set_ylim(0,1.2)
            ax.set_xlabel('Sample index')
            ax.set_ylabel('Magnitude')                

            ax2 = self.figTime.add_subplot(312)
            ax2.grid()
            ax2.set_ylim(-1.2,1.2)
            ax2.set_xlabel('Sample index')
            ax2.set_ylabel('Amplitude')                
            
            ax3 = self.figTime.add_subplot(313)
            ax3.grid()
            ax3.set_ylim(-1.2,1.2)
            ax3.set_xlabel('Sample index')
            ax3.set_ylabel('Amplitude')                           

            IQdataRX = np.zeros(1000,dtype=complex)
            t = np.linspace(0,  IQdataRX.size-1,  IQdataRX.size);#/self.fs*1e+6
            self.lineAbs, = ax.plot(t,abs(IQdataRX), label='ABS')
            self.lineReal, = ax2.plot(t,IQdataRX.real, 'r-' ,label='I')
            self.lineImag, = ax3.plot(t,IQdataRX.imag, 'g-', label='Q')
            ax.legend()
            ax2.legend()
            ax3.legend()
            if sys.platform.startswith("win"):
                mngr = plt.get_current_fig_manager()
                mngr.window.setGeometry(self.xPos, self.yPos, self.dx, self.dy)  
            self.figTime.canvas.draw()
            self.figTime.canvas.flush_events()                                

            subcarrierIndices = np.arange(-self.NidftOAC/2,self.NidftOAC/2)
            magnitudeSubcarriers = np.zeros((self.numberOfRadios+self.numberOfOACOFDMsymbols,self.NidftOAC), dtype=complex)
            angleSubcarriers = np.zeros((self.numberOfRadios+self.numberOfOACOFDMsymbols,self.NidftOAC), dtype=complex)
            symbolsOAC = np.zeros(self.numberOfOACOFDMsymbols*len(self.indActiveSubcarriersOAC), dtype=complex)
               

            self.figFreq = plt.figure(33)
            ax = self.figFreq.add_subplot(211)
            ax.set_ylim(0,2)
            ax.set_xlim(-self.NidftOAC/2,self.NidftOAC/2-1)
            ax.set_xlabel('Subcarrier indices')
            ax.set_ylabel('Magnitude')
            ax.grid()
            ax2 = self.figFreq.add_subplot(212)
            ax2.set_xlabel('Subcarrier indices')
            ax2.set_ylabel('Phase')
            ax2.grid()
            ax2.set_ylim(-200,200)
            ax2.set_xlim(-self.NidftOAC/2,self.NidftOAC/2-1)  
            self.lineCFRabsOAC = []
            self.lineCFRangleOAC = []
            for indED in range(self.numberOfRadios):
                hAbs, = ax.plot(subcarrierIndices,np.fft.fftshift(magnitudeSubcarriers[indED,:].real),  label=['ED #' + str(indED)]) # Returns a tuple of line objects, thus the comma
                hAngle, = ax2.plot(subcarrierIndices,np.fft.fftshift(angleSubcarriers[indED,:].real),  label=['ED #' + str(indED)]) # Returns a tuple of line objects, thus the comma      
                self.lineCFRabsOAC.append(hAbs)
                self.lineCFRangleOAC.append(hAngle)
            ax.legend(loc='upper right')
            ax2.legend(loc='upper right')
            if sys.platform.startswith("win"):
                mngr = plt.get_current_fig_manager()
                mngr.window.setGeometry(self.xPos, self.yPos+self.dy+self.dye, self.dx, self.dy)         
            self.figFreq.canvas.draw()
            self.figFreq.canvas.flush_events()  
    def encode(self, data, dataWeight = 1):
        msg = ''
        if self.OACmethod == 'directMapping': # Direct - coherent
            oacSymbols  = dataWeight*data*self.OACscalar  # coherent aggregation scales with K  
              
            NoacPadding = int(self.numberOfOACOFDMsymbols*self.indDataSubcarriersOAC.size/self.resourcesPerParameter - len(oacSymbols))                
            oacSymbolsShaped = np.reshape(np.concatenate((oacSymbols, np.zeros(NoacPadding))),(self.numberOfOACOFDMsymbols,-1))       

        elif self.OACmethod == 'directSignMapping': # Sign of data - coherent
            oacSymbols  = np.sign(data)
            oacSymbols[oacSymbols==0] = 2*np.random.randint(0,2,np.sum(oacSymbols==0))-1 # randomize zeros to -1 or 1
            oacSymbols  = dataWeight*oacSymbols*self.OACscalar  # coherent aggregation scales with K   
                  
            NoacPadding = int(self.numberOfOACOFDMsymbols*self.indDataSubcarriersOAC.size/self.resourcesPerParameter - len(oacSymbols))                
            oacSymbolsShaped = np.reshape(np.concatenate((oacSymbols, np.zeros(NoacPadding))),(self.numberOfOACOFDMsymbols,-1)) 
                  
        elif self.OACmethod == 'signedBasedTBMA': # Sign of data - non-coherent
            indices = np.abs(data)<0.005 # with absentees
            dataSign = np.sign(data)
            dataSign[indices] = 0
            oacSymbols = np.zeros((len(data),2))
            oacSymbols[dataSign == int(-1),0]= np.sqrt(2)
            oacSymbols[dataSign == int(1),1] = np.sqrt(2)
            oacSymbols  = oacSymbols*self.OACscalar  # coherent aggregation scales with K
          
            NoacPadding = int(self.numberOfOACOFDMsymbols*self.indDataSubcarriersOAC.size/self.resourcesPerParameter - len(oacSymbols))                
            oacSymbolsShaped = np.reshape( np.concatenate((oacSymbols.reshape(-1), np.zeros(NoacPadding)  ))   ,(self.numberOfOACOFDMsymbols,-1))      
        elif self.OACmethod == 'multiDimOAC': # Multi-dimensional OAC symbols - coherent
            indices = np.abs(data)# with absentees
            oacSymbols  = self.OACconstellation[indices,:]*self.OACscalar  # coherent aggregation scales with K
          
            NoacPadding = int(self.numberOfOACOFDMsymbols*self.indDataSubcarriersOAC.size/self.resourcesPerParameter - len(oacSymbols))                
            oacSymbolsShaped = np.reshape( np.concatenate((oacSymbols.reshape(-1), np.zeros(NoacPadding)  ))   ,(self.numberOfOACOFDMsymbols,-1))               
             
        
        symbolsMapped = np.zeros((self.numberOfOACOFDMsymbols+self.numberOfRadios,self.NidftOAC), dtype=complex)
        indData = np.arange(0,self.numberOfOACOFDMsymbols,1,dtype=int)
        symbolsMapped[self.virtualID,self.indActiveSubcarriersOAC] = self.chestSymbols # CHEST symbols

        if self.useScrambler == 1: 
            oacSymbolsShaped = oacSymbolsShaped*self.scrambleSymbolsOAC
            
        symbolsMapped[np.ix_(self.numberOfRadios+indData,self.indDataSubcarriersOAC)] = fft(oacSymbolsShaped,self.NdftPrecoderOAC)/np.sqrt(self.NdftPrecoderOAC) # oac symbols
    
        ppdu = ifft(symbolsMapped,self.NidftOAC,1)*self.NidftOAC/np.sqrt(len(self.indDataSubcarriersOAC)) # mean power is set to 1
        ppdu = ppdu[:,np.arange(-self.NcpOAC,self.NidftOAC)]   
        ppdu = np.reshape(ppdu,(1,-1))*10**(-self.backOffPPDUdB_OAC/20)
        if max(abs(ppdu[0].real)) > 1:
            msg = "Power backoff for OAC PPDU is not sufficient. Real part will be clipped. Ratio: " + str(sum(abs(ppdu[0].real)>1)/ppdu[0].size * 100) + "%"
            np.clip(ppdu.real, -1, 1, out=ppdu.real)
        if max(abs(ppdu[0].imag)) > 1:
            msg = "Power backoff for OAC PPDU is not sufficient. Imag part will be clipped. Ratio: " + str(sum(abs(ppdu[0].imag)>1)/ppdu[0].size * 100) + "%"
            np.clip(ppdu.imag, -1, 1, out=ppdu.imag)
        return ppdu[0], msg
    def decode(self, IQdataRX, Nsync):
        t = np.linspace(0,  IQdataRX.size-1,  IQdataRX.size);#/self.fs*1e+6

        
        if self.debugFlag:
            t = np.linspace(0,  IQdataRX.size-1,  IQdataRX.size);#/self.fs*1e+6
            self.lineAbs.set_data(t,np.abs(IQdataRX)) 
            self.lineReal.set_data(t,IQdataRX.real) 
            self.lineImag.set_data(t,IQdataRX.imag) 
            self.figTime.canvas.draw()
            self.figTime.canvas.flush_events()     
            self.figTime.axes[0].set_xlim(0, max(t))
            self.figTime.axes[1].set_xlim(0, max(t))
            self.figTime.axes[2].set_xlim(0, max(t))
            
        if False:
            IQdataRX = IQdataRX - np.mean(IQdataRX)

        Nofdm = self.NidftOAC+self.NcpOAC
        indices = np.arange(0,Nofdm*(self.numberOfOACOFDMsymbols + self.numberOfRadios), 1, dtype=int)
        rOFDMwithCP = IQdataRX[Nsync+indices]
        rOFDMwithCP = np.reshape(rOFDMwithCP,(-1,Nofdm))
        rOFDMwithoutCP = rOFDMwithCP[:,np.arange(self.NcpOAC,Nofdm)]
        symbolsFreq = fft(rOFDMwithoutCP)/np.sqrt(self.NidftOAC)
        
       
        
        H_eds = np.zeros((self.numberOfRadios), dtype=complex)
        for indED in range(self.numberOfRadios):
            magnitudeSubcarriers = np.zeros((self.Nidft), dtype=float)
            magnitudeSubcarriers[self.indActiveSubcarriersOAC] = np.abs(symbolsFreq[indED,self.indActiveSubcarriersOAC]/self.chestSymbols)
            self.HCFR_y_data[indED] = np.fft.fftshift(magnitudeSubcarriers)
            H_eds[indED] = (np.mean(symbolsFreq[indED,self.indActiveSubcarriersOAC]/self.chestSymbols))
            
         

        # SNR = 2000
        # Haggregated = symbolsFreq[0,self.indActiveSubcarriersOAC]/self.chestSymbols
        # if False:
        #     symbolsFreq[np.ix_(1+indData,self.indActiveSubcarriersOAC)] = (symbolsFreq[np.ix_(1+indData,self.indActiveSubcarriersOAC)]*np.conjugate(Haggregated)/(np.abs(Haggregated)**2+1/SNR))
        # else:
        #     symbolsFreq[np.ix_(1+indData,self.indActiveSubcarriersOAC)] = (symbolsFreq[np.ix_(1+indData,self.indActiveSubcarriersOAC)]*Haggregated.real/(Haggregated.real**2+1/SNR))
        
        
        indData = self.numberOfRadios + np.arange(0,self.numberOfOACOFDMsymbols,1,dtype=int)
        symbolsOAC = ifft(symbolsFreq[np.ix_(indData,self.indActiveSubcarriersOAC)],self.NdftPrecoderOAC)*np.sqrt(self.NdftPrecoderOAC)

        
        if self.useScrambler == 1: 

            symbolsOAC = symbolsOAC/self.scrambleSymbolsOAC
        

   
        
        # symbolsOAC  = symbolsOAC*np.sqrt(self.numberOfRadios)           
        symbolsOAC = symbolsOAC.reshape(-1)
        symbolsOAC = symbolsOAC[np.arange(0,self.numberOfParameters*self.resourcesPerParameter,1,dtype=int)]

        if self.OACmethod == 'directMapping':
            symbolsOACdecode = symbolsOAC.real/self.OACscalar
        elif self.OACmethod == 'directSignMapping': 
            symbolsOACdecode = symbolsOAC.real/self.OACscalar
        elif self.OACmethod == 'signedBasedTBMA':
            symbolsOACdecode = np.zeros(self.numberOfParameters, dtype=float)
            votePlus = np.abs(symbolsOAC[range(1,len(symbolsOAC),2)])
            voteMinus = np.abs(symbolsOAC[range(0,len(symbolsOAC),2)])
            symbolsOACdecode[votePlus > voteMinus] = 1
            symbolsOACdecode[votePlus < voteMinus] = -1
        elif self.OACmethod == 'multiDimOAC': # Multi-dimensional OAC symbols - coherent
            H_mean = np.mean(H_eds);           
            symbolsOAC = symbolsOAC/ H_mean/self.OACscalar             
            categories = np.zeros(self.numberOfParameters, dtype=int)
            for indParam in range(self.numberOfParameters):
                symbolReceived = symbolsOAC[indParam*self.resourcesPerParameter:(indParam+1)*self.resourcesPerParameter]
                distances = np.sum(np.abs(symbolReceived - self.OACsuperpose)**2,axis=1)
                categories[indParam] = np.argmin(distances)
            symbolsOACdecode = self.OACsuperposeVals[categories]

        if self.debugFlag:
            magnitudeSubcarriers = np.zeros((self.numberOfRadios+self.numberOfOACOFDMsymbols,self.NidftOAC), dtype=complex)
            magnitudeSubcarriers[:,self.indActiveSubcarriersOAC] = np.abs(symbolsFreq[:,self.indActiveSubcarriersOAC] )
            angleSubcarriers = np.zeros((self.numberOfRadios+self.numberOfOACOFDMsymbols,self.NidftOAC), dtype=complex)
            angleSubcarriers[:,self.indActiveSubcarriersOAC] = np.angle(symbolsFreq[:,self.indActiveSubcarriersOAC])/(2*np.pi)*360
  
            #if symbolsOAC.size == self.lineConstellation._x.size:
            # self.lineConstellation.set_xdata(symbolsOAC.real) 
            # self.lineConstellation.set_ydata(symbolsOAC.imag) 
            # self.lineConstellationReal.set_xdata(symbolsOAC.real)
                
                # frequency, bins = np.histogram(symbolsOAC.real,  bins=self.bins, range=self.range)
                # for i, bar in enumerate(self.figHistogramReal):
                #     bar.set_height(frequency[i]/np.max(frequency))


            for indED in range(self.numberOfRadios):
                self.lineCFRabsOAC[indED].set_ydata(np.fft.fftshift(magnitudeSubcarriers[indED,:].real)) 
                if magnitudeSubcarriers[indED,:].max() > 0.1:
                    self.lineCFRangleOAC[indED].set_ydata(np.fft.fftshift(angleSubcarriers[indED,:].real))    
                else:
                    self.lineCFRangleOAC[indED].set_ydata(np.zeros(len(angleSubcarriers[indED,:].real)))  
                            
            # self.figConstellation.canvas.draw()
            # self.figConstellation.canvas.flush_events() 
            # self.figConstellationReal.canvas.draw()
            # self.figConstellationReal.canvas.flush_events() 
            self.figFreq.canvas.draw()
            self.figFreq.canvas.flush_events() 
    

        return symbolsOACdecode, H_eds
    def fcn_enumerate(self, K, Q):
        if Q == 1:
            return [[K]]
        else:
            M = []
            for K1 in range(K + 1):
                listB = self.fcn_enumerate(K - K1, Q - 1)
                
                # Equivalent of [repmat(K1, size(listB,1), 1) listB]
                combined = [[K1] + row for row in listB]
                
                # Equivalent of stacking on top: [combined; M]
                M = combined + M
            
            return M
