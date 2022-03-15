module cogito;

import dmd.frontend;
import dmd.astcodegen;
import dmd.errors;
import dmd.globals;

public import cogito.list;
public import cogito.meter;
public import cogito.visitor;

Result runOnFiles(string[] args)
{
    initialize();
    LocalHandler localHandler;
    diagnosticHandler = &localHandler.handler;

    scope (exit)
    {
        diagnosticHandler = null;
        deinitialize();
    }
    auto tree = parseModule!AST(args[0]);

    if (tree.diagnostics.hasErrors())
    {
        return typeof(return)(localHandler.errors);
    }
    auto visitor = new CognitiveVisitor();

    tree.module_.accept(visitor);

    return typeof(return)(visitor.source);
}

Result runOnCode(string code)
{
    synchronized
    {
        initialize();
        LocalHandler localHandler;
        scope (exit)
        {
            diagnosticHandler = null;
            deinitialize();
        }
        auto tree = parseModule!ASTCodegen("app.d", code);

        if (tree.diagnostics.hasErrors())
        {
            return typeof(return)(localHandler.errors);
        }
        auto visitor = new CognitiveVisitor();

        tree.module_.accept(visitor);

        return typeof(return)(visitor.source);
    }
}
