module cogito;

import dmd.frontend;
import dmd.astcodegen;

public import cogito.list;
public import cogito.meter;
public import cogito.visitor;

Source runOnFiles(string[] args)
{
    initialize();
    scope (exit)
    {
        deinitialize();
    }

    auto tree = parseModule!ASTCodegen(args[0]);
    auto visitor = new CognitiveVisitor();

    // Check for errors.
    tree[0].accept(visitor);

    return Source(visitor.meter, args[0]);
}

Source runOnCode(string code)
{
    initialize();
    scope (exit)
    {
        deinitialize();
    }

    auto tree = parseModule!ASTCodegen("app.d", code);
    auto visitor = new CognitiveVisitor();

    // Check for errors.
    tree[0].accept(visitor);

    return Source(visitor.meter);
}
