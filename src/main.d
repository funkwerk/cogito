import cogito;

import std.range;

void main(string[] args)
{
    args.popFront;

    const meter = runOnFiles(args);

    printMeter(meter);
}
