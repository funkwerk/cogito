module cogito.arguments;

import argparse;
import std.algorithm;
import std.conv;
import std.format;
import std.range;
import std.traits;

// Help message.
private enum string returnCodes = q"HELP
  Return codes:
    0  Success
    1  Command line arguments are invalid
    2  Some source files contain errors
    3  Threshold violation
HELP";

/**
 * Possible output formats.
 */
enum OutputFormat
{
    silent,
    flat,
    verbose,
    debug_,
}

private enum string allowedOutputFormat(OutputFormat Member) =
    Member.to!string.strip('_');
private enum string[] allowedOutputFormats = [
    staticMap!(allowedOutputFormat, EnumMembers!OutputFormat)
];

private OutputFormat parseOutputFormat(string input)
{
    switch (input)
    {
        case "debug":
            return OutputFormat.debug_;
        case "silent":
            return OutputFormat.silent;
        case "flat":
            return OutputFormat.flat;
        case "verbose":
            return OutputFormat.verbose;
        default:
            enum string validValues = allowedOutputFormats.join(',');
            enum string errorFormat =
                "Invalid value '%s' for argument '--format'.\nValid argument values are: %s";
            throw new Exception(format!errorFormat(input, validValues));
    }
}

/**
 * Arguments supported by the CLI.
 */
@(Command("cogito").Epilog(returnCodes))
struct Arguments
{
    /// Input files.
    @(PositionalArgument(0).Description("Source files").Required())
    string[] files = [];

    /// Module threshold.
    @(NamedArgument(["module-threshold"])
            .Optional()
            .Description("Fail if the source score exceeds this threshold")
            .Placeholder("NUMBER"))
    uint moduleThreshold = 0;

    /// Function threshold.
    @(NamedArgument(["threshold"])
            .Optional()
            .Description("Fail if a function score exceeds this threshold")
            .Placeholder("NUMBER"))
    uint threshold = 0;

    /// Aggregate threshold.
    @(NamedArgument(["aggregate-threshold"])
            .Optional()
            .Description("Fail if an aggregate exceeds this threshold")
            .Placeholder("NUMBER"))
    uint aggregateThreshold = 0;

    /// Output format.
    @(NamedArgument
            .AllowedValues!allowedOutputFormats
            .PreValidation!((string x) => true)
            .Parse!parseOutputFormat
            .Validation!((OutputFormat x) => true)
    )
    OutputFormat format = OutputFormat.flat;
}
