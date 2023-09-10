#!/bin/bash

set -e

TMPDIR=$(mktemp -d)
trap 'rm -rf $TMPDIR' EXIT

RED="\033[31m"
GREEN="\033[32m"
YELLOW="\033[33m"
ENDCOLOR="\033[0m"

USAGE=$(cat << EOF
Usage:
$ snap.sh -d /path/to/tests/dir -c "command to run" [-t "test1,test2" -p 3 -u -h]
    
    Required parameters:
    -d|--directory      Directory to find test cases.
    -c|--command        Command to test.
    
    Optional parameters: 
    -t|--tests          Filter tests to run. By default runs all tests.
    -p|--parallel       Run N tests in parallel. By default runs tests serially.
    -u|--update         Update snapshot files for failing tests. 
    -h|--help           Prints this help message.
EOF
)

function error() {
    echo "${RED}Error: $1${ENDCOLOR}\n$USAGE"
    exit 1
}

function testname() {
    path=$1
    basename "${path/.input/}"
}

function runtest() {
    inp=$1

    test=$(testname "$inp")

    out=${inp/.input/.output}
    if [[ ! -f $out ]]; then
        echo "${YELLOW}SKIP${ENDCOLOR} $test"
        return 2
    fi

    command=${CMD/FILE/$inp}
    actual="${TMPDIR}/${test}".actual
    eval "$command" > "$actual"

    diff "$out" "${TMPDIR}/${test}.actual" > "${TMPDIR}/${test}.diff" && true
    if [[ $? -ne 0 ]]; then
        [[ "$UPDATE" -eq 1 ]] && patch -s "$out" "${TMPDIR}/${test}.diff"
        echo "${RED}FAIL${ENDCOLOR} $test"
        return 1
    fi
    echo "${GREEN}PASS${ENDCOLOR} $test"
}

function shouldrun() {
    if [[ -z $TESTS ]]; then
        return 0
    fi

    test=$(testname "$1")
    # shellcheck disable=SC2076
    if [[ "|${TESTS/,/|}|" =~ "|${test}|" ]]; then
        return 0
    fi
    return 1
}

UPDATE=0

while (( $# > 0 )); do
    case "$1" in
        -d|--directory)
            WORKDIR=$2
            [[ -n $WORKDIR ]] || error "test directory not provided."
            test -d "$WORKDIR" || error "Invalid directory $WORKDIR"
            shift; shift
            ;;
        -c|--command)
            CMD=$2
            [[ -n $CMD ]] || error "target program not provided"
            shift; shift
            ;;
        -t|--tests)
            TESTS=$2
            shift; shift
            ;;
        -u|--update)
            UPDATE=1
            shift
            ;;
        -p|--parallel)
            error "parallel not supported"
            ;;
        -h|--help|*)
            echo "$USAGE"
            exit 0
            ;;
    esac
done

TOTAL=0
PASS=0
FAIL=0
SKIP=0

tests=()
for inp in "${WORKDIR}"/*.input
do
    code=0
    shouldrun "$inp" || code=$?
    [[ $code -eq 0 ]] || continue
    tests+=( "$inp" )
done

TOTAL=${#tests[*]}
echo "Running $TOTAL tests.."
for test in "${tests[@]}"
do
    code=0
    runtest "$test" || code="$?"
    if [[ $code -eq 1 ]]; then
        ((FAIL+=1))
    elif [[ $code -eq 2 ]]; then
        ((SKIP+=1))
    else
        ((PASS+=1))
    fi
done

echo "TOTAL $TOTAL" \
    "${GREEN}PASS $PASS${ENDCOLOR}" \
    "${RED}FAIL $FAIL${ENDCOLOR}" \
    "${YELLOW}SKIP $SKIP${ENDCOLOR}"
