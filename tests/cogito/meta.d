module cogito.tests.meta;

import cogito;
import std.sumtype;

@("Top-level static if")
unittest
{
    auto meter = runOnCode(q{
static if (true)
{
    alias Integer = int;
}
    });

    assert(meter.tryMatch!((Source source) => source.score) == 1);
}

@("static foreach declaration")
unittest
{
    auto meter = runOnCode(q{
static foreach (const a; 0..1)
{
    alias Integer = int;
}
    });

    assert(meter.tryMatch!((Source source) => source.score) == 1);
}

@("Static foreach statement")
unittest
{
    auto meter = runOnCode(q{
void f()
{
    static foreach (const a; 0..1)
    {
        alias Integer = int;
    }
}
    });

    assert(meter.tryMatch!((Source source) => source.score) == 1);
}

@("Version block")
unittest
{
    auto meter = runOnCode(q{
version (Version)
{
    alias Integer = int;
}
    });

    assert(meter.tryMatch!((Source source) => source.score) == 1);
}

@("Static if in a function")
unittest
{
    auto meter = runOnCode(q{
void f()
{
    static if (true)
    {
    }
}
    });

    assert(meter.tryMatch!((Source source) => source.score) == 1);
}

@("Static else declaration")
unittest
{
    auto meter = runOnCode(q{
static if (true)
{
}
else
{
}
    });

    assert(meter.tryMatch!((Source source) => source.score) == 2);
}

@("Static else-if declaration")
unittest
{
    auto meter = runOnCode(q{
static if (true)
{
}
else static if (false)
{
}
    });

    assert(meter.tryMatch!((Source source) => source.score) == 2);
}

@("Multiple nested static-else-if declarations")
unittest
{
    auto meter = runOnCode(q{
static if (true)
{
    static if (true)
    {
    }
    else static if (false)
    {
    }
    else static if (false)
    {
    }
}
else
{
}
    });

    assert(meter.tryMatch!((Source source) => source.score) == 5);
}

@("Multiple nested static-else-if statements")
unittest
{
    auto meter = runOnCode(q{
void f()
{
    static if (true)
    {
        static if (true)
        {
        }
        else static if (false)
        {
        }
        else static if (false)
        {
        }
    }
    else
    {
    }
}
    });

    assert(meter.tryMatch!((Source source) => source.score) == 6);
}

@("debug")
unittest
{
    auto meter = runOnCode(q{
void f()
{
    debug
    {
    }
}
    });

    assert(meter.tryMatch!((Source source) => source.score) == 1);
}

@("debug-else")
unittest
{
    auto meter = runOnCode(q{
void f()
{
    debug
    {
    }
    else
    {
    }
}
    });

    assert(meter.tryMatch!((Source source) => source.score) == 2);
}
