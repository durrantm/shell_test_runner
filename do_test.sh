#!/usr/bin/env bash
. colors_for_text.sh 2> /dev/null

do_test () {
  if [[ $# -eq 0 ]]; then
    printf "$fail_color Error - do_test: No parameters provided - Usage is do_test [function_name] \$LINENO [expected result] [optional params]\n"
    exit 1
  elif [[ $# -eq 1 ]]; then
    printf "$fail_color Error - do_test: Two parameters missing - \$LINENO and expected result (other params as needed)\n"
    exit 1
  fi
  declare -ig test_runs test_passes test_fails
  local -r function="$1";shift
  local -r line_number="$1";shift
  local failfast="False"
  local debug="False"
  local verbose="False"
  local test_description=
  local test_matcher=
  local expected=
  local pass_on_params=
  local command_not_found=False
  local syntax_error=False
  result=''
  type "setup" &> /dev/null && setup
  # TODO Replace with for loop (initial attempts failed)
  [[ "$1" == "failfast" ]] && failfast="True" && shift
  [[ "$1" == "debug" ]] && debug="True" && shift
  [[ "$1" == "verbose" ]] && verbose="True" && shift
  [[ "$1" == "failfast" ]] && failfast="True" && shift
  [[ "$1" == "debug" ]] && debug="True" && shift
  [[ "$1" == "failfast" ]] && failfast="True" && shift
  if [[ "$1" =~ ^description= ]]; then
    [[ `echo $1 | grep =` ]] && test_description=`echo $1 | sed 's/.*=//'` && shift
  fi
  if [[ "$1" =~ ^matcher= ]]; then
    [[ `echo "$1" | grep =` ]] && test_matcher="`echo "$1" | sed 's/matcher=//'`" && shift
  fi
  if [[ $# -eq 0 ]]; then
    printf "$fail_color Error - Function: $function, Line: $line_number \n
do_test: Third parameter missing - expected result\n"
    exit 1
  fi
  expected="$1";shift
  pass_on_params="$@"
  test_runs+=1

  $function ${pass_on_params[@]}
  if [[ "$test_matcher" == "==" ]]; then
    [[ "$result" == "$expected" ]] && record_test_success "$function" || record_test_failure "$function";
  elif [[ "$expected" =~ ^-?[0-9]+$ ]]; then
    [[ "$result" -eq $expected ]] && record_test_success "$function" || record_test_failure "$function";
  else
    [[ "$result" == "$expected" ]] && record_test_success "$function" || record_test_failure "$function";
  fi
}
record_test_success () {
  [[ $# -eq 0 ]] && no_param_quit $FUNCNAME
  local -r function="$1"
  [[ "$verbose" == "True" ]] && printf "\n$function($test_description) "
  printf "$pass_color"."$color_end"
  test_passes+=1
}
record_test_failure () {
  [[ $# -eq 0 ]] && no_param_quit $FUNCNAME
  local -r function="$1"
  test_fails+=1
  printf "$fail_color"F"$color_end"
  function_exists? "$function" &&
    error_messages=$error_messages"$fail_color""$test_description""Line: $line_number - \
'$function ${pass_on_params[@]}' failed:\n\
Expected: $expected\n\
Received: $result $color_end\n\n" ||
    error_messages=$error_messages"$fail_color""Line: $line_number: \
Function '$function' is undefined\n"
  [[ "$failfast" == "True" ]] && failfast "Test" $error_messages
}
record_script_failure () {
  [[ $# -eq 0 ]] && no_param_quit $FUNCNAME
  local -r function="$1"
  test_fails+=1
  err=`cat $TMPDIR/output.txt`
  printf $err
  error_messages=$error_messages"$fail_color""Line: $line_number: \
Error within function '$function', getting"
  if [[ $command_not_found == "True" ]]; then
    error_messages="$error_messages \"command not found\""
  else
    error_messages="$error_messages \"error\""
  fi
  error_messages="$error_messages in $err \n"
  [[ "$failfast" == "True" ]] && failfast "Script" $error_messages
}
failfast () {
  printf "\n$1 error & failfast set to exit immediately.\n$2\n" && exit 1
}

no_param_quit () {
  printf "\nError - 1 parameter required for: $1 - exiting\n" && exit 1
}
function_exists?() {
    declare -f -F $1 > /dev/null
    return $?
}
debug_echo () {
  [[ "$debug" == "True" ]] && echo "$1"
}
debug_printf () {
  [[ "$debug" == "True" ]] && printf "$1"
}
