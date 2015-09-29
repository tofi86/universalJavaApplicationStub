#!/bin/sh

# Java JRE version tester
# tofi86 @ 2015-09-29

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
    java_req_num=`echo ${java_req} | sed -E 's/[[:punct:]]//g'`
    java_ver_num=`echo ${java_ver} | sed -E 's/[[:punct:]]//g'`
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


function extractJavaMajorVersion() {
  echo `"$1" -version 2>&1 | awk '/version/{print $NF}' | sed -E 's/"([0-9.]{3})[0-9_.]{5}"/\1/g'`
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
