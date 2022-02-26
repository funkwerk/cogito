module cogito.meter;

import dmd.frontend;
import dmd.identifier;
import dmd.globals;

import std.stdio;

struct Meter
{
    Identifier name;
    Loc location;
    uint score = 0;
}

void printMeter(const Meter meter)
{
    printf("\x1b[36m%s:\x1b[0m\n", meter.location.filename);
    writefln("  %s:", meter.name);
    writeln("    Location (line): ", meter.location.linnum);
    writeln("    Score: ", meter.score);
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
