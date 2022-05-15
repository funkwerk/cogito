module cogito.tests.meter;

import cogito;
import cogito.list;
import cogito.meter;
import std.array;
import dmd.identifier;
import dmd.globals;
import std.algorithm;
import std.sumtype;

@("filename.d:line: identifier: score")
unittest
{
    enum string filename = "filename.d";
    auto meter = Meter(new Identifier(""), Loc(filename, 2, 1), Meter.Type.callable);
    auto meters = List!Meter();

    meter.ownScore = 3;
    meters.insert(meter);

    auto source = Source(meters, filename);
    auto output = appender!string();
    auto reporter = FlatReporter!((string x) => output.put(x))(source);

    reporter.report(Threshold(1, 50));

    assert(output.data == "filename.d:2: function (λ): 3\n");
}

@("flat reporter prepends function identifiers with function")
unittest
{
    enum string filename = "filename.d";
    auto meter = Meter(new Identifier("f"), Loc(filename, 2, 1), Meter.Type.callable);
    auto meters = List!Meter();

    meter.ownScore = 3;
    meters.insert(meter);

    auto source = Source(meters, filename);
    auto output = appender!string();
    auto reporter = FlatReporter!((string x) => output.put(x))(source);

    reporter.report(Threshold(1, 50));

    assert(output.data == "filename.d:2: function f: 3\n");
}

@("reports interface score")
unittest
{
    enum string filename = "filename.d";
    auto meter = Meter(new Identifier("I"), Loc(filename, 2, 1), Meter.Type.interface_);
    auto meters = List!Meter();

    meter.ownScore = 3;
    meters.insert(meter);

    auto source = Source(meters, filename);
    auto output = appender!string();
    auto reporter = FlatReporter!((string x) => output.put(x))(source);

    reporter.report(Threshold(1, 2));

    assert(output.data == "filename.d:2: interface I: 3\n");
}

@("reports interface aggregate type")
unittest
{
    auto meter = runOnCode(q{
interface I
{
}
    });
    auto output = appender!string();
    auto reporter = meter.tryMatch!((Source source) =>
            FlatReporter!((string x) => output.put(x))(source));

    reporter.report(Threshold());

    assert(output.data.canFind("interface I"));
}

@("reports struct aggregate type")
unittest
{
    auto meter = runOnCode(q{
struct S
{
}
    });
    auto output = appender!string();
    auto reporter = meter.tryMatch!((Source source) =>
            FlatReporter!((string x) => output.put(x))(source));

    reporter.report(Threshold());

    assert(output.data.canFind("struct S"));
}

@("reports class aggregate type")
unittest
{
    auto meter = runOnCode(q{
class C
{
}
    });
    auto output = appender!string();
    auto reporter = meter.tryMatch!((Source source) =>
            FlatReporter!((string x) => output.put(x))(source));

    reporter.report(Threshold());

    assert(output.data.canFind("class C"));
}

@("reports union aggregate type")
unittest
{
    auto meter = runOnCode(q{
union U
{
    char a;
    byte b;
}
    });
    auto output = appender!string();
    auto reporter = meter.tryMatch!((Source source) =>
            FlatReporter!((string x) => output.put(x))(source));

    reporter.report(Threshold());

    assert(output.data.canFind("union U"));
}

@("reports template aggregate type")
unittest
{
    auto meter = runOnCode(q{
template T()
{
}
    });
    auto output = appender!string();
    auto reporter = meter.tryMatch!((Source source) =>
            FlatReporter!((string x) => output.put(x))(source));

    reporter.report(Threshold());

    assert(output.data.canFind("template T"));
}

@("FlatReporter reports only functions on function threshold violation")
unittest
{
    auto meter = runOnCode(q{
struct S
{
    void f()
    {
        if (true)
        {
        }
        else
        {
        }
    }

    void g()
    {
        if (true)
        {
        }
        else
        {
        }
    }
}
    });
    auto output = appender!string();
    auto reporter = meter.tryMatch!((Source source) =>
            FlatReporter!((string x) => output.put(x))(source));

    reporter.report(Threshold(1, 0));

    assert(!output.data.canFind("struct S"));
}

@("FlatReporter reports only functions on function threshold violation if aggregate threshold is set")
unittest
{
    auto meter = runOnCode(q{
struct S
{
    void f()
    {
        if (true)
        {
        }
        else
        {
        }
    }

    void g()
    {
        if (true)
        {
        }
        else
        {
        }
    }
}
    });
    auto output = appender!string();
    auto reporter = meter.tryMatch!((Source source) =>
            FlatReporter!((string x) => output.put(x))(source));

    reporter.report(Threshold(1, 10));

    assert(!output.data.canFind("struct S"));
}
