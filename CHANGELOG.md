ChangeLog
---------

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
