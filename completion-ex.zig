const std = @import("std");
const ap = @import("src/argparse.zig");

// [kaarmu@SURFACE argparse]$ example foo bar zoo
// info: COMP_CWORD: null
// info: COMP_LINE: example foo bar zoo
// info: COMP_POINT: 19
// info: COMP_TYPE: 9
// info: COMP_KEY: 9
// info: COMP_WORDBREAKS: null
// info: COMP_WORDS: null
// example foo bar zoo
// ^ ^ ^ ^ ^ ^ ^ ^ ^ ^
// 0 2 4 6 8 10  12  14

pub inline fn myParser(allocator: std.mem.Allocator) !ap.Parser {
    // don't forget to deinit on the parser
    var parser = ap.Parser.init(allocator, .{});

    try parser.addArgument(.{ .short = "n", .long = "names", .nargs = '*' });
    try parser.addArgument(.{ .short = "c", .long = "count", .nargs = 1, .default = "1" });

    return parser;
}

pub fn main() !void {

    // setup allocator
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    var allocator = arena.allocator();
    defer arena.deinit();

    // setup parser
    var parser = try myParser(allocator);
    defer parser.deinit();

    // run completion
    try (ap.BashCompletion{}).complete(&parser);
}
