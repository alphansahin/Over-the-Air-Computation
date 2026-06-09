$pathTestbed =  "C:\Users\alpha\Dropbox\Work\Project_synchronousSDRs\development_testbed"
$nodePass = "1"

Set-Location $pathTestbed
Get-Process -Name WindowsTerminal | Stop-Process -Force

for ($i = 10; $i -le 19; $i++) {
    Write-Host "Node $i"

    $N = $i+10

    $nodeIP = "192.168.0.$N"
    $nodeID = "node$i" 

    # turn off/on USB ports
    Start-Process -FilePath wt.exe $("$pathTestbed\tools\batch_turnOnOffUSB.bat $nodeID $nodePass $nodeIP")
}



# single node
if (0){
    $i = 0;
    Write-Host "Node $i"

    $N = $i+10

    $nodeIP = "192.168.0.$N"
    $nodeID = "node$i" 

    # turn off/on USB ports
    Start-Process -FilePath wt.exe $("$pathTestbed\tools\batch_turnOnOffUSB.bat $nodeID $nodePass $nodeIP")
}