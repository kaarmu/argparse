const std = @import("std");
const tst = std.testing;
const ap = @import("src/argparse.zig");

//---------//
// default //
//---------//

// 0 values; store, nargs = ?
test "default-01" {
    // Create parser
    var parser = ap.ArgumentParser.init(tst.allocator);
    defer parser.deinit();

    // Add arguments
    try parser.addArgument(.{ .short = "-s", .action = .store, .nargs = '?', .default = "A" });

    // Parse arguments
    try parser.parseArgs(ap.ArgvIterator(.{ "main.zig", "-s" }));

    // ----------------------------------------------------
    // Tests

    var arg = parser.getArgument("-s").?;
    try tst.expectEqualSlices(u8, arg.results.items[0], "A");
}

// 1 values; store, nargs = 1
test "default-02" {
    // Create parser
    var parser = ap.ArgumentParser.init(tst.allocator);
    defer parser.deinit();

    // Add arguments
    try parser.addArgument(.{ .short = "-s", .action = .store, .nargs = '?', .default = "A" });

    // Parse arguments
    try parser.parseArgs(ap.ArgvIterator(.{ "main.zig", "-s", "a" }));

    // ----------------------------------------------------
    // Tests

    var arg = parser.getArgument("-s").?;
    try tst.expectEqualSlices(u8, arg.results.items[0], "a");
}

//-------//
// nargs //
//-------//

// 1 value; pos, nargs = 1
test "nargs-01" {
    // Create parser
    var parser = ap.ArgumentParser.init(tst.allocator);
    defer parser.deinit();

    // Add arguments
    try parser.addArgument(.{ .long = "--POS", .action = .pos, .nargs = 1 });

    // Parse arguments
    try parser.parseArgs(ap.ArgvIterator(.{ "main.zig", "a" }));

    // ----------------------------------------------------
    // Tests

    var arg = parser.getArgument("--POS").?;
    try tst.expectEqualSlices(u8, arg.results.items[0], "a");
}

// 5 values; pos, nargs = 5
test "nargs-02" {
    // Create parser
    var parser = ap.ArgumentParser.init(tst.allocator);
    defer parser.deinit();

    // Add arguments
    try parser.addArgument(.{ .long = "--POS", .action = .pos, .nargs = 5 });

    // Parse arguments
    try parser.parseArgs(ap.ArgvIterator(.{ "main.zig", "a", "b", "c", "d", "e" }));

    // ----------------------------------------------------
    // Tests

    var arg = parser.getArgument("--POS").?;

    comptime var i = 0;
    inline while (i < 5) : (i += 1)
        try tst.expectEqualSlices(u8, arg.results.items[i], &[1]u8{'a' + i});
}

// 5 values; pos, nargs = 2; pos, nargs = 3
test "nargs-03" {
    // Create parser
    var parser = ap.ArgumentParser.init(tst.allocator);
    defer parser.deinit();

    // Add arguments
    try parser.addArgument(.{ .long = "--POS1", .action = .pos, .nargs = 2 });
    try parser.addArgument(.{ .long = "--POS2", .action = .pos, .nargs = 3 });

    // Parse arguments
    try parser.parseArgs(ap.ArgvIterator(.{ "main.zig", "a", "b", "c", "d", "e" }));

    // ----------------------------------------------------
    // Tests

    var pos1 = parser.getArgument("--POS1").?;
    var pos2 = parser.getArgument("--POS2").?;

    comptime var i = 0;
    inline while (i < 2) : (i += 1)
        try tst.expectEqualSlices(u8, pos1.results.items[i], &[1]u8{'a' + i});
    inline while (i < 2 + 3) : (i += 1)
        try tst.expectEqualSlices(u8, pos2.results.items[i - 2], &[1]u8{'a' + i});
}

// 3 values; pos, nargs = 2; UnexpectedPositional
test "nargs-04" {
    // Create parser
    var parser = ap.ArgumentParser.init(tst.allocator);
    defer parser.deinit();

    // Add arguments
    try parser.addArgument(.{ .long = "--POS1", .action = .pos, .nargs = 2 });

    // ----------------------------------------------------
    // Tests

    try tst.expectError(error.UnexpectedPositional, parser.parseArgs(ap.ArgvIterator(.{ "main.zig", "a", "b", "c" })));
}

