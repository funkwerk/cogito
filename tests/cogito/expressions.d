module cogito.tests.expressions;

import cogito;

// No conditions
unittest
{
    auto meter = runOnCode(q{
bool f()
{
    return true;
}
    });

    assert(meter.score == 0);
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

    assert(meter.score == 1);
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

    assert(meter.score == 1);
}
