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

struct ScoreScope
{
    Identifier name;
    Loc location;
}

struct Meter
{
    ScoreScope scoreScope;

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

    public this(Identifier name, Loc location, uint score = 0)
    {
        this.name = name;
        this.location = location;
        this.ownScore = score;
    }

    private void toString(void delegate(const(char)[]) sink, uint indentation)
    {
        const indentBytes = ' '.repeat(indentation * 2).array;
        const nextIndentation = indentation + 1;
        const nextIndentBytes = ' '.repeat(nextIndentation * 2).array;

        sink(indentBytes);
        sink(this.name.toString());
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

    void toString(void delegate(const(char)[]) sink)
    {
        toString(sink, 1);
    }

    mixin Ruler!();
}

struct Source
{
    string filename;

    public this(List!Meter inner, string filename = "main")
    {
        this.inner = inner;
        this.filename = filename;
    }

    mixin Ruler!();
}

/**
 * Returns: true if the score exceeds the threshold, otherwise returns false.
 */
bool printMeter(Source source, Nullable!uint threshold)
{
    const sourceScore = source.score;

    if (!threshold.isNull && sourceScore > threshold.get)
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

        return true;
    }
    return false;
}

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

void deinitialize()
{
    deinitializeDMD();
}

alias Result = SumType!(List!CognitiveError, Source);
