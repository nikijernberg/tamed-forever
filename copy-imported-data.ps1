$ErrorActionPreference = "Stop"
$srcRoot = "C:\Users\nikij\Downloads\Tamed-master\Tamed-master"
if (-not (Test-Path (Join-Path $srcRoot "data\TameableNPCs.lua"))) {
  $alt = Join-Path $PSScriptRoot "..\..\Downloads\Tamed-master\Tamed-master"
  if (Test-Path (Join-Path $alt "data\TameableNPCs.lua")) { $srcRoot = $alt }
}
$dst = $PSScriptRoot

New-Item -ItemType Directory -Force -Path (Join-Path $dst "data") | Out-Null
New-Item -ItemType Directory -Force -Path (Join-Path $dst "libs\AceGUI-3.0\widgets") | Out-Null

Copy-Item (Join-Path $srcRoot "data\TameableAbilities.lua") (Join-Path $dst "data\TameableAbilities.lua") -Force
Copy-Item (Join-Path $srcRoot "data\TameableNPCs.lua") (Join-Path $dst "data\TameableNPCs.lua") -Force

$ace = Join-Path $srcRoot "libs\AceGUI-3.0"
Copy-Item (Join-Path $ace "AceGUI-3.0.lua") (Join-Path $dst "libs\AceGUI-3.0\AceGUI-3.0.lua") -Force
Copy-Item (Join-Path $ace "widgets\AceGUIContainer-Frame.lua") (Join-Path $dst "libs\AceGUI-3.0\widgets\AceGUIContainer-Frame.lua") -Force
Copy-Item (Join-Path $ace "widgets\AceGUIContainer-TreeGroup.lua") (Join-Path $dst "libs\AceGUI-3.0\widgets\AceGUIContainer-TreeGroup.lua") -Force
Copy-Item (Join-Path $srcRoot "libs\LibDBIcon-1.0.lua") (Join-Path $dst "libs\LibDBIcon-1.0.lua") -Force

Write-Host "Imported original Tamed data and remaining AceGUI/LibDBIcon files into $dst"
Write-Host "Data remains original Tamed (Classic/TBC) and is not Forever-verified."
