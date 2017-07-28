universalJavaApplicationStub
=====================

[![Current release](https://img.shields.io/github/release/tofi86/universalJavaApplicationStub.svg)](https://github.com/tofi86/universalJavaApplicationStub/releases) [![Join the chat at https://gitter.im/tofi86/universalJavaApplicationStub](https://badges.gitter.im/tofi86/universalJavaApplicationStub.svg)](https://gitter.im/tofi86/universalJavaApplicationStub?utm_source=badge&utm_medium=badge&utm_campaign=pr-badge&utm_content=badge)

A BASH based *JavaApplicationStub* for Java Apps on Mac OS X that works with both Apple's and Oracle's plist format. It is released under the MIT License.


Why
---

Whilst developing some Java apps for Mac OS X I was facing the problem of supporting two different Java versions – the "older" Apple versions and the "newer" Oracle versions.

**Is there some difference, you might ask?** Yes, there is!

1. The installation directory differs:
  * Apple Java 1.5/1.6: `/System/Library/Java/JavaVirtualMachines/`
  * Oracle JRE 1.7/1.8: `/Library/Internet Plug-Ins/JavaAppletPlugin.plugin/Contents/`
  * Oracle JDK 1.7/1.8: `/System/Library/Java/JavaVirtualMachines/`

2. Mac Apps built with tools designed for Apple's Java (like Apple's *JarBundler* or the OpenSource [ANT task "Jarbundler"](https://github.com/UltraMixer/JarBundler)) won't work on Macs with Oracle Java 7 and no Apple Java installed.
  * This is because Apple's `JavaApplicationStub` only works for Apple's Java and their style to store Java properties in the `Info.plist` file.
  * To support Oracle Java 7 you would need to built a separate App package with [Oracles ANT task "Appbundler"](https://java.net/projects/appbundler).
  * Thus you would need the user to know which Java distribution he has installed on his Mac. Not very user friendly...

3. Oracle uses a different syntax to store Java properties in the applications `Info.plist` file. A Java app packaged as a Mac app with Oracles Appbundler also needs a different `JavaApplicationStub` and therefore won't work on systems with Apple's Java...

4. Starting with Mac OS X 10.10 *(Yosemite)*, Java Apps won't open anymore if they contain the *deprecated* Plist dictionary `Java`. This isn't confirmed by Apple, but [issue #9](https://github.com/tofi86/universalJavaApplicationStub/issues/9) leads to this assumption:
  * Apple seems to declare the `Java` dictionary as *deprecated* and ties it to the old Apple Java 6. If you have a newer version installed the app won't open.
  * If Java 7/8 is installed, Apple doesn't accept those java versions as suitable
  * Apple prompts for JRE 6 download even before the `JavaApplicationStub` is executed. This is why we can't intercept at this level and need to replace the `Java` dictionary by a `JavaX` dictionary key.
  * This requires to use the latest [JarBundler](https://github.com/UltraMixer/JarBundler/) version (see below for more details)

*So why, oh why, couldn't Oracle just use the old style of storing Java properties in `Info.plist` and offer a universal JavaApplicationStub?!* :rage:

Well, since I can't write such a script in C, C# or whatever fancy language, I wrote it as a Shell script. And it works!

How the script works
--------------------

You don't need a native `JavaApplicationStub` file anymore. The Shell script needs to be executable – that's all.

The script reads JVM properties from `Info.plist` regardless of whether it's Apple or Oracle flavour and feeds it to a commandline `java` call like the following:

```Bash
# execute Java and set
#	- classpath
#	- dock icon
#	- application name
#	- JVM options
#	- JVM default options
#	- main class
#	- JVM arguments
exec "$JAVACMD" \
    -cp "${JVMClassPath}" \
    -splash:"${ResourcesFolder}/${JVMSplashFile}" \
    -Xdock:icon="${ResourcesFolder}/${CFBundleIconFile}" \
    -Xdock:name="${CFBundleName}" \
    ${JVMOptions:+$JVMOptions }\
    ${JVMDefaultOptions:+$JVMDefaultOptions }\
    ${JVMMainClass}\
    ${JVMArguments:+ $JVMArguments}\
    ${ArgsPassthru:+ $ArgsPassthru}
```

It sets the classpath, the dock icon, the *AboutMenuName* (in Xdock style) and then every *JVMOptions*, *JVMDefaultOptions* or *JVMArguments* found in the `Info.plist` file.

The WorkingDirectory is either retrieved from Apple's Plist key `Java/WorkingDirectory` or set to the JavaRoot directory within the app bundle.

The name of the *main class* is also retrieved from `Info.plist`. If no *main class* is found, an applescript error dialog is shown and the script exits with *exit code 1*.

There is some *foo* happening to determine which Java versions are installed – here's the list in which order system properties are checked:

1. System variable `$JAVA_HOME`
  * can also be set to a relative path using the [`<LSEnvironment>` Plist dictionary key](https://developer.apple.com/library/content/documentation/General/Reference/InfoPlistKeyReference/Articles/LaunchServicesKeys.html#//apple_ref/doc/uid/20001431-106825)
    * which allows for bundling a custom version of Java inside your app!
2. Highest available Java version *(Java 8 trumps 7)* found in one of these locations:
  * `/usr/libexec/java_home` symlinks
  * Oracle's JRE Plugin: `/Library/Internet Plug-Ins/JavaAppletPlugin.plugin/Contents/Home/bin/java`
  * Symlink for old Apple Java: `/Library/Java/Home/bin/java`
3. If you require a specific Java version with the Plist key `JVMVersion` the script will try to find a matching JDK or JRE in all of the above locations
  * if multiple matching JVM's are found, the script will pick the latest (highest version number)

If none of these could be found or executed the script shows an applescript error dialog saying that Java needs to be installed:

![Error Dialog No Java Found](/docs/java-error.png?raw=true)

Messages are localized and displayed either in English (Default), French or German. Language contributions are very welcome!

What you need to do
-------------------

Use whichever ANT task you like:
* the opensource ["JarBundler"](https://github.com/UltraMixer/JarBundler) *(recommended)*
  * or my [JarBundler fork](https://github.com/tofi86/Jarbundler) *(deprecated)*
  * _both support the newly introduced and recommended `JavaX` dict key_
* Oracle's opensource ["Appbundler"](https://java.net/projects/appbundler) *(seems to be dead)*
  * or [*infinitekind*'s fork](https://bitbucket.org/infinitekind/appbundler/overview)

### JarBundler (≥ v3.3) example
Download the latest JarBundler release [from its github repo](https://github.com/UltraMixer/JarBundler).

:exclamation: **Attention:**
> Using an older version of JarBundler (e.g. [old JarBundler ≤ v2.3](http://informagen.com/JarBundler/) or [new JarBundler ≤ v3.2](https://github.com/UltraMixer/JarBundler)) might result in [issue #9](https://github.com/tofi86/universalJavaApplicationStub/issues/9) *(Mac OS X 10.10 asking to install deprecated Apple JRE 6 instead of using a newer Java version)*
>
> If you don't want to care about compatibility issues between OS X and Java versions, make sure to use the [latest JarBundler version ≥ 3.3](https://github.com/UltraMixer/JarBundler/releases)

Then place the `universalJavaApplicationStub` from this repo in your build resources folder and link it in your ANT task (attribute `stubfile`). Don't forget to set the newly introduced `useJavaXKey` option for compatibility:
```XML
<jarbundler
	name="Your-App"
	shortname="Your Application"
	icon="${resources.dir}/icon.icns"
	stubfile="${resources.dir}/universalJavaApplicationStub"
	useJavaXKey="true"
	... >
</jarbundler>
```

The ANT task will care about the rest...

You should get a fully functional Mac Application Bundle working with both Java distributions from Apple and Oracle and all Mac OS X versions.


### Appbundler example
Just place the `universalJavaApplicationStub` from this repo in your build resources folder and link it in your ANT task (attribute `executableName` from [*infinitekind* fork](https://bitbucket.org/infinitekind/appbundler/overview)):
```XML
<appbundler
	name="Your-App"
	displayname="Your Application"
	icon="${resources.dir}/icon.icns"
	executableName="${resources.dir}/universalJavaApplicationStub"
	... >
</appbundler>
```


The ANT task will care about the rest...

You should get a fully functional Mac Application Bundle working with both Java distributions from Apple and Oracle and all Mac OS X versions.


Missing Features
----------------

At the moment, there's no support for
* required JVM architecture (like `x86_64`, etc.)


License
-------

*universalJavaApplicationStub* is released under the MIT License.
