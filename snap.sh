#!/bin/bash

set -e

TMPDIR=$(mktemp -d)
trap "rm -rf $TMPDIR" EXIT

[[ -n $1 ]] || { echo "Error: test directory not provided"; exit 1; }
WORKDIR=$1
test -d $WORKDIR || { echo "Error: Invalid direcctory $WORKDIR"; exit 1; }
shift

[[ -n $1 ]] || { echo "Error: target program not provided"; exit 1; }
CMD=$1
shift

TESTS=$1

PARALLEL=$2

function testname() {
    path=$1
    echo "$(basename $(echo ${path/.input/}))"
}

function runtest() {
    inp=$1

    test=$(testname $inp)

    out=${inp/.input/.output}
    if [[ ! -f $out ]]; then
        echo "SKIP $test"
        return 2
    fi

    command=${CMD/FILE/$inp}
    actual="$TMPDIR/$test".actual
    eval $command > $actual

    diff $out "$TMPDIR/$test".actual > "$TMPDIR/$test".diff && true
    if [[ $? -ne 0 ]]; then
        # patch $out "$TMPDIR/$test".diff
        echo "FAIL $test"
        return 1
    fi
    echo "PASS $test"
}

function shouldrun() {
    if [[ -z $TESTS ]]; then
        return 0
    fi

    test=$(testname $1)
    if [[ "|${TESTS/,/|}|" =~ "|${test}|" ]]; then
        return 0
    fi
    return 1
}

TOTAL=0
PASS=0
FAIL=0
SKIP=0

tests=()
for inp in $WORKDIR/*.input
do
    code=0
    shouldrun $inp || code=$?
    [[ $code -eq 0 ]] || continue
    tests+=( $inp )
done

TOTAL=${#tests[*]}
echo "Running $TOTAL tests.."
for test in ${tests[*]}
do
    code=0
    runtest $test || code="$?"
    if [[ $code -eq 1 ]]; then
        ((FAIL+=1))
    elif [[ $code -eq 2 ]]; then
        ((SKIP+=1))
    else
        ((PASS+=1))
    fi
done

echo "TOTAL $TOTAL PASS $PASS FAIL $FAIL SKIP $SKIP"
