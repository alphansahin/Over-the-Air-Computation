import socket
import paramiko
from libraryProtocol import *
from libraryUtility import *
import threading
import time
# ---------------------------
# SSH Server Interface for edge devices
# ---------------------------
class objNetworkInterface():
    def __init__(self, **kwargs):
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
        
        self.worker = objNetworkInterface_worker(**parametersWorker)
        self.sshServerSocketTimeout = 10 # if Python is killed socket timeout will allow port to be released and recreated when the program is restarted.
        self.sshServerChannelTimeout = 10 # Channel timeout will keep the channel alive for a certain time after the last command is received. This allows multiple commands to be sent without reconnecting, while also ensuring that idle channels are eventually closed.
    def start(self):
        print("Constructing SSH server to listen for commands from edge server")    
        socketCMD = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
        socketCMD.setsockopt(socket.SOL_SOCKET, socket.SO_REUSEADDR, 1)
        socketCMD.bind(("0.0.0.0", self.localPort))  # Listen on port 8080
        socketCMD.listen(100) 
        socketCMD.settimeout(self.sshServerSocketTimeout) 
        print("Server listening on port " + str(self.localPort))        
        while True:
            try:
                client, addr = socketCMD.accept()
                print(f"Accepted connection from {addr}")
                ## main loop of the SSH servers
                sshServerThread = threading.Thread(target=self.worker.start, args=(client,addr,self.sshServerChannelTimeout))
                sshServerThread.start()
                sshServerThread.join()
            except socket.timeout:
                # print("No incoming connection, still waiting...")
                continue
      
class objNetworkInterface_worker(): # worker handles the commands from the edge server after the connection is established.
    class SSHServer(paramiko.ServerInterface):
        def __init__(self):
            pass
        def check_auth_password(self, username, password):
            if username == "user" and password == "pass":
                return paramiko.AUTH_SUCCESSFUL
            return paramiko.AUTH_FAILED
        def check_channel_request(self, kind, chanid):
            if kind == "session":
                return paramiko.OPEN_SUCCEEDED
            return paramiko.OPEN_FAILED_ADMINISTRATIVELY_PROHIBITED    
    def __init__(self,  **kwargs):
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
        print("Starting the protocol loop in a separate thread")
        threading.Thread(target=self.myProtocol.protocol_loop, args=(), daemon=True).start()        
    def start(self, client_socket, addr, channel_timeout):
        HOST_KEY = paramiko.RSAKey.generate(2048)
        transport = paramiko.Transport(client_socket)
        transport.add_server_key(HOST_KEY)
        server = self.SSHServer()
        transport.start_server(server=server)
        # Wait for the client to open a channel
        channel = transport.accept(20)
        if channel is None:
            return
        
        # handle loop
        
        start_time = time.time()
        while time.time() - start_time < channel_timeout:
            if channel.recv_ready():
                cmd = channel.recv(1024).decode('utf-8').strip()
                if not cmd:
                    continue
                else:
                    start_time = time.time()  # reset timer on valid command

                print(f"Received command: {cmd}")
                command, kwargs = parse_command(cmd)
                if command not in self.myProtocol.dispatchTable:
                    response = "Unknown command"    
                else:
                    try:
                        action = self.myProtocol.dispatchTable[command]
                        if kwargs:
                            result = action(**kwargs)
                        else:
                            result = action()
                        if result != None:
                            if type(result) != str:
                                result = str(result)
                            response = result
                        else:
                            if kwargs:
                                response = f"{action.__name__} with arguments {kwargs} is executed successfully."
                            else:
                                response = f"{action.__name__} is executed successfully."
                    except Exception as e:
                        response = f"Error: {str(e)}"
                print(response)
                channel.send(response.encode())
            time.sleep(0.1)  # prevent CPU spinning
        channel.close()
        transport.close()
        print(f"Channel closed after handling commands from {addr}.")
