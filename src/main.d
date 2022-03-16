import cogito;

import cogito.arguments;
import std.algorithm;
import std.sumtype;
import std.stdio;

int accumulateResult(int accumulator, Result result)
{
    return accumulator + match!(
        (List!CognitiveError errors) {
            printErrors(errors);
            return 1;
        },
        (Source source) {
            printMeter(source);
            return 0;
        }
    )(result);
}

int main(string[] args)
{
    return parseArguments(args).match!(
        (ArgumentError error) {
            writeln(error);

            return 2;
        },
        (Arguments arguments) {
            auto meter = runOnFiles(arguments.files);

            return meter.fold!accumulateResult(0) > 0 ? 1 : 0;
        }
    );
}
