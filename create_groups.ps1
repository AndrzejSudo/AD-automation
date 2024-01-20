# Import the Active Directory module
Import-Module ActiveDirectory

# Define the path to the CSV file containing user details
$csvGroups = "data\groups.csv"

# Read the CSV files
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
