import json
import fileinput
import sys

assert len(sys.argv) > 0, 'must provide file name'

with open(sys.argv[1]) as f:
    input = json.load(f)
    for val in input.values(): 
        assert not isinstance(val, dict), 'Nested dict not supported'
        print(val)

