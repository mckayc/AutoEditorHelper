# This script simplifies running Auto-Editor (software to automatically remove silent sections of a vidoe file)
# If you do not already have Auto-Editor installed, make sure you have Python installed then run: pip install auto-editor
# Check the website for more info: https://auto-editor.com/ (Note; this is an awesome piece of software. I did not write it, I am only writing this script to simplify running it.)

######################################### Instructions for making this script act as an app (searchable in the Windows search bar #########################################
# 1. Download all files in this repository. Put them in a folder. You can name the folder whatever you want and place it wherever you want.
# 2. Right click on the bat file and make it a shortcut. In the shortcut properties change the icon. Change it to whatever you want. I added an .ico shortcut file that you can use.
# 3. Move the shortcut file to %programdata%\Microsoft\Windows\Start Menu\Program  (your system will have to have "Show hidden files" enabled in Explorer)
# (Note; if you put the shortcut on your desktop I think it also becomes searchable)
# 4. Press the windows key and type in "Auto Editor" and the shortcut to the bat file should now show up. Click on it or press Enter when it is highlighted.
###########################################################################################################################################################################

## Useful Commands ##
# Check Version: auto-editor --version    (Note:24.3.1 is what I am using 2024-02-28) (2024-05-20 - Now using version 24.13.1)
# Install the version that has worked best for me: pip install auto-editor==24.13.1
# Uninstall: pip uninstall auto-editor
# Upgrade: pip install auto-editor --upgrade

# Bypass the execution policy for the current session
Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass

Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

# Initialize form and controls
$form = New-Object System.Windows.Forms.Form
$form.Text = "Video Editor Settings"
$form.Size = New-Object System.Drawing.Size(500, 500)
$form.StartPosition = "CenterScreen"

# Create labels and textboxes for audio threshold, margin before, and margin after
$audioThresholdLabel = New-Object System.Windows.Forms.Label
$audioThresholdLabel.Text = "Audio Threshold:"
$audioThresholdLabel.Location = New-Object System.Drawing.Point(10, 20)
$form.Controls.Add($audioThresholdLabel)

$audioThreshold = New-Object System.Windows.Forms.TextBox
$audioThreshold.Text = "1.9"
$audioThreshold.Location = New-Object System.Drawing.Point(150, 20)
$form.Controls.Add($audioThreshold)

$marginBeforeLabel = New-Object System.Windows.Forms.Label
$marginBeforeLabel.Text = "Margin Before:"
$marginBeforeLabel.Location = New-Object System.Drawing.Point(10, 60)
$form.Controls.Add($marginBeforeLabel)

$marginBefore = New-Object System.Windows.Forms.TextBox
$marginBefore.Text = ".03"
$marginBefore.Location = New-Object System.Drawing.Point(150, 60)
$form.Controls.Add($marginBefore)

$marginAfterLabel = New-Object System.Windows.Forms.Label
$marginAfterLabel.Text = "Margin After:"
$marginAfterLabel.Location = New-Object System.Drawing.Point(10, 100)
$form.Controls.Add($marginAfterLabel)

$marginAfter = New-Object System.Windows.Forms.TextBox
$marginAfter.Text = ".04"
$marginAfter.Location = New-Object System.Drawing.Point(150, 100)
$form.Controls.Add($marginAfter)

# Create a dropdown for video editor
$videoEditorLabel = New-Object System.Windows.Forms.Label
$videoEditorLabel.Text = "Video Editor:"
$videoEditorLabel.Location = New-Object System.Drawing.Point(10, 140)
$form.Controls.Add($videoEditorLabel)

$videoEditor = New-Object System.Windows.Forms.ComboBox
$videoEditor.Items.AddRange(@("resolve", "final-cut-pro", "shotcut"))
$videoEditor.SelectedIndex = 0
$videoEditor.Location = New-Object System.Drawing.Point(150, 140)
$form.Controls.Add($videoEditor)

