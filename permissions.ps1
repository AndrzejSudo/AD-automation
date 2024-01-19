# Import the Active Directory module
Import-Module ActiveDirectory

# Import and read groups names from CSV
$csvGroups = "data\groups.csv"
$groupsList = Import-CSV $csvGroups

# Specify domain name
$myDomain = "adhome"
$myDomainSuf = "local"

# Specify the Organizational Unit (OU) where you want to create the users and groups
$ouUsersPath = "CN=Users,DC=$myDomain,DC=$myDomainSuf"
$ouGroupsPath = "OU=Groups,DC=$myDomain,DC=$myDomainSuf"

# Define folders and their paths
$dirPath = "C:\Shares\"

# Create security groups if not already done with user creation
function Create-Dir {

    param ($dirpath, $groupsList)
    foreach ($groupOb in $groupsList) {
        $group = $groupOb.group
        $path = $dirpath + $group

        # Check if the group already exists
        if (Get-ADGroup -Filter { Name -eq $group }) {
            Write-Host "Group '$group' already exists."
        } else {
            # Create the group
            New-ADGroup -Name $group -Path $ouGroupsPath -GroupScope Global -GroupCategory Security
            Write-Host "Group '$group' created successfully."
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
Create-Dir -dirpath $dirpath -groupslist $groupsList

# Assign permissions to groups on directories
for ($i=0; $i -le $groupsList.count-1; $i++) {
    $groupName = $groupsList[$i].group
    $permission = Get-Random @("Read", "Execute", "Modify", "FullControl")
    $Path = $dirpath + $groupName

    # Define permission settings based on your requirements
    $permissions = @{ $groupName = $permission }

    # Get the group object
    $groupOb = Get-ADGroup -Filter { Name -eq $groupName }

    # Check if the directory exists
    if (Test-Path $Path) {
        # Grant permissions to the group on the directories
        $acl = Get-Acl -Path $Path
        $rule = New-Object System.Security.AccessControl.FileSystemAccessRule(
            $groupOb.SamAccountName,
            $permissions[$groupName],
            "Allow"
        )
        $acl.AddAccessRule($rule)
        Set-Acl -Path $Path -AclObject $acl
        Write-Host "Permissions assigned to '$groupName' on '$Path'."
    } else {
        Write-Host "Folder '$dPath' not found."
        Create-Dir -dirpath $path -groupslist $groupsList
    }
}
#>