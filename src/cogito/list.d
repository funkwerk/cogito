module cogito.list;

/**
 * List range.
 */
struct Range(T)
{
    private Entry!T* entry;

    @disable this();

    private this(Entry!T* entry)
    {
        this.entry = entry;
    }

    /**
     * Returns: Whether the range is empty.
     */
    public bool empty() const
    {
        return this.entry is null;
    }

    /**
     * Returns: The front element.
     */
    public ref inout(T) front() inout
    in(this.entry !is null)
    {
        return this.entry.element;
    }

    /**
     * Removes the front element of the range.
     */
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

/**
 * Queue that supports recursive data definitions.
 */
struct List(T)
{
    private Entry!T* first;
    private Entry!T* last;

    invariant((this.first is null && this.last is null)
        || (this.first !is null && this.last !is null));

    /**
     * Appends $(D_PARAM element) to the list.
     *
     * Params:
     *     element = The element to append.
     */
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

    /**
     * Remove the first element.
     */
    void removeFront()
    in(!empty)
    {
        this.first = this.first.next;
        if (this.first is null)
        {
            this.last = null;
        }
    }

    /**
     * Returns: Whether this list is empty.
     */
    @property bool empty() const
    {
        return this.first is null;
    }

    /**
     * Returns: Head element.
     */
    @property ref inout(T) front() inout
    in(!empty)
    {
        return this.first.element;
    }

    /**
     * Returns: Last element.
     */
    @property ref inout(T) back() inout
    in(!empty)
    {
        return this.last.element;
    }

    /**
     * Returns: Range over this list.
     */
    Range!T opIndex()
    {
        return Range!T(this.first);
    }

    /**
     * Remove all elements.
     */
    void clear()
    {
        while (!empty)
        {
            removeFront();
        }
    }
}
