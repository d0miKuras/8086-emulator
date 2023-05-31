const std = @import("std");
const debug = std.debug;

pub fn populateOpcodes(map: *std.AutoHashMap(u8, []const u8)) !void{
    try map.put(0b10001001, "mov");
}

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const alloc = gpa.allocator();
    defer {
        const deinit_status = gpa.deinit();
        _ = deinit_status;
    }
    var opcodes = std.AutoHashMap(u8, []const u8).init(alloc);
    defer opcodes.deinit();
    try populateOpcodes(&opcodes);
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
    const contents = try file.reader().readAllAlloc(alloc, 1024);
    defer alloc.free(contents);
    {
        var i : usize = 0;
        while(i < contents.len){
            debug.print("{b}\n", .{contents[i]});
            var val = opcodes.get(contents[i]);
            if(val) |op|{
                debug.print("{s}\n", .{op});
            }
            debug.print("{b}\n", .{contents[i + 1]});
            i += 2;
        }
    }
}
