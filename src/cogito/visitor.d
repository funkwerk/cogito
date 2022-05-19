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

private Meter.Type declarationType(Declaration : AST.Dsymbol)(Declaration declaration)
{
    if (declaration.isUnionDeclaration())
    {
        return Meter.Type.union_;
    }
    else if (declaration.isStructDeclaration())
    {
        return Meter.Type.struct_;
    }
    else if (declaration.isInterfaceDeclaration())
    {
        return Meter.Type.interface_;
    }
    else if (declaration.isClassDeclaration())
    {
        return Meter.Type.class_;
    }
    else if (declaration.isTemplateDeclaration())
    {
        return Meter.Type.template_;
    }
    return Meter.Type.aggregate;
}

private string moduleName(AST.ModuleDeclaration* moduleDeclaration)
{
    return moduleDeclaration is null
        ? "app"
        : moduleDeclaration.toString.idup;
}

private mixin template VisitorHelper()
{
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

    private void stepInAggregate(Declaration : AST.Dsymbol)(Declaration declaration)
    {
        debug writeln("Aggregate declaration ", declaration);

        auto meterType = declarationType(declaration);
        auto newMeter = Meter(declaration.ident, declaration.loc, meterType);
        auto parent = this.parent;
        this.parent = &newMeter;

        super.visit(declaration);

        this.parent = parent;
        this.meter.insert(newMeter);
    }

    private void stepInStaticDeclaration(T : ASTNode)(T declaration)
    {
        increase(max(this.depth, 1));

        ++this.depth;
        super.visit(declaration);
        --this.depth;
    }

    private void stepInLoop(T : ASTNode)(T statement)
    {
         increase(this.depth);

        ++this.depth;
        super.visit(statement);
        --this.depth;
    }

    private void stepInStatementWithLabel(T : AST.Statement)(T statement)
    {
        if (statement.ident !is null)
        {
            increase;
        }
        super.visit(statement);
    }
}

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

    override void visit(AST.DebugStatement statement)
    {
        debug writeln("Debug statement ", statement);
        // Handled as ConditionalStatement or Condition
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
        // Unions are handled as StructDeclarations
        super.visit(statement);
    }

    override void visit(AST.InterfaceDeclaration statement)
    {
        // Interfaces are handled as ClassDeclarations
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
        stepInAggregate!(AST.StructDeclaration)(structDeclaration);
    }

    override void visit(AST.ClassDeclaration classDeclaration)
    {
        stepInAggregate!(AST.ClassDeclaration)(classDeclaration);
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

    override void visit(AST.TemplateDeclaration declaration)
    {
        debug writeln("Template declaration ", declaration);

        if (declaration.onemember !is null && declaration.members.length == 1)
        {
            // Ignore the template if it has only one member of the same name.
            declaration.onemember.accept(this);
        }
        else
        {
            stepInAggregate!(AST.TemplateDeclaration)(declaration);
        }
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

        if (expression.isLogicalExp())
        {
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
            visitElseStatement(elseIf.elsebody);
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
            visitNestedDeclarations(declaration);
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
        each!(x => forEachStaticElseDeclaration(x))((*declaration)[]);
    }

    private void forEachStaticElseDeclaration(AST.Dsymbol elseDeclaration)
    {
        if (strcmp(elseDeclaration.kind, "static if") != 0)
        {
            increase;

            ++this.depth;
            elseDeclaration.accept(this);
            --this.depth;

            return;
        }
        auto elseIf = cast(AST.StaticIfDeclaration) elseDeclaration;

        if (elseIf.decl !is null)
        {
            increase;
            visitNestedDeclarations(elseIf);
        }
        visitStaticElseDeclaration(elseIf.elsedecl);
    }

    private void visitNestedDeclarations(ref AST.StaticIfDeclaration elseIf)
    {
        ++this.depth;
        each!(de => de.accept(this))(*elseIf.decl);
        --this.depth;
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
        if (elseIf is null)
        {
            increase;

            ++this.depth;
            statement.accept(this);
            --this.depth;

            return;
        }
        if (elseIf.ifbody)
        {
            increase;

            ++this.depth;
            elseIf.ifbody.accept(this);
            --this.depth;
        }
        visitStaticElseStatement(elseIf.elsebody);
    }

    override void visit(AST.StaticForeachDeclaration foreachDeclaration)
    {
        debug writeln("Static foreach declaration ", foreachDeclaration);

        stepInStaticDeclaration(foreachDeclaration);
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

    override void visit(AST.Module moduleDeclaration)
    {
        debug writeln("Module declaration ", moduleDeclaration);

        this.source_.moduleName = moduleName(moduleDeclaration.md);

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
        ++this.depth;
        each!(catch_ => this.visit(catch_))(*statement.catches);
        --this.depth;
    }

    override void visit(AST.BreakStatement statement)
    {
        debug writeln("Break ", statement.ident);

        stepInStatementWithLabel(statement);
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

    mixin VisitorHelper;
}
