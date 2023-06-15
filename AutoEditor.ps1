# This script simplifies running Auto-Editor (software to automatically remove silent sections of a vidoe file)
# If you do not already have Auto-Editor installed, make sure you have Python installed then run: pip install auto-editor
# Check the website for more info: https://auto-editor.com/ (Note; this is an awesome piece of software. I did not write it, I am only writing this script to simplify running it.)

# Allow file to be run
Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass

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
$defaults = Read-Host -Prompt 'Would you like to change the default values? (Y / (blank))'

if ($defaults -eq 'y')
{
    # Allow changes to audio threshold
    $audioThresholdNew = Read-Host -Prompt "The default audio threshold is $audioThreshold - Please input a threshold (0-100) or leave blank to keep the default"

    if ($audioThresholdNew -ne '')
        {
            $audioThreshold = $audioThresholdNew
        }

    # Allow changes to video editor
    $videoEditorNew = Read-Host -Prompt "The default editor is $videoEditor - Please input an editor (resolve, final-cut-pro, shotcut) or leave blank to keep the default"

    if ($videoEditorNew -ne '')
        {
            $videoEditor = $videoEditorNew
        }

    # Allow changes to margin
    $marginNew = Read-Host -Prompt "The default margin is $margin - Please input a number (0.0 - ~) or leave blank to keep the default"

    if ($marginNew -ne '')
        {
            $margin = $marginNew
            }
}

# Display defaults
Write-Host "Default Audio Threshold = $audioThreshold"
Write-Host "Video Editor = $videoEditor"
Write-Host "margin = $margin"

# Run the script
auto-editor $filePath --margin $margin'sec' --export $videoEditor --edit audio:threshold=$audioThreshold%
