import cogito;

import std.range;

void main(string[] args)
{
    args.popFront;

    auto meter = runOnFiles(args);

    printMeter(meter);
}
