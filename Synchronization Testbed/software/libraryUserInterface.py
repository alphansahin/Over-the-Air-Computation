import paramiko
import numpy as np
import debugpy
from libraryProtocol import *
from libraryUtility import *
from PyQt5 import QtCore
from PyQt5.QtWidgets import QApplication, QWidget, QMainWindow, QPushButton,  QWidget, QGridLayout, QSlider, QLabel, QHBoxLayout, QLineEdit, QStatusBar, QTabWidget, QVBoxLayout
import pyqtgraph as pg
from datetime import datetime
import ast
from threading import Thread, Event


# ---------------------------
# User Interface
# ---------------------------
class objUserInterface(QtCore.QObject):
    signal_I2W_executeLocalTask = QtCore.pyqtSignal(str, dict)
    signal_I2W_executeNetworkTask = QtCore.pyqtSignal(str, dict, int)
    signal_I2W_executeProtocol = QtCore.pyqtSignal(str)
    def __init__(self,  parent: QtCore.QObject | None = None, **kwargs):
        # Parsing
        self.nodeID = 0
        self.virtualID = 0
        self.nodeRole = "none"
        self.isSDRavailable = 0
        self.isNetworkAvailable = 0
        self.hostKeysPath = ""
        self.signatureInputForSaving = "none"
        self.localPort = "none"
        self.usernameSSH = "none"
        self.passwordSSH = "none"
        
        overwriteParameters(self, **kwargs)
        
        
        super().__init__(parent)

        parametersWorker = dict([
            ('nodeID', self.nodeID), 
            ('virtualID', self.virtualID),
            ('nodeRole', self.nodeRole),            
            ('isSDRavailable', self.isSDRavailable), 
            ('hostKeysPath', self.hostKeysPath), 
            ('signatureInputForSaving', self.signatureInputForSaving),             
            ('localPort', self.localPort), 
            ('usernameSSH', self.usernameSSH), 
            ('passwordSSH', self.passwordSSH),
        ])
        self.worker = objUserInterface_worker(**parametersWorker)
        
        self.numberOfEDs = self.worker.myProtocol.numberOfEDs
        self.txAttnSliderfactor = int(1/self.worker.myProtocol.resAttnTX)
        self.rxGainSliderfactor = int(1/self.worker.myProtocol.resGainRX)           
        self.allowSendingTask = True
        
        self.worker.signal_W2I_figIQDataTX.connect(self.figIQDataTX_newData)
        self.worker.signal_W2I_figIQDataRX.connect(self.figIQDataRX_newData)
        self.worker.signal_W2I_figSounding.connect(self.figSounding_newData)
        self.worker.signal_W2I_figOAC.connect(self.figOAC_newData)
        self.worker.signal_W2I_resultsFromNetwork.connect(self.updateNetworkResults)
        self.worker.signal_W2I_resultsFromLocal.connect(self.updateLocalResults)

         
        self.signal_I2W_executeLocalTask.connect(self.worker.run_localTask)
        self.signal_I2W_executeNetworkTask.connect(self.worker.run_networkTask)
        self.signal_I2W_executeProtocol.connect(self.worker.run_protocol)
        self.resultsFromNetwork = None
        self.resultsFromLocal = None
        
        self.slider_style = """
                            QSlider::horizontal {
                                min-height: 12px; /* Overall thickness of the slider area */
                            }
                            QSlider::groove:horizontal {
                                height: 4px; /* Thickness of the track itself */
                                background: #cccccc; 
                            }
                            QSlider::handle:horizontal {
                                background: #2196F3;
                                width: 10px;
                                height: 10px;
                                margin: -6px 0; /* Centers the handle over the thinner groove */
                                border-radius: 4px;
                            }
                            """      
        
        self.build_windows()
        
        self.worker.start()
        
    def build_resultsWindow(self):
        self.tabsResults = QTabWidget()
        self.tabSounding = QWidget()
        edData_layout = QGridLayout()
        
        factor1 = int(np.sqrt(self.numberOfEDs))
        while self.numberOfEDs % factor1 != 0:
            factor1 -= 1
        factor2 = self.numberOfEDs // factor1        
        self.rows = factor1 
        self.cols = factor2            
        
        self.plotsSounding = []
        self.curvesSounding = []   
        self.curvesOACSounding = []  
        self.feedbackTXincLabels = []   
        self.feedbackCFOLabels = []   

        for r in range(self.rows):
            for c in range(self.cols):

                
                plotFreq = pg.PlotWidget()
                plotFreq.setLabel("left", 'Magnitude')
                plotFreq.setLabel("bottom", "Subcarrier indices")
                plotFreq.setTitle('ED'+ str(r*self.cols+c), color='k', size='10pt')
                plotFreq.setBackground("w")
                plotFreq.setYRange(*(0,.5))
                plotFreq.showGrid(x=True, y=True, alpha=0.3)
                curve = plotFreq.plot([], [], pen=pg.mkPen(color='b', width=2))
                curveOAC = plotFreq.plot([], [], pen=pg.mkPen(color='r', width=2))

                feedbackTXincLabel = QLabel("TX Power Inc: N/A")
                feedbackCFOLabel = QLabel("CFO: N/A")
                
                self.feedbackTXincLabels.append(feedbackTXincLabel)
                self.feedbackCFOLabels.append(feedbackCFOLabel)
                self.plotsSounding.append(plotFreq)
                self.curvesSounding.append(curve)  
                self.curvesOACSounding.append(curveOAC)  

                numberOfRowsPerED = 3
                edData_layout.addWidget(plotFreq, numberOfRowsPerED*r, c)
                edData_layout.addWidget(feedbackTXincLabel, numberOfRowsPerED*r+1, c)  # place the label below the plot 
                edData_layout.addWidget(feedbackCFOLabel, numberOfRowsPerED*r+2, c)  # place the label below the plot 


        self.tabSounding.setLayout(edData_layout)
        self.tabsResults.addTab(self.tabSounding, "Sounding Results")            
    def build_edParametersWindow(self):
        self.tabsEDParameters = QTabWidget()
        
        self.tabTXRXParameters = QWidget()
        edParameters_layout = QGridLayout()
        
       
        self.txAttnLabelEDs = {}
        self.txAttnLabelEDs_current = {}
        self.txAttnSliderEDs = {}
        
        self.rxGainLabelEDs = {}
        self.rxGainLabelEDs_current = {}    
        self.rxGainSlidersEDs = {}  
        
        self.timer1ed_label = {}
        self.timer1ed_current = {}              
        self.timer2ed_label = {}
        self.timer2ed_current = {}              
        self.timer3ed_label = {}
        self.timer3ed_current = {}              
        self.timer4ed_label = {}
        self.timer4ed_current = {}              
              
        
              
        for indED in range(self.numberOfEDs):

            ########################### TX attenuation & RX gain sliders  ###########################
            self.txAttnLabelEDs[indED] = QLabel(f"ED{indED}: TX Attn [0-40 dB]:")            
            self.txAttnLabelEDs_current[indED] = QLabel("(N/A dB)")            
            self.txAttnSliderEDs[indED] = QSlider(QtCore.Qt.Orientation.Horizontal)
            self.txAttnSliderEDs[indED].setRange(0, 40*self.txAttnSliderfactor)
            self.txAttnSliderEDs[indED].setValue(15*self.txAttnSliderfactor)  # Set initial value
            self.txAttnSliderEDs[indED].valueChanged.connect(lambda value, ind=indED: self.on_txAttnSliderEDs_changed(ind))
            self.txAttnSliderEDs[indED].setStyleSheet(self.slider_style)

            attnSlidersEDs_layout = QHBoxLayout()
            attnSlidersEDs_layout.addWidget(self.txAttnLabelEDs[indED])
            attnSlidersEDs_layout.addWidget(self.txAttnLabelEDs_current[indED])
            attnSlidersEDs_layout.addWidget(self.txAttnSliderEDs[indED])
            attnSlidersEDs_layout.setStretch(2, 1) 

            self.rxGainLabelEDs[indED] = QLabel(f"ED{indED}: RX Gain [0-70 dB]:")
            self.rxGainLabelEDs_current[indED] = QLabel("(N/A dB)")
            self.rxGainSlidersEDs[indED] = QSlider(QtCore.Qt.Orientation.Horizontal)
            self.rxGainSlidersEDs[indED].setRange(0, 70*self.rxGainSliderfactor)
            self.rxGainSlidersEDs[indED].setValue(45*self.rxGainSliderfactor)  # Set initial value
            self.rxGainSlidersEDs[indED].valueChanged.connect(lambda value, ind=indED: self.on_rxGainSliderEDs_changed(ind))
            self.rxGainSlidersEDs[indED].setStyleSheet(self.slider_style)
            
            gainSlidersEDs_layout = QHBoxLayout()
            gainSlidersEDs_layout.addWidget(self.rxGainLabelEDs[indED])
            gainSlidersEDs_layout.addWidget(self.rxGainLabelEDs_current[indED])
            gainSlidersEDs_layout.addWidget(self.rxGainSlidersEDs[indED])
            gainSlidersEDs_layout.setStretch(2, 1) 
                        
            self.timer1ed_label[indED] = QLabel("T1:")
            self.timer2ed_label[indED] = QLabel("T2:")
            self.timer3ed_label[indED] = QLabel("T3:")
            self.timer4ed_label[indED] = QLabel("T4:")
            self.timer1ed_current[indED] = QLabel("N/A")
            self.timer2ed_current[indED] = QLabel("N/A")
            self.timer3ed_current[indED] = QLabel("N/A")
            self.timer4ed_current[indED] = QLabel("N/A")   
            
            timerEDs_layout = QHBoxLayout() 
            timerEDs_layout.addWidget(self.timer1ed_label[indED]   )
            timerEDs_layout.addWidget(self.timer1ed_current[indED] ) 
            timerEDs_layout.addWidget(self.timer2ed_label[indED]   )
            timerEDs_layout.addWidget(self.timer2ed_current[indED] ) 
            timerEDs_layout.addWidget(self.timer3ed_label[indED]   )
            timerEDs_layout.addWidget(self.timer3ed_current[indED] ) 
            timerEDs_layout.addWidget(self.timer4ed_label[indED]   )
            timerEDs_layout.addWidget(self.timer4ed_current[indED] ) 
            

            edParameters_layout.addLayout(attnSlidersEDs_layout, indED, 0)   
            edParameters_layout.addLayout(gainSlidersEDs_layout, indED, 1)                             
            edParameters_layout.addLayout(timerEDs_layout, indED, 2)                             
            edParameters_layout.setColumnStretch(0, 2)
            edParameters_layout.setColumnStretch(1, 2)
            edParameters_layout.setColumnStretch(2, 1)
    

        self.tabTXRXParameters.setLayout(edParameters_layout)
        self.tabsEDParameters.addTab(self.tabTXRXParameters, "ED TX/RX Parameters")             

    def build_esWindow(self):
        self.tabsES = QTabWidget()
        self.tabIQdata = QWidget()
        IQData_layout = QGridLayout()        
        
        
        ### IQ data plots
        self.IQDataTX_abs = pg.PlotWidget()
        self.IQDataTX_abs.setBackground("w")
        self.IQDataTX_abs.setTitle("IQdataTX - Absolute", color='k', size='10pt')   
        self.IQDataTX_abs.showGrid(x=True, y=True, alpha=0.3)
        self.IQDataTX_abs.setLabel("left", "Amplitude")
        self.IQDataTX_abs.setLabel("bottom", "Sample Index")
        self.IQDataTX_abs.setYRange(*(-.1,1))
        self.IQDataTX_curve_abs = self.IQDataTX_abs.plot(pen=pg.mkPen(color='k', width=2))
        self.IQDataTX_real = pg.PlotWidget()
        self.IQDataTX_real.setBackground("w")
        self.IQDataTX_real.setTitle("IQdataTX - Real", color='k', size='10pt')   
        self.IQDataTX_real.showGrid(x=True, y=True, alpha=0.3)
        self.IQDataTX_real.setLabel("left", "Amplitude")
        self.IQDataTX_real.setLabel("bottom", "Sample Index")
        self.IQDataTX_real.setYRange(*(-1,1))
        self.IQDataTX_curve_real = self.IQDataTX_real.plot(pen=pg.mkPen(color='k', width=2))
        self.IQDataTX_imag = pg.PlotWidget()
        self.IQDataTX_imag.setBackground("w")
        self.IQDataTX_imag.setTitle("IQdataTX - Imaginary", color='k', size='10pt')   
        self.IQDataTX_imag.showGrid(x=True, y=True, alpha=0.3)
        self.IQDataTX_imag.setLabel("left", "Amplitude")
        self.IQDataTX_imag.setLabel("bottom", "Sample Index")
        self.IQDataTX_imag.setYRange(*(-1,1))
        self.IQDataTX_curve_imag = self.IQDataTX_imag.plot(pen=pg.mkPen(color='k', width=2))

        self.IQDataRX_abs = pg.PlotWidget()
        self.IQDataRX_abs.setBackground("w")
        self.IQDataRX_abs.setTitle("IQdataRX - Absolute", color='k', size='10pt')
        self.IQDataRX_abs.showGrid(x=True, y=True, alpha=0.3)
        self.IQDataRX_abs.setLabel("left", "Amplitude")
        self.IQDataRX_abs.setLabel("bottom", "Sample Index")
        self.IQDataRX_abs.setYRange(*(-.1,1))
        self.IQDataRX_curve_abs = self.IQDataRX_abs.plot(pen=pg.mkPen(color='b', width=2))
        self.IQDataRX_real = pg.PlotWidget()
        self.IQDataRX_real.setBackground("w")
        self.IQDataRX_real.setTitle("IQdataRX - Real", color='k', size='10pt')
        self.IQDataRX_real.showGrid(x=True, y=True, alpha=0.3)
        self.IQDataRX_real.setLabel("left", "Amplitude")
        self.IQDataRX_real.setLabel("bottom", "Sample Index")
        self.IQDataRX_real.setYRange(*(-1,1))
        self.IQDataRX_curve_real = self.IQDataRX_real.plot(pen=pg.mkPen(color='b', width=2))
        self.IQDataRX_imag = pg.PlotWidget()
        self.IQDataRX_imag.setBackground("w")
        self.IQDataRX_imag.setTitle("IQdataRX - Imaginary", color='k', size='10pt')
        self.IQDataRX_imag.showGrid(x=True, y=True, alpha=0.3)
        self.IQDataRX_imag.setLabel("left", "Amplitude")
        self.IQDataRX_imag.setLabel("bottom", "Sample Index")
        self.IQDataRX_imag.setYRange(*(-1,1))
        self.IQDataRX_curve_imag = self.IQDataRX_imag.plot(pen=pg.mkPen(color='b', width=2))       
        
        ## Combine
   
        IQData_layout.addWidget(self.IQDataTX_abs, 0, 0)
        IQData_layout.addWidget(self.IQDataTX_real, 1, 0)
        IQData_layout.addWidget(self.IQDataTX_imag, 2, 0)
        

        IQData_layout.addWidget(self.IQDataRX_abs, 0, 1)
        IQData_layout.addWidget(self.IQDataRX_real, 1, 1)
        IQData_layout.addWidget(self.IQDataRX_imag, 2, 1)

        
        IQData_layout.setColumnStretch(0, 1)
        IQData_layout.setColumnStretch(1, 1)        
                      
        self.tabIQdata.setLayout(IQData_layout)
        self.tabsES.addTab(self.tabIQdata, "ES Information")           
    def build_esParameterWindow(self):       
        self.tabsESparameters = QTabWidget()
        self.tabTXRXParameters = QWidget()
                


        ########################### TX attenuation & RX gain sliders for edge server ###########################
        self.txAttnLabel = QLabel("ES: TX Atn [0-40 dB]:")            
                
        self.txAttnSlider = QSlider(QtCore.Qt.Orientation.Horizontal)
        self.txAttnSlider.setRange(0, 40*self.txAttnSliderfactor)
        self.txAttnSlider.setStyleSheet(self.slider_style)
        
        self.signal_I2W_executeLocalTask.emit('GET_TX_ATTN',{})
        currentTxAttn = self.resultsFromLocal
        if currentTxAttn != None:
            self.txAttnLabel_current = QLabel("(" + str(currentTxAttn) + " dB)")    
            self.txAttnSlider.setValue(int(currentTxAttn*self.txAttnSliderfactor))  # Set initial value
        else:
            self.txAttnLabel_current = QLabel("(" + "N/A" + " dB)")    
            self.txAttnSlider.setValue(int(10))  # Set initial value
        self.txAttnSlider.valueChanged.connect(self.on_txAttnSlider_changed)

        self.rxGainLabel = QLabel("ES: RX Gain [0-70 dB]:")
        self.rxGainSlider = QSlider(QtCore.Qt.Orientation.Horizontal)
        self.rxGainSlider.setRange(0, 70*self.rxGainSliderfactor)
        self.rxGainSlider.setStyleSheet(self.slider_style)
        
        self.signal_I2W_executeLocalTask.emit('GET_RX_GAIN',{})
        currentRXGain = self.resultsFromLocal
        if currentRXGain != None:
            self.rxGainLabel_current = QLabel("(" + str(currentRXGain) + " dB)")
            self.rxGainSlider.setValue(int(currentRXGain*self.rxGainSliderfactor))  # Set initial value
        else:
            self.rxGainLabel_current = QLabel("(" + "N/A" + " dB)")
            self.rxGainSlider.setValue(int(10))  # Set initial value        
        self.rxGainSlider.valueChanged.connect(self.on_rxGainSlider_changed)
        
        attnSliders_layout = QHBoxLayout()
        attnSliders_layout.addWidget(self.txAttnLabel)
        attnSliders_layout.addWidget(self.txAttnLabel_current)  
        attnSliders_layout.addWidget(self.txAttnSlider)
        attnSliders_layout.setStretch(2, 1)               
                    
        gainSliders_layout = QHBoxLayout()                    
        gainSliders_layout.addWidget(self.rxGainLabel)
        gainSliders_layout.addWidget(self.rxGainLabel_current)
        gainSliders_layout.addWidget(self.rxGainSlider)
        gainSliders_layout.setStretch(2, 1)     
           
        # timer
        self.timer1es_label = QLabel("T1:")
        self.timer2es_label = QLabel("T2:")
        self.timer3es_label = QLabel("T3:")
        self.timer4es_label = QLabel("T4:")           
        self.timer1es_current = QLabel()
        self.timer2es_current = QLabel()
        self.timer3es_current = QLabel()
        self.timer4es_current = QLabel()      
            
        timerES_layout = QHBoxLayout() 
        timerES_layout.addWidget(self.timer1es_label   )
        timerES_layout.addWidget(self.timer1es_current ) 
        timerES_layout.addWidget(self.timer2es_label   )
        timerES_layout.addWidget(self.timer2es_current ) 
        timerES_layout.addWidget(self.timer3es_label   )
        timerES_layout.addWidget(self.timer3es_current ) 
        timerES_layout.addWidget(self.timer4es_label   )
        timerES_layout.addWidget(self.timer4es_current )           
        
        # Combine   
        esParameters_layout = QGridLayout()    
        esParameters_layout.addLayout(attnSliders_layout, 0, 0)
        esParameters_layout.addLayout(gainSliders_layout, 0, 1)
        esParameters_layout.addLayout(timerES_layout, 0, 2)
        
        esParameters_layout.setColumnStretch(0, 2)
        esParameters_layout.setColumnStretch(1, 2)
        esParameters_layout.setColumnStretch(2, 1)
        
        self.tabTXRXParameters.setLayout(esParameters_layout)
        self.tabsESparameters.addTab(self.tabTXRXParameters, "ES TX/RX Parameters")    
        
    def build_cmdWindow(self):       
        self.tabsCmd = QTabWidget()
        self.tabCmd = QWidget()
        cmd_layout = QGridLayout()          
         
        ########################### Command line for the network ###########################
        networkCmd_layout = QGridLayout()  
        self.label_networkCommand = QLabel("Commands:")
        self.label_networkCommand.setAlignment(QtCore.Qt.AlignmentFlag.AlignCenter)
        self.textbox_networkCommand = QLineEdit('SET_TX_ATTN ID=ALL value=10')
        self.button_sendNetworkCommand = QPushButton("Send (ctrl+enter)") 
        self.button_sendNetworkCommand.clicked.connect(self.on_cmd_button_clicked)
        self.button_sendNetworkCommand.setShortcut("Ctrl+Return")  # Press Enter to trigger the button
        
        networkCmd_layout = QGridLayout()
        networkCmd_layout.addWidget(self.label_networkCommand,0,0,1,1)
        networkCmd_layout.addWidget(self.textbox_networkCommand,0,1,1,1)
        networkCmd_layout.addWidget(self.button_sendNetworkCommand,0,2,1,1)

        networkCmd_layout.setColumnStretch(1, 1)  # make text input expand

        ########################### Other buttons ###########################
        self.action_label = QLabel("Transmission:")
        
        self.button_trigger = QPushButton("Trigger") 
        self.button_trigger.clicked.connect(self.on_trigger_clicked)   
        
        self.button_sounding = QPushButton("Sounding") 
        self.button_sounding.clicked.connect(self.on_sounding_clicked)   
        
        self.button_calibration = QPushButton("Calibration") 
        self.button_calibration.clicked.connect(self.on_calibration_clicked)  
        
        self.button_feedback = QPushButton("Feedback") 
        self.button_feedback.clicked.connect(self.on_feedback_clicked)
        
        self.button_aggregation = QPushButton("Aggregation") 
        self.button_aggregation.clicked.connect(self.on_aggregation_clicked)
        
        
        self.button_aggregationProcess = QPushButton("Aggregation Results") 
        self.button_aggregationProcess.clicked.connect(self.on_aggregationProcess_clicked)
        
        self.label_CER = QLabel("Computation Error Rate: N/A")
                
        
        self.button_startStopAggregationProtocol = QPushButton("Aggregation Protocol") 
        self.button_startStopAggregationProtocol.clicked.connect(self.on_startStopAggregationProtocol_clicked)           
        
        self.button_startStopSoundingProtocol = QPushButton("Sounding Protocol") 
        self.button_startStopSoundingProtocol.clicked.connect(self.on_startStopSoundingProtocol_clicked)           
                
        
        self.process_label = QLabel("Processing:")
        
        self.button_soundingProcess = QPushButton("Sounding Results") 
        self.button_soundingProcess.clicked.connect(self.on_soundingProcess_clicked)
        
        self.button_triggerForAggregation = QPushButton("Trigger with PCP")             
        self.button_triggerForAggregation.clicked.connect(self.on_triggerForAggregation_clicked)

        self.button_readCurrent = QPushButton("Read TX/RX Gains") 
        self.button_readCurrent.clicked.connect(self.on_readCurrent_clicked)  

        
        command_layout = QGridLayout()
        command_layout.addWidget(self.action_label,0,0)
        command_layout.addWidget(self.button_trigger,0,1)
        command_layout.addWidget(self.button_sounding,0,2)
        command_layout.addWidget(self.button_calibration,0,3)
        command_layout.addWidget(self.button_feedback,0,4)
        command_layout.addWidget(self.button_aggregation,0,5)
        command_layout.addWidget(self.button_triggerForAggregation,0,6)
        command_layout.addWidget(self.button_startStopAggregationProtocol,0,7)
        command_layout.addWidget(self.button_startStopSoundingProtocol,0,8)
        
        command_layout.addWidget(self.process_label,1,0)
        command_layout.addWidget(self.button_soundingProcess,1,2)
        command_layout.addWidget(self.button_aggregationProcess,1,6)
        command_layout.addWidget(self.label_CER,1,7)
        
        command_layout.addWidget(self.button_readCurrent, 1, 1) 
        
        command_layout.setColumnStretch(1, 1) 
        command_layout.setColumnStretch(2, 1) 
        command_layout.setColumnStretch(3, 1) 
        command_layout.setColumnStretch(4, 1)
        command_layout.setColumnStretch(5, 1)
        command_layout.setColumnStretch(6, 1)
        command_layout.setColumnStretch(7, 1)
        
        # Combine     
        cmd_layout.addLayout(networkCmd_layout, 1, 0)
        cmd_layout.addLayout(command_layout, 2, 0)

        cmd_layout.setColumnStretch(0, 1)
        self.tabCmd.setLayout(cmd_layout)
        self.tabsCmd.addTab(self.tabCmd, "Commands")
    def build_timerWindow(self):       
        self.tabsTimers = QTabWidget()
        self.tabTimers = QWidget()

        
        
        ## Timers
        self.signal_I2W_executeLocalTask.emit("GET_TIMER_CONSTRUCTORS",{})   
        self.timerParameter_gap_a_label = QLabel(f"gap a: {{:3.0f}}".format(self.resultsFromLocal['gap_a']))
        self.timerParameter_gap_d_label = QLabel(f"gap d: {{:3.0f}}".format(self.resultsFromLocal['gap_d']))
        self.timerParameter_gap_g_label = QLabel(f"gap g: {{:3.0f}}".format(self.resultsFromLocal['gap_g']))
        self.timerParameter_gap_e_label = QLabel(f"gap e: {{:3.0f}}".format(self.resultsFromLocal['gap_e']))
        self.timerParameter_gap_xi_label = QLabel(f"gap xi: {{:3.0f}}".format(self.resultsFromLocal['gap_xi']))
        self.timerParameter_gap_epsilon_label = QLabel(f"gap epsilon: {{:3.0f}}".format(self.resultsFromLocal['gap_epsilon']))
        self.timerParameter_gap_a_slider = QSlider(QtCore.Qt.Orientation.Horizontal)
        self.timerParameter_gap_d_slider = QSlider(QtCore.Qt.Orientation.Horizontal)
        self.timerParameter_gap_g_slider = QSlider(QtCore.Qt.Orientation.Horizontal)
        self.timerParameter_gap_e_slider = QSlider(QtCore.Qt.Orientation.Horizontal)
        self.timerParameter_gap_xi_slider = QSlider(QtCore.Qt.Orientation.Horizontal)
        self.timerParameter_gap_epsilon_slider = QSlider(QtCore.Qt.Orientation.Horizontal)

        self.timerFactor = 4
        self.timerParameter_gap_a_slider.setRange(0, int(300/self.timerFactor))
        self.timerParameter_gap_a_slider.setValue(int(self.resultsFromLocal['gap_a']/self.timerFactor))  # Set initial value
        self.timerParameter_gap_a_slider.valueChanged.connect(self.on_gap_a_slider_changed)
        self.timerParameter_gap_a_slider.setStyleSheet(self.slider_style)

        self.timerParameter_gap_d_slider.setRange(0, int(300/self.timerFactor))
        self.timerParameter_gap_d_slider.setValue(int(self.resultsFromLocal['gap_d']/self.timerFactor))  # Set initial value
        self.timerParameter_gap_d_slider.valueChanged.connect(self.on_gap_d_slider_changed)
        self.timerParameter_gap_d_slider.setStyleSheet(self.slider_style)
        
        self.timerParameter_gap_g_slider.setRange(0, int(300/self.timerFactor))
        self.timerParameter_gap_g_slider.setValue(int(self.resultsFromLocal['gap_g']/self.timerFactor))  # Set initial value
        self.timerParameter_gap_g_slider.valueChanged.connect(self.on_gap_g_slider_changed)
        self.timerParameter_gap_g_slider.setStyleSheet(self.slider_style)

        self.timerParameter_gap_e_slider.setRange(0, int(16000/self.timerFactor))
        self.timerParameter_gap_e_slider.setValue(int(self.resultsFromLocal['gap_e']/self.timerFactor))  # Set initial value
        self.timerParameter_gap_e_slider.valueChanged.connect(self.on_gap_e_slider_changed)
        self.timerParameter_gap_e_slider.setStyleSheet(self.slider_style)
        
        self.timerParameter_gap_xi_slider.setRange(0, int(300/self.timerFactor))
        self.timerParameter_gap_xi_slider.setValue(int(self.resultsFromLocal['gap_xi']/self.timerFactor))  # Set initial value
        self.timerParameter_gap_xi_slider.valueChanged.connect(self.on_gap_xi_slider_changed)
        self.timerParameter_gap_xi_slider.setStyleSheet(self.slider_style)
        
        self.timerParameter_gap_epsilon_slider.setRange(0, int(300/self.timerFactor)) 
        self.timerParameter_gap_epsilon_slider.setValue(int(self.resultsFromLocal['gap_epsilon']/self.timerFactor))  # Set initial value
        self.timerParameter_gap_epsilon_slider.valueChanged.connect(self.on_gap_epsilon_slider_changed)  
        self.timerParameter_gap_epsilon_slider.setStyleSheet(self.slider_style)                      
       
        self.timerConfig_button = QPushButton("Update Timers")
        self.timerConfig_button.clicked.connect(self.on_timerConfig_button_clicked)   
        
        self.timerRead_button = QPushButton("Read Timers")
        self.timerRead_button.clicked.connect(self.on_timerRead_button_clicked)   

        timerConfig_layout = QGridLayout()    
        timerConfig_layout.addWidget(self.timerParameter_gap_a_label,        0, 0, 1, 1)
        timerConfig_layout.addWidget(self.timerParameter_gap_a_slider,       0, 1, 1, 1)
        timerConfig_layout.addWidget(self.timerParameter_gap_d_label,        0, 2, 1, 1)            
        timerConfig_layout.addWidget(self.timerParameter_gap_d_slider,       0, 3, 1, 1)            
        timerConfig_layout.addWidget(self.timerParameter_gap_g_label,        0, 4, 1, 1)            
        timerConfig_layout.addWidget(self.timerParameter_gap_g_slider,       0, 5, 1, 1)            
        timerConfig_layout.addWidget(self.timerParameter_gap_e_label,        1, 0, 1, 1)            
        timerConfig_layout.addWidget(self.timerParameter_gap_e_slider,       1, 1, 1, 1)            
        timerConfig_layout.addWidget(self.timerParameter_gap_xi_label,       1, 2, 1, 1)            
        timerConfig_layout.addWidget(self.timerParameter_gap_xi_slider,      1, 3, 1, 1)            
        timerConfig_layout.addWidget(self.timerParameter_gap_epsilon_label,  1, 4, 1, 1)            
        timerConfig_layout.addWidget(self.timerParameter_gap_epsilon_slider, 1, 5, 1, 1)            

        timerConfig_layout.addWidget(self.timerConfig_button, 2, 0, 1, 3) 
        timerConfig_layout.addWidget(self.timerRead_button, 2, 3, 1, 3) 

        timerConfig_layout.setColumnStretch(1, 1)
        timerConfig_layout.setColumnStretch(3, 1)
        timerConfig_layout.setColumnStretch(5, 1)
        
        
        
        self.tabTimers.setLayout(timerConfig_layout)
        self.tabsTimers.addTab(self.tabTimers, "FPGA Timer Configuration")    
    
    def build_windows(self):
            # Control window
            self.control_window = QMainWindow()
            self.control_window.setWindowTitle("Synchronization Testbed Control Panel")
            
            self.statusBar = self.control_window.statusBar()
            self.statusBar.showMessage("Status: Ready")            

            control_central = QWidget()
            control_layout = QGridLayout(control_central)
            
            self.build_cmdWindow()
            self.build_resultsWindow()
            self.build_edParametersWindow()
            self.build_esParameterWindow()
            self.build_esWindow()
            self.build_timerWindow()
            
            layout1 = QVBoxLayout()
            layout1.addWidget(self.tabsES, 0)
            layout1.addWidget(self.tabsESparameters, 1)            
            layout1.setStretch(1, 1)


            
            layout2 = QVBoxLayout()
            layout2.addWidget(self.tabsResults, 0)
            layout2.addWidget(self.tabsEDParameters, 1)
            layout2.setStretch(1, 1)

            
            layout3 = QHBoxLayout()
            layout3.addWidget(self.tabsCmd, 0)
            layout3.addWidget(self.tabsTimers, 0)
            layout3.setStretch(0, 2)            
            layout3.setStretch(0, 1)            

            control_layout.addLayout(layout1,0,0)
            control_layout.addLayout(layout2,0,1)
            control_layout.addLayout(layout3,1,0,1,2)
            control_layout.setColumnStretch(0, 2)
            control_layout.setColumnStretch(1, 2)

            self.control_window.setCentralWidget(control_central)
           

            
            
            # Status bar with time
            self.statusBar = QStatusBar()
            self.control_window.setStatusBar(self.statusBar)  # ← REQUIRED
            
            self.time_label = QLabel()
            self.statusBar.addPermanentWidget(self.time_label)  
            self.statusBar.setStyleSheet("""
                QStatusBar {
                    border-top: 1px solid rgba(0, 0, 0, 80);
                }
            """)

            # Timer to update time every second
            self.timer = QtCore.QTimer()
            self.timer.timeout.connect(self.update_time)
            self.timer.start(1000)     
            
            self.update_time()    
            self.updateStatus("User interface is ready.")   
            
            if True:
                screen = QApplication.primaryScreen()
                screen_size = screen.size()
                hControlNew = 720
                wControlNew = 620
                
                xOrigin = 800
                yOrigin = int((screen_size.height()) // 2.5 )
            else:
                # get the sceen size and move the window to the center
                wControl = 2000 # as ratios of the screen size
                hControl = 700 # as ratios of the screen size
                ratioControlToScreenHeight = 0.6
                screen = QApplication.primaryScreen()
                screen_size = screen.size()
                hControlNew = int(screen_size.height() * ratioControlToScreenHeight) 
                wControlNew = int(hControlNew * wControl / hControl)
                
                xOrigin = (screen_size.width() - wControlNew) // 2
                yOrigin = (screen_size.height() - hControlNew) // 2
            
            self.control_window.resize(wControlNew, hControlNew)
            self.control_window.move(xOrigin, yOrigin)
            
            
            
            self.control_window.show()
    def figIQDataTX_newData(self, x_data, y_data):
        self.IQDataTX_curve_abs.setData(x_data, np.abs(y_data))
        self.IQDataTX_curve_real.setData(x_data, np.real(y_data))
        self.IQDataTX_curve_imag.setData(x_data, np.imag(y_data))
    def figIQDataRX_newData(self, x_data, y_data):
        self.IQDataRX_curve_abs.setData(x_data, np.abs(y_data))
        self.IQDataRX_curve_real.setData(x_data, np.real(y_data))
        self.IQDataRX_curve_imag.setData(x_data, np.imag(y_data))
    def figSounding_newData(self,  x_data, y_data, powerIncrementFeedbackExact, CFOlistExact, powerIncrementFeedback, CFOlist):
        for index in range(self.rows * self.cols):
            if x_data is not None and y_data is not None:
                self.curvesSounding[index].setData(x_data[index], y_data[index])
                self.feedbackTXincLabels[index].setText(f"TX Power Inc: {powerIncrementFeedbackExact[index]:.2f} dB [FB: {powerIncrementFeedback[index]:.2f} dB]")
                self.feedbackCFOLabels[index].setText(f"CFO: {CFOlistExact[index]:.3f} Hz  [FB: {CFOlist[index]:.2f} Hz]")
    def figOAC_newData(self,  x_data, y_data, CER):
        if CER == -1:
            self.label_CER.setText(f"Computation Error Rate: N/A")
        else:
            self.label_CER.setText(f"Computation Error Rate: {{:3.2f}}%".format(CER))
        for index in range(self.rows * self.cols):
            if x_data is not None and y_data is not None:
                self.curvesOACSounding[index].setData(x_data[index], y_data[index])
                
    def on_txAttnSlider_changed(self):
        new_value = self.txAttnSlider.value()/self.txAttnSliderfactor
        self.txAttnLabel_current.setText(f"({{:2.2f}} dB)".format(new_value))
        if self.allowSendingTask:
            self.signal_I2W_executeLocalTask.emit("SET_TX_ATTN", {"value": new_value})
    def on_rxGainSlider_changed(self):
        new_value = self.rxGainSlider.value()/self.rxGainSliderfactor
        self.rxGainLabel_current.setText(f"({{:2.2f}} dB)".format(new_value))
        if self.allowSendingTask:
            self.signal_I2W_executeLocalTask.emit("SET_RX_GAIN", {"value": new_value})
    def on_txAttnSliderEDs_changed(self, indED):
        new_value = self.txAttnSliderEDs[indED].value()/self.txAttnSliderfactor
        self.txAttnLabelEDs_current[indED].setText(f"({{:2.2f}} dB)".format(new_value))
        if self.allowSendingTask:
            self.signal_I2W_executeNetworkTask.emit("SET_TX_ATTN", {"value": new_value}, indED)
    def on_rxGainSliderEDs_changed(self, indED):
        new_value = self.rxGainSlidersEDs[indED].value()/self.rxGainSliderfactor
        self.rxGainLabelEDs_current[indED].setText(f"({{:2.2f}} dB)".format(new_value))
        if self.allowSendingTask:
            self.signal_I2W_executeNetworkTask.emit("SET_RX_GAIN", {"value": new_value}, indED)

    def on_gap_a_slider_changed(self):
        new_value = self.timerParameter_gap_a_slider.value()     
        self.timerParameter_gap_a_label.setText(f"gap a: {{:3.0f}}".format(new_value*self.timerFactor))   
    def on_gap_d_slider_changed(self):        
        new_value = self.timerParameter_gap_d_slider.value()
        self.timerParameter_gap_d_label.setText(f"gap d: {{:3.0f}}".format(new_value*self.timerFactor))
    def on_gap_g_slider_changed(self):        
        new_value = self.timerParameter_gap_g_slider.value()
        self.timerParameter_gap_g_label.setText(f"gap g: {{:3.0f}}".format(new_value*self.timerFactor))
    def on_gap_e_slider_changed(self):        
        new_value = self.timerParameter_gap_e_slider.value()
        self.timerParameter_gap_e_label.setText(f"gap e: {{:5.0f}}".format(new_value*self.timerFactor))
    def on_gap_xi_slider_changed(self):        
        new_value = self.timerParameter_gap_xi_slider.value()
        self.timerParameter_gap_xi_label.setText(f"gap xi: {{:3.0f}}".format(new_value*self.timerFactor))
    def on_gap_epsilon_slider_changed(self):        
        new_value = self.timerParameter_gap_epsilon_slider.value()
        self.timerParameter_gap_epsilon_label.setText(f"gap epsilon: {{:3.0f}}".format(new_value*self.timerFactor))        

    def on_cmd_button_clicked(self):
        commandString = self.textbox_networkCommand.text()
        cmd, kwarg = parse_command(commandString)
        if 'ID' not in kwarg:
            self.updateStatus("No ID is specified. ID should be 'all' or an index corresponding to an edge device.")
            return
        if kwarg['ID'].lower() == 'all' or (kwarg['ID'].isdigit() and int(kwarg['ID']) in np.arange(self.numberOfEDs)):
            if kwarg['ID'].lower() == 'all':
                ID = -1  # Use -1 to indicate "all" in the network task
            else:
                ID = int(kwarg['ID'])
            del kwarg['ID']  # Remove 'ID' from kwargs to avoid confusion in local tasks
            if cmd:
                self.updateStatus("Command sent: " + cmd) 
                self.signal_I2W_executeNetworkTask.emit(cmd, kwarg, ID)  # You can modify this to include additional parameters if needed
            else:
                self.updateStatus("No text entered")
        else:
            self.updateStatus("Invalid ID. ID should be 'all' or an index corresponding to an edge device.")
    def on_readCurrent_clicked(self):
        self.updateStatus("Current TX/RX gains values of EDs and ES are read...")
        self.allowSendingTask = False
        self.signal_I2W_executeLocalTask.emit('GET_TX_ATTN', {})
        self.txAttnSlider.setValue(int(float(self.resultsFromLocal)*self.txAttnSliderfactor))
        self.signal_I2W_executeLocalTask.emit('GET_RX_GAIN', {})
        self.rxGainSlider.setValue(int(float(self.resultsFromLocal)*self.rxGainSliderfactor))
        
        self.signal_I2W_executeNetworkTask.emit('GET_TX_ATTN', {}, -1)
        for indED in range(self.numberOfEDs):
            self.txAttnSliderEDs[indED].setValue(int(float(self.resultsFromNetwork[indED])*self.txAttnSliderfactor))
        self.signal_I2W_executeNetworkTask.emit('GET_RX_GAIN', {}, -1)
        for indED in range(self.numberOfEDs):
            self.rxGainSlidersEDs[indED].setValue(int(float(self.resultsFromNetwork[indED])*self.rxGainSliderfactor))
        self.allowSendingTask = True
        self.updateStatus("Current TX/RX gains values of EDs and ES are read... done.")
    def on_timerConfig_button_clicked(self):
        self.updateStatus("Timer configuration update is initiated...")
        self.signal_I2W_executeLocalTask.emit("CALC_TIMERS",{'a': self.timerParameter_gap_a_slider.value()*self.timerFactor, 'd': self.timerParameter_gap_d_slider.value()*self.timerFactor, 
                                                     'g': self.timerParameter_gap_g_slider.value()*self.timerFactor, 'e': self.timerParameter_gap_e_slider.value()*self.timerFactor,
                                                     'xi': self.timerParameter_gap_xi_slider.value()*self.timerFactor, 'epsilon': self.timerParameter_gap_epsilon_slider.value()*self.timerFactor})        
        
        self.signal_I2W_executeLocalTask.emit("SET_TIMERS",{})
        self.signal_I2W_executeNetworkTask.emit("CALC_TIMERS",{'a': self.timerParameter_gap_a_slider.value()*self.timerFactor, 'd': self.timerParameter_gap_d_slider.value()*self.timerFactor, 
                                                     'g': self.timerParameter_gap_g_slider.value()*self.timerFactor, 'e': self.timerParameter_gap_e_slider.value()*self.timerFactor,
                                                     'xi': self.timerParameter_gap_xi_slider.value()*self.timerFactor, 'epsilon': self.timerParameter_gap_epsilon_slider.value()*self.timerFactor}, -1)
        self.signal_I2W_executeNetworkTask.emit("SET_TIMERS",{},-1)
        self.on_timerRead_button_clicked()
        self.updateStatus("Timer configuration update is initiated... done.")
    def on_timerRead_button_clicked (self):
        self.updateStatus("Timer configurations of EDs and ES are read...")
        self.signal_I2W_executeLocalTask.emit("GET_TIMERS",{})
        self.timer1es_current.setText(str(self.resultsFromLocal['T1']))
        self.timer2es_current.setText(str(self.resultsFromLocal['T2']))
        self.timer3es_current.setText(str(self.resultsFromLocal['T3']))
        self.timer4es_current.setText(str(self.resultsFromLocal['T4']))
        self.signal_I2W_executeNetworkTask.emit("GET_TIMERS",{},-1)

        for indED in range(self.numberOfEDs):
            d = ast.literal_eval(self.resultsFromNetwork[indED])
            self.timer1ed_current[indED].setText(str(d['T1']))
            self.timer2ed_current[indED].setText(str(d['T2']))
            self.timer3ed_current[indED].setText(str(d['T3']))
            self.timer4ed_current[indED].setText(str(d['T4']))
        self.updateStatus("Timer configurations of EDs and ES are read... done.")
    
    def on_trigger_clicked(self):
        self.updateStatus("Trigger is initiated.")
        self.signal_I2W_executeLocalTask.emit("TX_TRIGGER",{})
        self.updateStatus("Trigger is sent.")
    def on_calibration_clicked(self):
        self.updateStatus("Calibration is initiated.")
        self.signal_I2W_executeLocalTask.emit("TX_CALIBRATION",{})
        self.updateStatus("Calibration command is sent.")
    def on_sounding_clicked(self):
        self.updateStatus("Sounding is initiated.")
        self.signal_I2W_executeLocalTask.emit("TX_SOUNDING",{})
        self.updateStatus("Sounding command is sent.")
    def on_aggregation_clicked(self):
        self.updateStatus("Aggregation is initiated.")
        self.signal_I2W_executeLocalTask.emit("TX_AGGREGATION",{})
        self.updateStatus("Aggregation command is sent.")
    def on_feedback_clicked(self):
        self.updateStatus("Feedback is initiated.")
        self.signal_I2W_executeLocalTask.emit("TX_FEEDBACK",{"is_TXattn_Feedback": True, "is_CFO_Feedback": False})
        self.updateStatus("Feedback command is sent.")
    def on_soundingProcess_clicked(self):
        self.updateStatus("Calculating sounding results...")
        self.signal_I2W_executeLocalTask.emit("CALC_SOUNDING_RES",{})
        self.updateStatus("Calculating sounding results... done")  
        
    def on_aggregationProcess_clicked(self):
        self.updateStatus("Calculating aggregation results...")
        self.signal_I2W_executeLocalTask.emit("CALC_OAC_RES",{})
        self.updateStatus("Calculating aggregation results... done")  
        
    def on_startStopAggregationProtocol_clicked(self):
        self.updateStatus("Start/Stop aggregation protocol...")
        self.signal_I2W_executeProtocol.emit("Aggregation")
        self.updateStatus("Start/Stop aggregation protocol... done")
        
    def on_startStopSoundingProtocol_clicked(self):
        self.updateStatus("Start/Stop sounding protocol...")
        self.signal_I2W_executeProtocol.emit("Sounding")
        self.updateStatus("Start/Stop sounding protocol... done")        
    def on_triggerForAggregation_clicked(self):
        self.updateStatus("Triggering for Aggregation...")
        self.signal_I2W_executeLocalTask.emit("TX_TRIGGER_FOR_OAC",{})
        self.updateStatus("Triggering for Aggregation... done")  

        
    def updateStatus(self, statusInput):
        self.resultAtStatusBar = statusInput
        self.statusBar.showMessage(statusInput   + ' (' + datetime.now().strftime("%H:%M:%S") + ')')
    def updateNetworkResults(self, input):
        
        self.resultsFromNetwork = input
    def updateLocalResults(self, input):
        self.resultsFromLocal = input
    def update_time(self):
        current_time = datetime.now().strftime("%H:%M:%S")
        self.time_label.setText(current_time)
        
class objUserInterface_worker(QtCore.QThread):
    signal_W2I_figIQDataTX = QtCore.pyqtSignal(np.ndarray, np.ndarray) # x_data, y_data
    signal_W2I_figIQDataRX = QtCore.pyqtSignal(np.ndarray, np.ndarray) # x_data, y_data
    signal_W2I_figSounding = QtCore.pyqtSignal(np.ndarray, np.ndarray, np.ndarray, np.ndarray, np.ndarray, np.ndarray) # x_data, y_data, powerIncrementFeedback    
    signal_W2I_figOAC = QtCore.pyqtSignal(np.ndarray, np.ndarray, float) # x_data, y_data 
    signal_W2I_resultsFromNetwork = QtCore.pyqtSignal(object)
    signal_W2I_resultsFromLocal = QtCore.pyqtSignal(object)

    def __init__(self, parent=None, **kwargs):
        super().__init__(parent)
        
        # Parsing
        self.nodeID = 0
        self.virtualID = 0
        self.nodeRole = "none"
        self.isSDRavailable = 0
        self.hostKeysPath = ""
        self.signatureInputForSaving = "none"
        self.localPort = "none"
        self.usernameSSH = "none"
        self.passwordSSH = "none"
        
        overwriteParameters(self, **kwargs)
        
        parameters = dict([
            ('nodeID', self.nodeID), 
            ('virtualID', self.virtualID),
            ('nodeRole', self.nodeRole),            
            ('isSDRavailable', self.isSDRavailable), 
            ('hostKeysPath', self.hostKeysPath), 
            ('signatureInputForSaving', self.signatureInputForSaving), 
            ])

        self.myProtocol = objProtocol(**parameters)        

        
        # self.tryToConnectNetwork()
        self.servers = {}
        self.channels = {}
        self.isNetworkAvailable = np.zeros(self.myProtocol.numberOfEDs, dtype=int) 
        self.resultsLocal = list(self.myProtocol.numberOfEDs * [None])
        self.resultsNetwork = list(self.myProtocol.numberOfEDs * [None])

    @QtCore.pyqtSlot(str, dict)
    def run_localTask(self, task_name, kwargs):
        if task_name not in self.myProtocol.dispatchTable:
            print(f"Unknown task: {task_name}")
            self.signal_W2I_resultsFromLocal.emit(f"error")
            return
        try:
            action = self.myProtocol.dispatchTable[task_name]
            result = action(**kwargs)
            if kwargs:
                print(f"{task_name} with arguments {kwargs} is executed successfully.")
            else:
                print(f"{task_name} is executed successfully.")            
            self.signal_W2I_resultsFromLocal.emit(result)
        except Exception as e:
            self.signal_W2I_resultsFromLocal.emit(f"error")
            print(f"Error while executing {task_name}: {e}")

    def run_protocol(self, cmd):
        if self.myProtocol.isProtocolRunning == False:
            self.thread = threading.Thread(target=self.myProtocol.protocol_loop, args=(cmd,), daemon=True)
            self.thread.start()
        elif self.myProtocol.isProtocolRunning == True:
            self.myProtocol.stopEventforProtocolLoop.set()
            

    def run_networkTask(self, cmd, kwargs, ID):
        commandString = cmd + " " + " ".join([f"{key}={value}" for key, value in kwargs.items()])
        if ID == -1:  # -1 indicates "all"
            threads = list()
            for indNode in np.arange(self.myProtocol.numberOfEDs):
                x = threading.Thread(target=self.tryToSendAndReceive, args=(commandString, indNode))
                threads.append(x)
                x.start()
            for index, thread in enumerate(threads):
                thread.join()
            self.signal_W2I_resultsFromNetwork.emit(self.resultsNetwork)    
        else:
            self.tryToSendAndReceive(commandString, ID)
            self.signal_W2I_resultsFromNetwork.emit(self.resultsNetwork[ID])    
                    
    def tryToSendAndReceive(self, commandString, indNode):
        if self.isNetworkAvailable[indNode] == 1:
            try:
                self.channels[indNode].send(commandString)
                result = self.channels[indNode].recv(1024)
                self.resultsNetwork[indNode] = result.decode()
                
            except Exception:
                self.tryToConnectNetwork(indNode)
                if self.isNetworkAvailable[indNode] == 1:
                    self.channels[indNode].send(commandString)
                    result = self.channels[indNode].recv(1024)
                    self.resultsNetwork[indNode] = result.decode()  
                else:
                    self.resultsNetwork[indNode] = 'error' 
        else:
            self.tryToConnectNetwork(indNode)
            if self.isNetworkAvailable[indNode] == 1:
                self.channels[indNode].send(commandString)
                result = self.channels[indNode].recv(1024)
                self.resultsNetwork[indNode] = result.decode() 
            else:
                self.resultsNetwork[indNode] = 'error' 

                
    def tryToConnectNetwork(self, indNode):
        try:
            print(f"Trying to reconnect the SSH server at node {indNode}...")
            nodeIPs = [f"192.168.0.{i+10}" for i in np.arange(self.myProtocol.numberOfEDs)] 

            self.servers[indNode] = paramiko.SSHClient()
            self.servers[indNode].set_missing_host_key_policy(paramiko.AutoAddPolicy())
            self.servers[indNode].connect(nodeIPs[indNode], port=self.localPort, username=self.usernameSSH, password=self.passwordSSH, timeout=5)  # replace with actual credentials
            self.channels[indNode] = self.servers[indNode].get_transport().open_session()
            self.channels[indNode].settimeout(5)
            self.isNetworkAvailable[indNode] = 1
            print(f"Successfully connected to SSH server at node {indNode}.")
        except Exception as e:
            print(f"Error while connecting to SSH server at node {indNode}: {e}")
            self.isNetworkAvailable[indNode] = 0
            
            
            
    def run(self): # runPeriodic tasks
        debugpy.debug_this_thread()
        while True:
            self.signal_W2I_figIQDataRX.emit(np.arange(len(self.myProtocol.IQdataRX)), self.myProtocol.IQdataRX)
            self.signal_W2I_figIQDataTX.emit(np.arange(len(self.myProtocol.IQdataTX)), self.myProtocol.IQdataTX)
            self.signal_W2I_figSounding.emit(self.myProtocol.mySounding.HCFR_x_data, self.myProtocol.mySounding.HCFR_y_data, self.myProtocol.feedbackPowerIncrementExact, self.myProtocol.feedbackCFOAllExact, self.myProtocol.feedbackPowerIncrement, self.myProtocol.feedbackCFOAll)
            self.signal_W2I_figOAC.emit(self.myProtocol.myOAC.HCFR_x_data, self.myProtocol.myOAC.HCFR_y_data, self.myProtocol.CER)
            time.sleep(0.05)
            