// 1 value; pos, nargs = 2; MissingPositional
test "nargs-05" {
    // Create parser
    var parser = ap.ArgumentParser.init(tst.allocator);
    defer parser.deinit();

    // Add arguments
    try parser.addArgument(.{ .long = "--POS1", .action = .pos, .nargs = 2 });

    // ----------------------------------------------------
    // Tests

    try tst.expectError(error.MissingValues, parser.parseArgs(ap.ArgvIterator(.{ "main.zig", "a" })));
}

// 0 values; pos, nargs = *
test "nargs-06" {
    // Create parser
    var parser = ap.ArgumentParser.init(tst.allocator);
    defer parser.deinit();

    // Add arguments
    try parser.addArgument(.{ .long = "--POS", .action = .pos, .nargs = '*', .default = "A" });

    // Parse arguments
    try parser.parseArgs(ap.ArgvIterator(.{"main.zig"}));

    // ----------------------------------------------------
    // Tests

    var arg = parser.getArgument("--POS").?;
    try tst.expectEqualSlices(u8, arg.results.items[0], "A");
}

// 5 values; pos, nargs = *
test "nargs-07" {
    // Create parser
    var parser = ap.ArgumentParser.init(tst.allocator);
    defer parser.deinit();

    // Add arguments
    try parser.addArgument(.{ .long = "--POS", .action = .pos, .nargs = '*', .default = "A" });

    // Parse arguments
    try parser.parseArgs(ap.ArgvIterator(.{ "main.zig", "a", "b", "c", "d", "e" }));

    // ----------------------------------------------------
    // Tests

    var arg = parser.getArgument("--POS").?;

    comptime var i = 0;
    inline while (i < 5) : (i += 1)
        try tst.expectEqualSlices(u8, arg.results.items[i], &[1]u8{'a' + i});
}

// 0 values; pos, nargs = +; MissingValues
test "nargs-08" {
    // Create parser
    var parser = ap.ArgumentParser.init(tst.allocator);
    defer parser.deinit();

    // Add arguments
    try parser.addArgument(.{ .long = "--POS", .action = .pos, .nargs = '+' });

    // ----------------------------------------------------
    // Tests

    // Parse arguments
    try tst.expectError(error.MissingValues, parser.parseArgs(ap.ArgvIterator(.{"main.zig"})));
}

// 5 values; pos, nargs = +
test "nargs-09" {
    // Create parser
    var parser = ap.ArgumentParser.init(tst.allocator);
    defer parser.deinit();

    // Add arguments
    try parser.addArgument(.{ .long = "--POS", .action = .pos, .nargs = '+' });

    // Parse arguments
    try parser.parseArgs(ap.ArgvIterator(.{ "main.zig", "a", "b", "c", "d", "e" }));

    // ----------------------------------------------------
    // Tests

    var arg = parser.getArgument("--POS").?;

    comptime var i = 0;
    inline while (i < 5) : (i += 1)
        try tst.expectEqualSlices(u8, arg.results.items[i], &[1]u8{'a' + i});
}

// 1 values; pos, nargs = ?
test "nargs-11" {
    // Create parser
    var parser = ap.ArgumentParser.init(tst.allocator);
    defer parser.deinit();

    // Add arguments
    try parser.addArgument(.{ .long = "--POS", .action = .pos, .nargs = '?', .default = "A" });

    // Parse arguments
    try parser.parseArgs(ap.ArgvIterator(.{ "main.zig", "a" }));

    // ----------------------------------------------------
    // Tests

    var arg = parser.getArgument("--POS").?;
    try tst.expectEqualSlices(u8, arg.results.items[0], "a");
}

// 0 values; pos, nargs = ?
test "nargs-12" {
    // Create parser
    var parser = ap.ArgumentParser.init(tst.allocator);
    defer parser.deinit();

    // Add arguments
    try parser.addArgument(.{ .long = "--POS", .action = .pos, .nargs = '?', .default = "A" });

    // Parse arguments
    try parser.parseArgs(ap.ArgvIterator(.{"main.zig"}));

    // ----------------------------------------------------
    // Tests

    var arg = parser.getArgument("--POS").?;
    try tst.expectEqualSlices(u8, arg.results.items[0], "A");
}

//----------//
// required //
//----------//

// 0 values; store, nargs = 1, required; ArgumentNotFound
test "required-01" {
    // Create parser
    var parser = ap.ArgumentParser.init(tst.allocator);
    defer parser.deinit();

    // Add arguments
    try parser.addArgument(.{ .short = "-s", .action = .store, .nargs = 1, .required = true });

    // ----------------------------------------------------
    // Tests

    // Parse arguments
    try tst.expectError(error.MissingValues, parser.parseArgs(ap.ArgvIterator(.{"main.zig"})));
}

