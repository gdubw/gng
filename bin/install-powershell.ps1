
Param(
    [Parameter(
            Mandatory=$false,
            HelpMessage=@"
Which level of the Powershell modules folders is the target for this module?
"@)]
    [Int32]
    $level = 0
    )
$script:moduleTitle = 'GradleWrapperModule'

$script:mm = ($ENV:PSModulePath -split ';')[$level]
$script:moduleTarget = Join-Path -Path $script:mm -ChildPath $script:moduleTitle
if (-Not (Test-Path -Path $script:moduleTarget)) {
    New-Item -Path $script:moduleTarget -ItemType Directory
}
Write-Debug "Module paths: source = $PSScriptRoot, target = $script:moduleTarget"
Copy-Item -Path (Join-Path -Path $PSScriptRoot -ChildPath "${script:moduleTitle}.psm1") -Destination $script:moduleTarget -Force
#Copy-Item -Path (Join-Path -Path $PSScriptRoot -ChildPath "${script:moduleTitle}.psd1") -Destination $script:moduleTarget -Force

$gradleDir = Join-Path -Path $PSScriptRoot -ChildPath '../gradle'
Copy-Item -Path (Join-Path -Path $gradleDir -ChildPath 'wrapper') -Recurse -Destination $script:moduleTarget -Force
Copy-Item -Path (Join-Path -Path $gradleDir -ChildPath 'gng.yaml') -Destination $script:moduleTarget -Force
Copy-Item -Path (Join-Path -Path $gradleDir -ChildPath 'gradlew') -Destination $script:moduleTarget -Force
Copy-Item -Path (Join-Path -Path $gradleDir -ChildPath 'gradlew.bat') -Destination $script:moduleTarget -Force

#Get-Module -ListAvailable $script:moduleTitle | Remove-Module -Verbose -Force
Get-Module -ListAvailable $script:moduleTitle | Format-List
Import-Module -Verbose  $script:moduleTitle -Force


