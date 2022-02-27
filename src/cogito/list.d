module cogito.list;

struct Range(T)
{
    private Entry!T* entry;

    @disable this();

    private this(Entry!T* entry)
    {
        this.entry = entry;
    }

    public bool empty() const
    {
        return this.entry is null;
    }

    public ref const(T) front() const
    in(this.entry !is null)
    {
        return this.entry.element;
    }

    public void popFront()
    in(this.entry !is null)
    {
        this.entry = this.entry.next;
    }
}

private struct Entry(T)
{
    private T element;
    private Entry!T* next;
}

struct List(T)
{
    private Entry!T* first;
    private Entry!T* last;

    invariant((this.first is null && this.last is null)
        || (this.first !is null && this.last !is null));

    void insert(T element)
    {
        auto entry = new Entry!T(element, null);

        if (this.first is null)
        {
            this.first = entry;
        }
        if (this.last is null)
        {
            this.last = entry;
        }
        else
        {
            this.last.next = entry;
            this.last = entry;
        }
    }

    @property bool empty()
    {
        return this.first is null;
    }

    @property ref T front()
    in(!empty)
    {
        return this.first.element;
    }

    @property ref T back()
    in(!empty)
    {
        return this.last.element;
    }

    Range!T opSlice()
    {
        return Range!T(this.first);
    }
}
