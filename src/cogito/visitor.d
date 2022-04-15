module cogito.visitor;

import core.stdc.string;
import dmd.ast_node;
import dmd.astcodegen;
import dmd.parsetimevisitor;
import dmd.visitor;
import dmd.tokens;

import cogito.list;
import cogito.meter;
import std.algorithm;
import std.stdio;

alias AST = ASTCodegen;

extern(C++) final class CognitiveVisitor : SemanticTimeTransitiveVisitor
{
    alias visit = SemanticTimeTransitiveVisitor.visit;

    private uint depth = 0U;
    private Source source_;
    private List!TOK stack;
    private Meter* parent;

    extern(D) this()
    {
        this.source_ = Source(List!Meter());
    }

    extern(D) this(string filename)
    {
        this.source_ = Source(List!Meter(), filename);
    }

    /**
     * Returns collected scores.
     */
    @property ref List!Meter meter()
    {
        return this.parent is null ? this.source_.inner : this.parent.inner;
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
        if (this.parent !is null)
        {
            this.parent.ownScore += by;
        }
        else
        {
            this.source.ownScore += by;
        }
    }

    override void visit(AST.Dsymbol symbol)
    {
        debug printf("Symbol %s\n", symbol.toPrettyChars());

        super.visit(symbol);
    }

    override void visit(AST.Expression expression)
    {
        debug writeln("Expression ", expression);

        super.visit(expression);
    }

    override void visit(AST.TemplateParameter parameter)
    {
        debug writeln("Parameter ", parameter);

        super.visit(parameter);
    }

    override void visit(AST.Condition condition)
    {
        debug writeln("Condition ", condition);

        super.visit(condition);
    }

    override void visit(AST.Initializer initializer)
    {
        debug writeln("Initializer ", initializer);

        super.visit(initializer);
    }

    override void visit(AST.PeelStatement statement)
    {
        debug writeln("Peel statement ", statement);

        super.visit(statement);
    }

    override void visit(AST.UnrolledLoopStatement statement)
    {
        debug writeln("Unrolled loop statement ", statement);

        super.visit(statement);
    }

    override void visit(AST.DebugStatement statement)
    {
        debug writeln("Debug statement ", statement);
        // Handled as ConditionalStatement or Condition
        super.visit(statement);
    }

    override void visit(AST.ForwardingStatement statement)
    {
        debug writeln("Forwarding statement ", statement);

        super.visit(statement);
    }

    override void visit(AST.StructLiteralExp expression)
    {
        debug writeln("Struct literal expression ", expression);

        super.visit(expression);
    }

    override void visit(AST.CompoundLiteralExp expression)
    {
        debug writeln("Compound literal expression ", expression);

        super.visit(expression);
    }

    override void visit(AST.DotTemplateExp expression)
    {
        debug writeln("Dot template expression ", expression);

        super.visit(expression);
    }

    override void visit(AST.DotVarExp expression)
    {
        debug writeln("dot var expression ", expression);

        super.visit(expression);
    }

    override void visit(AST.DelegateExp expression)
    {
        debug writeln("Delegate expression ", expression);

        super.visit(expression);
    }

    override void visit(AST.DelegatePtrExp expression)
    {
        debug writeln("Delegate pointer expression ", expression);

        super.visit(expression);
    }

    override void visit(AST.DelegateFuncptrExp expression)
    {
        debug writeln("Delegate function pointer expression ", expression);

        super.visit(expression);
    }

    override void visit(AST.DotTypeExp expression)
    {
        debug writeln("Dot type expression ", expression);

        super.visit(expression);
    }

    override void visit(AST.VectorExp expression)
    {
        debug writeln("Vector expression ", expression);

        super.visit(expression);
    }

    override void visit(AST.VectorArrayExp expression)
    {
        debug writeln("Vector array expression ", expression);

        super.visit(expression);
    }

    override void visit(AST.SliceExp expression)
    {
        debug writeln("Slice expression ", expression);

        super.visit(expression);
    }

    override void visit(AST.ArrayLengthExp expression)
    {
        debug writeln("Array length expression ", expression);

        super.visit(expression);
    }

    override void visit(AST.DotExp expression)
    {
        debug writeln("Dot expression ", expression);

        super.visit(expression);
    }

    override void visit(AST.IndexExp expression)
    {
        debug writeln("Index expression ", expression);

        super.visit(expression);
    }

    override void visit(AST.RemoveExp expression)
    {
        debug writeln("Remove expression ", expression);

        super.visit(expression);
    }

    override void visit(AST.Declaration declaration)
    {
        debug writeln("Declaration ", declaration);

        super.visit(declaration);
    }

    override void visit(AST.ScopeDsymbol statement)
    {
        debug writeln("Scope symbol ", statement);

        super.visit(statement);
    }

    override void visit(AST.Package statement)
    {
        debug writeln("Package ", statement);

        super.visit(statement);
    }

    override void visit(AST.AggregateDeclaration statement)
    {
        debug writeln("Aggregate declaration ", statement);

        super.visit(statement);
    }

    override void visit(AST.TupleDeclaration statement)
    {
        debug writeln("Tuple declaration ", statement);

        super.visit(statement);
    }

    override void visit(AST.CtorDeclaration statement)
    {
        debug writeln("Constructor declaration ", statement);

        super.visit(statement);
    }

    override void visit(AST.SharedStaticCtorDeclaration declaration)
    {
        debug writeln("Shared static constructor declaration ", declaration);

        stepInFunction!(AST.SharedStaticCtorDeclaration)(declaration);
    }

    override void visit(AST.SharedStaticDtorDeclaration declaration)
    {
        debug writeln("Shared static destructor declaration ", declaration);

        stepInFunction!(AST.SharedStaticDtorDeclaration)(declaration);
    }

    override void visit(AST.UnionDeclaration statement)
    {
        debug writeln("Union ", statement);

        // Unions are handled as StructDeclarations
        super.visit(statement);
    }

    override void visit(AST.InterfaceDeclaration statement)
    {
        debug writeln("Interface ", statement);

        // Interfaces are handled as ClassDeclarations
        super.visit(statement);
    }

    override void visit(AST.BitFieldDeclaration statement)
    {
        debug writeln(statement.stringof, ' ', statement);

        super.visit(statement);
    }

    override void visit(AST.StaticForeachStatement statement)
    {
        debug writeln("Static foreach statement ", statement);

        stepInStaticDeclaration(statement);
    }

    override void visit(AST.GotoStatement statement)
    { // There are also GotoDefaultStatement and GotoCaseStatement
        debug writeln("Goto statement ", statement);

        increase;
        super.visit(statement);
    }

    override void visit(AST.StructDeclaration structDeclaration)
    {
        debug writeln("Struct declaration ", structDeclaration);

        stepInAggregate!(AST.StructDeclaration)(structDeclaration);
    }

    override void visit(AST.ClassDeclaration classDeclaration)
    {
        debug writeln("Class declaration ", classDeclaration);

        stepInAggregate!(AST.ClassDeclaration)(classDeclaration);
    }

    private void stepInAggregate(Declaration : AST.AggregateDeclaration)(Declaration declaration)
    {
        auto newMeter = Meter(declaration.ident, declaration.loc, Meter.Type.aggregate);
        auto parent = this.parent;
        this.parent = &newMeter;

        super.visit(declaration);

        this.parent = parent;
        this.meter.insert(newMeter);
    }

    override void visit(AST.FuncLiteralDeclaration declaration)
    {
        debug writeln("Function literal ", declaration);

        stepInFunction(declaration);
    }

    override void visit(AST.FuncDeclaration declaration)
    {
        debug writeln("Function declaration ", declaration);

        stepInFunction(declaration);
    }

    override void visit(AST.DtorDeclaration declaration)
    {
        debug writeln("Destructor ", declaration);

        stepInFunction(declaration);
    }

    private void stepInFunction(T : AST.FuncDeclaration)(T declaration)
    {
        auto newMeter = Meter(declaration.ident, declaration.loc, Meter.Type.callable);
        auto parent = this.parent;
        this.parent = &newMeter;

        ++this.depth;
        super.visit(declaration);
        --this.depth;

        this.parent = parent;
        this.meter.insert(newMeter);
    }

    override void visit(AST.Statement s)
    {
        debug writeln("Statement ", s.stmt);

        super.visit(s);
    }

    override void visit(AST.Type type_)
    {
        debug writeln("Type ", type_);

        super.visit(type_);
    }

    override void visit(AST.BinExp expression)
    {
        debug writeln("Binary expression ", expression);

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

    override void visit(AST.IfStatement statement)
    {
        debug writeln("if statement ", statement);

        statement.condition.accept(this);

        if (statement.ifbody)
        {
            increase(this.depth);

            ++this.depth;
            statement.ifbody.accept(this);
            --this.depth;
        }
        visitElseStatement(statement.elsebody);

    }

    private void visitElseStatement(AST.Statement statement)
    {
        if (statement is null)
        {
            return;
        }
        auto elseIf = statement.isIfStatement();
        if (elseIf !is null)
        {
            if (elseIf.ifbody)
            {
                increase;

                ++this.depth;
                elseIf.ifbody.accept(this);
                --this.depth;
            }
            visitStaticElseStatement(elseIf.elsebody);
        }
        else
        {
            increase;

            ++this.depth;
            statement.accept(this);
            --this.depth;
        }
    }

    override void visit(AST.StaticIfDeclaration declaration)
    {
        debug writeln("static if declaration ", declaration);

        declaration.condition.accept(this);

        if (declaration.decl)
        {
            increase(max(1, this.depth));

            ++this.depth;
            foreach (de; *declaration.decl)
            {
                de.accept(this);
            }
            --this.depth;
        }
        visitStaticElseDeclaration(declaration.elsedecl);
    }

    private void visitStaticElseDeclaration(AST.Dsymbols* declaration)
    {
        if (declaration is null)
        {
            return;
        }
        if (declaration.length == 0)
        {
            increase;
        }
        foreach (elseDeclaration; *declaration)
        {
            if (strcmp(elseDeclaration.kind, "static if") == 0)
            {
                auto elseIf = cast(AST.StaticIfDeclaration) elseDeclaration;
                if (elseIf.decl !is null)
                {
                    increase;

                    ++this.depth;
                    foreach (de; *elseIf.decl)
                    {
                        de.accept(this);
                    }
                    --this.depth;
                }
                visitStaticElseDeclaration(elseIf.elsedecl);
            }
            else
            {
                increase;

                ++this.depth;
                elseDeclaration.accept(this);
                --this.depth;
            }
        }
    }

    override void visit(AST.ConditionalStatement statement)
    {
        debug writeln("Conditional statement ", statement);

        statement.condition.accept(this);

        if (statement.ifbody)
        {
            increase(this.depth);

            ++this.depth;
            statement.ifbody.accept(this);
            --this.depth;
        }
        visitStaticElseStatement(statement.elsebody);
    }

    private void visitStaticElseStatement(AST.Statement statement)
    {
        if (statement is null)
        {
            return;
        }
        auto elseIf = statement.isConditionalStatement();
        if (elseIf !is null)
        {
            if (elseIf.ifbody)
            {
                increase;

                ++this.depth;
                elseIf.ifbody.accept(this);
                --this.depth;
            }
            visitStaticElseStatement(elseIf.elsebody);
        }
        else
        {
            increase;

            ++this.depth;
            statement.accept(this);
            --this.depth;
        }
    }

    override void visit(AST.StaticForeachDeclaration foreachDeclaration)
    {
        debug writeln("Static foreach declaration ", foreachDeclaration);

        stepInStaticDeclaration(foreachDeclaration);
    }

    private void stepInStaticDeclaration(T : ASTNode)(T declaration)
    {
        increase(max(this.depth, 1));

        ++this.depth;
        super.visit(declaration);
        --this.depth;
    }

    override void visit(AST.WhileStatement whileStatement)
    {
        debug writeln("while statement ", whileStatement);

        stepInLoop(whileStatement);
    }

    override void visit(AST.DoStatement doStatement)
    {
        debug writeln("do statement ", doStatement);

        stepInLoop(doStatement);
    }

    override void visit(AST.ForStatement forStatement)
    {
        debug writeln("for statement ", forStatement);

        stepInLoop(forStatement);
    }

    override void visit(AST.ForeachStatement foreachStatement)
    {
        debug writeln("foreach statement ", foreachStatement);

        stepInLoop(foreachStatement);
    }

    private void stepInLoop(T : ASTNode)(T statement)
    {
         increase(this.depth);

        ++this.depth;
        super.visit(statement);
        --this.depth;
   }

    override void visit(AST.Module moduleDeclaration)
    {
        debug writeln("Module declaration ", moduleDeclaration);

        this.source_.moduleName = moduleDeclaration.md is null
            ? "app"
            : moduleDeclaration.md.toString.idup;

        super.visit(moduleDeclaration);
    }

    override void visit(AST.CondExp expression)
    {
        debug writeln("Ternary operator ", expression);

        stepInLoop(expression);
    }

    override void visit(AST.SwitchStatement statement)
    {
        debug writeln("Switch ", statement);

        stepInLoop(statement);
    }

    override void visit(AST.TryCatchStatement statement)
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

    override void visit(AST.BreakStatement statement)
    {
        debug writeln("Break ", statement.ident);

        stepInStatementWithLabel(statement);
    }

    private void stepInStatementWithLabel(T : AST.Statement)(T statement)
    {
        if (statement.ident !is null)
        {
            increase;
        }
        super.visit(statement);
    }

    override void visit(AST.ContinueStatement statement)
    {
        debug writeln("Label ", statement);

        stepInStatementWithLabel(statement);
    }

    override void visit(AST.PostBlitDeclaration declaration)
    {
        debug writeln("Blit ", declaration);

        stepInFunction(declaration);
    }

    override void visit(AST.VersionCondition condition)
    {
        debug writeln("Version condition ", condition);

        stepInStaticDeclaration(condition);
    }
}
