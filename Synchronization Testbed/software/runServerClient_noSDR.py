import os
import sys
from main import *


if len(sys.argv) > 1:
    nodeID = int(sys.argv[1])
    virtualID = int(sys.argv[2])
    nodeRole = "edgeDevice"
    signatureInputForSaving = 'emuED' + str(nodeID)
    runProtocol = 1
  
    sshKeyFile = "/home/node" + str(nodeID) + "/.ssh/known_hosts"
    print("SSH Key File:", sshKeyFile)    

    parameters = dict([
        ('isSDRavailable', 1), 
        ('isNetworkAvailable', 1), 
        ('hostKeysPath', sshKeyFile), 
        ('signatureInputForSaving', signatureInputForSaving), 
        ('nodeID', nodeID), 
        ('nodeRole', nodeRole),
        ('virtualID', virtualID)
        ])
    
else:   
    print("As no arguments are provided, it runs the following settings.")    
    nodeID = 0
    nodeRole = 'edgeServer'
    if nodeRole == "edgeServer":
        signatureInputForSaving = 'emuES' + str(nodeID)
    elif nodeRole == "edgeDevice":
        signatureInputForSaving = 'emuED' + str(nodeID)

    sshKeyFile = 'C:\\Users\\alpha\\.ssh\\known_hosts'       
    print("SSH Key File:", sshKeyFile)    
    
    parameters = dict([
        ('isSDRavailable', 0), 
        ('isNetworkAvailable', 0), 
        ('hostKeysPath', sshKeyFile), 
        ('signatureInputForSaving', signatureInputForSaving), 
        ('nodeID', nodeID), 
        ('nodeRole', nodeRole),
        ('virtualID', 0)
        ])

myMain =  objMain(**parameters)
myMain.run()
