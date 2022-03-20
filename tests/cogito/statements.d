module cogito.tests.statements;

import cogito;
import std.sumtype;

@("if")
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

@("while")
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

@("else")
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

@("Simple else-if")
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

@("Simple for")
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

@("Simple do while")
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

@("Simple foreach")
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

@("Simple reverse foreach")
unittest
{
    auto meter = runOnCode(q{
void f()
{
    foreach_reverse (const x; xs)
    {
    }
}
    });

    assert(meter.tryMatch!((Source source) => source.score) == 1);
}

@("try-catch")
unittest
{
    auto meter = runOnCode(q{
void f()
{
    try
    {
    }
    catch (Exception)
    {
    }
}
    });

    assert(meter.tryMatch!((Source source) => source.score) == 1);
}

@("Nested statement in try")
unittest
{
    auto meter = runOnCode(q{
void f()
{
    try
    {
        if (true)
        {
        }
    }
    catch (Exception)
    {
    }
}
    });

    assert(meter.tryMatch!((Source source) => source.score) == 2);
}

@("Nested statement in catch")
unittest
{
    auto meter = runOnCode(q{
void f()
{
    try
    {
    }
    catch (Exception)
    {
        if (true)
        {
        }
    }
}
    });

    assert(meter.tryMatch!((Source source) => source.score) == 3);
}

@("Switch statement")
unittest
{
    auto meter = runOnCode(q{
void f()
{
    char c;

    switch (c)
    {
        case 'a':
            break;
        case 'b':
            break;
        default:
            assert(false);
    }
}
    });

    assert(meter.tryMatch!((Source source) => source.score) == 1);
}

@("Break statement")
unittest
{
    auto meter = runOnCode(q{
void f() {
  WhileLabel: while (true) {
    break WhileLabel;
  }
}
    });

    assert(meter.tryMatch!((Source source) => source.score) == 2);
}

@("Continue with a label")
unittest
{
    auto meter = runOnCode(q{
void f() {
  WhileLabel: while (true) {
    continue WhileLabel;
  }
}
    });

    assert(meter.tryMatch!((Source source) => source.score) == 2);
}

@("Continue statement")
unittest
{
    auto meter = runOnCode(q{
void f() {
  WhileLabel: while (true) {
    continue;
  }
}
    });

    assert(meter.tryMatch!((Source source) => source.score) == 1);
}

@("Multiple nested else-if statements")
unittest
{
    auto meter = runOnCode(q{
void f()
{
    if (true)
    {
        if (true)
        {
        }
        else if (false)
        {
            if (true)
            {
            }
        }
    }
    else
    {
    }
}
    });

    assert(meter.tryMatch!((Source source) => source.score) == 8);
}

@("goto")
unittest
{
    auto meter = runOnCode(q{
void f()
{
    goto end;
end:
}
    });

    assert(meter.tryMatch!((Source source) => source.score) == 1);
}
