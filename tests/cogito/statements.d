module cogito.tests.statements;

import cogito;
import std.sumtype;

// if
unittest
{
    auto meter = runOnCode(q{
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

    assert(meter.tryMatch!((Source source) => source.score) == 6);
}

// while
unittest
{
    auto meter = runOnCode(q{
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

    assert(meter.tryMatch!((Source source) => source.score) == 6);
}

// else
unittest
{
    auto meter = runOnCode(q{
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

    assert(meter.tryMatch!((Source source) => source.score) == 2);
}

// Simple else-if
unittest
{
    auto meter = runOnCode(q{
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

    assert(meter.tryMatch!((Source source) => source.score) == 2);
}

// Simple for
unittest
{
    auto meter = runOnCode(q{
void f()
{
    for (;;)
    {
    }
}
    });

    assert(meter.tryMatch!((Source source) => source.score) == 1);
}

// Simple do while
unittest
{
    auto meter = runOnCode(q{
void f()
{
    do
    {
    }
    while (true);
}
    });

    assert(meter.tryMatch!((Source source) => source.score) == 1);
}

// Simple foreach
unittest
{
    auto meter = runOnCode(q{
void f()
{
    foreach (const x; xs)
    {
    }
}
    });

    assert(meter.tryMatch!((Source source) => source.score) == 1);
}
