# Import the Active Directory module
Import-Module ActiveDirectory

# Import and read groups names from CSV
#$csvGroups = "data\groups.csv"
#$groupsList = Import-CSV $csvGroups

# Specify domain name
$myDomain = "adhome"
$myDomainSuf = "local"

# Specify permissions
$permissionsList= @("Read", "Execute", "Modify", "FullControl", "GenericAll", "GenericWrite")

# Specify the Organizational Unit (OU) where you want to create the users and groups
$ouUsersPath = "CN=Users,DC=$myDomain,DC=$myDomainSuf"
$ouGroupsPath = "OU=Groups,DC=$myDomain,DC=$myDomainSuf"

# Define folders and their paths
$dirPath = "C:\Shares\"

# Array with security groups from 'Groups' OU
$groupsList = Get-ADGroup -Filter * -SearchBase $ouGroupsPath

# Array with created users
$usersList = Get-ADUser -Filter * -SearchBase $ouUsersPath

# Create directories for specific security groups
function Create-Dir {

    param ($dirpath, $groupsList)
    foreach ($groupOb in $groupsList) {
        $group = $groupOb.group
        $path = $dirpath + $group

        # Check if the group already exists
        if (Get-ADGroup -Filter { Name -eq $group }) {
            Write-Host "Group '$group' already exists."
        } else {
            # Create the groups
            .\create_groups.ps1
            #New-ADGroup -Name $group -Path $ouGroupsPath -GroupScope Global -GroupCategory Security
            #Write-Host "Group '$group' created successfully."
        }

        # Create a directories, based on security groups if it doesn't exist
        if (-not (Test-Path $path)) {
            New-Item -ItemType Directory -Path $path -Force
            Write-Host "Directory created: $path"
        } else {
            Write-Host "Directory already exists: $path"
        }
    }
}
#Create-Dir -dirpath $dirpath -groupslist $groupsList

# Assign permissions to groups on directories
for ($i=0; $i -le $groupsList.count-1; $i++) {
    $groupName = $groupsList.SamAccountName[$i]
    $permissions = Get-Random -InputObject $permissionsList
    $Path = $dirpath + $groupName

    # Define permission settings based on your requirements
    $permission = @{ $groupName = $permissions }

    # Get the group object
    #$groupOb = Get-ADGroup -Filter { Name -eq $groupName }

    # Check if the directory exists
    if (Test-Path $Path) {
        # Grant permissions to the group on the directories
        $acl = Get-Acl -Path $Path
        $rule = New-Object System.Security.AccessControl.FileSystemAccessRule(
            $groupName,
            $permission[$groupName],
            "Allow"
        )
        $acl.AddAccessRule($rule)
        Set-Acl -Path $Path -AclObject $acl
        Write-Host "Permissions assigned to '$groupName' on '$Path'."
    } else {
        Write-Host "Folder '$Path' not found."
        Create-Dir -dirpath $dirPath -groupslist $groupsList
    }

<#
foreach ($user in $usersList){
    $permission = Get-Random -InputObject $permissionsList
    $group = Get-Random -InputObject $groupsList
    $path = $dirpath + $group.SamAccountName
    $acl = Get-Acl -path $Path
    $rule = New-Object System.Security.AccessControl.FileSystemAccessRule(
        $group.SamAccountName, 
        $permission, 
        "ContainerInherit",
        "All", 
        "None", 
        "Allow")
    $acl.AddAccessRule($rule)
    Set-Acl -path $path -AclObject $acl
    Add-ADGroupMember -Identity $group -Members $user
}#>

}
#>