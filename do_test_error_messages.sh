#!/usr/bin/env bash
. colors_for_text.sh 2> /dev/null
do_test_error_messages () {
  echo
  if [[ "$error_messages" == "" ]]; then
    printf $pass_color"ALL $test_runs TESTS PASSED $color_end\n"
  else
    printf "$error_messages"
    printf "$fail_color============- FAIL -============ $color_end \n"
    printf " Runs: $test_runs $pass_color Passes: $test_passes $fail_color Fails: $test_fails\n"
    printf "$fail_color============- FAIL -============ $color_end \n"
  fi
}
