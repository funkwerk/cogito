module cogito.meter;

import core.stdc.stdarg;
import core.stdc.stdio : fputc, fputs, fprintf, stderr;
import dmd.frontend;
import dmd.identifier;
import dmd.globals;
import dmd.console;
import dmd.root.outbuffer;

import cogito.arguments;
import cogito.list;
import std.algorithm;
import std.conv;
import std.range;
import std.stdio : write, writefln;
import std.typecons;
import std.sumtype;
import std.traits;

private mixin template Ruler()
{
    uint ownScore = 0;
    List!Meter inner;

    @disable this();

    public uint score()
    {
        return this.ownScore
            + reduce!((accum, x) => accum + x.score)(0, this.inner[]);
    }
}

/**
 * Identifier and its location in the source file.
 */
struct ScoreScope
{
    /**
     * Declaration identifier (e.g. function or struct name, may be empty if
     * this is a lambda).
     */
    Identifier identifier;

    /// Source position.
    Loc location;
}

/**
 * Collects the score from a single declaration, like a function. Can contain
 * nested $(D_SYMBOL Meter) structures with nested declarations.
 */
struct Meter
{
    private ScoreScope scoreScope;

    /// Symbol type.
    enum Type
    {
        aggregate, /// Aggregate.
        callable, /// Function.
        class_, /// Class.
        interface_, /// Interface.
        struct_, /// Struct.
        template_, /// Template.
        union_, /// Union.
    }
    private Type type;

    /// Gets the evaluated identifier.
    @property ref Identifier identifier() return
    {
        return this.scoreScope.identifier;
    }

    /// Sets the evaluated identifier.
    @property void identifier(ref Identifier identifier)
    {
        this.scoreScope.identifier = identifier;
    }

    @property const(char)[] name()
    {
        auto stringName = this.scoreScope.identifier.toString();

        if (stringName.empty)
        {
            return "(λ)";
        }
        else if (stringName == "__ctor")
        {
            return "this";
        }
        else if (stringName == "__dtor")
        {
            return "~this";
        }
        else if (stringName == "__postblit")
        {
            return "this(this)";
        }
        else if (stringName.startsWith("_sharedStaticCtor_"))
        {
            return "shared static this";
        }
        else if (stringName.startsWith("_sharedStaticDtor_"))
        {
            return "shared static ~this";
        }
        else
        {
            return stringName;
        }
    }

    /// Gets identifier location.
    @property ref Loc location() return
    {
        return this.scoreScope.location;
    }

    /// Sets identifier location.
    @property void location(ref Loc location)
    {
        this.scoreScope.location = location;
    }

    /**
     * Params:
     *     identifier = Identifier.
     *     location = Identifier location.
     *     type = Symbol type.
     */
    public this(Identifier identifier, Loc location, Type type)
    {
        this.identifier = identifier;
        this.location = location;
        this.type = type;
    }

    /**
     * Returns: $(D_KEYWORD true) if any function or aggregate inside the
     *          current node excceds the threshold, otherwise
     *          $(D_KEYWORD false).
     */
    bool isAbove(Threshold threshold)
    {
        if (threshold.noneSet)
        {
            return false;
        }
        if (threshold.function_ != 0
                && this.type == Type.callable
                && this.score > threshold.function_)
        {
            return true;
        }
        else if (threshold.aggregate != 0
                && this.type != Type.callable // Aggregate.
                && this.score > threshold.aggregate)
        {
            return true;
        }
        else
        {
            return reduce!((accum, x) => accum || x.isAbove(threshold))(false, this.inner[]);
        }
    }

    mixin Ruler!();
}

private string typeToString(Meter.Type meterType)
{
    final switch(meterType) with (Meter.Type)
    {
        case aggregate:
             return "aggregate";
        case callable:
             return "function";
        case class_:
             return "class";
        case interface_:
             return "interface";
        case struct_:
             return "struct";
        case template_:
             return "template";
        case union_:
             return "union";
    }
}

/**
 * Prints the information about the given identifier.
 *
 * Params:
 *     sink = Function used to print the information.
 */
struct DebugReporter(alias sink)
if (isCallable!sink)
{
    private Source source;

    @disable this();

    this(Source source)
    {
        this.source = source;
    }

    /**
     * Params:
     *     meter = The score statistics to print.
     */
    void report()
    {
        sink(this.source.moduleName);
        sink(": ");
        sink(this.source.score.to!string);
        sink("\n");

        foreach (ref meter; this.source.inner[])
        {
            traverse(meter, 1);
        }
    }

    private void traverse(ref Meter meter, const uint indentation)
    {
        const indentBytes = ' '.repeat(indentation * 2).array;
        const nextIndentation = indentation + 1;
        const nextIndentBytes = ' '.repeat(nextIndentation * 2).array;

        sink(indentBytes);
        sink(meter.name);

        sink(":\n");
        sink(nextIndentBytes);
        sink("Location: ");
        sink(to!string(meter.location.linnum));
        sink(":");
        sink(to!string(meter.location.charnum));
        sink("\n");
        sink(nextIndentBytes);
        sink("Score: ");

        sink(meter.score.to!string);
        sink("\n");

        meter.inner[].each!(meter => this.traverse(meter, nextIndentation));
    }
}

/**
 * Prints the information about the given identifier.
 *
 * Params:
 *     sink = Function used to print the information.
 */
