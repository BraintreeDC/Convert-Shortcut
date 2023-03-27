# Convert-Shortcut

> ***This script has been archived as it is no longer in use since the deprecation/removal of Internet Explorer.***

Script to convert *.website shortcuts (Internet Explorer specific) to *.url shortcuts (generic favourite shortcuts).

This is to prepare shortcuts for the removal of Internet Explorer from Windows 10 and to ensure that shortcuts are able to open in either Microsoft Edge or Google Chrome (where the Legacy Browser Support module will redirect sites on the Enterprise Site List to Microsoft Edge with IE Mode).

## Purpose
This script is used at Braintree District Council to convert legacy Internet Explorer shortcut files to generic URL shortcuts to prepare for the removal of Internet Explorer on Windows 10. 

This is being done after configuring Microsoft Edge IE Mode and setting up Google Chrome Legacy Browser Support (LBS) to redirect sites on our Enterprise Site List to Microsoft Edge (phasing out the direct usage of Internet Explorer for users prior to the removal of application by Microsoft).

When going through our compatibility testing, we noticed no issues moving users from IE to Edge with IE Mode. However, we did encounter the issue of old .website shortcuts potentially not working for users when IE was going to be removed. This script was created to parse all the .website shortcuts on an end user device and replace them with generic .URL shortcuts which would open in the user's default browser (Google Chrome or Microsoft Edge). If the URL requires Internet Explorer for compatiblity reasons, it will then be loaded in Microsoft Edge with IE Mode.

We didn't find any resources of how to do this online and no documentation was provided by Microsoft for this. The .website files are structured as INI files and can be read via the Get-Content cmdlet in PowerShell (which allows for the URL to be extracted for use when creating the replacement shortcut). We hope that by posting this resource publicly, it might help other system administrators ease the burden of moving away from Internet Explorer.

## Usage
This script will get all *.website files on the local C: drive of the device, then parse the INI configuration of each shortcut to create a new shortcut (and remove the .website file after it has been created).

This is designed to be run in a local system context via a deployment tool (e.g. Microsoft SCCM, Microsoft Intune, PDQ Deploy etc.).

The script will return an output log (prepended with a timestamp) and will exit with code 0 if successful.

If any errors occur, the script will return the number of errors as the exit code (e.g. 2 errors will result in the script exiting with code 2).

## Requirements
This script needs to run in the local system context of the device (or an account with local admin rights) to allow it to access all directories on the C: drive (along with being able to read, write and remove files).

This script has been tested with PowerShell 5.1 on Windows 10 1909, 20H2 and 21H2 builds using PDQ Deploy to run in the local system context.

## Reporting issues
If you encounter any issues, please report them using the Issues tab on this GitHub repo.

## Important notice
Please refer to the LICENSE file before using this script in production.

As with all scripts on the internet - please read the code before executing it and test before pushing this to live systems.
