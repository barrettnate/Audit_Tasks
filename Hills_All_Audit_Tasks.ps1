#All Hill's IT Audit Tasks
#This script should cover all audit tasks that need documentation.
#It is expandable for future needs.

#Hill's Pet Nutrition
#Nate Barrett/Benjamin Medina
#nate_barrett@hillspet.com
#10/26/2023


#Declaring Variables
$global:keywords = read-host -Prompt "Please provide the Facility OU for these tasks. ex.(USEP): "
$keywords = $keywords.ToUpper()
$global:year = get-date -Format yyyy
$global:task_complete_color = "Green"
$global:task_error_color = "Red"

#Choose Quarter of Audit
write-host "Select the Quarter:
1: Annual/Q1
2: Q2
3: Q3
4: Q4"
$userChoice = read-host -Prompt " "
switch($userChoice)
{
    1 {$global:quarter = "Annual_Q1"}
    2 {$global:quarter = "Q2"}
    3 {$global:quarter = "Q3"}
    4 {$global:quarter = "Q4"}
}

#Create Folder Structure - Change this if you want output stored elsewhere.
$global:Path = "O:\My Drive\Audit Evidence\$keywords\$year\$quarter\"
If (!(Test-Path $Path)) {New-Item -ItemType Directory -Path $Path -Force}


#Audit Task Functions
function Get-task9_2 {

#DEFINE VARIABLES
#Define the path to the OU containing the groups
$coreOU = ",OU=United States,DC=us,DC=am,DC=win,DC=colpal,DC=com"
$facilityOU = $keywords
$ouPath = "OU=Groups," + "OU=" + $facilityOU + $coreOU
$local_path = $Path + 'Task_9_2-empty_groups.csv'
#$messageText = "No empty groups were found.: $(Get-Date)"
#$outFile = $path + "empty_groups.csv"

#FINDING EMPTY AD GROUPS
#Search Active Directory for OU's
$middleous = Get-ADOrganizationalUnit -LDAPFilter '(name=*)' -SearchBase $ouPath -SearchScope OneLevel

#Remove CSV file before new population
if (Test-Path -Path $local_path -PathType Leaf) {
    try{
        Remove-Item -Path $local_path
        Write-Host "The file at [$local_path] has been deleted."
    }
    catch {
        throw $_.Exception.Message
    }
}

#Add date to the top of CSV File
Get-Date | Out-File -FilePath $local_path

#Loop through each AD Group in the list
foreach ($middleou in $middleous) {
    $middleou | Select-Object Name | Out-File -FilePath $local_path -Append
    Get-ADGroup -Filter * -SearchBase $middleou -Properties Members | Where-Object {-not $_.members} | Select-Object Name | Out-File -FilePath $local_path -Append  
}
Write-host "Task 9.2 completed.`n" -ForegroundColor $task_complete_color
Start-Sleep -Seconds 3
}

function Get-task9_1 {


#Define local path
$local_path = $Path + 'task9_1IDs.txt'
$user_search = '*' + $keywords + '*'

#Define the path to the OU containing the groups
$ouPath = "DC=us,DC=am,DC=win,DC=colpal,DC=com"

#Search Active Directory for enabled users whose names contain the keywords
$users = Get-ADUser -LDAPFilter "(&(name=$user_search)(!(userAccountControl:1.2.840.113556.1.4.803:=2)))" -SearchBase $ouPath

#Loop through each user in the list
foreach ($user in $users) {
    #Add the user's name to the text file
    Add-Content -Path $local_path  -Value $user.Name
    Write-Host "Added user $($user.Name) to the text file"
}

#Clear variable
Clear-Variable -name users

#Task completed statement
Write-host "Task 9.1 completed.`n" -ForegroundColor $task_complete_color
}

function Get-task9_3{
$ErrorActionPreference = 'SilentlyContinue'

#Declare Variables - WIP
$PCAdmin = $keywords + '_PCAdmin'
$PCAdminDL = $keywords + '_PCAdminDL'
$ServerAdmins = $keywords + '_ServerAdmins'
$ServerAdminsDL = $keywords + '_ServerAdminsDL'
$ServerAdminsU = $keywords + '_ServerAdminsU'
$SiteAdmins = $keywords + '_SiteAdmins'
$SiteAdminsDL = $keywords + '_SiteAdminsDL'
$SiteAdminsU = $keywords + '_SiteAdminsU'
$local_path = $Path + 'group_members.csv'

$groups = $PCAdmin, $PCAdminDL, $ServerAdmins, $ServerAdminsDL, $ServerAdminsU, $SiteAdmins, $SiteAdminsDL, $SiteAdminsU

#Cycle through groups and get members
$results = foreach ($group in $groups) {
    Get-ADGroupMember $group | Select-Object @{n='GroupName';e={$group}}, @{n='Description';e={(Get-ADGroup $group -Properties description).description}}, name
}

#$results
$results | Export-csv $local_path -NoTypeInformation

#Task complete statement
Write-host "Task 9.3 completed.`n" -ForegroundColor $task_complete_color
}

#Function to run all tasks instead of just 1 at a time.
function Run_all {
Get-task9_1
Get-task9_2
Get-task9_3
}

#Function to exit the script.
function Quit {
Write-host "Exiting script now." -ForegroundColor $task_complete_color
exit
}

#Function to select which task you would like to complete.
function Select_task {
write-host "Select the number of the task you would like to run:
1: Task 9.1
2: Task 9.2
3: Task 9.3
4: 
5: 
6: 
7: 
8: 
9:  Run All
10: Exit script."

$userChoice = read-host -Prompt " "
switch($userChoice)
{
    1 {Get-task9_1}
    2 {Get-task9_2}
    3 {Get-task9_3}
    4 {}
    5 {}
    6 {}
    7 {}
    8 {}
    9 {Run_all}
    10 {Quit}
}
}
while($true){Select_task
}
