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
 * Map a filename to an array of files.
 *
 * Params:
 *     filename = file or directory name.
 *
 * Returns: Array of filenames.
 *   If the filename points to a folder all d-files are returned,
 *   If the filename points to a file an array with only that file is returned.
 */
string[] toFiles(string filename)
{
    import std.file : isFile, isDir, dirEntries, SpanMode;
    if (filename.isFile)
    {
        return [filename];
    }
    if (filename.isDir)
    {
        return filename
            .dirEntries("*.d", SpanMode.breadth)
            .filter!("a.isFile")
            .map!("a.name")
            .array;
    }
    import std.format : format;
    throw new Exception(format!("%s is neither a file nor a directory")(filename));
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
    return args
        .map!toFiles
        .joiner
        .array
        .sort
        .map!runOnFile;
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
