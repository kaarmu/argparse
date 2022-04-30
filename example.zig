const std = @import("std");
const ap = @import("src/argparse.zig");

// my user-defined constructor for my parser
const myParser = @import("completion-ex.zig").myParser;

pub fn main() !void {
    // setup allocator
    // var allocator = std.testing.allocator;
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    var allocator = arena.allocator();
    defer arena.deinit();

    // create parser
    var parser = try myParser(allocator);
    defer parser.deinit();

    // parse arguments
    try parser.parseArgs();

    // retreive arguments
    const arg_exe = try parser.getArgument("prog");
    const arg_names = try parser.getArgument("--names");
    const arg_count = try parser.getArgument("--count");

    const exe = arg_exe.results.items[0];
    const names = arg_names.results.items;
    var count = if (arg_count.results.items.len > 0) arg_count.results.items[0][0] - '0' else 0;

    // get stdout/stderr
    var stdout_writer = std.io.getStdOut().writer();

    // print names
    try stdout_writer.print("executable = {s}\n", .{exe});
    if (names.len > 0) while (count > 0) : (count -= 1) {
        try stdout_writer.print("count = {d}:\n", .{count});
        for (names) |name|
            try stdout_writer.print("  {s}\n", .{name});
    };
}
