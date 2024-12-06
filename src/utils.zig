const std = @import("std");

pub fn readFile(file_path: []const u8, alloc: *std.mem.Allocator) ![]u8 {
    const file = try std.fs.cwd().openFile(file_path, .{ .mode = std.fs.File.OpenMode.read_only });
    defer file.close();
    const file_size = try file.getEndPos();
    const buffer = try alloc.*.alloc(u8, file_size);
    _ = try file.readAll(buffer);
    return buffer;
}
