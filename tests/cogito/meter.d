module cogito.tests.meter;

import cogito.list;
import cogito.meter;
import std.array;
import dmd.identifier;
import dmd.globals;

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
