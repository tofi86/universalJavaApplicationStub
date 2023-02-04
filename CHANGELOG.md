# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).


## [3.3.0] - 2023-02-04

PLEASE NOTE: This is the last official release as I'm going to sunset this project for personal reasons.

### Added
- Support country specific locales such as Brazilian Portuguese (`pt-BR`)
- Translation of messages to Brazilian Portuguese (#115, Thanks to @israelins85 for his contribution)

### Changed
- Changed Adopt OpenJDK link and name to Adoptium

### Removed
- Option to fund this project


## [3.2.0] - 2021-02-21
### Added
- Also expand variables `$APP_PACKAGE`, `$JAVAROOT` and `$USER_HOME` in Oracle style PList files
- Also expand variable `$APP_ROOT` in Apple style PList files
- Oracle JVMDefaultOptions key: expand variables $APP_PACKAGE, $APP_ROOT, $JAVAROOT, $USER_HOME (#99)

### Changed
- Improved language detection by reading the user preferred languages from the macOS System Preferences instead of using the system locale (#101, thanks to @Flexperte for his valuable feedback)
- Improved logging for JAVA_HOME detection (#100)

### Fixed
- Fixed a crash when `/usr/libexec/java_home` returns no JVMs (#93)


## [3.1.0] - 2021-01-07
### Added
- Support for macOS 11.0 "Big Sur" (#91)
- Support for JDK's installed via SDKMAN! (#95)
- Apple `VMOptions` key: expand variables `$APP_PACKAGE`, `$JAVAROOT`, `$USER_HOME` (#84)
- Translation of messages to Spanish (PR #88, Thanks to @fvarrui for his contribution)
- Added a CI action for automated releases that builds and publishes binary releases with `shc` (#85, #87, PR #96)

### Changed
- Suppress empty `-splash` option if no splash image is specified in `Info.plist` (#94)
- Replace Travis CI with GitHub Actions CI


## [3.0.6] - 2020-03-19
### Fixed
- Fixed an issue related to Java 4-8 version number detection (PR #81, Thanks to @thatChadM for his contribution)


## [3.0.5] - 2019-12-15
### Added
- If java is missing, offer a choice between Oracle and AdoptOpenJDK download buttons (#78)
- Support Array style `Java:Arguments` for Apple Plist style (#76)

### Fixed
- Bugfix: do not crash if `CFBundleIconFile` is provided without ".icns" extension (#75)
- Minor French translation fix (PR #73, Thanks to @ebourg for his contribution)


## [3.0.4] - 2018-08-24
### Fixed
- Bugfix: Variables `$APP_PACKAGE`, `$JAVAROOT`, `$USER_HOME` in `JVMOptions` key (Oracle) or `Java:Properties` key (Apple) were not expanded (#69)

## [3.0.3] - 2018-07-29
### Fixed
- Bugfix: changes for the new Java 10 `java -version` formatting (#66)


## [3.0.2] - 2018-04-12
### Added
- Added a basic Travis CI build pipeline running a `shellcheck` test for errors and executing the basic testsuite

### Fixed
- Bugfix: fix typo in JVMOptions expansion on java exec call (PR #63, Thanks to @michaelweiser for his contribution)


## [3.0.1] - 2018-03-10
### Fixed
- Bugfix: remove build number from JVM version number when creating comparable version number or extracting major version (fixes #61)


## [3.0.0] - 2018-02-25
### Added
- Completeley overhauled algorithm for JVM detection (JRE and JDK)
  - JDK has no longer precedence over JRE
  - All Java Virtual Machines on the system are taken into account
  - See Readme section 'How the script works' for more details
- NEW special syntax in Plist key `JVMVersion` to specify a maximum JVM version requirement in addition to the minimum requirement.
  - See issue #51 for examples
- Support `JVMVersion` also in Oracle PList style (#59)
- Implemented logging to `syslog` facility which can be viewed via `Console.app` (#49)
- Translation of messages to Chinese (PR #55, Thanks to @acely for his contribution)
- Added a table with 'Supported PList keys' to the Readme file
- Refactoring of functions, bash syntax, etc... (#46, #50, #56)

### Fixed
- Bugfix: pass JVM options with spaces correctly to the java exec call (#14)
- Bugfixes: better handling of MainClass arguments with spaces (#57, #58)
- Bugfixes: issues #47, #48, #52


## [2.1.0] - 2017-07-28
### Added
- Support for Java 9 which introduces a new version number schema (fixes #43)


## [2.0.2] - 2017-04-23
### Fixed
- Bugfix: do NOT expand/evaluate the default Oracle Classpath (`App.app/Contents/Java/*`) (PR #42, Thanks to @mguessan for his contribution)


## [2.0.1] - 2016-11-27
### Fixed
- Bugfix for regression in argument passthru introduced in 2.0.0 (fixes #39)


## [2.0.0] - 2016-11-20
### Added
- Localization of messages (English, German, French) (fixes #27 / PR #30, Thanks to @ebourg for his contribution)
- Improve the version of Java reported in the error messages (fixes #28)
- Send to java.com when the version of Java installed is too old (fixes #29)
- Pass command line arguments through to the application (PR #31, Thanks to @dbankieris for his contribution)
- Add support for arrays of VMOptions in Apple style Info.plists (PR #25, Thanks to @spectre683 for his contribution)
- Allow specifying `$JAVA_HOME` relative to `$AppPackageFolder` (fixes #7 / PR #26, Thanks to @toonetown for his contribution)
  - This allows you to set a relative `$JAVA_HOME` via the `<LSEnvironment>` Plist key
  - Which means you can bundle a custom version of Java inside your app!

### Changed
- Better search algorithm for specific Java version (fixes #35)
- Use highest available Java version for execution if `JVMversion` is NOT specified (fixes #37)
  - matches the new behaviour for when `JVMversion` IS specified (#35)
- Switch to `/bin/bash` with changes in #35

### Fixed
- Bugfix for parsing 3-digit java release/build numbers (e.g. for 1.8.0_101) (fixes #36)


## [1.0.1] - 2015-11-02
### Changed
- Improved display error message with applescript (PR #22, Thanks to @ygesnel for his initial contribution)
- Reorder search for Java VM locations when specific JVM version is required (PR #22, Thanks to @yoe for his contribution)


## [1.0.0] - 2015-10-08
### Added
- Support for a splash file (PR #19)
  - For details see https://github.com/tofi86/universalJavaApplicationStub/pull/19
- Expand variables like $APP_ROOT or $JAVAROOT in Apple formatted Plist files so as to match the Oracle format  (PR #17, Thanks to @cxbrooks for his contribution)
- Support for `JVMClasspath` in Oracle formatted Plist files (PR #16, Thanks to @pedrofvteixeira for his contribution)

### Fixed
- Also search for JRE's (not only for JDK's) when a specific JVMversion is required (fixes #15)
- Mark script as executable (PR #18, Thanks to @yoe for his contribution)
- Fix JVMDefaultOptions when retrieved from array
- Hide the retrieved java home path in stdout


## [0.9.0] - 2015-05-15
### Added
- Added support for `JavaX` Plist key (fixes #9)


## [0.8.1] - 2015-03-26
### Fixed
- Bugfix for `JVMVersion` key present but no JVMs in `/usr/libexec/java_home`


## [0.8.0] - 2015-02-22
### Added
- Support for `JVMVersion` key (fixes #13, Thanks to @Dylan-M for his contribution)

### Changed
- Use `$HOME` instead of `~` to set the users home directory (fixes #11)
- WorkingDirectory: improved substitution of variables ($JAVAROOT, $APP_PACKAGE, $USER_HOME) (fixes #12)
- Use different non-zero exit codes


## [0.7.0] - 2014-10-12
### Added
- Read ClassPath from ApplePlist in either Array or String style (PR #5, Thanks to Philipp Holzschneider for his contribution)
- Read StartOnMainThread (issue #4, Thanks to @wrstlbrnft for his contribution)


## [0.6.3] - 2014-07-31
### Changed
- Check Info.plist for Apple style Java keys. Better indicator to distinguish between Apple or Oracle parsing...

## [0.6.2] - 2014-07-28
### Fixed
- Minor code refactoring and bugfixes

## [0.6.1] - 2014-07-27
### Changed
- Standard Working Directory for Apple PList apparently is the AppRoot directory

## [0.6] - 2014-07-12
### Fixed
- Also catch fixed paths for Plist key `JVMWorkDir` *(thanks @dpolivaev)*

## [0.5] - 2014-06-30
### Fixed
- Bugfix for pathes / App bundles containing spaces (#2)

## [0.4] - 2014-06-30
### Added
- Read and set WorkingDirectory based on the key in `Info.plist` (#1)
  - interpret the 3 different values $JAVAROOT, $APP_PACKAGE, $USER_HOME
  - fallback to root / as standard

## [0.3] - 2014-03-16
### Added
- Enable drag&drop to the dock icon

## [0.2] - 2014-03-16
### Fixed
- Trim whitespace from variables and commandline
- Don't show errors in output for Info.plist querying

## [0.1] - 2014-03-09
- Initial release of 'universalJavaApplicationStub'
