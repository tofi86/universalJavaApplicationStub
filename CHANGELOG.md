ChangeLog
---------

### v3.0.1 (2018-03-10)
* Bugfix: remove build number from JVM version number when creating comparable version number or extracting major version (fixes #61)

### v3.0.0 (2018-02-25)
* Completeley overhauled algorithm for JVM detection (JRE and JDK)
  * JDK has no longer precedence over JRE
  * All Java Virtual Machines on the system are taken into account
  * See Readme section 'How the script works' for more details
* NEW special syntax in Plist key `JVMVersion` to specify a maximum JVM version requirement in addition to the minimum requirement.
  * See issue #51 for examples
* Support `JVMVersion` also in Oracle PList style (#59)
* Implemented logging to `syslog` facility which can be viewed via `Console.app` (#49)
* Translation of messages to Chinese (PR #55, Thanks to @acely for his contribution)
* Added a table with 'Supported PList keys' to the Readme file
* Refactoring of functions, bash syntax, etc... (#46, #50, #56)
* Bugfix: pass JVM options with spaces correctly to the java exec call (#14)
* Bugfixes: better handling of MainClass arguments with spaces (#57, #58)
* Bugfixes: issues #47, #48, #52

### v2.1.0 (2017-07-28)
* Support for Java 9 which introduces a new version number schema (fixes #43)

### v2.0.2 (2017-04-23)
* Bugfix: do NOT expand/evaluate the default Oracle Classpath (`App.app/Contents/Java/*`) (PR #42, Thanks to @mguessan for his contribution)

### v2.0.1 (2016-11-27)
* Bugfix for regression in argument passthru introduced in 2.0.0 (fixes #39)

### v2.0.0 (2016-11-20)
* Localization of messages (English, German, French) (fixes #27 / PR #30, Thanks to @ebourg for his contribution)
* Improve the version of Java reported in the error messages (fixes #28)
* Send to java.com when the version of Java installed is too old (fixes #29)
* Bugfix for parsing 3-digit java release/build numbers (e.g. for 1.8.0_101) (fixes #36)
* Better search algorithm for specific Java version (fixes #35)
* Use highest available Java version for execution if `JVMversion` is NOT specified (fixes #37)
  * matches the new behaviour for when `JVMversion` IS specified (#35)
* Switch to `/bin/bash` with changes in #35
* Add support for arrays of VMOptions in Apple style Info.plists (PR #25, Thanks to @spectre683 for his contribution)
* Pass command line arguments through to the application (PR #31, Thanks to @dbankieris for his contribution)
* Allow specifying `$JAVA_HOME` relative to `$AppPackageFolder` (fixes #7 / PR #26, Thanks to @toonetown for his contribution)
  * This allows you to set a relative `$JAVA_HOME` via the `<LSEnvironment>` Plist key
  * Which means you can bundle a custom version of Java inside your app!

### v1.0.1 (2015-11-02)
* Improved display error message with applescript (PR #22, Thanks to @ygesnel for his initial contribution)
* Reorder search for Java VM locations when specific JVM version is required (PR #22, Thanks to @yoe for his contribution)

### v1.0.0 (2015-10-08)
* Support for a splash file (PR #19)
  * For details see https://github.com/tofi86/universalJavaApplicationStub/pull/19
* Also search for JRE's (not only for JDK's) when a specific JVMversion is required (fixes #15)
* Expand variables like $APP_ROOT or $JAVAROOT in Apple formatted Plist files so as to match the Oracle format  (PR #17, Thanks to @cxbrooks for his contribution)
* support for `JVMClasspath` in Oracle formatted Plist files (PR #16, Thanks to @pedrofvteixeira for his contribution)
* Mark script as executable (PR #18, Thanks to @yoe for his contribution)
* bugfix: fix JVMDefaultOptions when retrieved from array
* bugfix: hide the retrieved java home path in stdout

### v0.9.0 (2015-05-15)
* added support for `JavaX` Plist key (fixes #9)

### v0.8.1 (2015-03-26)
* Bugfix for `JVMVersion` key present but no JVMs in `/usr/libexec/java_home`

### v0.8.0 (2015-02-22)
* support for `JVMVersion` key (fixes #13, Thanks to @Dylan-M for his contribution)
* use `$HOME` instead of `~` to set the users home directory (fixes #11)
* WorkingDirectory: improved substitution of variables ($JAVAROOT, $APP_PACKAGE, $USER_HOME) (fixes #12)
* use different non-zero exit codes

### v0.7.0 (2014-10-12)
* read ClassPath from ApplePlist in either Array or String style (PR #5, Thanks to Philipp Holzschneider for his contribution)
* read StartOnMainThread (issue #4, Thanks to @wrstlbrnft for his contribution)

### v0.6.3 (2014-07-31)
* check Info.plist for Apple style Java keys. Better indicator to distinguish between Apple or Oracle parsing...

### v0.6.2 (2014-07-28)
* minor code refactoring and bugfixes

### v0.6.1 (2014-07-27)
* Standard Working Directory for Apple PList apparently is the AppRoot directory

### v0.6 *(2014-07-12)*
* also catch fixed paths for Plist key `JVMWorkDir` *(thanks @dpolivaev)*

### v0.5 *(2014-06-30)*
* bugfix for pathes / App bundles containing spaces (#2)

### v0.4 *(2014-06-30)*
* read and set WorkingDirectory based on the key in `Info.plist` (#1)
 * interpret the 3 different values $JAVAROOT, $APP_PACKAGE, $USER_HOME
 * fallback to root / as standard

### v0.3 *(2014-03-16)*
* enable drag&drop to the dock icon

### v0.2 *(2014-03-16)*
* trim whitespace from variables and commandline
* don't show errors in output for Info.plist querying

### v0.1 *(2014-03-09)*
* initial release of 'universalJavaApplicationStub'
