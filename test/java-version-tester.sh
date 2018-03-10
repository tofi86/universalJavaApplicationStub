#!/bin/bash

# Tests for the functions used in universalJavaApplicationStub script
# tofi86 @ 2018-03-10



# function 'get_java_version_from_cmd()'
#
# returns Java version string from 'java -version' command
# works for both old (1.8) and new (9) version schema
#
# @param1  path to a java JVM executable
# @return  the Java version number as displayed in 'java -version' command
################################################################################
function get_java_version_from_cmd() {
	# second sed command strips " and -ea from the version string
	echo $("$1" -version 2>&1 | awk '/version/{print $NF}' | sed -E 's/"//g;s/-ea//g')
}


# function 'extract_java_major_version()'
#
# extract Java major version from a version string
#
# @param1  a Java version number ('1.8.0_45') or requirement string ('1.8+')
# @return  the major version (e.g. '7', '8' or '9', etc.)
################################################################################
function extract_java_major_version() {
	echo $(echo "$1" | sed -E 's/^1\.//;s/^([0-9]+)(-ea|(\.[0-9_.]{1,7})?)(-b[0-9]+-[0-9]+)?[+*]?$/\1/')
}


# function 'get_comparable_java_version()'
#
# return comparable version for a Java version number or requirement string
#
# @param1  a Java version number ('1.8.0_45') or requirement string ('1.8+')
# @return  an 8 digit numeral ('1.8.0_45'->'08000045'; '9.1.13'->'09001013')
################################################################################
function get_comparable_java_version() {
	# cleaning: 1) remove leading '1.'; 2) remove build string (e.g. '-b14-468'); 3) remove 'a-Z' and '-*+' (e.g. '-ea'); 4) replace '_' with '.'
	local cleaned=$(echo "$1" | sed -E 's/^1\.//g;s/-b[0-9]+-[0-9]+$//g;s/[a-zA-Z+*\-]//g;s/_/./g')
	# splitting at '.' into an array
	local arr=( ${cleaned//./ } )
	# echo a string with left padded version numbers
	echo "$(printf '%02s' ${arr[0]})$(printf '%03s' ${arr[1]})$(printf '%03s' ${arr[2]})"
}


# function 'is_valid_requirement_pattern()'
#
# check whether the Java requirement is a valid requirement pattern
#
# supported requirements are for example:
# - 1.6       requires Java 6 (any update)      [1.6, 1.6.0_45, 1.6.0_88]
# - 1.6*      requires Java 6 (any update)      [1.6, 1.6.0_45, 1.6.0_88]
# - 1.6+      requires Java 6 or higher         [1.6, 1.6.0_45, 1.8, 9, etc.]
# - 1.6.0     requires Java 6 (any update)      [1.6, 1.6.0_45, 1.6.0_88]
# - 1.6.0_45  requires Java 6u45                [1.6.0_45]
# - 1.6.0_45+ requires Java 6u45 or higher      [1.6.0_45, 1.6.0_88, 1.8, etc.]
# - 9         requires Java 9 (any update)      [9.0.*, 9.1, 9.3, etc.]
# - 9*        requires Java 9 (any update)      [9.0.*, 9.1, 9.3, etc.]
# - 9+        requires Java 9 or higher         [9.0, 9.1, 10, etc.]
# - 9.1       requires Java 9.1 (any update)    [9.1.*, 9.1.2, 9.1.13, etc.]
# - 9.1*      requires Java 9.1 (any update)    [9.1.*, 9.1.2, 9.1.13, etc.]
# - 9.1+      requires Java 9.1 or higher       [9.1, 9.2, 10, etc.]
# - 9.1.3     requires Java 9.1.3               [9.1.3]
# - 9.1.3*    requires Java 9.1.3 (any update)  [9.1.3]
# - 9.1.3+    requires Java 9.1.3 or higher     [9.1.3, 9.1.4, 9.2.*, 10, etc.]
# - 10-ea     requires Java 10 (early access release)
#
# unsupported requirement patterns are for example:
# - 1.2, 1.3, 1.9       Java 2, 3 are not supported
# - 1.9                 Java 9 introduced a new versioning scheme
# - 6u45                known versioning syntax, but unsupported
# - 9-ea*, 9-ea+        early access releases paired with */+
# - 9., 9.*, 9.+        version ending with a .
# - 9.1., 9.1.*, 9.1.+  version ending with a .
# - 9.3.5.6             4 part version number is unsupported
#
# @param1  a Java requirement string ('1.8+')
# @return  boolean exit code: 0 (is valid), 1 (is not valid)
################################################################################
function is_valid_requirement_pattern() {
	local java_req=$1
	java8pattern='1\.[4-8](\.0)?(\.0_[0-9]+)?[*+]?'
	java9pattern='(9|1[0-9])(-ea|[*+]|(\.[0-9]+){1,2}[*+]?)?'
	# test matches either old Java versioning scheme (up to 1.8) or new scheme (starting with 9)
	if [[ ${java_req} =~ ^(${java8pattern}|${java9pattern})$ ]]; then
		return 0
	else
		return 1
	fi
}


# function 'does_java_version_satisfy_requirement()'
#
# this function checks whether a given java version number
# satisfies the given requirement
#
# the function returns with an error (exit 2) if the requirement string
# is not supported
#
# @param1  the java version in plain form as 'java -version' returns it
# @param2  the java requirement (1.6, 1.7+, 9, 9.1*, 9.2.3, etc.)
# @return  an exit code: 0 (satiesfies), 1 (does not), 2 (invalid requirement)
################################################################################
function does_java_version_satisfy_requirement() {
	# update short versions (9, 9.1, 10) to semver form (9.0.0, 9.1.0, 10.0.0)
	local java_ver=$(pad_short_version_to_semver $1)
	local java_req=$2

	if ! is_valid_requirement_pattern ${java_req} ; then
		return 2

	# requirement ends with * modifier
	# e.g. 1.8*, 9*, 9.1*, 9.2.4*, 10*, 10.1*, 10.1.35*
	elif [[ ${java_req} == *\* ]] ; then
		# use the * modifier from the requirement string as wildcard for a 'starts with' comparison
		if [[ ${java_ver} == ${java_req} ]] ; then
			return 0
		else
			return 1
		fi

	# requirement ends with + modifier
	# e.g. 1.8+, 9+, 9.1+, 9.2.4+, 10+, 10.1+, 10.1.35+
	elif [[ ${java_req} == *+ ]] ; then
		local java_req_num=$(get_comparable_java_version ${java_req})
		local java_ver_num=$(get_comparable_java_version ${java_ver})
		if [ ${java_ver_num} -ge ${java_req_num} ] ; then
			return 0
		else
			return 1
		fi

	# matches standard requirements without modifier
	# e.g. 1.8, 9, 9.1, 9.2.4, 10, 10.1, 10.1.35
	else
		# java version equals requirement string (1.8.0_45 == 1.8.0.45)
		if [ ${java_ver} == ${java_req} ] ; then
			return 0
		# java version starts with requirement string (1.8.0_45 == 1.8)
		elif [[ ${java_ver} == ${java_req}* ]] ; then
			return 0
		else
			return 1
		fi

	fi
}





# test function:
# tests the extract_java_major_version() function
##########################################################
function testExtractMajor() {
	local java_version=$1
	local expected_major=$2
	local actual_major=$(extract_java_major_version "$java_version")
	if [ ${expected_major} == ${actual_major} ] ; then
		echo "[TEST OK] Extracted Java major version '${actual_major}' for Java '${java_version}'"
	else
		echo "[TEST FAILED] Extracted Java major version '${actual_major}' for Java '${java_version}' but expected '${expected_major}'"
	fi
}


echo ""
echo "########################################################"
echo "Testing function extract_java_major_version()"
echo ""
echo "Tests with Java 1.6:"
testExtractMajor "1.6" "6"
testExtractMajor "1.6+" "6"
testExtractMajor "1.6.0" "6"
testExtractMajor "1.6.0_07" "6"
testExtractMajor "1.6.0_45" "6"
testExtractMajor "1.6.0_65-b14-468" "6"
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
# tests the get_comparable_java_version() function
##########################################################
function testComparable() {
	local version=$1
	local expected=$2
	local actual=$(get_comparable_java_version $version)
	if [ "$actual" == "$expected" ] ; then
		echo "[TEST OK] Version number '$version' has comparable form '$actual' (matches expected result '$expected')"
	else
		echo "[TEST FAILED] Version number '$version' has comparable form '$actual' (DOES NOT MATCH expected result '$expected')"
	fi
}


echo ""
echo ""
echo "########################################################"
echo "Testing function get_comparable_java_version()"
echo ""
echo "Tests with Java 1.6:"
testComparable "1.6" "06000000"
testComparable "1.6+" "06000000"
testComparable "1.6.0_45" "06000045"
testComparable "1.6.0_65-b14-468" "06000065"
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
# tests the is_valid_requirement_pattern() function
##########################################################
function testValidReqPattern() {
	local pattern=$1
	local expected=$2
	local actual=$(is_valid_requirement_pattern "$pattern" ; echo $?)
	if [ "$expected" == "$actual" ] ; then
		case $expected in
			0)
				echo "[TEST OK] [${expected}==${actual}] Requirement pattern '$pattern' is valid"
				;;
			1)
				echo "[TEST OK] [${expected}==${actual}] Requirement pattern '$pattern' is not valid"
				;;
		esac
	else
		echo "[TEST FAILED] [${expected}!=${actual}] Requirement ${pattern} ; Expected: ${expected} ; Actual: ${actual}"
	fi
}


