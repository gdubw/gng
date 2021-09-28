
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
$script:moduleTarget = Join-Path -Path $script:mm -ChildPath 'gng'
if (-Not (Test-Path -Path $script:moduleTarget)) {
    New-Item -Path $script:moduleTarget -ItemType Directory
}
Write-Debug "Module paths: source = $PSScriptRoot, target = $script:moduleTarget"
Copy-Item -Path (Join-Path -Path $PSScriptRoot -ChildPath 'gng.psm1') -Destination $script:moduleTarget -Force
$gradleDir = Join-Path -Path $PSScriptRoot -ChildPath '../gradle'
Copy-Item -Path (Join-Path -Path $gradleDir -ChildPath 'wrapper') -Destination $script:moduleTarget -Force
Copy-Item -Path (Join-Path -Path $gradleDir -ChildPath 'gng.json') -Destination $script:moduleTarget -Force
Copy-Item -Path (Join-Path -Path $gradleDir -ChildPath 'gradlew') -Destination $script:moduleTarget -Force
Copy-Item -Path (Join-Path -Path $gradleDir -ChildPath 'gradlew.bat') -Destination $script:moduleTarget -Force

Get-Module -ListAvailable gng | Format-List name, path
Import-Module -Verbose gng -Force

