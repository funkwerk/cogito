module cogito.meter;

import dmd.frontend;
import dmd.identifier;
import dmd.globals;

import cogito.list;
import std.algorithm;
import std.stdio;

private mixin template Ruler()
{
    uint ownScore = 0;
    List!Meter inner;

    @disable this();

    public uint score()
    {
        return reduce!((accum, x) => accum + x.ownScore)(0, this.inner[]);
    }
}

struct Meter
{
    Identifier name;
    Loc location;

    @disable this();

    public this(Identifier name, Loc location, uint score = 0)
    {
        this.name = name;
        this.location = location;
        this.ownScore = score;
    }

    mixin Ruler!();
}

struct Source
{
    string filename;

    @disable this();

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

    foreach (const m; source.inner[])
    {
        writefln("  %s:", m.name);
        writeln("    Location (line): ", m.location.linnum);
        writeln("    Score: ", m.ownScore);
        writeln();
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
