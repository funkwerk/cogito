[![CI](https://github.com/funkwerk/cogito/workflows/CI/badge.svg)](https://github.com/funkwerk/cogito/actions?query=workflow%3ACI)
[![License](https://img.shields.io/badge/license-MPL_2.0-blue.svg)](https://raw.githubusercontent.com/funkwerk/mocked/master/LICENSE)

# cōgitō

cōgitō analyses D code and calculates its [cognitive complexity].

## Installing and usage

Run `./make.rb install release`.

It will download and install the frontend and build a binary.
Then you can run it on some D source:

Run `./build/cogito sample/sample.d`.

## Example output

```
sample/sample.d:
  f:
    Location (line): 3
    Score: 4
```

[cognitive complexity]: https://sonarsource.com/docs/CognitiveComplexity.pdf
