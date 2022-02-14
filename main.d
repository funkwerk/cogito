import dmd.lexer;
import dmd.tokens;
import dmd.frontend;
// import dmd.astbase;
import dmd.astcodegen;
import dmd.globals;
import dmd.parsetimevisitor;
import dmd.visitor;

import std.file;
import std.string;
import std.stdio;

struct Meter
{
    Loc location;
}

extern(C++) final class CognitiveVisitor : SemanticTimeTransitiveVisitor
{
    alias AST = ASTCodegen;

    alias visit = ParseTimeVisitor!AST.visit;
    alias visit = Visitor.visit;
    alias visit = SemanticTimeTransitiveVisitor.visit;

    private uint ifLayers = 0;
    private Meter meter;

    override void visit(AST.Dsymbol symbol)
    {
        writeln("Dsymbol ", symbol.ident);

        super.visit(symbol);
    }

    override void visit(AST.Parameter)
    {
        writeln("Parameter");
        assert(0);
    }

    override void visit(AST.Statement s)
    {
        writeln("Statement");

        super.visit(s);
    }

    override void visit(AST.Type type_)
    {
        writeln("Type");

        super.visit(type_);
    }

    override void visit(AST.Expression expression)
    {
        writeln("Expression");

        super.visit(expression);
    }

    override void visit(AST.TemplateParameter)
    {
        writeln("Template parameter");
        assert(0);
    }

    override void visit(AST.Condition)
    {
        writeln("Condition");
        assert(0);
    }

    override void visit(AST.Initializer)
    {
        writeln("Initializer");
        assert(0);
    }

    override void visit(AST.IfStatement s)
    {
        writeln("If statement ", s.condition);

        if (this.ifLayers >= 2) {
            this.meter = Meter(s.loc);
        }
        ++this.ifLayers;
        super.visit(s);
        --this.ifLayers;
    }
}

void main()
{
    // const sourceName = "main.d";
    // string sourceCode = readText(sourceName);

    // auto lexer = new Parser!ASTBase(null, sourceCode, false);

    initDMD(null, [],
            ContractChecks(
                ContractChecking.default_,
                ContractChecking.default_,
                ContractChecking.default_,
                ContractChecking.default_,
                ContractChecking.default_,
                ContractChecking.default_
            )
    );

    auto tree = parseModule!ASTCodegen("./a.d");
    auto visitor = new CognitiveVisitor();
    // Check for errors.
    tree[0].accept(visitor);

    writeln("Ifs: ", visitor.meter);
}
