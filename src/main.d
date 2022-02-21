import dmd.frontend;
import dmd.identifier;
import dmd.astcodegen;
import dmd.globals;
import dmd.parsetimevisitor;
import dmd.visitor;

import cogito.visitor;

import std.file;
import std.string;
import std.range;

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

const(Meter) runOnFiles(string[] args)
{
    initialize();
    scope (exit)
    {
        deinitializeDMD();
    }

    auto tree = parseModule!ASTCodegen(args[0]);
    auto visitor = new CognitiveVisitor();

    // Check for errors.
    tree[0].accept(visitor);

    return visitor.meter;
}

const(Meter) runOnCode(string code)
{
    initialize();
    scope (exit)
    {
        deinitializeDMD();
    }

    auto tree = parseModule!ASTCodegen("app.d", code);
    auto visitor = new CognitiveVisitor();

    // Check for errors.
    tree[0].accept(visitor);

    return visitor.meter;
}

void main(string[] args)
{
    args.popFront;

    const meter = runOnFiles(args);

    printMeter(meter);
}

// if
unittest
{
    const meter = runOnCode(q{
void f()
{
    if (true)
    {
        if (false)
        {
            if (true)
            {
            }
        }
    }
}
    });

    assert(meter.score == 6);
}

// while
unittest
{
    const meter = runOnCode(q{
void f()
{
    if (true)
    {
        while (false)
        {
            if (true)
            {
            }
        }
    }
}
    });

    assert(meter.score == 6);
}

// else
unittest
{
    const meter = runOnCode(q{
void f()
{
    if (true)
    {
    }
    else
    {
    }
}
    });

    assert(meter.score == 2);
}

// Simple else-if
unittest
{
    const meter = runOnCode(q{
void f()
{
    if (true)
    {
    }
    else if (false)
    {
    }
}
    });

    assert(meter.score == 2);
}

// Simple for
unittest
{
    const meter = runOnCode(q{
void f()
{
    for (;;)
    {
    }
}
    });

    assert(meter.score == 1);
}
