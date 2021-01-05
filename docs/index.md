![](https://github.com/dantesun/gng/workflows/Validate%20Gradle%20Wrapper/badge.svg)

# GNG is merging with gdub

I am working on merge gng and gdub together after talked with the author of `gdub`. `gng` will still be kept as a symbol link to `gw`.

# GNG is Not Gradle

GNG is a script that automatically search your `gradlew` when you are inside your Gradle project and execute it. It also provides a bootstrap function installing any Gradle wrapper version you prefer If you are creating a new Gradle project.

This is originally inspired by [gdub](https://www.gdub.rocks/) and [gradlew-bootstrap](https://github.com/viphe/gradlew-bootstrap). I shamelessly steal some code from them.

## What's the problem?

I worked with a lot of gradle projects, every project has its own Gradle Wrapper. So the global installed one, normally installed with `brew install gradle`, is seldom used. In fact, the global installed gradle’s version may conflict with the project you are working on and some weird and unexpected building failures may happen. **The best practice is always using Gradle Wrapper comes with a project.** It's more better to not keep a copy of global available gradle.

But keep typing `./gradlew` is cumbersome. It becoms even worse when you have to type `../gradlew`, or `../../gradlew`.

I am a heavy Gradle user, I always need to create a new Gradle project for trying some new ideas,
without the globally installed gradle , it is not possible installing Gradle Wrapper into a brand new project.

You might interest in these discussions.
>
> Quoted from [gdub](https://gdub.rocks)
>
> - [Issue Gradle-2429](http://issues.gradle.org/browse/Gradle-2429)
> - [Spencer Allain's Gradle Forum Post](http://gsfn.us/t/33g0l)
> - [Phil Swenson's Gradle Forum Post](http://gsfn.us/t/39h67)
>

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
