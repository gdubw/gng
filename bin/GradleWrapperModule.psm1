<#
  Gradle Wrapper Module
  This module contains a set of wrapper scripts that
  enable a user to perform Gradle tasks.
 #>

$script:psprovidername = "Microsoft-Windows-PowerShell"
$script:baseGradlewFileName = "gradlew"

<#
.SYNOPSIS

It is mostly just a wrapper for gradlew with some additional parameters.

.DESCRIPTION

This is the primary GNG function.
It performs an upward search for the $script:baseGradlewFileName and runs that.
It does not include the incubating or deprecated paramters.
It allows for either the current directory or the $script:baseGradlewFileName directory.

Defaults for some values are read from the gng.yaml configuration file.
#>
function Invoke-Gradle {
  param(
      [Parameter(
              Mandatory=$false,
              HelpMessage=@"
The gradle task to run preceed it with a ':'.
By default runs the ':tasks' task.
"@)]
      [string[]]
      $Tasks = ':tasks',
  #
      [Parameter(
              Mandatory=$false,
              HelpMessage=@"
The working directory, defaults to current directory.
"@)]
      [string]
      $WorkingDir = (Get-Location),
  #
      [Alias('w')]
      [Parameter(
              Mandatory=$false,
              HelpMessage=@"
Use the working directory, defaults to false, i.e. use the gradlew-directory.
"@)]
      [switch]
      $UseWorkingDirectory = $false,
  #
      [Parameter(
              Mandatory=$false,
              HelpMessage="Do not rebuild project dependencies.")]
      [switch]
      $NoRebuild = $false,
  #
      [Parameter(
              Mandatory=$false,
              HelpMessage="Enables the Gradle build cache. Gradle will try to reuse outputs from previous builds.")]
      [switch]
      $BuildCache = $false,
  #
      [Parameter(
              Mandatory=$false,
              HelpMessage=@"
Specifies which type of console output to generate. default: 'auto'.
"@)]
      [ValidateNotNullOrEmpty()]
      [ValidateSet('plain','auto','rich','verbose')]
      [string]
      $Console = "auto",
  #
      [Parameter(
              Mandatory=$false,
              HelpMessage="Continue task execution after a task failure.")]
      [switch]
      $Continue = $false,
  #
      [Parameter(
              Mandatory=$false,
              HelpMessage="Set system property of the JVM (e.g. -Dmyprop=myvalue).")]
      [string]
      $SystemProp,
  #
      [Parameter(
              Mandatory=$false,
              HelpMessage="Log in debug mode (includes normal stacktrace).")]
      [switch]
      $GradleDebug = $false,
  #
      [Parameter(
              Mandatory=$false,
              HelpMessage="Set log level to warn.")]
      [switch]
      $GradleWarn  = $false,
  #
      [Parameter(
              Mandatory=$false,
              HelpMessage="Set log level to info.")]
      [switch]
      $GradleInfo = $false,
  #
      [Parameter(
              Mandatory=$false,
              HelpMessage="Log errors only.")]
      [switch]
      $GradleQuiet  = $false,
  #
      [Parameter(
              Mandatory=$false,
              HelpMessage="Uses the Gradle Daemon to run the build. Starts the Daemon if not running.")]
      [switch]
      $Daemon = $false,
  #
      [Parameter(
              Mandatory=$false,
              HelpMessage="Configures the dependency verification mode, default: 'off'")]
      [ValidateNotNullOrEmpty()]
      [ValidateSet('strict','lenient','off')]
      [string]
      $DependencyVerification = 'off',
  #
      [Parameter(
              Mandatory=$false,
              HelpMessage="Starts the Gradle Daemon in the foreground.")]
      [switch]
      $Foreground = $false,
      #
      [Parameter(
              Mandatory=$false,
              HelpMessage="Specifies the gradle user home directory.")]
      [string]
      $GradleUserHome,
  #
      [Parameter(
              Mandatory=$false,
              HelpMessage="Specify an initialization script.")]
      [string]
      $InitScript,
  #
      [Parameter(
          Mandatory=$false,
          HelpMessage="Include the specified build in the composite.")]
      [string]
      $IncludeBuild,
  #
      [Parameter(
          Mandatory=$false,
          HelpMessage="Generates checksums for dependencies used in the project (comma-separated list).")]
      [switch]
      $WriteVerificationMetadata  = $false,
  #
      [Parameter(
              Mandatory=$false,
              HelpMessage="Run the builds with all task actions disabled.")]
      [switch]
      $DryRun  = $false,
  #
      [Parameter(
          Mandatory=$false,
          HelpMessage="Configure the number of concurrent workers Gradle is allowed to use.")]
      [Int32]
      $MaxWorkers  = 3,
  #
      [Parameter(
          Mandatory=$false,
          HelpMessage="Disables the Gradle build cache.")]
      [switch]
      $NoBuildCache  = $false,
  #
      [Parameter(
          Mandatory=$false,
          HelpMessage=@"
Do not use the Gradle daemon to run the build.
Useful occasionally if you have configured Gradle to always run with the daemon by default.
"@)]
      [switch]
      $NoDaemon  = $false,
  #
      [Parameter(
          Mandatory=$false,
          HelpMessage="Disables parallel execution to build projects.")]
      [switch]
      $NoParallel  = $false,
  #
      [Parameter(
          Mandatory=$false,
          HelpMessage=@"
Disables the creation of a build scan.
For more information about build scans, please visit https://gradle.com/build-scans.
"@)]
      [switch]
      $NoScan  = $false,
  #
      [Parameter(
          Mandatory=$false,
          HelpMessage="Disables watching the file system.")]
      [switch]
      $NoWatchFs  = $false,
  #
      [Parameter(
          Mandatory=$false,
          HelpMessage="Execute the build without accessing network resources.")]
      [switch]
      $Offline  = $false,
  #
      [Parameter(
          Mandatory=$false,
          HelpMessage="Set project property for the build script (e.g. -Pmyprop=myvalue).")]
      [string]
      $ProjectProp  = "",
  #
      [Parameter(
          Mandatory=$false,
          HelpMessage="Specifies the start directory for Gradle. Defaults to current directory.")]
      [string]
      $ProjectDir  = (Get-Location),
  #
      [Parameter(
          Mandatory=$false,
          HelpMessage="Build projects in parallel. Gradle will attempt to determine the optimal number of executor threads to use.")]
      [switch]
      $Parallel  = $false,
  #
      [Parameter(
          Mandatory=$false,
          HelpMessage=@"
Specifies the scheduling priority for the Gradle daemon and all processes launched by it. default: 'normal'
"@)]
      [ValidateNotNullOrEmpty()]
      [ValidateSet('normal','low')]
      [string]
      $Priority  = "normal",
  #
      [Parameter(
          Mandatory=$false,
          HelpMessage="Profile build execution time and generates a report in the <build_dir>/reports/profile directory.")]
      [switch]
      $Profile = $false,
  #
      [Parameter(
              Mandatory=$false,
              HelpMessage="Specify the project-specific cache directory. Defaults to .gradle in the root project directory.")]
      [string]
      $ProjectCacheDir  = ".gradle",
  #
      [Parameter(
              Mandatory=$false,
              HelpMessage="Refresh the state of dependencies.")]
      [switch]
      $RefreshDependencies  = $false,
  #
      [Parameter(
              Mandatory=$false,
              HelpMessage="Refresh the public keys used for dependency verification.")]
      [switch]
      $RefreshKeys  = $false,
  #
      [Parameter(
              Mandatory=$false,
              HelpMessage="Ignore previously cached task results.")]
      [switch]
      $RerunTasks  = $false,
  #
      [Parameter(
              Mandatory=$false,
              HelpMessage="Print out the full (very verbose) stacktrace for all exceptions.")]
      [switch]
      $FullStacktrace  = $false,
  #
      [Parameter(
              Mandatory=$false,
              HelpMessage="Print out the stacktrace for all exceptions.")]
      [switch]
      $Stacktrace  = $false,
  #
      [Parameter(
              Mandatory=$false,
              HelpMessage="Creates a build scan. Gradle will emit a warning if the build scan plugin has not been applied. (https://gradle.com/build-scans)")]
      [switch]
      $Scan  = $false,
  #
      [Parameter(
              Mandatory=$false,
              HelpMessage="Shows status of running and recently stopped Gradle Daemon(s).")]
      [switch]
      $Status  = $false,
  #
      [Parameter(
              Mandatory=$false,
              HelpMessage="Stops the Gradle Daemon if it is running.")]
      [switch]
      $Stop  = $false,
  #
      [Parameter(
              Mandatory=$false,
              HelpMessage="Enables continuous build. Gradle does not exit and will re-execute tasks when task file inputs change.")]
      [switch]
      $Continuous  = $false,
  #
      [Parameter(
              Mandatory=$false,
              HelpMessage="Print version info.")]
      [switch]
      $Version  = $false,
  #
      [Parameter(
              Mandatory=$false,
              HelpMessage="Specifies which mode of warnings to generate. default 'summary'")]
      [ValidateNotNullOrEmpty()]
      [ValidateSet('all','fail','summary','none')]
      [string]
      $WarningMode  = "summary",
  #
      [Parameter(
              Mandatory=$false,
              HelpMessage=@"
Enables watching the file system for changes, allowing data about the file system to be re-used for the next build.
"@)]
      [switch]
      $Watch  = $false,
  #
      [Parameter(
              Mandatory=$false,
              HelpMessage="Persists dependency resolution for locked configurations, ignoring existing locking information if it exists")]
      [switch]
      $WriteLocks  = $false,
  #
      [Alias('x')]
      [Parameter(
              Mandatory=$false,
              HelpMessage="Specify tasks to be excluded from execution.")]
      [string[]]
      $ExcludeTask
  )

  Write-Debug "select $baseGradlewFileName starting in $WorkingDir"
  $path = if (-Not (Test-Path -Path $WorkingDir)) { Get-Location } else { $WorkingDir }
  $gradlewFileName = $script:baseGradlewFileName
  # https://stackoverflow.com/questions/45642517/search-directory-for-a-file-iterating-up-parent-directories-if-not-found
  while($path -and (-Not (Test-Path (Join-Path $path $gradlewFileName)))) {
    Write-Debug "candidate path $path $gradlewFileName"
    if ($path -eq ((Split-Path $path -Qualifier)+"/")) {
      break
    }
    $path = Split-Path $path -Parent
  }
  $gradlewPath = (Join-Path $path $gradlewFileName)
  if (-Not (Test-Path -Path $gradlewPath))
  {
    Write-Error "No ${gradlew} set up for this project; Please use 'Install-Gradle'."
    Exit-PSHostProcess
  }
  Write-Debug "Using gradle at '${gradlewPath}' to run"
  $gradlewDir = (Split-Path -Path $gradlewPath -Parent)
  $yamlConfFile = Join-Path $gradlewDir 'gradle/gng.yaml'
  $defaultYamlConfFile = Join-Path $PSScriptRoot "gng.yaml"

  $yamlConf = if (Test-Path -Path $yamlConfFile) {
      Get-Content $yamlConfFile | Out-String | ConvertFrom-Yaml
  } elseif (Test-Path -Path $defaultYamlConfFile) {
      Get-Content $defaultYamlConfFile | Out-String | ConvertFrom-Yaml
  } else {
      ConvertFrom-Yaml @'
options:
'@
  }
  # Add default JVM options here.
  $defaultJvmOpts = $yamlConf["options"]["jvm"]
  $defaultGradleOpts = $yamlConf["options"]["gradle"]

  $gradleArgList = @()

  if ($NoRebuild) { $gradleArgList += '--no-rebuild' }
  if ($BuildCache) { $gradleArgList += '--build-cache' }
  if ($Continue) { $gradleArgList += '--continue' }
  if ($GradleDebug) { $gradleArgList += '--debug' }
  if ($GradleWarn) { $gradleArgList += '--warn' }
  if ($GradleInfo) { $gradleArgList += '--info' }
  if ($GradleQuiet) { $gradleArgList += '--quiet' }
  if ($Daemon) { $gradleArgList += '--daemon' }
  if ($Foreground) { $gradleArgList += '--foreground' }
  if ($WriteVerificationMetadata) { $gradleArgList += '--write-verification-metadata' }
  if ($DryRun) { $gradleArgList += '--dry-run' }
  if ($NoBuildCache) { $gradleArgList += '--no-build-cache' }
  if ($NoDaemon) { $gradleArgList += '--no-daemon' }
  if ($NoParallel) { $gradleArgList += '--no-parallel' }
  if ($NoScan) { $gradleArgList += '--no-scan' }
  if ($NoWatchFs) { $gradleArgList += '--no-watch-fs' }
  if ($Offline) { $gradleArgList += '--offline' }
  if ($Parallel) { $gradleArgList += '--parallel' }
  if ($Profile) { $gradleArgList += '--profile' }
  if ($RefreshDependencies) { $gradleArgList += '--refresh-dependencies' }
  if ($RefreshKeys) { $gradleArgList += '--refresh-keys' }
  if ($RerunTasks) { $gradleArgList += '--rerun-tasks' }
  if ($FullStacktrace) { $gradleArgList += '--full-stacktrace' }
  if ($Stacktrace) { $gradleArgList += '--stacktrace' }
  if ($Scan) { $gradleArgList += '--scan' }
  if ($Status) { $gradleArgList += '--status' }
  if ($Stop) { $gradleArgList += '--stop' }
  if ($Continuous) { $gradleArgList += '--continuous' }
  if ($Version) { $gradleArgList += '--version' }
  if ($Watch) { $gradleArgList += '--watch-fs' }
  if ($WriteLocks) { $gradleArgList += '--write-locks' }

  if ($SystemProp.Length -gt 0) { $gradleArgList += @('--system-prop', $SystemProp) }
  if ($ProjectProp.Length -gt 0) { $gradleArgList += @('--project-prop', $ProjectProp) }
  if ($GradleUserHome.Length -gt 0) { $gradleArgList += @('--gradle-user-home', $GradleUserHome) }
  if ($InitScript.Length -gt 0) { $gradleArgList += @('--init-script', $InitScript) }
  if ($IncludeBuild.Length -gt 0) { $gradleArgList += @('--include-build', $IncludeBuild) }
  if ($ProjectDir.Length -gt 0) { $gradleArgList += @('--project-dir', $ProjectDir) }
  if ($ProjectCacheDir.Length -gt 0) { $gradleArgList += @('--project-cache-dir', $ProjectCacheDir) }

  if ($Console -ne 'auto') { $gradleArgList += @('--console', $Console) }
  if ($DependencyVerification -ne 'off') { $gradleArgList += @('--dependency-verification', $DependencyVerification) }
  if ($Priority -ne 'normal') { $gradleArgList += @('--priority', $Priority) }
  if ($WarningMode -ne 'summary') { $gradleArgList += @('--warning-mode', $WarningMode) }

  $gradleArgList += @('--max-workers', $MaxWorkers)

  Foreach ($xtask in $ExcludeTask) {
      $gradleArgList += @('--exclude-task') + $xtask
  }
  $gradleArgList += $Tasks
  Write-Debug "gradlew argument list '${gradleArgList}'"
  Write-Debug "gradlew configuration '${yamlConf}'"

  # We bypass the gradlew.bat and run the java program directly.
  # The gradlew.bat script only does a few things.
  $appBaseName = $gradlewFileName
  $appHome = $gradlewDir

  if (Test-Path $env:JAVA_HOME)  {
      $javaHome = $env:JAVA_HOME.Replace('"','')
      $javaExe = Join-Path -Path $env:JAVA_HOME -ChildPath "bin/java.exe"

      if (-Not (Test-Path $javaExe)) {
          Write-Error @"
JAVA_HOME is set to an invalid directory: $javaHome
Please set the JAVA_HOME variable in your environment to match the
location of your Java installation.
"@
      }
  } else {
      $javaExe = Get-Command "java.exe"
      if (-Not (Test-Path $javaExe)) {
          Write-Error @"
JAVA_HOME is not set and no 'java' command could be found in your PATH.
Please set the JAVA_HOME variable in your environment to match the
location of your Java installation.
"@
      }
      $javaHome = Split-Path -Path (Split-Path -Path $javaExe -Parent) -Parent
  }
  $classPath = Join-Path -Path $appHome -ChildPath 'gradle/wrapper/gradle-wrapper.jar'
  $javaArgList = @()
  if ($Watch) { $gradleArgList += '--watch-fs' }

  $javaArgList = @()

  # You can also use JAVA_OPTS and GRADLE_OPTS to pass JVM options to this script.
  if (Test-Path -Path $env:JAVA_OPTS -ErrorAction SilentlyContinue) {
      $javaArgList += $env:JAVA_OPTS
  } elseif (-Not ($defaultJvmOpts -eq $null)) {
      $javaArgList += $defaultJvmOpts
  }
  if (Test-Path -Path $env:GRADLE_OPTS -ErrorAction SilentlyContinue) {
      $javaArgList += $env:GRADLE_OPTS
  } elseif (-Not ($defaultGradleOpts -eq $null)) {
      $javaArgList += $defaultGradleOpts
  }
  $javaArgList += @(
      "-Dorg.gradle.appname=$appBaseName",
      '-classpath', $classPath,
      'org.gradle.wrapper.GradleWrapperMain'
  )
  $workingDirectory = if ($UseWorkingDirectory) { $WorkingDir } else { $gradlewDir }
  $argList = $javaArgList + $gradleArgList
  Write-Debug "start-process argList '$argList'"
  $procOptions = @{
      FilePath = $javaExe
      WorkingDirectory = $workingDirectory
      ArgumentList = $argList
      Wait = $True
      PassThru = $True
      NoNewWindow = $True
  }
  [string[]] $procOptionString = $procOptions.GetEnumerator().ForEach({ "$($_.Name)=$($_.Value)" })
  Write-Debug "start-process '$procOptionString'"

  $rc = Start-Process @procOptions
  if ($rc.ExitCode -eq 0) {
      Write-Debug "gradlew task complete"
  } else {
      Write-Error "gradle task complete with error ${rc.ExitCode}"
  }
}

<#
.SYNOPSIS

The wrapper does not make use of the gradle wrapper task.
Instead it replicates the behavior of that script.
This is because GNG has some configuration properties to install in the project as well.
#>
function Install-GradleWrapper {
    Param(
        [Parameter(
                Mandatory=$false,
                HelpMessage=@"
Gradle Version (default: 'latest')
Version information is from https://services.gradle.org/versions/current,
visit https://services.gradle.org/versions/all for all available versions)
"@)]
        [string]
        $version = 'latest',

        [Parameter(
                Mandatory=$false,
                HelpMessage="Gradle Distribution Type (default: 'all')")]
        [string]
        $distributionType = 'all',

        [Parameter(
                Mandatory=$false,
                HelpMessage=@"
Gradle Distribution Mirror URL Prefix
(Optional with no default value. The url prefix replaces https://services.gradle.org/distributions/)
It replaces the whole distributionUrl except the file part in a URL.
For example, if specify '-m "https://example.com/gradle/"',
then "https://services.gradle.org/distributions/gradle-6.8-all.zip"
will become "https://example.com/gradle/gradle-6.8-all.zip"
"@)]
        [string]
        $mirrorUrl,

        [Parameter(
                Mandatory=$false,
                HelpMessage=@"
The folder location where generated Gradle Wrapper(default: 'Your current working directory')
"@)]
        [string]
        $destinationDir = (Get-Location)
    )
    if ($version -eq 'latest') {
      Write-Information "Fetching the latest Gradle version from services.gradle.org"
      $gradleInfo = Invoke-WebRequest -Uri "https://services.gradle.org/versions/current" | ConvertFrom-Json
      Write-Information "The latest Gradle version is ${gradleInfo}"
    }
    $dir = if (-not (Test-Path -Path $destinationDir -PathType Container)) {
        New-Item -ItemType Directory -Force -Path (Join-Path $dir 'gradle/wrapper')
    } else { $destinationDir }
    Write-Information @"
Installing Gradle Wrapper in ${dir}. (version=${version}, distributionType=${distributionType}, mirrorUrl=${mirrorUrl})
"@

    #Copy the embedded Gradle Wrapper
    $srcDir = $PSScriptRoot
    Copy-Item -LiteralPath (Join-Path $srcDir 'gng.cfg') -Destination (Join-Path $dir 'gradle') -Force
    Copy-Item -LiteralPath (Join-Path $srcDir 'gradlew') -Destination $dir -Force
    Copy-Item -LiteralPath (Join-Path $srcDir 'gradlew.bat') -Destination $dir -Force
    Copy-Item -LiteralPath (Join-Path $srcDir 'wrapper/gradle-wrapper.jar') `
        -Destination (Join-Path $dir 'gradle/wrapper') -Force

    $distributionUrl = $mirrorUrl -replace '[#\!=:]','\$0'
    $distributionUrl = Join-Path $distributionUrl "gradle-${version}-${type}.zip"
    @"
#Generated by GNG
distributionBase=GRADLE_USER_HOME
distributionPath=wrapper/dists
distributionUrl=${distributionUrl}
zipStoreBase=GRADLE_USER_HOME
zipStorePath=wrapper/dists
"@ | Out-File -FilePath (Join-Path $dir 'gradle/wrapper/gradle-wrapper.properties') -Force

}


<#
.SYNOPSIS

Manage certificates

.LINK

https://docs.oracle.com/javase/8/docs/technotes/tools/unix/keytool.html
#>
function Get-GradleCert {
  Param(
    [Parameter(
            Mandatory=$false,
            HelpMessage=@"
host
"@)]
    [string]
    $host = 'localhost',

      [Parameter(
              Mandatory=$false,
              HelpMessage=@"
port
"@)]
      [string]
      $port = '443',

      [Parameter(
              Mandatory=$true,
              HelpMessage=@"
provide the keystore password
"@)]
      [SecureString]
      $password
  )
  $keytoolPath = (Get-Command keytool).Source
  $keytoolDir = (Split-Path -Path $keytoolPath -Parent)
  $keystoreFile = (Join-Path -Path $keytoolDir -ChildPath '/../lib/security/cacerts')
  & keytoolPath -printcert -sslserver "${host}:${port}" -rfc | keytoolPath -import -noprompt -alias "${host}" -keystore "${keystoreFile}" -storepass "${password}"
}

Set-Alias gw Invoke-Gradle
Set-Alias gng Install-GradleWrapper

Export-ModuleMember -Function Invoke-Gradle, Install-GradleWrapper, Get-Gradle-Cert -Alias gw, gng