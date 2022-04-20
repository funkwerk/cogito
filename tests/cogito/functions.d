module cogito.tests.functions;

import cogito;
import std.algorithm;
import std.sumtype;

@("2 functions")
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

    assert(meter.tryMatch!((Source source) => count(source.inner[])) == 2);
}

@("class function")
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

    assert(meter.tryMatch!((Source source) => source.score) == 1);
}

@("struct function")
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

    assert(meter.tryMatch!((Source source) => source.score) == 1);
}

@("class function")
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

    assert(meter.tryMatch!((Source source) => source.score) == 1);
}

@("Interface function")
unittest
{
    auto meter = runOnCode(q{
interface C
{
    void f();
}
    });

    assert(meter.tryMatch!((Source source) => source.inner[].front.name) == "C");
}

@("Union")
unittest
{
    auto meter = runOnCode(q{
union U
{
}
    });

    assert(meter.tryMatch!((Source source) => source.inner[].front.name) == "U");
}

@("Constructor")
unittest
{
    auto meter = runOnCode(q{
class C
{
    this()
    {
        if (true)
        {
        }
    }
}
    });

    assert(meter.tryMatch!((Source source) => source.score) == 1);
}

@("Class destructor")
unittest
{
    auto meter = runOnCode(q{
class C
{
    ~this()
    {
        if (true)
        {
        }
    }
}
    });

    assert(meter.tryMatch!((Source source) => source.score) == 1);
}

@("Struct destructor")
unittest
{
    auto meter = runOnCode(q{
struct C
{
    ~this()
    {
        if (true)
        {
        }
    }
}
    });

    assert(meter.tryMatch!((Source source) => source.score) == 1);
}

@("Postblit constructor")
unittest
{
    auto meter = runOnCode(q{
struct C
{
    this(this)
    {
        if (true)
        {
        }
    }
}
    });

    assert(meter.tryMatch!((Source source) => source.score) == 1);
}

@("Module static constructor")
unittest
{
    auto meter = runOnCode(q{
shared static this()
{
    if (true)
    {
    }
}
    });

    assert(meter.tryMatch!((Source source) => source.score) == 1);
}

@("Module static destructor")
unittest
{
    auto meter = runOnCode(q{
shared static ~this()
{
    if (true)
    {
    }
}
    });

    assert(meter.tryMatch!((Source source) => source.score) == 1);
}

@("Function literal")
unittest
{
    auto meter = runOnCode(q{
int[] f() {
  return [1, 2].map(i => i % 2 ? i : i);
}
    });

    assert(meter.tryMatch!((Source source) => source.score) == 2);
}

@("Function literal template parameter")
unittest
{
    auto meter = runOnCode(q{
int[] f() {
  return [1, 2].map!(i => i % 2 ? i : i);
}
    });

    assert(meter.tryMatch!((Source source) => source.score) == 2);
}

@("Nested function")
unittest
{
    auto meter = runOnCode(q{
void f() {
    int g(int i) {
        return i % 2 ? i : i;
    }
}
    });

    assert(meter.tryMatch!((Source source) => source.score) == 2);
}

@("else-if in aggregate function")
unittest
{
    auto meter = runOnCode(q{
struct S
{
    @property const(char)[] name()
    {
        if (stringName.empty)
        {
            return "(λ)";
        }
        else if (stringName == "__ctor")
        {
            return "this";
        }
        else if (stringName == "__dtor")
        {
            return "~this";
        }
        else
        {
            return stringName;
        }
    }
}
    });

    assert(meter.tryMatch!((Source source) => source.score) == 4);
}
