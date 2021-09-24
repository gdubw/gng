
Param(
    [Parameter(
            Mandatory=$false,
            HelpMessage=@"
Which level of the Powershell modules folders is the target for this module?
"@)]
    [Int32]
    $level = 0
    )

$script:mm = ($ENV:PSModulePath -split ';')[$level]
$script:mmPath = Join-Path -Path $script:mm -ChildPath 'gng'
if (-Not (Test-Path -Path $script:mmPath)) {
    New-Item -Path $script:mmPath -ItemType Directory
}

Copy-Item -Path (Join-Path -Path $PSScriptRoot -ChildPath 'gng.psm1') -Destination (Join-Path -Path $script:mm -ChildPath 'gng')
$gradleDir = Join-Path -Path $PSScriptRoot -ChildPath '../gradle'
Copy-Item -Path (Join-Path -Path $gradleDir -ChildPath 'wrapper') -Destination (Join-Path -Path $script:mm -ChildPath 'gng')
Copy-Item -Path (Join-Path -Path $gradleDir -ChildPath 'gng.json') -Destination (Join-Path -Path $script:mm -ChildPath 'gng')
Copy-Item -Path (Join-Path -Path $gradleDir -ChildPath 'gradlew') -Destination (Join-Path -Path $script:mm -ChildPath 'gng')
Copy-Item -Path (Join-Path -Path $gradleDir -ChildPath 'gradlew.bat') -Destination (Join-Path -Path $script:mm -ChildPath 'gng')

Get-Module -ListAvailable gng | Format-List name, path
Import-Module -Verbose gng

