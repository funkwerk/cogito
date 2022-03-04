module cogito.tests.meta;

import cogito;

// Top-level static if
unittest
{
    auto meter = runOnCode(q{
static if (true)
{
    alias Integer = int;
}
    });

    assert(meter.score == 1);
}

// Top-level static foreach
unittest
{
    auto meter = runOnCode(q{
static foreach (const a; 0..1)
{
    alias Integer = int;
}
    });

    assert(meter.score == 1);
}
