const std = @import("std");

pub fn main() !void {
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    var allocator = arena.allocator();
    defer arena.deinit();

    var argv: [][:0]u8 = undefined;

    argv = try std.process.argsAlloc(allocator);
    defer std.process.argsFree(allocator, argv);

    for (argv) |s|
        std.log.info("{s}", .{s});
}