echo ""
echo ""
echo "########################################################"
echo "Testing function is_valid_requirement_pattern()"
echo ""
echo "Tests with old version scheme (valid requirements):"
testValidReqPattern "1.4" "0"
testValidReqPattern "1.5" "0"
testValidReqPattern "1.6" "0"
testValidReqPattern "1.6*" "0"
testValidReqPattern "1.6+" "0"
testValidReqPattern "1.6.0" "0"
testValidReqPattern "1.6.0*" "0"
testValidReqPattern "1.6.0+" "0"
testValidReqPattern "1.6.0_45" "0"
testValidReqPattern "1.6.0_45+" "0"
testValidReqPattern "1.6.0_100" "0"
testValidReqPattern "1.6.0_100+" "0"
echo ""
echo "Tests with old version scheme (invalid requirements):"
testValidReqPattern "1.2" "1"
testValidReqPattern "1.3" "1"
testValidReqPattern "1.9" "1"
testValidReqPattern "1.9*" "1"
testValidReqPattern "1.9+" "1"
testValidReqPattern "1.9.0_20" "1"
testValidReqPattern "1.9.0_20*" "1"
testValidReqPattern "1.9.0_20+" "1"
testValidReqPattern "6u45" "1"
echo ""
echo "Tests with new version scheme (valid requirements):"
testValidReqPattern "9" "0"
testValidReqPattern "9*" "0"
testValidReqPattern "9+" "0"
testValidReqPattern "9-ea" "0"
testValidReqPattern "9.1" "0"
testValidReqPattern "9.1*" "0"
testValidReqPattern "9.1+" "0"
testValidReqPattern "9.1.3" "0"
testValidReqPattern "9.1.3*" "0"
testValidReqPattern "9.1.3+" "0"
testValidReqPattern "9.0.13" "0"
testValidReqPattern "9.11" "0"
testValidReqPattern "9.11*" "0"
testValidReqPattern "9.11+" "0"
testValidReqPattern "9.10.23" "0"
testValidReqPattern "9.10.101" "0"
testValidReqPattern "10" "0"
testValidReqPattern "10*" "0"
testValidReqPattern "10-ea" "0"
testValidReqPattern "10.1" "0"
testValidReqPattern "10.1*" "0"
testValidReqPattern "10.1+" "0"
testValidReqPattern "10.0.1" "0"
testValidReqPattern "10.0.1*" "0"
testValidReqPattern "10.0.1+" "0"
testValidReqPattern "10.0.13" "0"
testValidReqPattern "10.1.3" "0"
testValidReqPattern "10.12" "0"
testValidReqPattern "10.10.23" "0"
testValidReqPattern "10.10.113" "0"
echo ""
echo "Tests with new version scheme (invalid requirements):"
testValidReqPattern "9-ea*" "1"
testValidReqPattern "9-ea+" "1"
testValidReqPattern "9." "1"
testValidReqPattern "9.*" "1"
testValidReqPattern "9.+" "1"
testValidReqPattern "9.1." "1"
testValidReqPattern "9.1.*" "1"
testValidReqPattern "9.1.+" "1"
testValidReqPattern "9.2.15." "1"
testValidReqPattern "9.2.15.*" "1"
testValidReqPattern "9.2.15.+" "1"
testValidReqPattern "9.3.5.6" "1"
