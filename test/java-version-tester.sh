#!/bin/bash

# Java JRE version tester
# tofi86 @ 2017-06-12



# helper function:
# extract Java version string from `java -version` command
# works for both old (1.8) and new (9) version schema
##########################################################
function extractJavaVersionString() {
  # second sed command strips " and -ea from the version string
  echo `"$1" -version 2>&1 | awk '/version/{print $NF}' | sed -E 's/"//g;s/-ea//g'`
}


# helper function:
# extract Java major version from java version string
# - input '1.7.0_76' returns '7'
# - input '1.8.0_121' returns '8'
# - input '9-ea' returns '9'
# - input '9.0.3' returns '9'
##########################################################
function extractJavaMajorVersion() {
  java_ver=$1
  # Java 6, 7, 8 starts with 1.x
  if [ "${java_ver:0:2}" == "1." ] ; then
    echo ${java_ver} | sed -E 's/1\.([0-9])[0-9_.]{2,6}/\1/g'
  else
    # Java 9+ starts with x using semver versioning
    echo ${java_ver} | sed -E 's/([0-9]+)(-ea|(\.[0-9]+)*)/\1/g'
  fi
}


# helper function:
# return comparable version for java version string
# basically just strip punctuation and leading '1.'
##########################################################
function comparableJavaVersionNumber() {
  echo $1 | sed -E 's/^1\.//g;s/[[:punct:]]//g'
}


# function:
# Java version tester checks whether a given java version
# satisfies the given requirement
# - parameter1: the java major version (6, 7, 8, 9, etc.)
# - parameter2: the java requirement (1.6, 1.7+, etc.)
# - return: 0 (satiesfies), 1 (does not), 2 (error)
##########################################################
function JavaVersionSatisfiesRequirement() {
  java_ver=$1
  java_req=$2

  # matches requirements with * modifier
  # e.g. 1.8*, 9*, 9.1*, 9.2.4*, 10*, 10.1*, 10.1.35*
  if [[ ${java_req} =~ ^[0-9]+(\.[0-9]+)*\*$ ]] ; then
    # remove last char (*) from requirement string for comparison
    java_req_num=${java_req::${#java_req}-1}
    if [ ${java_ver} == ${java_req_num} ] ; then
      return 0
    else
      return 1
    fi

  # matches requirements with + modifier
  # e.g. 1.8+, 9+, 9.1+, 9.2.4+, 10+, 10.1+, 10.1.35+
  elif [[ ${java_req} =~ ^[0-9]+(\.[0-9]+)*\+$ ]] ; then
    java_req_num=$(comparableJavaVersionNumber ${java_req})
    java_ver_num=$(comparableJavaVersionNumber ${java_ver})
    if [ ${java_ver_num} -ge ${java_req_num} ] ; then
      return 0
    else
      return 1
    fi

  # matches standard requirements without modifier
  # e.g. 1.8, 9, 9.1, 9.2.4, 10, 10.1, 10.1.35
  elif [[ ${java_req} =~ ^[0-9]+(\.[0-9]+)*$ ]] ; then
    if [ ${java_ver} == ${java_req} ] ; then
      return 0
    else
      return 1
    fi

  # not matching any of the above patterns
  # results in an error
  else
    return 2
  fi
}





# test function:
# tests the extractJavaMajorVersion() function
##########################################################
function testExtractMajor() {
  java_version=$1
  expected_major=$2
  actual_major=`extractJavaMajorVersion $java_version`
  if [ ${expected_major} == ${actual_major} ] ; then
    echo "[TEST OK] Extracted Java major version '${actual_major}' for Java '${java_version}'"
  else
    echo "[TEST FAILED] Extracted Java major version '${actual_major}' for Java '${java_version}' but expected '${expected_major}'"
  fi
}


echo ""
echo "########################################################"
echo "Testing function extractJavaMajorVersion()"
echo ""
echo "Tests with Java 1.6:"
testExtractMajor 1.6.0 6
testExtractMajor 1.6.0_07 6
testExtractMajor 1.6.0_45 6
echo ""
echo "Tests with Java 1.7:"
testExtractMajor 1.7.0 7
testExtractMajor 1.7.0_09 7
testExtractMajor 1.7.0_79 7
echo ""
echo "Tests with Java 1.8:"
testExtractMajor 1.8.0 8
testExtractMajor 1.8.0_05 8
testExtractMajor 1.8.0_91 8
testExtractMajor 1.8.0_131 8
echo ""
echo "Tests with Java 9:"
testExtractMajor 9-ea 9
testExtractMajor 9.0.1 9
testExtractMajor 9.0.23 9
testExtractMajor 9.10.120 9
echo ""
echo "Tests with Java 10:"
testExtractMajor 10-ea 10
testExtractMajor 10.0.1 10
testExtractMajor 10.0.23 10
testExtractMajor 10.10.120 10


# test function:
# tests the JavaVersionSatisfiesRequirement() function
##########################################################
function testCompare() {
  java_version=$1
  java_requirement=$2
  expected_result=$3
  actual_result=`JavaVersionSatisfiesRequirement $java_version $java_requirement ; echo $?`
  if [ ${expected_result} == ${actual_result} ] ; then
    case $expected_result in
      0)
        echo "[TEST OK] [${expected_result}==${actual_result}] Java version ${java_version} satisfies requirement ${java_requirement}"
        ;;
      1)
        echo "[TEST OK] [${expected_result}==${actual_result}] Java version ${java_version} does not satisfy requirement ${java_requirement}"
        ;;
      2)
        echo "[TEST OK] [${expected_result}==${actual_result}] Invalid Java version requirement ${java_requirement}"
        ;;
    esac
  else
    echo "[TEST FAILED] [${expected_result}!=${actual_result}] Java version: ${java_version} ; Requirement ${java_requirement} ; Expected: ${expected_result} ; Actual: ${actual_result}"
  fi
}


