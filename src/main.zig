const std = @import("std");
const debug = std.debug;

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const alloc = gpa.allocator();
    defer {
        const deinit_status = gpa.deinit();
        _ = deinit_status;
    }
    var argIter = try std.process.argsWithAllocator(alloc);
    defer argIter.deinit();
    while(argIter.next()) |iter| {
        debug.print("{s}\n", .{iter});
        const file = try std.fs.cwd().createFile(iter, .{.read = true});
        try file.seekTo(0);
        const contents = try file.reader().readAllAlloc(alloc, 128);
        debug.print("{s}\n", .{contents});
        // const stat = try file.stat();
        // debug.print("File size: {d}\n", .{stat.size});
        defer file.close();
    }
}
