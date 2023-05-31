const std = @import("std");
const debug = std.debug;

pub fn populateOpcodes(map: *std.AutoHashMap(u8, []const u8)) !void{
    try map.put(0b100010, "mov");
}

pub fn populateRegistersW(map: *std.AutoHashMap(u8, []const u8)) !void{
    try map.put(0b000, "AX");
    try map.put(0b001, "CX");
    try map.put(0b010, "DX");
    try map.put(0b011, "BX");
    try map.put(0b100, "SP");
    try map.put(0b101, "BP");
    try map.put(0b110, "SI");
    try map.put(0b111, "DI");
}

pub fn populateRegistersNoW(map: *std.AutoHashMap(u8, []const u8)) !void{
    try map.put(0b000, "AL");
    try map.put(0b001, "CL");
    try map.put(0b010, "DL");
    try map.put(0b011, "BL");
    try map.put(0b100, "AH");
    try map.put(0b101, "CH");
    try map.put(0b110, "DH");
    try map.put(0b111, "BH");
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
    var registersNoW = std.AutoHashMap(u8, []const u8).init(alloc);
    defer registersNoW.deinit();
    try populateRegistersNoW(&registersNoW);
    var registersW = std.AutoHashMap(u8, []const u8).init(alloc);
    defer registersW.deinit();
    try populateRegistersW(&registersW);
    var argIter = try std.process.argsWithAllocator(alloc);
    defer argIter.deinit();
    // while(argIter.next()) |iter| {
    //     debug.print("{s}\n", .{iter});
    // }
    var path_buffer: [std.fs.MAX_PATH_BYTES]u8 = undefined;
    const path = try std.fs.cwd().realpath("mov_multi", &path_buffer);
    debug.print("{s}\n", .{path});
    const file = try std.fs.openFileAbsolute(path, .{});
    defer file.close();
    try file.seekTo(0);
    const contents = try file.reader().readAllAlloc(alloc, 1024);
    defer alloc.free(contents);
    {
        var i : usize = 0;
        debug.print("bits 16\n", .{});
        while(i < contents.len){
            // debug.print("{b}\n", .{contents[i]});
            // debug.print("{b}\n", .{contents[i + 1]});
            var op = opcodes.get(contents[i]>>2).?;
            debug.print("{s}\t", .{op});
            // W 1
            if(contents[i] & 1 == 1){
                const destReg = registersW.get(contents[i + 1] >> 0 & 0b111).?;
                const srcReg = registersW.get(contents[i + 1] >> 3 & 0b111).?;
                debug.print("{s}, {s}\n", .{destReg, srcReg});
            }
            else{
                const destReg = registersNoW.get(contents[i + 1] >> 0 & 0b111).?;
                const srcReg = registersNoW.get(contents[i + 1] >> 3 & 0b111).?;
                debug.print("{s}, {s}\n", .{destReg, srcReg});
            }
            i += 2;
        }
    }
}
