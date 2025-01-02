const std = @import("std");
const utils = @import("../utils.zig");
const Map = std.AutoHashMap;

fn parseInput(
    buffer: *const []const u8,
    locks: *Map([5]usize, void),
    keys: *Map([5]usize, void),
) !void {
    var keyOrLocksIter = std.mem.split(u8, buffer.*, "\n\n");

    while (keyOrLocksIter.next()) |keyOrLock| {
        var lens: [5]usize = .{ 0, 0, 0, 0, 0 };
        var rowIter = std.mem.split(u8, keyOrLock, "\n");
        const firstRow = rowIter.next().?;

        var allHash = true;
        for (firstRow, 0..) |c, j| {
            if (c == '#') {
                lens[j] += 1;
            } else {
                allHash = false;
            }
        }

        while (rowIter.next()) |row| {
            for (row, 0..) |c, j| {
                if (c == '#') lens[j] += 1;
            }
        }

        if (allHash == true) {
            try locks.put(lens, {});
        } else {
            try keys.put(lens, {});
        }
    }
}

pub fn day25() !void {
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();
    var alloc = arena.allocator();

    const path = "./src/inputs/day25.txt";

    const buffer = try utils.readFile(path, &alloc);

    var locks = Map([5]usize, void).init(alloc);
    var keys = Map([5]usize, void).init(alloc);
    const totalHeight: usize = 7;
    var matches: usize = 0;

    try parseInput(&buffer, &locks, &keys);

    var lockIter = locks.iterator();
    while (lockIter.next()) |lock| {
        const lockLens = lock.key_ptr.*;

        var keyIter = keys.iterator();
        keyLoop: while (keyIter.next()) |key| {
            const keyLens = key.key_ptr.*;
            for (keyLens, 0..) |len, j| {
                if (len + lockLens[j] > totalHeight) continue :keyLoop;
            }

            matches += 1;
        }
    }

    std.debug.print("Part1: {}\n", .{matches});
}
