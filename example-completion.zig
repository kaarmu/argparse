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

pub inline fn myArguments(parser: anytype) !void {
    try parser.addArgument(.{ .short = "n", .long = "names", .nargs = '*' });
    try parser.addArgument(.{ .short = "c", .long = "count", .nargs = 1, .default = "1" });
}

pub fn main() !void {
    // setup allocator
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    var allocator = arena.allocator();
    defer arena.deinit();

    // create parser
    var parser = ap.CompletionParser.init(allocator, .{});
    defer parser.deinit();

    try myArguments(&parser);

    // completion program
    try ap.bashCompletion(parser, .{});
}
