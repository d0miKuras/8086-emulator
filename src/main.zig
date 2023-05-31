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
    // while(argIter.next()) |iter| {
    //     debug.print("{s}\n", .{iter});
    // }
    var path_buffer: [std.fs.MAX_PATH_BYTES]u8 = undefined;
    const path = try std.fs.cwd().realpath("mov", &path_buffer);
    debug.print("{s}\n", .{path});
    const file = try std.fs.openFileAbsolute(path, .{});
    defer file.close();
    try file.seekTo(0);
    const contents = try file.reader().readAllAlloc(alloc, std.fs.MAX_PATH_BYTES);
    defer alloc.free(contents);
    debug.print("{b}\n", .{contents});
}
