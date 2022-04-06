module cogito.tests.visitor;

import cogito;
import std.sumtype;

unittest
{
    auto meter = runOnCode(q{
struct S
{
    static if (true)
    {
    }
    else
    {
        ubyte[T.sizeof] data;
    }
}
    });

    assert(meter.tryMatch!((Source source) => source.score) == 2);
}
