module cogito.visitor;

import dmd.astcodegen;
import dmd.parsetimevisitor;
import dmd.visitor;
import dmd.tokens;

import cogito.list;
import cogito.meter;
import std.algorithm;
import std.stdio;

extern(C++) final class CognitiveVisitor : SemanticTimeTransitiveVisitor
{
    alias AST = ASTCodegen;

    alias visit = ParseTimeVisitor!AST.visit;
    alias visit = Visitor.visit;
    alias visit = SemanticTimeTransitiveVisitor.visit;

    private uint depth = 0U;
    private List!Meter meter_;
    private List!TOK stack;

    /**
     * Returns collected scores.
     */
    @property List!Meter meter()
    {
        return this.meter_;
    }

    override void visit(AST.StructDeclaration structDeclaration)
    {
        stepInAggregate!(ASTCodegen.StructDeclaration)(structDeclaration);
    }

    override void visit(ASTCodegen.ClassDeclaration classDeclaration)
    {
        stepInAggregate!(ASTCodegen.ClassDeclaration)(classDeclaration);
    }

    private void stepInAggregate(Declaration : ASTCodegen.AggregateDeclaration)(Declaration declaration)
    {
        auto currentMeter = this.meter_;

        this.meter.clear();
        super.visit(declaration);

        auto newMeter = Meter(declaration.ident, declaration.loc);

        newMeter.inner = this.meter_;
        currentMeter.insert(newMeter);
        this.meter_ = currentMeter;
    }

    override void visit(ASTCodegen.FuncDeclaration functionDeclaration)
    {
        this.meter_.insert(Meter(functionDeclaration.ident, functionDeclaration.loc));

        ++this.depth;
        super.visit(functionDeclaration);
        --this.depth;
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

    override void visit(AST.BinExp expression)
    {
        if (expression.isLogicalExp()) {
            // Each operator like && or || is counted once in an expression
            // chain.
            if (find(this.stack[], expression.op).empty)
            {
                ++this.meter_.back.ownScore;
            }
            this.stack.insert(expression.op);
        }

        super.visit(expression);

        if (expression.isLogicalExp()) {
            this.stack.removeFront();
        }
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

    override void visit(ASTCodegen.SymbolDeclaration s)
    {
        debug writeln("Symbol declaration ", s);

        super.visit(s);
    }
}
