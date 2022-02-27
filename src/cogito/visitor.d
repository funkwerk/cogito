module cogito.visitor;

import dmd.astcodegen;
import dmd.parsetimevisitor;
import dmd.visitor;

import cogito.list;
import cogito.meter;
import std.stdio;

extern(C++) final class CognitiveVisitor : SemanticTimeTransitiveVisitor
{
    alias AST = ASTCodegen;

    alias visit = ParseTimeVisitor!AST.visit;
    alias visit = Visitor.visit;
    alias visit = SemanticTimeTransitiveVisitor.visit;

    private uint depth = 0U;
    private List!Meter meter_;

    /**
     * Returns collected scores.
     */
    @property List!Meter meter()
    {
        return this.meter_;
    }

    override void visit(AST.StructDeclaration structDeclaration)
    {
        debug writeln("struct {} ", structDeclaration.ident);

        super.visit(structDeclaration);
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

    override void visit(AST.IfStatement s)
    {
        if (s.elsebody is null || !s.elsebody.isIfStatement) {
            this.meter_.back.ownScore += this.depth;
        }
        if (s.elsebody !is null && !s.elsebody.isIfStatement)
        {
            ++this.meter_.back.ownScore;
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
         this.meter_.back.ownScore += this.depth;

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

        this.meter_.insert(Meter(s.ident, s.loc));

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
