module cogito.tests.statements;

import cogito;

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

    assert(meter.score == 6);
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

    assert(meter.score == 6);
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

    assert(meter.score == 2);
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

    assert(meter.score == 2);
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

    assert(meter.score == 1);
}
