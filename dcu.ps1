# before trying to run the script, allow running scripts:
#   Set-ExecutionPolicy -ExecutionPolicy bypass -Scope CurrentUser

# Define the directory to look for files
$directoryPath = "$HOME\Downloads\testdata"

# import the forms package
Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

$fontSizeFactor = 1.2
# Create a new form object
$form = New-Object System.Windows.Forms.Form
$form.SuspendLayout()

$flowPanel = New-Object System.Windows.Forms.FlowLayoutPanel
$flowPanel.FlowDirection = [System.Windows.Forms.FlowDirection]::TopDown
$flowPanel.Dock = [System.Windows.Forms.DockStyle]::Fill
$flowPanel.WrapContents = $false
$form.Controls.Add($flowPanel)

# Add a label and a button to the form
$label = New-Object System.Windows.Forms.Label
$label.Text = "Hello <User>, what do you measure now?"
$label.AutoSize = $true
$label.Font = New-Object System.Drawing.Font($label.Font.Name, $($label.Font.Size*$fontSizeFactor))  # increase font size
$flowPanel.Controls.Add($label)

$textBox = New-Object System.Windows.Forms.TextBox
$textBox.Text = "<Measurement series description>"
$textBox.Multiline = $false
$textBox.Font = New-Object System.Drawing.Font($textBox.Font.Name, $($textBox.Font.Size*$fontSizeFactor))  # increase font size
$textBox.Anchor = [System.Windows.Forms.AnchorStyles]::Top -bor [System.Windows.Forms.AnchorStyles]::Bottom
$flowPanel.Controls.Add($textBox)

# Create a list to store the text box objects
$textBoxList = New-Object System.Collections.Generic.List[System.Windows.Forms.TextBox]
$labelList = New-Object System.Collections.Generic.List[System.Windows.Forms.Label]
$layoutList = New-Object System.Collections.Generic.List[System.Windows.Forms.FlowLayoutPanel]

# Function to update text boxes based on the files in the directory
function UpdateTextBoxes {
    for ($i = 0; $i -lt $layoutList.Count; $i++) {
        $layoutList[$i].Controls.Remove($textBoxList[$i])
        $layoutList[$i].Controls.Remove($labelList[$i])
        $flowPanel.Controls.Remove($layoutList[$i])
    }
    $textBoxList.Clear()
    $labelList.Clear()
    $layoutList.Clear()

    # Get the list of files in the directory
    $files = Get-ChildItem -Path $directoryPath -File

    # Loop through each file and create a text box for each
    foreach ($file in $files) {
        Write-Output "Processing file: $($file.Name)"
        $rowLayout = New-Object System.Windows.Forms.FlowLayoutPanel
        $rowLayout.FlowDirection = [System.Windows.Forms.FlowDirection]::LeftToRight
        $rowLayout.AutoSize = $true
        $rowLayout.Dock = [System.Windows.Forms.DockStyle]::Fill
        $rowLayout.WrapContents = $false
        #$rowLayout.Padding = New-Object System.Windows.Forms.Padding(5, 5, 5, 5)
        $layoutList.Add($rowLayout) # add the layout to the list

        $label = New-Object System.Windows.Forms.Label  # create a label for each file
        $label.Text = $file.Name
        $label.AutoSize = $true
        $label.Anchor = [System.Windows.Forms.AnchorStyles]::None
        $label.Font = New-Object System.Drawing.Font($label.Font.Name, $($label.Font.Size*$fontSizeFactor))
        $labelList.Add($label) # add the label to the list
        $rowLayout.Controls.Add($label)

        $textBox = New-Object System.Windows.Forms.TextBox
        $textBox.Multiline = $false
        $textBox.Width = 200
        $textBox.Text = "<file description>"
        $textBox.Anchor = [System.Windows.Forms.AnchorStyles]::None
        $textBox.Font = New-Object System.Drawing.Font($textBox.Font.Name, $($textBox.Font.Size*$fontSizeFactor))
        $textBoxList.Add($textBox) # Add the text box to the list
        $rowLayout.Controls.Add($textBox)

        $flowPanel.Controls.Add($rowLayout)
    }
}

# Initial call to update text boxes
UpdateTextBoxes

$rowLayout = New-Object System.Windows.Forms.FlowLayoutPanel
$rowLayout.FlowDirection = [System.Windows.Forms.FlowDirection]::LeftToRight
$rowLayout.AutoSize = $true
$rowLayout.Dock = [System.Windows.Forms.DockStyle]::Top
$rowLayout.WrapContents = $false
$flowPanel.Controls.Add($rowLayout)

# Add a button to refresh the text boxes
$refreshButton = New-Object System.Windows.Forms.Button
$refreshButton.Text = "Refresh"
$refreshButton.Add_Click({
    UpdateTextBoxes
})
$rowLayout.Controls.Add($refreshButton)

# Add a button to read the user input from the text boxes
$readButton = New-Object System.Windows.Forms.Button
$readButton.Text = "Read Input"
$readButton.Add_Click({
    [System.Windows.Forms.MessageBox]::Show("Button Clicked!")
    $output = "Button Clicked: [$(Get-Date)]`n"
    $textBox.AppendText($output)
    foreach ($textBox in $textBoxList) {
        $userInput = $textBox.Text
        Write-Host "User Input: $userInput"
    }
})
$rowLayout.Controls.Add($readButton)

# Resize Event Handler
$resizeHandler = {
    $remainingHeight = $flowPanel.Height - (
        $label.Height + $label.Margin.Vertical +
        $button.Height + $button.Margin.Vertical +
        $textbox.Margin.Vertical
        )
    $textBox.Height = $remainingHeight
    $textbox.width = $flowPanel.Width - $flowPanel.Margin.Horizontal
}
$flowPanel.Add_Resize($resizeHandler)
$form.Add_Shown({
	write-host "add_shown"
	& $resizeHandler
})

# Set the form properties
$form.Text = "BAM Data Collection Utility"
# Adjust the form size to fit all elements
$totalHeight = $label.Height + $textBox.Height + $flowPanel.Height + $flowPanel.Margin.Vertical + 50 # Add some padding
$formHeight = [Math]::Max($totalHeight, 200) # Ensure a minimum height
$formWidth = 400 # Set a fixed width or calculate based on content
$form.ClientSize = New-Object System.Drawing.Size($formWidth, $formHeight)
$form.ResumeLayout($false)
$form.PerformLayout()

Write-Host "test"

# display the form
$form.ShowDialog() | Out-Null

# 1. To launch another program in PowerShell, you can use the Start-Process cmdlet
# Start-Process -FilePath "notepad.exe" -ArgumentList "C:\path\to\yourfile.txt"

# 2. let a user run a program as admin permanently
# https://www.perplexity.ai/search/on-windows-how-to-allow-a-user-zHOrkQBpRyGimM6JEzp5VQ#1

# 3. on windows, how to prevent a user from running a program directly but allowing it to be started  in a  specific script only?
# https://www.perplexity.ai/search/on-windows-how-to-allow-a-user-zHOrkQBpRyGimM6JEzp5VQ#2
