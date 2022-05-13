import cogito;

import argparse : Main, parseCLIArgs;
import cogito.arguments;
import std.algorithm;
import std.sumtype;
import std.functional;

int accumulateResult(Arguments arguments, int accumulator, Result result)
{
    auto nextResult = match!(
        (List!CognitiveError errors) {
            printErrors(errors);
            return 2;
        },
        (Source source) {
            const threshold = Threshold(arguments.threshold, arguments.aggregateThreshold, arguments.moduleThreshold);
            const result = report(source, threshold, arguments.format);
            return result ? 3 : 0;
        }
    )(result);
    if (accumulator == 2 || nextResult == 2)
    {
        return 2;
    }
    else if (accumulator != 0)
    {
        return accumulator;
    }
    return nextResult;
}

mixin Main.parseCLIArgs!(Arguments, (arguments) {
    return runOnFiles(arguments.files)
        .fold!(partial!(accumulateResult, arguments))(0);
});
