module cogito;

import dmd.frontend;
import dmd.astcodegen;
import dmd.errors;
import dmd.globals;

public import cogito.list;
public import cogito.meter;
public import cogito.visitor;

import std.algorithm;
import std.range;

private Result runOnFile(string file)
{
    initialize();
    LocalHandler localHandler;
    diagnosticHandler = &localHandler.handler;

    scope (exit)
    {
        diagnosticHandler = null;
        deinitialize();
    }
    auto tree = parseModule!AST(file);

    if (tree.diagnostics.hasErrors())
    {
        return typeof(return)(localHandler.errors);
    }
    auto visitor = new CognitiveVisitor(file);

    tree.module_.accept(visitor);

    return typeof(return)(visitor.source);
}

/**
 * Measure the complexity in a list of modules.
 *
 * Params:
 *     args = File paths.
 *
 * Returns: List of collected scores in each file.
 */
auto runOnFiles(R)(R args)
if (isInputRange!R && is(ElementType!R == string))
{
    return args.map!runOnFile();
}

/**
 * Measure the complexity of the given code.
 *
 * Params:
 *     code = Code as string.
 *
 * Returns: Collected score.
 */
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
