module cogito.visitor;

import dmd.astcodegen;
import dmd.parsetimevisitor;
import dmd.visitor;

import cogito.meter;
import std.stdio;

extern(C++) final class CognitiveVisitor : SemanticTimeTransitiveVisitor
{
    alias AST = ASTCodegen;

    alias visit = ParseTimeVisitor!AST.visit;
    alias visit = Visitor.visit;
    alias visit = SemanticTimeTransitiveVisitor.visit;

    private uint depth = 0;
    private Meter meter_;

    /**
     * Returns collected scores.
     */
    @property const(Meter) meter() const
    {
        return this.meter_;
    }

    override void visit(AST.Dsymbol symbol)
    {
        debug writeln("Dsymbol ", symbol.ident);

        super.visit(symbol);
    }

    override void visit(AST.Parameter)
    {
        debug writeln("Parameter");

        assert(false);
    }

    override void visit(AST.Statement s)
    {
        debug writeln("Statement");

        super.visit(s);
    }

    override void visit(AST.Type type_)
    {
        debug writeln("Type ", type_);

        super.visit(type_);
    }

    override void visit(AST.Expression expression)
    {
        debug writeln("Expression");

        super.visit(expression);
    }

    override void visit(AST.TemplateParameter)
    {
        debug writeln("Template parameter");
        assert(false);
    }

    override void visit(AST.Condition)
    {
        debug writeln("Condition");
        assert(false);
    }

    override void visit(AST.Initializer)
    {
        debug writeln("Initializer");
        assert(false);
    }

    override void visit(AST.IfStatement s)
    {
        if (s.elsebody is null || !s.elsebody.isIfStatement) {
            this.meter_.score += this.depth;
        }
        if (s.elsebody !is null && !s.elsebody.isIfStatement)
        {
            ++this.meter_.score;
        }

        ++this.depth;
        super.visit(s);
        --this.depth;
    }

    override void visit(AST.WhileStatement s)
    {
        stepInLoop(s);
    }

    override void visit(AST.DoStatement s)
    {
        stepInLoop(s);
    }

    override void visit(AST.ForStatement s)
    {
        stepInLoop(s);
    }

    private void stepInLoop(Statement)(Statement s)
    {
         this.meter_.score += this.depth;

        ++this.depth;
        super.visit(s);
        --this.depth;
   }

    /***********************************************
     * Additional overrides present in the parent. *
     ***********************************************/

    override void visit(ASTCodegen.DelegatePtrExp e)
    {
        debug writeln("Delegate pointer expression ", e);

        super.visit(e);
    }

    override void visit(ASTCodegen.DelegateExp e)
    {
        debug writeln("Delegate expression ", e);

        super.visit(e);
    }

    override void visit(ASTCodegen.DelegateFuncptrExp e)
    {
        debug writeln("Delegate funcptr expression ", e);

        super.visit(e);
    }

    override void visit(ASTCodegen.FuncAliasDeclaration s)
    {
        debug writeln("Function alis declaration ", s);

        super.visit(s);
    }

    override void visit(ASTCodegen.FuncDeclaration s)
    {
        debug writeln("Function declaration ", s);

        this.meter_ = Meter(s.ident, s.loc);

        ++this.depth;
        super.visit(s);
        --this.depth;
    }

    override void visit(ASTCodegen.SymbolDeclaration s)
    {
        debug writeln("Symbol declaration ", s);

        super.visit(s);
    }

    override void visit(ASTCodegen.TypeInfoFunctionDeclaration s)
    {
        debug writeln("TypeInfo function declaration ", s);

        super.visit(s);
    }
}
