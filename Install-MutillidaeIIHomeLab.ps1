#
💻 PowerShell Script for Automation of MutillidaeII Home Lab

This PowerShell script automates the installation and configuration process of OWASP Mutillidae II in a Windows environment, using XAMPP as a web server.

📌 Prerequisites:

- Internet access.

- PowerShell running as Administrator.

- Ports 80 (Apache) and 3306 (MySQL) free.

- Release temporary execution policy if needed:
Set-ExecutionPolicy RemoteSigned -Scope Process
#>

# --- Variables ---
$XAMPPInstallerURL = "https://www.apachefriends.org/xampp-files/8.2.4/xampp-windows-x64-8.2.4-0-VS16.exe"
$XAMPPInstallerName = "xampp-installer.exe"
$XAMPPInstallPath = "C:\xampp"

$MutillidaeZipURL = "https://github.com/Juliocesar-sec/MutillidaeII.HomeLab/archive/refs/heads/main.zip"
$MutillidaeZipName = "MutillidaeII.HomeLab.zip"
$MutillidaeExtractPath = "$XAMPPInstallPath\htdocs"
$MutillidaeFinalPath = Join-Path -Path $MutillidaeExtractPath -ChildPath "mutillidae"
$LogFile = "Mutillidae_Install_Log.txt"

# --- Functions ---
function Write-Log {
stop (
[string]$Message,
[string]$Level = "INFO"
)
$Timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
$Entry = "[$Timestamp] [$Level] $Message"
Write-Host $Entry
Add-Content -Path $LogFile -Value $Entry
}

function Download-File {
stop (
[string]$URL,
[string]$Destination
)
if (-not (Test-Path $Destination)) {
Write-Log "Downloading $URL to $Destination"
try {
Invoke-WebRequest -Uri $URL -OutFile $Destination -UseBasicParsing -TimeoutSec 600
Write-Log "Download completed successfully." } get {
Write-Log "Error downloading $URL: $($_.Exception.Message)" "ERROR"
output 1
}
} else {
Write-Log "File already exists: $Destination"
}
}

function Extract-Zip {
parameter (
[string]$ZipFile,
[string]$Destination
)
Write-Log "Extracting $ZipFile to $Dest"
try {
Expand-Archive -Path $ZipFile -DestinationPath $Dest -Force
Write-Log "Extraction complete." } get {
Write-Log "Error deleting: $($_.Exception.Message)" "ERROR"
output 1
}
}

# --- Execution ---
Write-Log "🛠️ Starting the Mutillidae II Home Lab installation process"

# 1. Download XAMPP
Download file $XAMPPInstallerURL $XAMPPInstallerName

# 2. Install XAMPP
Write-Log "Running XAMPP installer. Install manually at $XAMPPInstallPath"

Pause
Start-Process -FilePath $XAMPPInstallerName -Wait

if (-not (Test Path $XAMPPInstallPath)) {
Write-Log "XAMPP not found at $XAMPPInstallPath" "ERROR"
output 1
}

# 3. Download Mutillidae
Download file $MutillidaeZipURL $MutillidaeZipName

# 4. Extract and move
Extract-Zip $MutillidaeZipName $MutillidaeExtractPath

$SourceDir = Join-Path $MutillidaeExtractPath "MutillidaeII.HomeLab-main"
if (Test-Path $SourceDir) {
if (-not (Test-Path $MutillidaeFinalPath)) {
New-Item -Item-Type -Directory -Path $MutillidaeFinalPath | Output-Null
}
Get-Child-Item -Path $SourceDir | ForEach-Object {
Move-Item -Path $_.FullName -Destination $MutillidaeFinalPath -Force
}
Remove-Item -Path $SourceDir -Recurse -Force
Write-Log "Files moved to $MutillidaeFinalPath"
} else {
Write-Log "Directory $SourceDir not found." "ERROR"
output 1
}

# 5. Final Instructions
Write-Log "Please open the XAMPP Control Panel and start Apache and MySQL."
Write-Log "Go to http://localhost/phpmyadmin and click on the 'owasp10' database."
Write-Log "Then go to http://localhost/mutillidae/setup.php to configure the application."
Pause

# 6. Success!
Write-Log "✅ Mutillidae II successfully installed! Access at: http://localhost/mutillidae"

# 7. Cleanup
$cleanup = Read-Host "Do you want to temporarily disable the installed ones? (y/n)"
if ($cleanup -eq "y") {
Remove-Item $XAMPPInstallerName, $MutillidaeZipName -Force -ErrorAction SilentlyContinue
Write-Log "Installers removed."
}

Write-Log "🧪 MutillidaeII Home Lab Environment ready to use!"
