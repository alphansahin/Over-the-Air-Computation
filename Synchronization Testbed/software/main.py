
import threading
from libraryUserInterface import *
from libraryNetworkInterface import *
from libraryProtocol import *
from libraryUtility import *



# ---------------------------
# Main
# ---------------------------
class objMain():
    def __init__(self, **kwargs):
        self.isSDRavailable = 0
        self.isNetworkAvailable = 0
        self.isUserInterfaceEnabled = 0
        self.hostKeysPath = ""
        self.signatureInputForSaving = "none"
        self.nodeID = 0
        self.nodeRole = "none"
        self.virtualID = 0
        self.localPort = 8080
        self.passwordSSH = "pass"  # replace with actual password
        self.usernameSSH = "user"  # replace with actual username
        
        overwriteParameters(self, **kwargs)

        
        if self.nodeRole == 'edgeServer':
            self.runAs = self.runAsAnEdgeServer
        elif self.nodeRole == 'edgeDevice': 
            self.runAs = self.runAsAnEdgeDevice

        self.parametersInterface = dict([
            ('nodeID', self.nodeID), 
            ('virtualID', self.virtualID),
            ('nodeRole', self.nodeRole),            
            ('isSDRavailable', self.isSDRavailable), 
            ('isNetworkAvailable', self.isNetworkAvailable),
            ('hostKeysPath', self.hostKeysPath), 
            ('signatureInputForSaving', self.signatureInputForSaving),             
            ('localPort', self.localPort), 
            ('usernameSSH', self.usernameSSH), 
            ('passwordSSH', self.passwordSSH),
        ])

    def run(self):
        print("Starting the main loop as " + self.nodeRole)
        self.runAs()
        
    def runAsAnEdgeServer(self):
        print("Starting the user interface")
        app = QApplication(sys.argv)
        font = app.font()
        font.setPointSize(8) # Set a specific size
        app.setFont(font)
        userInterface = objUserInterface(**self.parametersInterface)
        sys.exit(app.exec_())        
    def runAsAnEdgeDevice(self):
        print("Starting the network interface")
        myNetworkInterface = objNetworkInterface(**self.parametersInterface)
        if self.isNetworkAvailable == 1:
            myNetworkInterface.start()

