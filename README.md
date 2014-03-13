universalJavaApplicationStub
=====================

A shellscript JavaApplicationStub for Java Apps on Mac OS X that works with both Apple's and Oracle's plist format.


Why
---

Whilst developing some Java apps for Mac OS X I was facing the problem of supporting two different Java versions – the "older" Apple versions and the "newer" Oracle versions.

**Is there some difference, you might ask?** Yes, there is!

1. The spot in the file system where the JRE or JDK is stored is different:
 * Apple Java 1.5/1.6: `/System/Library/Java/JavaVirtualMachines/`
 * Oracle Java 1.7/1.8: `/Library/Internet Plug-Ins/JavaAppletPlugin.plugin/Contents/`
 
2. Mac Apps built with tools designed for Apple's Java (like Apple's JarBundler or the [ANT task "Jarbundler"](http://informagen.com/JarBundler/)) won't work on Macs with Oracle Java 7 and no Apple Java installed.
 * This is because the Apple `JavaApplicationStub` only works for Apple's Java and their `Info.plist` style to store Java properties.
 * To support Oracle Java 7 you would need to built a separate App package with Oracles [ANT task "Appbundler"](https://java.net/projects/appbundler).
 * Thus you would need the user to know which Java distribution he has installed on his Mac. Not very user friendly...
 
3. Oracle uses a different syntax to store Java properties in the applications `Info.plist` file. A Java app packaged as a Mac app with Oracles Appbundler also needs a different `JavaApplicationStub` and therefore won't work on systems with Apple's Java...

*So why, oh why, couldn't Oracle just use the old style of storing Java properties in `Info.plist` and offer a universal JavaApplicationStub?!* :rage:

Well, since I can't write such a script in C, C# or whatever fancy language, I wrote it as a shell script. And it works! ;-)

How it works
------------

You don't need a native `JavaApplicationStub` file anymore...

The shell script reads JVM properties from `Info.plist` regardless of which format they have, Apple or Oracle, and feeds it to a commandline `java` call:

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
		-cp "${JVMClasspath}" \
		-Xdock:icon="$PROGDIR/../Resources/${CFBundleIconFile}" \
		-Xdock:name="${CFBundleName}" \
		${JVMOptions:+"$JVMOptions" }\
		${JVMDefaultOptions:+"$JVMDefaultOptions" }\
		"${JVMMainClass}"\
		${JVMArguments:+"$JVMArguments"}
```

It sets the classpath, the dock icon, the *AboutMenuName* (in Xdock style) and then every *JVMOptions*, *JVMDefaultOptions* or *JVMArguments* found in the `Info.plist` file.

The name of the *main class* is also retrieved from `Info.plist`. If no *main class* could be found, an applescript error dialog is shown and the script exits with *exit code 1*.

Also, there is some *foo* happening to determine which Java version is installed. Here's the list in which order system properties are checked:

1. system variable `$JAVA_HOME`
2. `/usr/libexec/java_home` symlinks
3. symlink for old Apple Java: `/Library/Java/Home/bin/java`
4. hardcoded fallback to Oracle's JRE Plugin: `/Library/Internet Plug-Ins/JavaAppletPlugin.plugin/Contents/Home/bin/java`

If none of these could be found or executed, an applescript error dialog is shown saying that Java need to be installed.

What you need to do
-------------------

Use whichever ANT task you like:
* the great opensource ["Jarbundler"](http://informagen.com/JarBundler/)
 * my JarBundler [fork on github](https://github.com/tofi86/Jarbundler) which supports *MixedLocalization*
* Oracle's opensource ["Appbundler"](https://java.net/projects/appbundler)

### JarBundler example
Just place the `universalJavaApplicationStub` from this repo in your build resources folder and link it in your ANT task (attribute `stubfile`):
```XML
<jarbundler
	name="Your-App"
	shortname="Your Application"
	icon="${resources.dir}/icon.icns"
	stubfile="${resources.dir}/universalJavaApplicationStub"
	... >
	
</jarbundler>
```

The ANT task will care about the rest...

You should get a fully functional Mac Application Bundle working with both Java distributions from Apple and Oracle.


### Appbundler example
Just place the `universalJavaApplicationStub` from this repo in your build resources folder and link it in your ANT task (attribute `executableName`):
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

You should get a fully functional Mac Application Bundle working with both Java distributions from Apple and Oracle.


Missing Features
----------------

At the moment, there's no support for
* File drag & drop to the dock icon
 * *personal reminder: files aren't passed as argument but on the drop clipboard. therefore probably not fixable...*
* required JVM architecture (like `x86_64`, etc.)
* required JVM version (like `1.6+`, etc.)
* etc...

An AppleScript dialog would be nice to prevent Java execution if the requirements aren't met.

License
-------

*universalJavaApplicationStub* is released under the MIT License.
