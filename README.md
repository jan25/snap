# snap

`snap` is a snapshot testing tool written in bash. It tests your command line tool by validating provided input and output test cases.

## Install

TODO add curl command to download.

## Usage

> TODO Some of features below are WIP.

snap requires you to specify a target command to test, it then evaluates your test cases against the output from that command. To do this create snap.cmd file in the directory where you intend to put your test cases.

```sh
# Example
$ echo "python3 myawesomeprogram.py" >> snap.cmd
```

snap runs your tests from a directory. To run your snapshot tests create test cases suffixed with `.input` and `.output` in a directory.

```sh
$ snap.sh /path/to/test/dir
Found 45 tests..
PASS test1
FAIL test2
...

40 PASS 5 FAIL
```

snap can automatically patch your test cases by passing an option.

```sh
$ snap.sh /path/to/test/dir --update
Patching 5 tests
DONE test1
DONE test3
...
```

By default snap runs all your tests. You can optionally tell it to run specific tests.

```sh
$ snap.sh /path/to/test/dir --tests test2,test4
Running 2 tests
PASS test2
...
```

snap can run multiple test concurrently. Default is serial execution.

```sh
$ snap.sh /path/to/test/dir --parallel 3
...
```

Use `--dry-run` option to print diff and not update snapshots.

## Develop

`examples` directory contains sample test cases to test snap locally.

```sh
$ snap.sh ./examples "cat FILE"
```

Use [`shellcheck`](https://github.com/koalaman/shellcheck) to catch potential bugs and conform with bash standards.

```sh
$ shellcheck snap.sh
```