# Create a textbox to show the log with a monospaced font
$logBox = New-Object System.Windows.Forms.TextBox
$logBox.Multiline = $true
$logBox.ReadOnly = $true
$logBox.ScrollBars = 'Vertical'
$logBox.Size = New-Object System.Drawing.Size(450, 150)
$logBox.Location = New-Object System.Drawing.Point(10, 240)
$logBox.Font = New-Object System.Drawing.Font('Consolas', 10) # Set monospaced font
$form.Controls.Add($logBox)

# Create a label and box for dragging files
$dropLabel = New-Object System.Windows.Forms.Label
$dropLabel.Text = "Drag files here:"
$dropLabel.Size = New-Object System.Drawing.Size(100, 30)
$dropLabel.Location = New-Object System.Drawing.Point(10, 180)
$form.Controls.Add($dropLabel)

# Create a panel to serve as a drag-and-drop area with visual indication
$dropBox = New-Object System.Windows.Forms.Panel
$dropBox.BorderStyle = 'Fixed3D'
$dropBox.AllowDrop = $true
$dropBox.Size = New-Object System.Drawing.Size(300, 40)
$dropBox.Location = New-Object System.Drawing.Point(150, 180)
$dropBox.BackColor = [System.Drawing.Color]::LightGray
$dropBox.BorderStyle = 'FixedSingle'
$form.Controls.Add($dropBox)

# Add instructional text inside the drag-and-drop area
$dropBoxLabel = New-Object System.Windows.Forms.Label
$dropBoxLabel.Text = "Drop files here"
$dropBoxLabel.TextAlign = 'MiddleCenter'
$dropBoxLabel.Dock = 'Fill'
$dropBox.Controls.Add($dropBoxLabel)

# Function to log actions in the logBox
function Log-Message {
    param ($message)
    $logBox.AppendText("$message`r`n")
    $logBox.ScrollToCaret()
}

# Function to show an error message box
function Show-Error {
    param ($message)
    [System.Windows.Forms.MessageBox]::Show($message, "Error", [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Error)
}

# Handle file drag and drop
$dropBox.Add_DragEnter({
    if ($_.Data.GetDataPresent([Windows.Forms.DataFormats]::FileDrop)) {
        $_.Effect = [Windows.Forms.DragDropEffects]::Copy
        # Change the background color to indicate an active drag
        $dropBox.BackColor = [System.Drawing.Color]::LightGreen
    }
})

$dropBox.Add_DragLeave({
    # Restore the background color when the drag leaves the area
    $dropBox.BackColor = [System.Drawing.Color]::LightGray
})

$dropBox.Add_DragDrop({
    $dropBox.BackColor = [System.Drawing.Color]::LightGray # Restore background color after drop
    $files = $_.Data.GetData([Windows.Forms.DataFormats]::FileDrop)
    foreach ($file in $files) {
        try {
            # Construct the auto-editor command with quoted file paths
            $filePath = "`"$file`""
            $marginBeforeValue = $marginBefore.Text
            $marginAfterValue = $marginAfter.Text
            $audioThresholdValue = $audioThreshold.Text
            $videoEditorValue = $videoEditor.SelectedItem
            
            # Log the details
            Log-Message "Processing file: $filePath"
            Log-Message "Audio Threshold: $audioThresholdValue"
            Log-Message "Margin Before: $marginBeforeValue"
            Log-Message "Margin After: $marginAfterValue"
            Log-Message "Video Editor: $videoEditorValue"
            
            # Construct the command string
            $command = "auto-editor '$filePath' --margin $marginBeforeValue's',$marginAfterValue'sec' --export $videoEditorValue --edit audio:threshold=$audioThresholdValue%"

            # Log the command being run
            Log-Message "Running command: $command"
            
            # Run the command and capture output
            $process = Start-Process powershell -ArgumentList "-Command & { $command }" -PassThru -Wait -RedirectStandardError "error.log" -RedirectStandardOutput "output.log"

            # Check if there are errors
            $errorLog = Get-Content "error.log"
            if ($errorLog) {
                Show-Error "The command failed with the following error(s):`r`n$errorLog"
            }
        } catch {
            # Catch and display any exceptions
            Show-Error "An error occurred: $_"
        }
    }
})

# Show the form
$form.Topmost = $true
$form.Add_Shown({ $form.Activate() })
[void]$form.ShowDialog()