struct FlatReporter(alias sink)
if (isCallable!sink)
{
    private Source source;

    @disable this();

    /**
     * Params:
     *     source = Scores collected from a source file.
     */
    this(Source source)
    {
        this.source = source;
    }

    /**
     * Params:
     *     threshold = Score limits.
     */
    void report(Threshold threshold)
    {
        const sourceScore = this.source.score;

        if (threshold.noneSet
                || (threshold.module_ != 0 && sourceScore > threshold.module_))
        {
            sink("module ");
            sink(this.source.moduleName);
            sink(": ");
            sink(sourceScore.to!string);
            sink(" (");
            sink(this.source.filename);
            sink(")");
            sink("\n");
        }

        foreach (ref meter; this.source.inner[])
        {
            traverse(meter, threshold, []);
        }
    }

    private void traverse(ref Meter meter,
            Threshold threshold, const string[] path)
    {
        if ((threshold.function_ != 0 || threshold.aggregate != 0)
                && !meter.isAbove(threshold))
        {
            return;
        }
        const nameParts = path ~ [meter.name.idup];

        sink(this.source.filename);
        sink(":");
        sink(to!string(meter.location.linnum));
        sink(": ");
        sink(typeToString(meter.type));
        sink(" ");
        sink(nameParts.join("."));
        sink(": ");
        sink(meter.score.to!string);
        sink("\n");

        meter.inner[].each!(meter => this.traverse(meter,
                threshold, nameParts));
    }
}

/**
 * Collects the score from a single D module.
 */
struct Source
{
    /// Module name.
    string moduleName = "main";

    /// Module file name.
    private string filename_;

    /**
     * Params:
     *     inner = List with module metrics.
     *     filename = Module file name.
     */
    this(List!Meter inner, string filename = "-")
    @nogc nothrow pure @safe
    {
        this.inner = inner;
        this.filename_ = filename;
    }

    @property string filename() @nogc nothrow pure @safe
    {
        return this.filename_;
    }

    /**
     * Returns: $(D_KEYWORD true) if any function inside the current node
     *          excceds the threshold, otherwise $(D_KEYWORD false).
     */
    bool isAbove(Threshold threshold)
    {
        if (threshold.noneSet)
        {
            return false;
        }
        else if (threshold.module_ != 0 && this.score > threshold.module_)
        {
            return true;
        }
        else
        {
            return reduce!((accum, x) => accum || x.isAbove(threshold))(false, this.inner[]);
        }
    }

    mixin Ruler!();
}

/**
 * Supported threshold values.
 */
struct Threshold
{
    /// Function threshold.
    uint function_;

    /// Aggregate threshold.
    uint aggregate;

    /// Module threshold.
    uint module_;

    /**
     * Returns: Whether none threshold is set.
     */
    bool noneSet()
    {
        return this.function_ == 0 && this.aggregate == 0 && this.module_ == 0;
    }
}

/**
 * Prints source file metrics to the standard output.
 *
 * Params:
 *     source = Collected metrics and scores.
 *     threshold = Maximum acceptable scores.
 *     format = Output format.
 *
 * Returns: $(D_KEYWORD true) if the score exceeds the threshold, otherwise
 *          returns $(D_KEYWORD false).
 */
bool report(Source source, Threshold threshold, OutputFormat format)
{
    const bool aboveAnyThreshold = source.isAbove(threshold);

    if (format == OutputFormat.silent)
    {
        return aboveAnyThreshold;
    }
    else if (format == OutputFormat.debug_)
    {
        DebugReporter!write(source).report();
    }
    else if (format == OutputFormat.verbose)
    {
        FlatReporter!write(source).report(Threshold());
    }
    else if (aboveAnyThreshold || threshold.noneSet)
    {
        FlatReporter!write(source).report(threshold);
    }

    return aboveAnyThreshold;
}

/**
 * Prints an error list to the standard output.
 *
 * Params:
 *     errors = The errors to print.
 */
void printErrors(List!CognitiveError errors)
{
    foreach (error; errors[])
    {
        auto location = error.location.toChars();

        if (*location)
        {
            fprintf(stderr, "%s: ", location);
        }
        fputs(error.header, stderr);

        fputs(error.message.peekChars(), stderr);
        fputc('\n', stderr);
    }
}

struct CognitiveError
{
    Loc location;
    Color headerColor;
    const(char)* header;
    RefCounted!OutBuffer message;
}

struct LocalHandler
{
    List!CognitiveError errors;

    bool handler(const ref Loc location,
        Color headerColor,
        const(char)* header,
        const(char)* messageFormat,
        va_list args,
        const(char)* prefix1,
        const(char)* prefix2) nothrow
    {
        CognitiveError error;

        error.location = location;
        error.headerColor = headerColor;
        error.header = header;

        if (prefix1)
        {
            error.message.writestring(prefix1);
            error.message.writestring(" ");
        }
        if (prefix2)
        {
            error.message.writestring(prefix2);
            error.message.writestring(" ");
        }
        error.message.vprintf(messageFormat, args);

        this.errors.insert(error);

        return true;
    }
}

/**
 * Initialize global variables.
 */
void initialize()
{
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
}

/**
 * Clean up global variables.
 */
void deinitialize()
{
    deinitializeDMD();
}

/// Result of analysing a source file.
alias Result = SumType!(List!CognitiveError, Source);
