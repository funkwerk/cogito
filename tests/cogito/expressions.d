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

// ?:
unittest
{
    auto meter = runOnCode(q{
int f()
{
    return true ? 0 : 1;
}
    });

    assert(meter.tryMatch!((Source source) => source.score) == 1);
}

// Nested ?:
unittest
{
    auto meter = runOnCode(q{
int f()
{
    return true ? (true ? 1 : 0) : 1;
}
    });

    assert(meter.tryMatch!((Source source) => source.score) == 3);
}

// Nested ?: in else
unittest
{
    auto meter = runOnCode(q{
int f()
{
    return true ? 0 : (true ? 1 : 0);
}
    });

    assert(meter.tryMatch!((Source source) => source.score) == 3);
}

// 2 nested ?:
unittest
{
    auto meter = runOnCode(q{
int f()
{
    return true ? (true ? 1 : 0) : (true ? 1 : 0);
}
    });

    assert(meter.tryMatch!((Source source) => source.score) == 5);
}
