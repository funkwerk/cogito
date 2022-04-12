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
module app: 7 (src/main.d)
accumulateResult: 5 (src/main.d:9)
accumulateResult.(λ): 0 (src/main.d:12)
accumulateResult.(λ): 2 (src/main.d:16)
main: 2 (src/main.d:33)
main.(λ): 0 (src/main.d:36)
main.(λ): 2 (src/main.d:42)
```

[cognitive complexity]: https://sonarsource.com/docs/CognitiveComplexity.pdf