echo ""
echo ""
echo "########################################################"
echo "Testing function JavaVersionSatisfiesRequirement()"
echo ""
echo "Tests with Java 1.6:"
testCompare 1.6 1.6 0
testCompare 1.6 1.6+ 0
testCompare 1.6 1.6* 0
testCompare 1.6 1.6.0_45 2
testCompare 1.6 1.7 1
testCompare 1.6 1.7+ 1
testCompare 1.6 1.7* 1
testCompare 1.6 1.7.0_71 2
testCompare 1.6 1.8 1
testCompare 1.6 1.8+ 1
testCompare 1.6 1.8* 1
testCompare 1.6 1.8.0_121 2
testCompare 1.6 9 1
testCompare 1.6 9+ 1
testCompare 1.6 9* 1
testCompare 1.6 9.1.2 1
echo ""
echo "Tests with Java 1.7:"
testCompare 1.7 1.6 1
testCompare 1.7 1.6+ 0
testCompare 1.7 1.6* 1
testCompare 1.7 1.6.0_45 2
testCompare 1.7 1.7 0
testCompare 1.7 1.7+ 0
testCompare 1.7 1.7* 0
testCompare 1.7 1.7.0_71 2
testCompare 1.7 1.8 1
testCompare 1.7 1.8+ 1
testCompare 1.7 1.8* 1
testCompare 1.7 1.8.0_121 2
testCompare 1.7 9 1
testCompare 1.7 9+ 1
testCompare 1.7 9* 1
testCompare 1.7 9.1.2 1
echo ""
echo "Tests with Java 1.8:"
testCompare 1.8 1.6 1
testCompare 1.8 1.6+ 0
testCompare 1.8 1.6* 1
testCompare 1.8 1.6.0_45 2
testCompare 1.8 1.7 1
testCompare 1.8 1.7+ 0
testCompare 1.8 1.7* 1
testCompare 1.8 1.7.0_71 2
testCompare 1.8 1.8 0
testCompare 1.8 1.8+ 0
testCompare 1.8 1.8* 0
testCompare 1.8 1.8.0_121 2
testCompare 1.8 9 1
testCompare 1.8 9+ 1
testCompare 1.8 9* 1
testCompare 1.8 9.1.2 1
echo ""
echo "Tests with Java 9:"
testCompare 9 1.6 1
testCompare 9 1.6+ 0
testCompare 9 1.6* 1
testCompare 9 1.6.0_45 2
testCompare 9 1.7 1
testCompare 9 1.7+ 0
testCompare 9 1.7* 1
testCompare 9 1.7.0_71 2
testCompare 9 1.8 1
testCompare 9 1.8+ 0
testCompare 9 1.8* 1
testCompare 9 1.8.0_121 2
testCompare 9 9 0
testCompare 9 9+ 0
testCompare 9 9* 0
testCompare 9 9.1.2 1
echo ""
echo "Tests with Java 10:"
testCompare 10 1.6 1
testCompare 10 1.6+ 0
testCompare 10 1.6* 1
testCompare 10 1.6.0_45 2
testCompare 10 1.7 1
testCompare 10 1.7+ 0
testCompare 10 1.7* 1
testCompare 10 1.7.0_71 2
testCompare 10 1.8 1
testCompare 10 1.8+ 0
testCompare 10 1.8* 1
testCompare 10 1.8.0_121 2
testCompare 10 9 1
testCompare 10 9+ 0
testCompare 10 9* 1
testCompare 10 9.1.2 1
testCompare 10 10 0
testCompare 10 10+ 0
testCompare 10 10* 0
testCompare 10 10.0.13 1
