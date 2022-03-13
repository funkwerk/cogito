module cogito.visitor;

import dmd.ast_node;
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
    private Source source_;
    private List!TOK stack;

    this()
    {
        this.source_ = Source(List!Meter());
    }

    /**
     * Returns collected scores.
     */
    @property ref List!Meter meter()
    {
        return this.source_.inner;
    }

    /**
     * Returns collected source file score.
     */
    @property ref Source source()
    {
        return this.source_;
    }

    /**
     * Increases the score in the current or the top-level scope.
     */
    private void increase(uint by = 1U)
    {
        if (this.meter.empty)
        {
            this.source.ownScore += by;
        } else {
            this.meter.back.ownScore += by;
        }
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
        auto currentMeter = this.meter;

        this.meter.clear();
        super.visit(declaration);

        auto newMeter = Meter(declaration.ident, declaration.loc);

        newMeter.inner = this.meter;
        currentMeter.insert(newMeter);
        this.meter = currentMeter;
    }

    override void visit(ASTCodegen.FuncDeclaration functionDeclaration)
    {
        stepInFunction(functionDeclaration);
    }

    override void visit(ASTCodegen.DtorDeclaration declaration)
    {
        debug writeln("Destructor ", declaration);

        stepInFunction(declaration);
    }

    private void stepInFunction(T : ASTCodegen.FuncDeclaration)(T declaration)
    {
        this.meter.insert(Meter(declaration.ident, declaration.loc));

        ++this.depth;
        super.visit(declaration);
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
                increase;
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
            increase(this.depth);
        }
        if (s.elsebody !is null && !s.elsebody.isIfStatement)
        {
            increase;
        }

        ++this.depth;
        super.visit(s);
        --this.depth;
    }

    override void visit(ASTCodegen.StaticIfDeclaration ifDeclaration)
    {
        stepInStaticDeclaration(ifDeclaration);
    }

    override void visit(ASTCodegen.StaticForeachDeclaration foreachDeclaration)
    {
        stepInStaticDeclaration(foreachDeclaration);
    }

    private void stepInStaticDeclaration(T : ASTCodegen.Dsymbol)(T declaration)
    {
        increase(max(this.depth, 1));

        ++this.depth;
        super.visit(declaration);
        --this.depth;
    }

    override void visit(AST.WhileStatement whileStatement)
    {
        stepInLoop(whileStatement);
    }

    override void visit(AST.DoStatement doStatement)
    {
        stepInLoop(doStatement);
    }

    override void visit(AST.ForStatement forStatement)
    {
        stepInLoop(forStatement);
    }

    override void visit(ASTCodegen.ForeachStatement foreachStatement)
    {
        stepInLoop(foreachStatement);
    }

    private void stepInLoop(T : ASTNode)(T statement)
    {
         increase(this.depth);

        ++this.depth;
        super.visit(statement);
        --this.depth;
   }

    override void visit(ASTCodegen.Module moduleDeclaration)
    {
        this.source_.filename = moduleDeclaration.ident.toString.idup;

        super.visit(moduleDeclaration);
    }

    override void visit(ASTCodegen.CondExp expression)
    {
        debug writeln("Ternary operator ", expression);

        stepInLoop(expression);
    }

    override void visit(ASTCodegen.SwitchStatement statement)
    {
        stepInLoop(statement);
    }

    override void visit(ASTCodegen.TryCatchStatement statement)
    {
        debug writeln("try-catch statement ", statement);

        if (statement._body)
        {
            increase(this.depth);

            statement._body.accept(this);
        }
        foreach (catch_; *statement.catches)
        {
            ++this.depth;
            this.visit(catch_);
            --this.depth;
        }
    }

    override void visit(ASTCodegen.BreakStatement statement)
    {
        debug writeln("Break ", statement.ident);

        stepInStatementWithLabel(statement);
    }

    private void stepInStatementWithLabel(T : ASTCodegen.Statement)(T statement)
    {
        if (statement.ident !is null)
        {
            increase;
        }
        super.visit(statement);
    }

    override void visit(ASTCodegen.ContinueStatement statement)
    {
        debug writeln("Label ", statement);

        stepInStatementWithLabel(statement);
    }

    override void visit(ASTCodegen.PostBlitDeclaration declaration)
    {
        debug writeln("Blit ", declaration);

        stepInFunction(declaration);
    }
}
