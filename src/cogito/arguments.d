module cogito.arguments;

import std.algorithm;
import std.range;
import std.conv;
import std.sumtype;
import std.typecons;

/// Help message.
enum string help = q"HELP
Usage: cogito [OPTION…] SOURCE…
    --module-threshold NUMBER      fail if the source score exceeds this threshold
    --threshold NUMBER             fail if a function score exceeds this threshold
    --format ENUMERATION           "silent", "flat" or "verbose"

  Return codes:
    0  Success
    1  Some source files contain errors
    2  Command line arguments are invalid
    3  Excess of threshold
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
struct Arguments
{
    /// Input files.
    string[] files = [];
    /// Module threshold.
    Nullable!uint moduleThreshold;
    /// Function threshold.
    Nullable!uint threshold;
    /// Output format.
    Nullable!OutputFormat format;
    /// Display help message.
    bool help = false;
}

/**
 * CLI argument parsing error.
 */
struct ArgumentError
{
    /// Error type.
    enum Type : int
    {
        unknown,
        wrongType,
        missingValue,
        noInput
    }

    private Type type_;
    private string argument_;
    /// Expected argument type.
    string expected;

    @disable this();

    this(Type type, string argument)
    {
        this.type_ = type;
        this.argument_ = argument;
    }

    @property Type type() const
    {
        return this.type_;
    }

    @property string argument()
    {
        return this.argument_;
    }

    string toString()
    {
        final switch (type)
        {
            case Type.unknown:
                return "Unknown argument " ~ argument;
            case Type.wrongType:
                return "Argument "
                    ~ argument
                    ~ " expected to have type "
                    ~ this.expected;
            case Type.missingValue:
                return "Argument "
                    ~ argument
                    ~ " is expected to have a value";
            case Type.noInput:
                return "At least one source file should be specified";
        }
    }
}

SumType!(ArgumentError, Arguments) postprocessArguments(Arguments arguments, string[] rest)
{
    arguments.files = (arguments.files ~ rest).sort.uniq.array;
    if (arguments.files.empty)
    {
        return typeof(return)(ArgumentError(ArgumentError.Type.noInput, null));
    }

    return typeof(return)(arguments);
}

SumType!(ArgumentError, Arguments) parseArguments(string[] args)
{
    alias ArgumentResult = typeof(return);
    args.popFront;
    Arguments arguments;

    while (!args.empty)
    {
        if (args.front == "--")
        {
            args.popFront;
            break;
        }
        else if (args.front == "--help")
        {
            arguments.help = true;
            return ArgumentResult(arguments);
        }
        else if (args.front.startsWith("--") && args.length == 1)
        {
            return ArgumentResult(ArgumentError(ArgumentError.Type.unknown, args.front));
        }
        else if (args.front == "--module-threshold" || args.front == "--threshold")
        {
            const next = args.front;
            args.popFront;
            try
            {
                if (next == "--module-threshold") 
                {
                    arguments.moduleThreshold = nullable(args.front.to!uint);
                }
                else
                {
                    arguments.threshold = nullable(args.front.to!uint);
                }
            }
            catch (ConvException e)
            {
                auto error = ArgumentError(ArgumentError.Type.wrongType, args.front);
                error.expected = "Positive number";

                return ArgumentResult(error);
            }
        }
        else if (args.front == "--format")
        {
            args.popFront;
            if (args.front == "flat") 
            {
                arguments.format = nullable(OutputFormat.flat);
            }
            else if (args.front == "silent")
            {
                arguments.format = nullable(OutputFormat.silent);
            }
            else if (args.front == "verbose")
            {
                arguments.format = nullable(OutputFormat.verbose);
            }
            else
            {
                auto error = ArgumentError(ArgumentError.Type.wrongType, args.front);
                error.expected = "silent|flat|verbose";

                return ArgumentResult(error);
            }
        }
        else if (args.front.startsWith("--"))
        {
            return ArgumentResult(ArgumentError(ArgumentError.Type.unknown, args.front));
        }
        else
        {
            arguments.files ~= args.front;
        }
        args.popFront;
    }
    return postprocessArguments(arguments, args);
}
