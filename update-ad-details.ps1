<# --------------------------------------------------------------------------------------------------------------
        UPDATE AD DETAILS FROM BAMBOOHR
        
        - Get a directory of users from BambooHR. This relies on https://github.com/SimonXCIV/Bamboozled.
        - Find each user in Active Directory
        - Update the user's AD details based on the data in BambooHR
-------------------------------------------------------------------------------------------------------------- #>

<# # EDITABLE VARIABLES --------------------------------------------
# Make sure to uncomment this block

# Your company's BambooHR API key
$apiKey = "api_key_goes_here"

# Your company's BambooHR subdomain
$subdomain = "example_subdomain"

# The hostname of the server to perform the operation on
$server = "hostname_of_your_server"

# END EDITABLE VARIABLES----------------------------------------- #>

# Get a list of all staff from BambooHR. Filter out those that have no email address set.
$employees = Get-BambooHRDirectory -apiKey $apikey -subDomain $subdomain -fields "workEmail,workPhoneExtension,location,country,jobTitle,department,division,supervisorEID,city,division" -active | Where-Object -filter {$_.workEmail}

foreach($employee in $employees)
{
    # Set a variable for the current employee's email address
    $emailAddress = $employee.workEmail

    write-host "working on" $emailAddress

    # Find the email address of the employee's supervisor based on the EID in BambooHR
    $supervisor = $employees | where-object -Property "id" -EQ -Value $employee.supervisorEID | Select-Object -expandProperty "workEmail"

    # Try to find the employee's manager in AD based on the supervisor's email address above
    try
    {
        # If the supervisor was successfully set earlier, search for them in AD
        if($supervisor)
        {
            $manager = Get-ADUser -filter {emailAddress -eq $supervisor}
        }

        # If $supervisor is empty, set $manager to $null
        else
        {
            $manager = $null
        }
    }

    # If the AD lookup fails, set $manager to $null
    catch
    {
        $manager = $null
    }

    # try to find the user in AD based on email address
    try
    {
        $user = Get-ADUser -Filter {emailAddress -eq $emailAddress}
    }

    # If the user isn't found, continue to the next employee. We can't really do anything here.
    catch
    {
        write-host "Couldn't find $emailAddress in AD" -ForegroundColor Red
        Continue
    }

    # Try to set the details for the employee in AD
    try
    {
        $user | set-aduser -OfficePhone      $employee.workPhoneExtension `
                           -title            $employee.jobTitle `
                           -Department       $employee.department `
                           -Company          $employee.division `
                           -City             $employee.city `
                           -Country          $employee.country `
                           -Office           $employee.location `
                           -Manager          $manager `
                           -Server           $server

    }

    # Tell us if the Set-AdUser operation failed
    catch
    {
        write-host "Could not update user $emailAddress" -ForegroundColor Red
    }
}