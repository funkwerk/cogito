import cogito;

import std.range;
import std.sumtype;

int main(string[] args)
{
    args.popFront;

    auto meter = runOnFiles(args);

    return match!(
        (List!CognitiveError errors) {
            printErrors(errors);
            return 1;
        },
        (Source source) {
            printMeter(source);
            return 0;
        }
    )(meter);
}
