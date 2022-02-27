module cogito.meter;

import dmd.frontend;
import dmd.identifier;
import dmd.globals;

import cogito.list;
import std.algorithm;
import std.conv;
import std.range;
import std.stdio;

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

struct Meter
{
    Identifier name;
    Loc location;

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
        sink(":\n");
        sink(nextIndentBytes);
        sink("Location (line): ");
        sink(to!string(this.location.linnum));
        sink("\n");
        sink(nextIndentBytes);
        sink("Score: ");
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

    public this(List!Meter inner, string filename = null)
    {
        this.inner = inner;
        this.filename = filename;
    }

    mixin Ruler!();
}

void printMeter(Source source)
{
    if (source.inner.empty)
    {
        return;
    }
    writefln("\x1b[36m%s:\x1b[0m", source.filename);

    foreach (m; source.inner[])
    {
        m.toString(input => write(input));
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
