import unit_threaded;

import cogito.tests.expressions;
import cogito.tests.functions;
import cogito.tests.meta;
import cogito.tests.statements;

int main(string[] args)
{
    import unit_threaded.runner.runner: runTests;

    return runTests!(
        cogito.tests.expressions,
        cogito.tests.functions,
        cogito.tests.meta,
        cogito.tests.statements
    )(args);
}
