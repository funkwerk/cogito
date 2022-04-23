module cogito.arguments;

import argparse;
import std.algorithm;
import std.range;

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
    verbose
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

    /// Output format.
    @NamedArgument
    OutputFormat format = OutputFormat.flat;
}
