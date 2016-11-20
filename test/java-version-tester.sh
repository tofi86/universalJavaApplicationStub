#!/bin/bash

# Java JRE version tester
# tofi86 @ 2016-08-27



# helper
# function: extract Java version string
#           from java -version command
############################################

function extractJavaVersionString() {
  echo `"$1" -version 2>&1 | awk '/version/{print $NF}' | sed -E 's/"//g'`
}

# helper
# function: extract Java major version
#           from java version string
############################################

function extractJavaMajorVersion() {
  version_str=$(extractJavaVersionString "$1")
  echo ${version_str} | sed -E 's/([0-9.]{3})[0-9_.]{5,6}/\1/g'
}

# helper
# function: generate comparable Java version
#           number from java version string
############################################

function comparableJavaVersionNumber() {
  echo $1 | sed -E 's/[[:punct:]]//g'
}



#
# function: Java version tester
#           check whether a given java version
#           satisfies the given requirement
############################################

function JavaVersionSatisfiesRequirement() {
  java_ver=$1
  java_req=$2

  # e.g. 1.8*
  if [[ ${java_req} =~ ^[0-9]\.[0-9]\*$ ]] ; then
    java_req_num=${java_req:0:3}
    java_ver_num=${java_ver:0:3}
    if [ ${java_ver_num} == ${java_req_num} ] ; then
      return 0
    else
      return 1
    fi

  # e.g. 1.8+
  elif [[ ${java_req} =~ ^[0-9]\.[0-9]\+$ ]] ; then
    java_req_num=$(comparableJavaVersionNumber ${java_req})
    java_ver_num=$(comparableJavaVersionNumber ${java_ver})
    if [ ${java_ver_num} -ge ${java_req_num} ] ; then
      return 0
    else
      return 1
    fi

  # e.g. 1.8
  elif [[ ${java_req} =~ ^[0-9]\.[0-9]$ ]] ; then
    if [ ${java_ver} == ${java_req} ] ; then
      return 0
    else
      return 1
    fi

  # not matching any of the above patterns
  else
    return 2
  fi
}


apple_jre_plugin="/Library/Java/Home/bin/java"
apple_jre_version=`extractJavaMajorVersion "${apple_jre_plugin}"`
oracle_jre_plugin="/Library/Internet Plug-Ins/JavaAppletPlugin.plugin/Contents/Home/bin/java"
oracle_jre_version=`extractJavaMajorVersion "${oracle_jre_plugin}"`


echo "assertions / tests with Apple JRE 1.6 ($apple_jre_version):"
echo [0] `JavaVersionSatisfiesRequirement $apple_jre_version 1.6 ; echo $?`
echo [0] `JavaVersionSatisfiesRequirement $apple_jre_version 1.6+ ; echo $?`
echo [0] `JavaVersionSatisfiesRequirement $apple_jre_version 1.6* ; echo $?`
echo [1] `JavaVersionSatisfiesRequirement $apple_jre_version 1.7 ; echo $?`
echo [1] `JavaVersionSatisfiesRequirement $apple_jre_version 1.7+ ; echo $?`
echo [1] `JavaVersionSatisfiesRequirement $apple_jre_version 1.7* ; echo $?`
echo [1] `JavaVersionSatisfiesRequirement $apple_jre_version 1.8 ; echo $?`
echo [1] `JavaVersionSatisfiesRequirement $apple_jre_version 1.8+ ; echo $?`
echo [1] `JavaVersionSatisfiesRequirement $apple_jre_version 1.8* ; echo $?`
echo [2] `JavaVersionSatisfiesRequirement $apple_jre_version 1.8.0_60 ; echo $?`

# false
if JavaVersionSatisfiesRequirement $apple_jre_version "1.7+" ; then
  echo true
else
  echo false
fi


echo "assertions / tests with Oracle JRE 1.8 ($oracle_jre_version):"
echo [1] `JavaVersionSatisfiesRequirement $oracle_jre_version 1.9 ; echo $?`
echo [1] `JavaVersionSatisfiesRequirement $oracle_jre_version 1.9+ ; echo $?`
echo [1] `JavaVersionSatisfiesRequirement $oracle_jre_version 1.9* ; echo $?`
echo [0] `JavaVersionSatisfiesRequirement $oracle_jre_version 1.8 ; echo $?`
echo [0] `JavaVersionSatisfiesRequirement $oracle_jre_version 1.8+ ; echo $?`
echo [0] `JavaVersionSatisfiesRequirement $oracle_jre_version 1.8* ; echo $?`
echo [1] `JavaVersionSatisfiesRequirement $oracle_jre_version 1.7 ; echo $?`
echo [0] `JavaVersionSatisfiesRequirement $oracle_jre_version 1.7+ ; echo $?`
echo [1] `JavaVersionSatisfiesRequirement $oracle_jre_version 1.7* ; echo $?`
echo [2] `JavaVersionSatisfiesRequirement $oracle_jre_version 1.7.0_60 ; echo $?`

# true
if JavaVersionSatisfiesRequirement $oracle_jre_version "1.8+" ; then
  echo true
else
  echo false
fi
