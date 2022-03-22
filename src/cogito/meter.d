module cogito.meter;

import core.stdc.stdarg;
import core.stdc.stdio : fputc, fputs, fprintf, stderr;
import dmd.frontend;
import dmd.identifier;
import dmd.globals;
import dmd.console;
import dmd.root.outbuffer;

import cogito.list;
import std.algorithm;
import std.conv;
import std.range;
import std.stdio : write, writefln;
import std.typecons;
import std.sumtype;

private mixin template Ruler()
{
    uint ownScore = 0;
    List!Meter inner;

    @disable this();

    public uint score()
    {
        return this.ownScore
            + reduce!((accum, x) => accum + x.score)(0, this.inner[]);
    }
}

/**
 * Identifier and its location in the source file.
 */
struct ScoreScope
{
    /**
     * Declaration identifier (e.g. function or struct name, may be empty if
     * this is a lambda).
     */
    Identifier name;

    /// Source position.
    Loc location;
}

/**
 * Collects the score from a single declaration, like a function. Can contain
 * nested $(D_SYMBOL Meter) structures with nested declarations.
 */
struct Meter
{
    private ScoreScope scoreScope;

    @property ref Identifier name() return
    {
        return this.scoreScope.name;
    }

    @property void name(ref Identifier name)
    {
        this.scoreScope.name = name;
    }

    @property ref Loc location() return
    {
        return this.scoreScope.location;
    }

    @property void name(ref Loc location)
    {
        this.scoreScope.location = location;
    }

    /**
     * Params:
     *     name = Identifier.
     *     location = Identifier location.
     *     score = Initial score.
     */
    public this(Identifier name, Loc location, uint score = 0)
    {
        this.name = name;
        this.location = location;
        this.ownScore = score;
    }

    private void toString(void delegate(const(char)[]) sink, const uint indentation)
    {
        const indentBytes = ' '.repeat(indentation * 2).array;
        const nextIndentation = indentation + 1;
        const nextIndentBytes = ' '.repeat(nextIndentation * 2).array;
        const identifierName = this.name.toString();

        sink(indentBytes);
        sink(identifierName.empty ? "(λ)" : identifierName);
        debug
        {
            sink(":\n");
            sink(nextIndentBytes);
            sink("Location (line): ");
            sink(to!string(this.location.linnum));
            sink("\n");
            sink(nextIndentBytes);
            sink("Score: ");
        }
        else
        {
            sink(": ");
        }
        sink(to!string(this.score));
        sink("\n");

        this.inner[].each!(meter => meter.toString(sink, nextIndentation));
    }

    /**
     * Prints the information about the given identifier. Debug build provides
     * more details.
     *
     * Params:
     *     sink = Function used to print the information.
     */
    void toString(void delegate(const(char)[]) sink)
    {
        toString(sink, 1);
    }

    mixin Ruler!();
}

/**
 * Collects the score from a single D module.
 */
struct Source
{
    /// Module name.
    string filename;

    /**
     * Params:
     *     inner = List with module metrics.
     *     filename = Module name.
     */
    public this(List!Meter inner, string filename = "main")
    {
        this.inner = inner;
        this.filename = filename;
    }

    mixin Ruler!();
}

/**
 * Prints source file metrics to the standard output.
 *
 * Params:
 *     source = Collected metrics and scores.
 *     threshold = Maximum acceptable score.
 *
 * Returns: true if the score exceeds the threshold, otherwise returns false.
 */
bool printMeter(Source source, Nullable!uint threshold)
{
    const sourceScore = source.score;
    debug
    {
        enum bool isDebug = true;
    }
    else
    {
        enum bool isDebug = false;
    }
    const bool aboveThreshold = !threshold.isNull && sourceScore > threshold.get;

    if (aboveThreshold || isDebug)
    {
        writefln("\x1b[36m%s:\x1b[0m", source.filename);

        if (!source.inner.empty)
        {
            foreach (m; source.inner[])
            {
                m.toString(input => write(input));
            }
        }
        writefln("  \x1b[36mScore: %s\x1b[0m", sourceScore);
    }
    return aboveThreshold;
}

/**
 * Prints an error list to the standard output.
 *
 * Params:
 *     errors = The errors to print.
 */
void printErrors(List!CognitiveError errors)
{
    foreach (error; errors[])
    {
        auto location = error.location.toChars();

        if (*location)
        {
            fprintf(stderr, "%s: ", location);
        }
        fputs(error.header, stderr);

        fputs(error.message.peekChars(), stderr);
        fputc('\n', stderr);
    }
}

struct CognitiveError
{
    Loc location;
    Color headerColor;
    const(char)* header;
    RefCounted!OutBuffer message;
}

struct LocalHandler
{
    List!CognitiveError errors;

    bool handler(const ref Loc location,
        Color headerColor,
        const(char)* header,
        const(char)* messageFormat,
        va_list args,
        const(char)* prefix1,
        const(char)* prefix2) nothrow
    {
        CognitiveError error;

        error.location = location;
        error.headerColor = headerColor;
        error.header = header;

        if (prefix1)
        {
            error.message.writestring(prefix1);
            error.message.writestring(" ");
        }
        if (prefix2)
        {
            error.message.writestring(prefix2);
            error.message.writestring(" ");
        }
        error.message.vprintf(messageFormat, args);

        this.errors.insert(error);

        return true;
    }
}

/**
 * Initialize global variables.
 */
void initialize()
{
    initDMD(null, [],
        ContractChecks(
            ContractChecking.default_,
            ContractChecking.default_,
            ContractChecking.default_,
            ContractChecking.default_,
            ContractChecking.default_,
            ContractChecking.default_
        )
    );
}

/**
 * Clean up global variables.
 */
void deinitialize()
{
    deinitializeDMD();
}

alias Result = SumType!(List!CognitiveError, Source);
