# Function to handle timestamping of logs
function Write-LogString {
	[CmdletBinding()]
	param (
		[Parameter()]
		[String]
		$Text
	)
	$Timestamp = Get-Date -Format O
	Write-Output "$($Timestamp) - $($Text)"
}
# Function to check if URL needs to be changed (example is HTTP URLs need to be changed to HTTPS for Echo)
function Get-ProperUrl {
	[CmdletBinding()]
	param(
		[Parameter()]
		[String]
		$URL
	)
	if ($URL.StartsWith('http://echo.braintree.gov.uk')) {
		return 'https://echo.braintree.gov.uk/'
	} else {
		return $URL
	}
}
# Get all .website shortcuts on the C: drive of the device
Write-LogString 'Getting shortcuts on this device...'
$Shortcuts = Get-ChildItem -Path C:\ -Recurse -Filter *.website -ErrorAction SilentlyContinue
# Variable to return on script completion
$ReturnCode = 0
# Check if there are shortcuts to update
if ($Shortcuts.Count -gt 0) {
	Write-LogString "Processing $($Shortcuts.Count) shortcut$(if($Shortcuts.Count -gt 1){'s'})..."
	# Loop through each shortcut
	foreach ($Shortcut in $Shortcuts) {
		# Get the name for the shortcut
		Write-LogString 'Getting file name for shortcut...'
		$ShortcutName = [System.IO.Path]::GetFileNameWithoutExtension($Shortcut)
		Write-LogString $ShortcutName
		try {
			# Get the URL from the old shortcut
			Write-LogString 'Getting URL from old shortcut...'
			$ShortcutURL = Get-Content $Shortcut.FullName | ForEach-Object { if ($_.StartsWith('URL=')) { return $_.Split('=')[1] } }
			Write-LogString $ShortcutURL
			# Replace unsecured Echo links with secured ones to prevent issues with the Not Secure notice in Edge
			$ShortcutURL = Get-ProperUrl -URL $ShortcutURL
		}
		catch {
			# If unable to get the URL for the shortcut - log issue and set variable to false
			Write-LogString "Unable to get the URL for $($ShortcutName)!"
			$ShortcutURL = $false
			# Bump return code so the deployment tool shows an error
			$ReturnCode++
		}
		# Provided a shortcut URL is found
		if ($ShortcutURL) {
			# Generate a new location for the shortcut
			Write-LogString 'Generate new shortcut location...'
			$NewShortcutLocation = "$($Shortcut.DirectoryName)\$($ShortcutName).url"
			Write-LogString $NewShortcutLocation
			# Check if the shortcut already exists
			if (Test-Path $NewShortcutLocation) {
				# Shortcut already exists - log issue and continue
				Write-LogString "Shortcut already exists at $($NewShortcutLocation)"
				# Bump return code so the deployment tool shows an error
				$ReturnCode++
			}
			else {
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
				Remove-Item $Shortcut.FullName -Force
			}
		}
	}
}
else {
	# Nothing to do as no shortcuts have been found
	Write-LogString 'Nothing to do...'
}
# End of script - exit with return code variable
Write-LogString 'Script has finished'
exit $ReturnCode