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
