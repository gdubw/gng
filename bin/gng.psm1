<#
  Gradle Wrapper Module
  This module contains a set of wrapper scripts that
  enable a user to perform Gradle tasks.
 #>

$script:psprovidername = "Microsoft-Windows-PowerShell"
$script:gradlewFileName = "gradlew.bat"

<#
This is the primary GNG function.
It performs an upward search for the gradlew.bat file and runs that.
It is mostly just a wrapper for gradlew but it adds a few parameters.
It does not include the incubating or deprecated paramters.
It allows for either the current directory or the gradlew.bat directory.
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
      $task = ':tasks',

      [Parameter(
              Mandatory=$false,
              HelpMessage=@"
The working directory, defaults to current directory.
"@)]
      [string]
      $workingDir = (Get-Location),

      [Parameter(
              Mandatory=$false,
              HelpMessage="Do not rebuild project dependencies.")]
      [switch]
      $noRebuild = $false,

      [Parameter(
              Mandatory=$false,
              HelpMessage="Enables the Gradle build cache. Gradle will try to reuse outputs from previous builds.")]
      [switch]
      $buildCache = $false,

      [Parameter(
              Mandatory=$false,
              HelpMessage="Specifies which type of console output to generate. Values are 'plain', 'auto' (default), 'rich' or 'verbose'.")]
      [string]
      $console = "auto",

      [Parameter(
              Mandatory=$false,
              HelpMessage="Continue task execution after a task failure.")]
      [switch]
      $continue = $false,

      [Parameter(
              Mandatory=$false,
              HelpMessage="Set system property of the JVM (e.g. -Dmyprop=myvalue).")]
      [string[]]
      $systemProp = $false,

      [Parameter(
              Mandatory=$false,
              HelpMessage="Log in debug mode (includes normal stacktrace).")]
      [switch]
      $debug = $false,

      [Parameter(
              Mandatory=$false,
              HelpMessage="Uses the Gradle Daemon to run the build. Starts the Daemon if not running.")]
      [switch]
      $daemon = $false,

      [Parameter(
              Mandatory=$false,
              HelpMessage="Configures the dependency verification mode (strict, lenient or off)")]
      [string]
      $dependencyVerification = $false,

      [Parameter(
              Mandatory=$false,
              HelpMessage="Starts the Gradle Daemon in the foreground.")]
      [switch]
      $foreground = $false,

      [Parameter(
              Mandatory=$false,
              HelpMessage="Specifies the gradle user home directory.")]
      [string]
      $gradleUserHome = $false,

      [Parameter(
              Mandatory=$false,
              HelpMessage="Specify an initialization script.")]
      [switch]
      $initScript = $false,

      [Parameter(
              Mandatory=$false,
              HelpMessage="Set log level to info.")]
      [switch]
      $info = $false,

      [Parameter(
          Mandatory=$false,
          HelpMessage="Include the specified build in the composite.")]
      [switch]
      $includeBuild  = $false,

      [Parameter(
          Mandatory=$false,
          HelpMessage="Generates checksums for dependencies used in the project (comma-separated list).")]
      [switch]
      $writeVerificationMetadata  = $false,

      [Parameter(
              Mandatory=$false,
              HelpMessage="Run the builds with all task actions disabled.")]
      [switch]
      $dryRun  = $false,

      [Parameter(
          Mandatory=$false,
          HelpMessage="Configure the number of concurrent workers Gradle is allowed to use.")]
      [Int32]
      $maxWorkers  = 3,
    
      [Parameter(
          Mandatory=$false,
          HelpMessage="Disables the Gradle build cache.")]
      [switch]
      $noBuildCache  = $false,
    
      [Parameter(
          Mandatory=$false,
          HelpMessage=@"
Do not use the Gradle daemon to run the build.
Useful occasionally if you have configured Gradle to always run with the daemon by default.
"@)]
      [switch]
      $noDaemon  = $false,
    
      [Parameter(
          Mandatory=$false,
          HelpMessage="Disables parallel execution to build projects.")]
      [switch]
      $noParallel  = $false,
    
      [Parameter(
          Mandatory=$false,
          HelpMessage=@"
Disables the creation of a build scan.
For more information about build scans, please visit https://gradle.com/build-scans.
"@)]
      [switch]
      $noScan  = $false,
    
      [Parameter(
          Mandatory=$false,
          HelpMessage="Disables watching the file system.")]
      [switch]
      $noWatchFs  = $false,
    
      [Parameter(
          Mandatory=$false,
          HelpMessage="Execute the build without accessing network resources.")]
      [switch]
      $offline  = $false,
    
      [Parameter(
          Mandatory=$false,
          HelpMessage="Set project property for the build script (e.g. -Pmyprop=myvalue).")]
      [string[]]
      $projectProp  = "",
    
      [Parameter(
          Mandatory=$false,
          HelpMessage="Specifies the start directory for Gradle. Defaults to current directory.")]
      [string]
      $projectDir  = (Get-Location),
    
      [Parameter(
          Mandatory=$false,
          HelpMessage="Build projects in parallel. Gradle will attempt to determine the optimal number of executor threads to use.")]
      [switch]
      $parallel  = $false,
    
      [Parameter(
          Mandatory=$false,
          HelpMessage=@"
Specifies the scheduling priority for the Gradle daemon and all processes launched by it.
Values are 'normal' (default) or 'low'
"@)]
      [switch]
      $priority  = "normal",
    
      [Parameter(
          Mandatory=$false,
          HelpMessage="Profile build execution time and generates a report in the <build_dir>/reports/profile directory.")]
      [switch]
      $profile = $false,

      [Parameter(
              Mandatory=$false,
              HelpMessage="Specify the project-specific cache directory. Defaults to .gradle in the root project directory.")]
      [string]
      $projectCacheDir  = ".gradle",

      [Parameter(
              Mandatory=$false,
              HelpMessage="Log errors only.")]
      [switch]
      $quiet  = $false,

      [Parameter(
              Mandatory=$false,
              HelpMessage="Refresh the state of dependencies.")]
      [switch]
      $refreshDependencies  = $false,

      [Parameter(
              Mandatory=$false,
              HelpMessage="Refresh the public keys used for dependency verification.")]
      [switch]
      $refreshKeys  = $false,

      [Parameter(
              Mandatory=$false,
              HelpMessage="Ignore previously cached task results.")]
      [switch]
      $rerunTasks  = $false,

      [Parameter(
              Mandatory=$false,
              HelpMessage="Print out the full (very verbose) stacktrace for all exceptions.")]
      [switch]
      $fullStacktrace  = $false,

      [Parameter(
              Mandatory=$false,
              HelpMessage="Print out the stacktrace for all exceptions.")]
      [switch]
      $stacktrace  = $false,

      [Parameter(
              Mandatory=$false,
              HelpMessage="Creates a build scan. Gradle will emit a warning if the build scan plugin has not been applied. (https://gradle.com/build-scans)")]
      [switch]
      $scan  = $false,

      [Parameter(
              Mandatory=$false,
              HelpMessage="Shows status of running and recently stopped Gradle Daemon(s).")]
      [switch]
      $status  = $false,

      [Parameter(
              Mandatory=$false,
              HelpMessage="Stops the Gradle Daemon if it is running.")]
      [switch]
      $stop  = $false,

      [Parameter(
              Mandatory=$false,
              HelpMessage="Enables continuous build. Gradle does not exit and will re-execute tasks when task file inputs change.")]
      [switch]
      $continuous  = $false,

      [Parameter(
              Mandatory=$false,
              HelpMessage="Print version info.")]
      [switch]
      $version  = $false,

      [Parameter(
              Mandatory=$false,
              HelpMessage="Set log level to warn.")]
      [switch]
      $warn  = $false,

      [Parameter(
              Mandatory=$false,
              HelpMessage="Specifies which mode of warnings to generate. Values are 'all', 'fail', 'summary'(default) or 'none'")]
      [string]
      $warningMode  = "summary",

      [Parameter(
              Mandatory=$false,
              HelpMessage=@"
Enables watching the file system for changes, allowing data about the file system to be re-used for the next build.
"@)]
      [switch]
      $watchFilesystem  = $false,

      [Parameter(
              Mandatory=$false,
              HelpMessage="Persists dependency resolution for locked configurations, ignoring existing locking information if it exists")]
      [switch]
      $writeLocks  = $false,

      [Parameter(
              Mandatory=$false,
              HelpMessage="Specify a task to be excluded from execution.")]
      [string[]]
      $excludeTask  = ""
  )

  Write-Debug "select $gradlewFileName starting in $workingDir"
  $path = if (-Not (Test-Path -Path $workingDir)) { Get-Location } else { $workingDir }
  $fileName = $script:gradlewFileName
  # https://stackoverflow.com/questions/45642517/search-directory-for-a-file-iterating-up-parent-directories-if-not-found
  while($path -and (-Not (Test-Path (Join-Path $path $fileName)))) {
    Write-Debug "candidate path $path $fileName"
    if ($path -eq ((Split-Path $path -Qualifier)+"/")) {
      break
    }
    $path = Split-Path $path -Parent
  }
  $gradlewPath = (Join-Path $path $fileName)
  if (-Not (Test-Path -Path $gradlewPath))
  {
    Write-Error "No ${gradlew} set up for this project; Please use 'Install-Gradle'."
    Exit-PSHostProcess
  }
  Write-Debug "Using gradle at '${gradlewPath}' to run"
  $gradlewDir = (Split-Path -Path $gradlewPath -Parent)
  $jsonConfFile = Join-Path $gradlewDir 'gradle/gng.json'
  $jsonConf = if (Test-Path -Path $jsonConfFile) {
      Get-Content (Join-Path (Join-Path $gradlewDir 'gradle') 'gng.json') | Out-String | ConvertFrom-Json
  } else {
      ConvertFrom-Json ''
  }
  Write-Debug "gradlew configuration '${jsonConf}'"
  $procOptions = @{
    FilePath = $gradlewPath
    WorkingDirectory = $gradlewDir
    ArgumentList = $task
    Wait = $True
    PassThru = $True
    NoNewWindow = $True
  }
  [string[]] $procOptionString = $procOptions.GetEnumerator().ForEach({ "$($_.Name)=$($_.Value)" })
  Write-Debug "gradlew command '$procOptionString'"
  Start-Process @procOptions
}

<#
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


# manage certificates
# use https://docs.oracle.com/javase/8/docs/technotes/tools/unix/keytool.html

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