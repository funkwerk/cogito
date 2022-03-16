module cogito.arguments;

import std.algorithm;
import std.range;
import std.conv;
import std.sumtype;

struct Arguments
{
    string[] files = [];
    uint threshold = 40;
}

struct ArgumentError
{
    enum Type : int
    {
        unknown,
        wrongType,
        missingValue
    }

    private Type type_;
    private string argument_;
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
        }
    }
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
        else if (args.front.startsWith("--") && args.length == 1)
        {
            return ArgumentResult(ArgumentError(ArgumentError.Type.unknown, args.front));
        }
        else if (args.front == "--threshold")
        {
            args.popFront;
            try
            {
                arguments.threshold = args.front.to!uint;
            }
            catch (ConvException e)
            {
                auto error = ArgumentError(ArgumentError.Type.wrongType, args.front);
                error.expected = "Positive number";

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
    arguments.files = (arguments.files ~ args).sort.uniq.array;

    return ArgumentResult(arguments);
}
