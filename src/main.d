import cogito;

import argparse : CLI;
import cogito.arguments;
import std.algorithm;
import std.sumtype;
import std.functional;
import std.stdio;

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

            if (result.isNull)
            {
                return 0;
            }
            else if (result.get == Threshold.Type.function_)
            {
                return 3;
            }
            else if (result.get == Threshold.Type.aggregate)
            {
                return 4;
            }
            else if (result.get == Threshold.Type.module_)
            {
                return 5;
            }
            assert(false, "Unknown threshold type");
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

mixin CLI!Arguments.main!((arguments) {
    try
    {
        return runOnFiles(arguments.files)
            .fold!(partial!(accumulateResult, arguments))(0);
    }
    catch (Exception exception)
    {
        stderr.writefln!"Error: %s"(exception.msg);
        return 1;
    }
});
