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
