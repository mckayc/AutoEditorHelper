# This script simplifies running Auto-Editor (software to automatically remove silent sections of a vidoe file)
# If you do not already have Auto-Editor installed, make sure you have Python installed then run: pip install auto-editor

# Set Default variables

$audioThreshold = 10
$videoEditor = "resolve"
$margin = .2

# Enter file path of video file
$filePath = Read-Host -Prompt 'Right click on the video file then click "Copy as Path" - Paste then press "Enter"'

# Display defaults
Write-Host "Default Audio Threshold = $audioThreshold"
Write-Host "Video Editor = $videoEditor"
Write-Host "margin = $margin"

# Give option to change defaults
#$defaults = Read-Host -Prompt 'Would you like to change the default values? (Y / (blank))'

# Run the script
auto-editor $filePath --margin $margin'sec' --export $videoEditor --edit audio:threshold=$audioThreshold%


$test = "cool beans"
$test2 = Read-Host -Prompt "Type something or leave blank:"

if ($test2 -ne '')
{
    $test = $test2
}

$test

