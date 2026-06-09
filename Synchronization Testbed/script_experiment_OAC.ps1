$pathExecution =  "C:\Users\alpha\Dropbox\Work\Project_synchronousSDRs\development_testbed"
Set-Location $pathExecution
Get-Process -Name WindowsTerminal | Stop-Process -Force
$folderName = "experiment_OAC_del"
$pyfileName = "runNode.py"

# upload files
for ($i = 0; $i -le 19; $i++) {
    Write-Host "Node $i - Upload folder"
    $N = $i+10

    $nodeIP = "192.168.0.$N"
    $nodeID = "node$i" 
    $nodePass = "1"
    $folderSource = $pathExecution
    $folderDestination = "/home/node$i/Desktop"
    
    # upload files
    Start-Process -FilePath wt.exe $pathExecution$("\tools\batch_uploadFolder.bat $nodeID $nodePass $nodeIP $folderSource $folderName $folderDestination")
}


$initialX = 200
$initialY = 50
$sizeXwt = 75 
$sizeYwt = 10
$deltaX = 720
$deltaY = 265

$initialX = 1200
$initialY = 50
$sizeXwt = 80 
$sizeYwt = 17
$deltaX = 520
$deltaY = 265

Start-Sleep -Seconds 5;
# run Python
for ($i = 0; $i -le 1; $i++) {
    Write-Host "Node $i - Run Python"
    $N = $i+10

    $nodeIP = "192.168.0.$N"
    $nodeID = "node$i" 
    $nodePass = "1"
    $folderDestination = "/home/node$i/Desktop"
    $radioIP = "192.168.2.1"
    $radioID = "$i"
    $radioRole = "edgeDevice"
    $parameters = "$radioIP $radioID $radioRole"

    if (1) {
        # align windows in columns:
        $Nc = 4
        $xPos = $initialX + ($i % $Nc)*$deltaX
        $yPos = $initialY + [math]::Floor($i / $Nc)*$deltaY
        
        $pyfileDirectoryPath = "/home/node$i/Desktop/" + $folderName

        wt.exe --size "$sizeXwt,$sizeYwt" --pos "$xPos,$yPos"--profile "RemoteSigned" PowerShell -command  "$pathExecution$("\tools\batch_runPython.bat $nodeID $nodePass $nodeIP $pyfileDirectoryPath $pyfileName $parameters")" 


    }
}


# single node
if (0){
    $i = 0
    Write-Host "Node $i - Run Python"
    $N = $i+10

    $nodeIP = "192.168.0.$N"
    $nodeID = "node$i" 
    $nodePass = "1"
    $folderDestination = "/home/node$i/Desktop"
    $radioIP = "192.168.2.1"
    $radioID = "$i"
    $radioRole = "edgeDevice"
    $parameters = "$radioIP $radioID $radioRole"

    if (1) {
        # align windows in columns:
        $Nc = 4
        $xPos = $initialX + ($i % $Nc)*$deltaX
        $yPos = $initialY + [math]::Floor($i / $Nc)*$deltaY
        
        $pyfileDirectoryPath = "/home/node$i/Desktop/" + $folderName

        wt.exe --size "$sizeXwt,$sizeYwt" --pos "$xPos,$yPos"--profile "RemoteSigned" PowerShell -command  "$pathExecution$("\tools\batch_runPython.bat $nodeID $nodePass $nodeIP $pyfileDirectoryPath $pyfileName $parameters")" 
    }
}


# # download results
# for ($i = 0; $i -le 19; $i++) {
#     Write-Host "Node $i - Download results"
#     $N = $i+10

#     $nodeIP = "192.168.0.$N"
#     $nodeID = "node$i" 
#     $nodePass = "1"
#     $folderSource = "/home/node$i/Desktop/" + $folderName + "/results"
#     $folderTarget = "C:\Users\alpha\Dropbox\Work\Project_synchronousSDRs\development_testbed\tools"

#     # upload files
#     Start-Process -FilePath wt.exe $pathTestbed$("batch_downloadFolder.bat $nodeID $nodePass $nodeIP $folderSource $folderTarget")
# }