# Import the Active Directory module
Import-Module ActiveDirectory

# Define the path to the CSV file containing user details
$csvUsers = "data\users.csv"
$csvPasswords = "data\passwords.csv"
$csvServiceAccounts = "data\services.csv"
#$csvGroups = "data\groups.csv"

# Read the CSV files
$usersList = Import-CSV $csvUsers
$passwordsList = Import-CSV $csvPasswords
$serviceAccounts = Import-CSV $csvServiceAccounts
#$groupsList = Import-CSV $csvGroups


# Specify domain name
$myDomain = "adhome"
$myDomainSuf = "local"

# Specify the Organizational Unit (OU) where you want to create the users and groups
$ouUsersPath = "CN=Users,DC=$myDomain,DC=$myDomainSuf"
$ouGroupsPath = "OU=Groups,DC=$myDomain,DC=$myDomainSuf"

# Create groups from additional script
.\create_groups.ps1
<#
foreach ($groupOb in $groupsList) {
    $group = $groupOb.group
    try {
        Get-ADGroup -Identity $group
        #Write-Host "Group '$group' already exists"
    }
    catch [Microsoft.ActiveDirectory.Management.ADIdentityNotFoundException] {
        New-ADGroup -Name $group -Path $ouGroupsPath -GroupScope global -GroupCategory Security
        Write-Host "Group '$group' created successfully."
    }
}
#>

# Create object with available groups
$groups = Get-ADGroup -Filter * -SearchBase $ouGroupsPath

# Loop through each user in the CSV file
foreach ($user in $usersList) {
    # Set user details from the CSV
    $firstName = $user.FirstName
    $lastName = $user.LastName
    $username = $firstName[0] + $lastName
    $password = Get-Random -InputObject $passwordsList.password
    $group = Get-Random $groups.SamAccountName

    # Create the user
    $userParams = @{
        'SamAccountName' = $username
        'UserPrincipalName' = "$username@$myDomain.com"
        'Name' = "$firstName $lastName"
        'GivenName' = $firstName
        'Surname' = $lastName
        'DisplayName' = $firstName + ' ' + $lastName
        'EmailAddress' = $email
        'AccountPassword' = (ConvertTo-SecureString -String $password -AsPlainText -Force)
        'Enabled' = $true
        'Path' = $ouUsersPath
    }

    # Create user and add to group
    try {
        New-ADUser @userParams
        Add-ADGroupMember -Identity $group -Members $username
        Write-Host "User $username created successfully and added to group $group."
    }
    catch [Microsoft.ActiveDirectory.Management.ADIdentityAlreadyExistsException] {
        Write-Host "User '$username' already exists"
    }
}

# Create service accounts
foreach ($service in $serviceAccounts){
    # Set services details from the CSV
    $name = $service.name
    $type = $service.type
    $password = Get-Random -InputObject $passwordsList.password

    $serviceParams = @{
        'Name' = $name + "_" + $type
        'Description' = "This is $name service account"
        'AccountPassword' = (ConvertTo-SecureString -String $password -AsPlainText -Force)
        'Enabled' = $true
    }
    
    # Create service
    try {
        New-ADServiceAccount @serviceParams -RestrictToSingleComputer
        Write-Host "Service account $($service.SamAccountName) created."
    }
    catch [Microsoft.ActiveDirectory.Management.ADIdentityAlreadyExistsException] {
        Write-Host "Service '$name' already exists"
    }

}

Write-Host "Accounts creation completed."