//---------------------//
// action = store_true //
//---------------------//

// 0 values; store_true
test "store_true-01" {
    // Create parser
    var parser = ap.ArgumentParser.init(tst.allocator);
    defer parser.deinit();

    // Add arguments
    try parser.addArgument(.{ .short = "-s", .action = .store_true });

    // Parse arguments
    try parser.parseArgs(ap.ArgvIterator(.{"main.zig"}));

    // ----------------------------------------------------
    // Tests

    var arg = parser.getArgument("-s").?;
    try tst.expectEqualSlices(u8, arg.results.items[0], "0");
}

// 1 values; store_true
test "store_true-02" {
    // Create parser
    var parser = ap.ArgumentParser.init(tst.allocator);
    defer parser.deinit();

    // Add arguments
    try parser.addArgument(.{ .short = "-s", .action = .store_true });

    // Parse arguments
    try parser.parseArgs(ap.ArgvIterator(.{ "main.zig", "-s" }));

    // ----------------------------------------------------
    // Tests

    var arg = parser.getArgument("-s").?;
    try tst.expectEqualSlices(u8, arg.results.items[0], "1");
}

//----------------------//
// action = store_false //
//----------------------//

// 0 values; store_false
test "store_false-01" {
    // Create parser
    var parser = ap.ArgumentParser.init(tst.allocator);
    defer parser.deinit();

    // Add arguments
    try parser.addArgument(.{ .short = "-s", .action = .store_false });

    // Parse arguments
    try parser.parseArgs(ap.ArgvIterator(.{"main.zig"}));

    // ----------------------------------------------------
    // Tests

    var arg = parser.getArgument("-s").?;
    try tst.expectEqualSlices(u8, arg.results.items[0], "1");
}

// 1 values; store_false
test "store_false-02" {
    // Create parser
    var parser = ap.ArgumentParser.init(tst.allocator);
    defer parser.deinit();

    // Add arguments
    try parser.addArgument(.{ .short = "-s", .action = .store_false });

    // Parse arguments
    try parser.parseArgs(ap.ArgvIterator(.{ "main.zig", "-s" }));

    // ----------------------------------------------------
    // Tests

    var arg = parser.getArgument("-s").?;
    try tst.expectEqualSlices(u8, arg.results.items[0], "0");
}

//----------------------//
// action = store_const //
//----------------------//

// 0 values; store_const
test "store_const-01" {
    // Create parser
    var parser = ap.ArgumentParser.init(tst.allocator);
    defer parser.deinit();

    // Add arguments
    try parser.addArgument(.{ .short = "-s", .action = .store_const, .value = "A" });

    // Parse arguments
    try parser.parseArgs(ap.ArgvIterator(.{"main.zig"}));

    // ----------------------------------------------------
    // Tests

    var arg = parser.getArgument("-s").?;
    try tst.expect(arg.results.items.len == 0);
}

// 1 values; store_const
test "store_const-02" {
    // Create parser
    var parser = ap.ArgumentParser.init(tst.allocator);
    defer parser.deinit();

    // Add arguments
    try parser.addArgument(.{ .short = "-s", .action = .store_const, .value = "A" });

    // Parse arguments
    try parser.parseArgs(ap.ArgvIterator(.{ "main.zig", "-s" }));

    // ----------------------------------------------------
    // Tests

    var arg = parser.getArgument("-s").?;
    try tst.expectEqualSlices(u8, arg.results.items[0], "A");
}

// 0 values; store_const, default
test "store_const-03" {
    // Create parser
    var parser = ap.ArgumentParser.init(tst.allocator);
    defer parser.deinit();

    // Add arguments
    try parser.addArgument(.{ .short = "-s", .action = .store_const, .value = "A", .default = "B" });

    // Parse arguments
    try parser.parseArgs(ap.ArgvIterator(.{"main.zig"}));

    // ----------------------------------------------------
    // Tests

    var arg = parser.getArgument("-s").?;
    try tst.expectEqualSlices(u8, arg.results.items[0], "B");
}

//----------------//
// action = store //
//----------------//

// test "store | 5 values; store, nargs = 2; store, nargs = 1" {
//     var argv = [_]Str{"-f", "a", "b", "-g", "c"};
//
//     var arguments = {
//
//     };
// }
