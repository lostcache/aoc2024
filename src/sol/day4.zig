const std = @import("std");
const utils = @import("../utils.zig");

pub fn day4() !void {
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();
    var alloc = arena.allocator();

    const path = "./src/inputs/day4.txt";

    const buffer = try utils.readFile(path, &alloc);
    const dirs: [8][2]i64 = .{
        .{ 1, 0 },
        .{ 0, 1 },
        .{ -1, 0 },
        .{ 0, -1 },
        .{ -1, -1 },
        .{ 1, 1 },
        .{ 1, -1 },
        .{ -1, 1 },
    };
    const pattern = "XMAS";
    var lines = std.mem.split(u8, buffer, "\n");
    const nCols = lines.peek().?.len;
    const nRows = lines.rest().len / (nCols + 1);

    var grid = try std.ArrayList(std.ArrayList(u8)).initCapacity(alloc, nRows);

    for (0..nRows) |_| {
        const row = lines.next().?;
        var gridRow = try std.ArrayList(u8).initCapacity(alloc, nCols);
        for (0..nCols) |j| {
            try gridRow.append(row[j]);
        }
        try grid.append(gridRow);
    }

    var xmasFound: usize = 0;
    var x_masFound: usize = 0;

    for (0..nRows) |i| {
        const row = grid.items[i];
        for (0..nCols) |j| {
            const char = row.items[j];
            if (char == 'X') {
                for (dirs) |dir| {
                    var patternPtr: usize = 0;
                    var currRow = @as(i64, @intCast(i));
                    var currCol = @as(i64, @intCast(j));
                    while (currRow >= 0 and currRow < nRows and currCol >= 0 and currCol < nCols and patternPtr < pattern.len and (grid.items[@as(usize, @intCast(currRow))]).items[@as(usize, @intCast(currCol))] == pattern[patternPtr]) {
                        currRow = currRow + dir[0];
                        currCol = currCol + dir[1];
                        patternPtr += 1;
                    }
                    if (patternPtr == pattern.len) {
                        xmasFound += 1;
                    }
                }
            }
        }
    }

    for (0..nRows) |i| {
        const row = grid.items[i];
        for (0..nCols) |j| {
            const char = row.items[j];
            if (char == 'A') {
                const currRow = @as(i64, @intCast(i));
                const currCol = @as(i64, @intCast(j));
                const prevRow = currRow - 1;
                const nextRow = currRow + 1;
                const prevCol = currCol - 1;
                const nextCol = currCol + 1;
                if (prevRow >= 0 and nextRow < nRows and prevCol >= 0 and nextCol < nCols) {
                    const prevRowIndex = @as(usize, @intCast(prevRow));
                    const nextRowIndex = @as(usize, @intCast(nextRow));
                    const prevColIndex = @as(usize, @intCast(prevCol));
                    const nextColIndex = @as(usize, @intCast(nextCol));
                    if (((grid.items[prevRowIndex].items[prevColIndex] == 'M' or grid.items[prevRowIndex].items[prevColIndex] == 'S') and (grid.items[nextRowIndex].items[nextColIndex] == 'S' or grid.items[nextRowIndex].items[nextColIndex] == 'M')) and (grid.items[nextRowIndex].items[nextColIndex] != grid.items[prevRowIndex].items[prevColIndex])) {
                        if (((grid.items[nextRowIndex].items[prevColIndex] == 'M' or grid.items[nextRowIndex].items[prevColIndex] == 'S') and (grid.items[prevRowIndex].items[nextColIndex] == 'S' or grid.items[prevRowIndex].items[nextColIndex] == 'M')) and (grid.items[nextRowIndex].items[prevColIndex] != grid.items[prevRowIndex].items[nextColIndex])) {
                            x_masFound += 1;
                        }
                    }
                }
            }
        }
    }

    std.debug.print("part 1: {}\n", .{xmasFound});
    std.debug.print("part 2: {}\n", .{x_masFound});
}
