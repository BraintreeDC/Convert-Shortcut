# Function to handle timestamping of logs
function Write-LogString {
	[CmdletBinding()]
	param (
		[Parameter()]
		[String]
		$Text
	)
	$Timestamp = Get-Date -Format O
	Write-Host "$($Timestamp) - $($Text)"
}
# Get all .website shortcuts on the C: drive of the device
Write-LogString 'Getting shortcuts on this device...'
$Shortcuts = Get-ChildItem -Path C:\ -Recurse -Filter *.website -ErrorAction SilentlyContinue
# Check if there are shortcuts to update
if ($Shortcuts.Count -gt 0) {
	Write-LogString "Processing $($Shortcuts.Count) shortcut$(if($Shortcuts.Count -gt 1){'s'})..."
	# Loop through each shortcut
	foreach ($Shortcut in $Shortcuts) {
		# Get the name for the shortcut
		Write-LogString 'Getting file name for shortcut...'
		$ShortcutName = [System.IO.Path]::GetFileNameWithoutExtension($Shortcut)
		Write-LogString $ShortcutName
		# Get the URL from the old shortcut
		Write-LogString 'Getting URL from old shortcut...'
		$ShortcutURL = Get-Content $Shortcut.FullName | ForEach-Object { if ($_.StartsWith('URL=')) { return $_.Split('=')[1] } }
		Write-LogString $ShortcutURL
		# Generate a new location for the shortcut
		Write-LogString 'Generate new shortcut location...'
		$NewShortcutLocation = "$($Shortcut.DirectoryName)\$($ShortcutName).url"
		Write-LogString $NewShortcutLocation
		# Check if the shortcut already exists
		if (Test-Path $NewShortcutLocation) {
			# Shortcut already exists - stop and return error code to deployment tool
			Write-LogString "Shortcut already exists at $($NewShortcutLocation)"
			Write-LogString 'Halting script to allow for manual intervention'
			exit 1
		} else {
			# Create a shell object
			Write-LogString 'Creating shell object...'
			$Shell = New-Object -ComObject ('WScript.Shell')
			# Create the new shortcut in the same directory as the old one
			Write-LogString 'Creating shortcut...'
			$NewShortcut = $Shell.CreateShortcut($NewShortcutLocation)
			# Set the URL to the one we got earlier
			Write-LogString 'Setting target path to correct URL...'
			$NewShortcut.TargetPath = $ShortcutURL
			# Save the shortcut
			Write-LogString 'Saving changes to the shortcut...'
			$NewShortcut.Save()
			# Remove the old shortcut (to avoid confusion for users)
			Write-LogString 'Remove the old shortcut...'
			Remove-Item $Shortcut -Force
		}
	}
}
else {
	# Nothing to do as no shortcuts have been found
	Write-LogString 'Nothing to do...'
}
# End of script - exit with code 0
Write-LogString 'Script has finished'
exit 0