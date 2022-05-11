import unit_threaded;

import cogito.tests.expressions;
import cogito.tests.functions;
import cogito.tests.meta;
import cogito.tests.meter;
import cogito.tests.statements;
import cogito.tests.visitor;

int main(string[] args)
{
    import unit_threaded.runner.runner: runTests;

    return runTests!(
        cogito.tests.expressions,
        cogito.tests.functions,
        cogito.tests.meta,
        cogito.tests.meter,
        cogito.tests.statements,
        cogito.tests.visitor
    )(args);
}
