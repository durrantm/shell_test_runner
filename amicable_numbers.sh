#!/usr/bin/env bash
. do_test.sh
. do_test_error_messages.sh

setup () {
  declare -g result=True
}

divisors () {
  [[ $# -eq 0 ]] && echo "Error - 1 Parameter required.  exiting" && exit 1
  result=1
  local UPTO=$1
  local i
  for ((i=2; i<UPTO; i++)); {
    [[ i*i -gt UPTO ]] && return
    if [[ $((UPTO % i)) -eq 0 ]]; then
      result="$result,$i"
      if [[ i -ne UPTO/i ]]; then
        result="$result,$((UPTO/i))"
      fi
    fi
  }
}

sum_of_divisors () {
  [[ $# -eq 0 ]] && echo "Error - 1 Parameter required.  exiting" && exit 1
  divisors $1
  sum_of_nums $result
}

sum_of_nums() {
  [[ $# -eq 0 ]] && echo "Error - 1 Parameter required.  exiting" && exit 1
  local -r DIVISORS_WITH_COMMAS=($1)
  IFS=","
  local -r NUMBER_OF_DIVISORS=`echo $DIVISORS_WITH_COMMAS | wc -w`
  IFS=" "
  local -r DIVISORS=(`echo $DIVISORS_WITH_COMMAS | tr ',' ' '`)
  local sum=0
  local i
  for ((i=0; i<NUMBER_OF_DIVISORS; i++)); {
    sum=$(( sum + DIVISORS[i] ))
  }
  result=$sum
}

amicable () {
  local -r COMPARE_TO="$1"
  sum_of_divisors $COMPARE_TO
  sum_of_divisors $result
  [[ "$COMPARE_TO" -eq "$result" ]] && result=0 || result=1
}

amicable_list () {
  [[ $# -eq 0 ]] && echo "Error - 1 Parameter required.  exiting" && exit 1
  local upto=$1
  local amicables=1
  local i=0
  for ((i=2; i<$upto; i++)); {
    amicable $i
    [[ $result -eq 0 ]] && amicables=$amicables','$i
  }
  result=$amicables
}

sum_of_amicable_list () {
  [[ $# -eq 0 ]] && echo "Error - 1 Parameter required.  exiting" && exit 1
  amicable_list $1
  sum_of_nums $result
  result=$result
}

#debug=True
debug=False

do_test setup $LINENO True 0
do_test divisors $LINENO failfast 1 1
do_test divisors $LINENO description="t2" 1,2 4
do_test divisors $LINENO 1 5
do_test divisors $LINENO 1,2,3 6
do_test divisors $LINENO 1,3 9
do_test divisors $LINENO 1 11
do_test divisors $LINENO 1,3,5 15
do_test divisors $LINENO 1,2,10,4,5 20
do_test sum_of_divisors $LINENO 1 1
do_test sum_of_divisors $LINENO 3 4
do_test sum_of_divisors $LINENO 6 6
do_test sum_of_divisors $LINENO 63 64
do_test amicable $LINENO 1 219
do_test amicable $LINENO 0 220
do_test amicable_list $LINENO 1,6,28 50
do_test amicable_list $LINENO 1,6,28,220 222
do_test amicable_list $LINENO 1,6,28,220,284,496 500
do_test amicable_list $LINENO 1,6,28,220,284,496 1000
do_test amicable_list $LINENO 1,6,28,220,284,496,1184,1210,2620,2924 3000
do_test sum_of_amicable_list $LINENO 35 50
do_test sum_of_amicable_list $LINENO 1035 500
do_test sum_of_amicable_list $LINENO 8973 4000
time do_test sum_of_amicable_list $LINENO description="timer" 124477 10000

debug_printf "\n1. result= $((result))\n"

do_test_error_messages
