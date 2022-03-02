module cogito.tests.functions;

import cogito;
import std.algorithm;

// 2 functions
unittest
{
    auto meter = runOnCode(q{
void f()
{
}
void g()
{
}
    });

    assert(count(meter.inner[]) == 2);
}

// class function
unittest
{
    auto meter = runOnCode(q{
class C
{
    void f()
    {
        if (true)
        {
        }
    }
}
    });

    assert(meter.score == 1);
}

// struct function
unittest
{
    auto meter = runOnCode(q{
struct C
{
    void f()
    {
        if (true)
        {
        }
    }
}
    });

    assert(meter.score == 1);
}

// class function
unittest
{
    auto meter = runOnCode(q{
class C
{
    void f()
    {
        if (true)
        {
        }
    }
}
    });

    assert(meter.score == 1);
}
