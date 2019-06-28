# Update Active Directory From BambooHR

A simple PowerShell script to update the details of AD users via the BambooHR API.

## Installation

1. Install the [Bamboozled PowerShell Module](https://github.com/simonxciv/Bamboozled)
   - Open an Administrative PowerShell window
   - Run `Install-Module -name Bamboozled`
   - If prompted, type `Y` followed by `[enter]` to approve the install
2. Download and open `update-ad-details.ps1` from this repo in your editor of choice
3. Uncomment the `Editable variables` comment block at the top of the script. Fill out the below variables with the relevant values:
   - **$apiKey:** Your BambooHR API key. See [here](https://www.bamboohr.com/api/documentation/) for more information.
   - **$subdomain:** Your BambooHR subdomain. This is the 'company' part of 'company.bamboohr.com', where you'd usually access your BambooHR instance.
   - **$server:** The hostname of a server on your network with the appropriate roles installed.
4. Run the script under a user account with the permissions required to edit user information in Active Directory.

*For bonus points, run the script as a scheduled task to complete this automatically once a day or as regularly as needed. Your users will thank you for keeping their Outlook Address Book up to date.*