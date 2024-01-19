# Import the Active Directory module
Import-Module ActiveDirectory

# Define the path to the CSV file containing user details
$csvUsers = "data\users.csv"
$csvPasswords = "data\passwords.csv"
$csvGroups = "data\groups.csv"

# Read the CSV file
$usersList = Import-CSV $csvUsers
$passwordsList = Import-CSV $csvPasswords
$groupsList = Import-CSV $csvGroups

# Specify domain name
$myDomain = "adhome"
$myDomainSuf = "local"

# Specify the Organizational Unit (OU) where you want to create the users and groups
$ouUsersPath = "CN=Users,DC=$myDomain,DC=$myDomainSuf"
$ouGroupsPath = "OU=Groups,DC=$myDomain,DC=$myDomainSuf"

# Create groups from CSV file
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

# Loop through each user in the CSV file
foreach ($user in $usersList) {
    # Set user details from the CSV
    $firstName = $user.FirstName
    $lastName = $user.LastName
    $username = $firstName[0] + $lastName
    $password = Get-Random -InputObject $passwordsList.password
    $group = Get-Random -InputObject $groupsList.group

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

Write-Host "User creation completed."