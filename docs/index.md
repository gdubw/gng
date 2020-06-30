![](https://github.com/dantesun/gng/workflows/Validate%20Gradle%20Wrapper/badge.svg)

# GNG is Not Gradle

GNG is a script that automatically search your `gradlew` when you are inside your Gradle project and execute it. It also provides a bootstrap function installing any Gradle wrapper version you prefer If you are creating a new Gradle project.

This is originally inspired by [gdub](https://www.gdub.rocks/) and [gradlew-bootstrap](https://github.com/viphe/gradlew-bootstrap). I shamelessly steal some code from them.

## What's the problem?

I worked with a lot of gradle projects, every project has its own Gradle Wrapper. So the global installed one, normally installed with `brew install gradle`, is seldom used. In fact, the global installed gradle’s version may conflict with the project you are working on and some weird and unexpected building failures may happen. **The best practice is always using Gradle Wrapper comes with a project.** It's more better to not keep a copy of global available gradle. 

But keep typing `./gradlew` is cumbersome. It becoms even worse when you have to type `../gradlew`, or `../../gradlew`.

I am a heavy Gradle user, I always need to create a new Gradle project for trying some new ideas, without the globally installed gradle , it is not possible installing Gradle Wrapper into a brand new project. 

The followings are quoted from http://gdub.rocks
>    ## The problems with `gradle` and `gradlew`
>    gdub is a convenience for developers running local Gradle commands and addresses
>    a few minor shortcomings of `gradle` and `gradlew`'s commandline behaviour.
>    These are known issues, and they are set to be addressed in future versions of
>    Gradle. If you are interested in the discussions surrounding them, check out:
>    
>      - [Issue Gradle-2429](http://issues.gradle.org/browse/Gradle-2429)
>      - [Spencer Allain's Gradle Forum Post](http://gsfn.us/t/33g0l)
>      - [Phil Swenson's Gradle Forum Post](http://gsfn.us/t/39h67)
>    
>    Here are the issues I feel are most important, and the ones gdub attempts to
>    address:
>    
>    ### You have to provide a relative path to `build.Gradle`
>    If you are using the `gradle` command, and you are not in the same directory as
>    the `build.gradle` file you want to run, you have to provide `gradle` the path.
>    Depending on where you happen to be, this can be somewhat cumbersome:
>    
>    ```bash
>    $ pwd
>    ~/myProject/src/main/java/org/project
>    $ gradle -b ../../../../../build.gradle build
>    ```
>    
>    With `gw`, this becomes:
>    
>    ```bash
>    $ gw build
>    ```
>    
>    ### You have to provide a relative path to `gradlew`
>    If you are using `gradlew` and you want to run your build, you need to do
>    something similiar and provide the relative path to the `gradlew` script:
>    
>    ```bash
>    $ pwd
>    ~/myProject/src/main/java/org/project/stuff
>    $ ../../../../../../gradlew build
>    ```
>    
>    Again, with `gw` this becomes:
>    
>    ```bash
>    $ gw build
>    ```
>    
>    ### You have a combination of the above problems
>    I don't even want to type out an example of this, let alone do it on a
>    day-to-day basis. Use your imagination.
>    
>    ### Typing `./gradlew` to run the Gradle wrapper is kind of inconvenient
>    Even with tab completion and sitting at the root of your project, you have to
>    type at least `./gr<tab>`. It gets a bit worse if you happen to have a
>    `Gradle.properties` file, and with the Gradle wrapper, you have a `gradle`
>    directory to contend with as well. A simple alias would solve this problem, but
>    you still have the other (more annoying) issues to contend with.
>    
>    ### You meant to use the project's `gradlew`, but typed `gradle` instead
>    This can be a problem if the project you are building has customizations to the
>    Gradle wrapper or for some reason is only compatible with a certain version of
>    Gradle that is configured in the wrapper. If you know the project uses Gradle,
>    you may be tempted to just use your own system's Gradle binary. This might be
>    ok, or it might cause the build to break, but if a project has a `gradlew`, it
>    is a pretty safe bet you should use it, and not whatever Gradle distribution you
>    happen to have installed on your system.

# Usage

Just type `gng` whenever you need to type `gradle` or `gradlew`, then your life will be easier.

If you don't have any Gradle or Gradle Wrapper installed, please don't worry. just type `gng --bootstrap`. It will create a Gradle wrapper in your current
working directory. By default, `gng` installs Gradle wrapper with the latest version of Gradle. 

The latest version is from https://services.gradle.org/versions/current

```text
gng --bootstrap [version] [distType]

version: Gradle version, like 6.5, 4.2.1, ...etc. 'latest' will install the latest gradle distribution

distType: 'all' for Gradle Distribution with source code, 'bin' for binary distribution.
```

Example: This command will install the latest version with Gradle distribution including source code.
```bash
gng --bootstrap latest all
```
It will output like this(version number may vary as time goes by):
```bash
Running the embedded wrapper ...
[GNG] Gradle Wrapper 6.5 installed, distributionUrl=https://services.gradle.org/distributions/gradle-6.5-all.zip
```
## More examples

1. `gng --bootstrap` will silently upgrade your existing Gradle Wrapper to the latest version
2. `gng --bootstrap 4.8.1` will silently upgrade your existing Gradle Wrapper to the version 4.8.1
2. `gng --bootstrap latest all` will silently upgrade your existing Gradle Wrapper to the latest version with Gradle source code archive.

# Installation

## Homebrew (TODO)

I am still working on it ...

## Installing from source

```bash
git clone https://github.com/dantesun/gng.git
cd gng
sudo ./install
```

## Aliasing the `gradle` command
To avoid using any system wide Gradle distribution add a `gradle` alias to `gw` to your shell's configuration file.

Example *bash*:

```text
echo "alias gradle=gng" >> ~/.bashrc
echo "export PATH=/usr/local/bin:${PATH}" >> ~/.bashrc
source ~/.bashrc
```

## install.sh usage
```bash
sudo ./install.sh [-fhsu]

Install gng from git source tree. See http://github.com/dantesun/gng for details.

-u uninstall
-f re-install
-h usage
-s check for update
```
examples:
1. `./install.sh -f` will re-install everything
2. `./install.sh -s` will check for latest updates from remote master
3. `git reset --hard && git pull` will keep your copy to the latest


# How does GNG install your Gradle Wrapper?

Internally, it uses an embedded Gradle Wrapper with version 1.0 distribution. The reason use `1.0` is the small distribution package size.
You can trust the embedded gradle-wrapper.jar. It is verified by [Gradle Wrapper Validation](https://github.com/marketplace/actions/gradle-wrapper-validation) ![](https://github.com/dantesun/gng/workflows/Validate%20Gradle%20Wrapper/badge.svg).
