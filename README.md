# snap [![example workflow](https://github.com/jan25/snap/actions/workflows/shellcheck.yml/badge.svg)](https://github.com/jan25/snap/actions/workflows/shellcheck.yml)

`snap` is a snapshot testing tool written in bash. It tests your command line tool by validating provided input and output test cases.

## Install

```sh
$ curl https://raw.githubusercontent.com/jan25/snap/main/snap.sh -o snap.sh
$ chmod +x snap.sh
# Optionally: move snap.sh to PATH

$ sh snap.sh -h
```

## Usage

Supplying test directory and command to test to snap will enumerate test case snapshots suffixed with `.output|.input` in the directory.

```sh
$ sh snap.sh -t /tests/dir -c "cat FILE"
Found 2 tests..
PASS test1
FAIL test2
TOTAL 2 PASS 1 FAIL 1 SKIP 0
```

> Note: `FILE` is a special placeholder which is used to pipe inputs to the command under test.


Use `-u|--update` to let snap update snaphot files for failing tests.

```sh
$ sh snap.sh -t /tests/dir -c "cat FILE" -u
Found 2 tests..
PASS test1
FAIL test2
TOTAL 2 PASS 1 FAIL 1 SKIP 0

$ sh snap.sh -t /tests/dir -c "cat FILE"
Found 2 tests..
PASS test1
PASS test2
TOTAL 2 PASS 2 FAIL 0 SKIP 0
```
By default snap runs all your tests. You can optionally tell it to run specific tests with `-t|--tests` option.

```sh
$ sh snap.sh -t /tests/dir -c "cat FILE" -t "test1,test3"
Running 1 tests..
PASS test1
TOTAL 1 PASS 1 FAIL 0 SKIP 0
```

## Develop

`examples` directory contains sample test cases to test snap locally.

```sh
$ snap.sh -t ./examples -c "cat FILE"
```

Use [`shellcheck`](https://github.com/koalaman/shellcheck) to catch potential bugs and conform with bash standards.

```sh
$ shellcheck snap.sh
```
