[![CI](https://github.com/funkwerk/cogito/workflows/CI/badge.svg)](https://github.com/funkwerk/cogito/actions?query=workflow%3ACI)
[![License](https://img.shields.io/badge/license-MPL_2.0-blue.svg)](https://raw.githubusercontent.com/funkwerk/mocked/master/LICENSE)

# cōgitō

cōgitō analyses D code and calculates its [cognitive complexity].

## Installing and usage

Run `make install build/release/bin/cogito`.

It will download and install the frontend and build a binary.
Then you can run it on some D source:

Run `./build/release/bin/cogito src/main.d`.

## Example output

```
module app: 5 (src/main.d)
accumulateResult: 5 (src/main.d:9)
accumulateResult.(λ): 0 (src/main.d:12)
accumulateResult.(λ): 2 (src/main.d:16)
(λ): 0 (src/main.d:33)
```

## Command line options

Property name | Allowed values | Description
-------------------|------------------|-----
--threshold | Positive numbers | Fail if the source score exceeds this threshold.
--module-threshold | Positive numbers | Fail if a function score exceeds this threshold.
--format | `flat`, `verbose` and `silent` | Flat format outputs all functions with their source file name and line number. Verbose output adds column numbers and scores inside aggregates. Silent format produces no output, but returns an error if one of the thresholds is exceeded.
--help | – | Show a help message.

## Return codes

The return code of the program provides some information on what kind of error
occurred.

- 0: Success
- 1: Command line arguments are invalid
- 2: Some source files contain errors
- 3: Threshold violation

[cognitive complexity]: https://sonarsource.com/docs/CognitiveComplexity.pdf
