import cogito;

import cogito.arguments;
import std.algorithm;
import std.sumtype;
import std.stdio;
import std.functional;

int accumulateResult(Arguments arguments, int accumulator, Result result)
{
    auto nextResult = match!(
        (List!CognitiveError errors) {
            printErrors(errors);
            return 1;
        },
        (Source source) {
            const result = printMeter(source, arguments.threshold,
                    arguments.moduleThreshold, arguments.format);
            return result ? 3 : 0;
        }
    )(result);
    if (accumulator == 1 || nextResult == 1)
    {
        return 1;
    }
    else if (accumulator != 0)
    {
        return accumulator;
    }
    return nextResult;
}

int main(string[] args)
{
    return parseArguments(args).match!(
        (ArgumentError error) {
            writeln(error);
            writeln(help);

            return 2;
        },
        (Arguments arguments) {
            if (arguments.help)
            {
                write(help);
                return 0;
            }
            auto meter = runOnFiles(arguments.files);

            return meter.fold!(partial!(accumulateResult, arguments))(0);
        }
    );
}
