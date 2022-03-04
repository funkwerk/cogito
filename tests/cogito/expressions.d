module cogito.tests.expressions;

import cogito;
import std.sumtype;

// No conditions
unittest
{
    auto meter = runOnCode(q{
bool f()
{
    return true;
}
    });

    assert(meter.tryMatch!((Source source) => source.score) == 0);
}

// Single &&
unittest
{
    auto meter = runOnCode(q{
bool f()
{
    return true && true;
}
    });

    assert(meter.tryMatch!((Source source) => source.score) == 1);
}

// && row
unittest
{
    auto meter = runOnCode(q{
bool f()
{
    return true && true && true;
}
    });

    assert(meter.tryMatch!((Source source) => source.score) == 1);
}
