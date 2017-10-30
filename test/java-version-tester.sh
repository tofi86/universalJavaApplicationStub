#!/bin/bash

# Java JRE version tester
# tofi86 @ 2017-10-30



# helper function:
# extract Java version string from `java -version` command
# works for both old (1.8) and new (9) version schema
##########################################################
function extractJavaVersionString() {
  # second sed command strips " and -ea from the version string
  echo `"$1" -version 2>&1 | awk '/version/{print $NF}' | sed -E 's/"//g;s/-ea//g'`
}


# helper function:
# extract Java major version from a Java version string
##########################################################
function extractJavaMajorVersion() {
  echo $(echo "$1" | sed -E 's/^1\.//;s/^([0-9]+)(-ea|(\.[0-9_.]{1,7})?)[+*]?$/\1/')
}


# helper function:
# return comparable version for java version string
# return value is an 8 digit numeral
##########################################################
function comparableJavaVersionNumber() {
  # cleaning: 1) remove leading '1.'; 2) remove 'a-Z' and '-*+' (e.g. '-ea'); 3) replace '_' with '.'
  cleaned=$(echo "$1" | sed -E 's/^1\.//g;s/[a-zA-Z+*\-]//g;s/_/./g')
  # splitting at '.' into an array
  arr=( ${cleaned//./ } )
  # echo a string with left padded version numbers
  echo "$(printf '%02s' ${arr[0]})$(printf '%03s' ${arr[1]})$(printf '%03s' ${arr[2]})"
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
testExtractMajor "1.6" "6"
testExtractMajor "1.6+" "6"
testExtractMajor "1.6.0" "6"
testExtractMajor "1.6.0_07" "6"
testExtractMajor "1.6.0_45" "6"
echo ""
echo "Tests with Java 1.7:"
testExtractMajor "1.7" "7"
testExtractMajor "1.7*" "7"
testExtractMajor "1.7.0" "7"
testExtractMajor "1.7.0_09" "7"
testExtractMajor "1.7.0_79" "7"
echo ""
echo "Tests with Java 1.8:"
testExtractMajor "1.8" "8"
testExtractMajor "1.8+" "8"
testExtractMajor "1.8.0" "8"
testExtractMajor "1.8.0_05" "8"
testExtractMajor "1.8.0_91" "8"
testExtractMajor "1.8.0_131" "8"
echo ""
echo "Tests with Java 9:"
testExtractMajor "9" "9"
testExtractMajor "9-ea" "9"
testExtractMajor "9.1*" "9"
testExtractMajor "9.0.1" "9"
testExtractMajor "9.0.1+" "9"
testExtractMajor "9.0.23" "9"
testExtractMajor "9.10.120" "9"
testExtractMajor "9.10.120+" "9"
testExtractMajor "9.100.120+" "9"
echo ""
echo "Tests with Java 10:"
testExtractMajor "10" "10"
testExtractMajor "10-ea" "10"
testExtractMajor "10.1+" "10"
testExtractMajor "10.0.1" "10"
testExtractMajor "10.0.1*" "10"
testExtractMajor "10.0.23" "10"
testExtractMajor "10.10.120" "10"
testExtractMajor "10.10.120+" "10"
testExtractMajor "10.100.120+" "10"



# test function:
# tests the comparableJavaVersionNumber() function
##########################################################
function testComparable() {
  version=$1
  expected=$2
  actual=$(comparableJavaVersionNumber $version)
  if [ "$actual" == "$expected" ] ; then
    echo "[TEST OK] Version number '$version' has comparable form '$actual' (matches expected result '$expected')"
  else
    echo "[TEST FAILED] Version number '$version' has comparable form '$actual' (DOES NOT MATCH expected result '$expected')"
  fi
}


echo ""
echo ""
echo "########################################################"
echo "Testing function JavaVersionSatisfiesRequirement()"
echo ""
echo "Tests with Java 1.6:"
testComparable "1.6" "06000000"
testComparable "1.6+" "06000000"
testComparable "1.6.0_45" "06000045"
testComparable "1.6.0_100" "06000100"
testComparable "1.6.1_87" "06001087"
echo ""
echo "Tests with Java 1.7:"
testComparable "1.7.0_76" "07000076"
testComparable "1.7.0_144" "07000144"
echo ""
echo "Tests with Java 1.8:"
testComparable "1.8" "08000000"
testComparable "1.8*" "08000000"
testComparable "1.8.0_98" "08000098"
testComparable "1.8.0_151" "08000151"
echo ""
echo "Tests with Java 9:"
testComparable "9" "09000000"
testComparable "9+" "09000000"
testComparable "9-ea" "09000000"
testComparable "9.2" "09002000"
testComparable "9.2*" "09002000"
testComparable "9.0.1" "09000001"
testComparable "9.0.13" "09000013"
testComparable "9.1.3" "09001003"
testComparable "9.11" "09011000"
testComparable "9.10.23" "09010023"
testComparable "9.10.101" "09010101"
echo ""
echo "Tests with Java 10:"
testComparable "10" "10000000"
testComparable "10*" "10000000"
testComparable "10-ea" "10000000"
testComparable "10.1" "10001000"
testComparable "10.1+" "10001000"
testComparable "10.0.1" "10000001"
testComparable "10.0.13" "10000013"
testComparable "10.1.3" "10001003"
testComparable "10.12" "10012000"
testComparable "10.10.23" "10010023"
testComparable "10.10.113" "10010113"


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
testCompare "1.6" "1.6" "0"
testCompare "1.6" "1.6+" "0"
testCompare "1.6" "1.6*" "0"
testCompare "1.6" "1.6.0_45" "2"
testCompare "1.6" "1.7" "1"
testCompare "1.6" "1.7+" "1"
testCompare "1.6" "1.7*" "1"
testCompare "1.6" "1.7.0_71" "2"
testCompare "1.6" "1.8" "1"
testCompare "1.6" "1.8+" "1"
testCompare "1.6" "1.8*" "1"
testCompare "1.6" "1.8.0_121" "2"
testCompare "1.6" "9" "1"
testCompare "1.6" "9+" "1"
testCompare "1.6" "9*" "1"
testCompare "1.6" "9.1.2" "1"
echo ""
echo "Tests with Java 1.7:"
testCompare "1.7" "1.6" "1"
testCompare "1.7" "1.6+" "0"
testCompare "1.7" "1.6*" "1"
testCompare "1.7" "1.6.0_45" "2"
testCompare "1.7" "1.7" "0"
testCompare "1.7" "1.7+" "0"
testCompare "1.7" "1.7*" "0"
testCompare "1.7" "1.7.0_71" "2"
testCompare "1.7" "1.8" "1"
testCompare "1.7" "1.8+" "1"
testCompare "1.7" "1.8*" "1"
testCompare "1.7" "1.8.0_121" "2"
testCompare "1.7" "9" "1"
testCompare "1.7" "9+" "1"
testCompare "1.7" "9*" "1"
testCompare "1.7" "9.1.2" "1"
echo ""
echo "Tests with Java 1.8:"
testCompare "1.8" "1.6" "1"
testCompare "1.8" "1.6+" "0"
testCompare "1.8" "1.6*" "1"
testCompare "1.8" "1.6.0_45" "2"
testCompare "1.8" "1.7" "1"
testCompare "1.8" "1.7+" "0"
testCompare "1.8" "1.7*" "1"
testCompare "1.8" "1.7.0_71" "2"
testCompare "1.8" "1.8" "0"
testCompare "1.8" "1.8+" "0"
testCompare "1.8" "1.8*" "0"
testCompare "1.8" "1.8.0_121" "2"
testCompare "1.8" "9" "1"
testCompare "1.8" "9+" "1"
testCompare "1.8" "9*" "1"
testCompare "1.8" "9.1.2" "1"
echo ""
echo "Tests with Java 9:"
testCompare "9" "1.6" "1"
testCompare "9" "1.6+" "0"
testCompare "9" "1.6*" "1"
testCompare "9" "1.6.0_45" "2"
testCompare "9" "1.7" "1"
testCompare "9" "1.7+" "0"
testCompare "9" "1.7*" "1"
testCompare "9" "1.7.0_71" "2"
testCompare "9" "1.8" "1"
testCompare "9" "1.8+" "0"
testCompare "9" "1.8*" "1"
testCompare "9" "1.8.0_121" "2"
testCompare "9" "9" "0"
testCompare "9" "9+" "0"
testCompare "9" "9*" "0"
testCompare "9" "9.1.2" "1"
echo ""
echo "Tests with Java 10:"
testCompare "10" "1.6" "1"
testCompare "10" "1.6+" "0"
testCompare "10" "1.6*" "1"
testCompare "10" "1.6.0_45" "2"
testCompare "10" "1.7" "1"
testCompare "10" "1.7+" "0"
testCompare "10" "1.7*" "1"
testCompare "10" "1.7.0_71" "2"
testCompare "10" "1.8" "1"
testCompare "10" "1.8+" "0"
testCompare "10" "1.8*" "1"
testCompare "10" "1.8.0_121" "2"
testCompare "10" "9" "1"
testCompare "10" "9+" "0"
testCompare "10" "9*" "1"
testCompare "10" "9.1.2" "1"
testCompare "10" "10" "0"
testCompare "10" "10+" "0"
testCompare "10" "10*" "0"
testCompare "10" "10.0.13" "1"
