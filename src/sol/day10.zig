const std = @import("std");
const utils = @import("../utils.zig");

fn dfsSearch(nRows: usize, nCols: usize, i: i64, j: i64, prevVal: i64, grid: *std.ArrayList(std.ArrayList(i64)), visited: *std.AutoHashMap([2]i64, void)) !usize {
    if (i < 0 or i >= nRows or j < 0 or j >= nCols) {
        return 0;
    }

    const rowIndex = @as(usize, @intCast(i));
    const colIndex = @as(usize, @intCast(j));

    if (grid.items[rowIndex].items[colIndex] - prevVal != 1) {
        return 0;
    }

    // const maybeVisited = visited.get(.{ i, j });
    // if (maybeVisited != null) {
    //     return 0;
    // }

    if (grid.items[rowIndex].items[colIndex] == 9) {
        _ = try visited.put(.{ i, j }, {});
        return 1;
    }

    const left = try dfsSearch(nRows, nCols, i, j - 1, grid.items[rowIndex].items[colIndex], grid, visited);
    const right = try dfsSearch(nRows, nCols, i, j + 1, grid.items[rowIndex].items[colIndex], grid, visited);
    const up = try dfsSearch(nRows, nCols, i - 1, j, grid.items[rowIndex].items[colIndex], grid, visited);
    const down = try dfsSearch(nRows, nCols, i + 1, j, grid.items[rowIndex].items[colIndex], grid, visited);

    return left + right + up + down;
}

fn getTotalPossibleTrails(nRows: usize, nCols: usize, i: i64, j: i64, grid: *std.ArrayList(std.ArrayList(i64)), visited: *std.AutoHashMap([2]i64, void)) !usize {
    return try dfsSearch(nRows, nCols, i, j + 1, 0, grid, visited) +
        try dfsSearch(nRows, nCols, i, j - 1, 0, grid, visited) +
        try dfsSearch(nRows, nCols, i + 1, j, 0, grid, visited) +
        try dfsSearch(nRows, nCols, i - 1, j, 0, grid, visited);
}

pub fn day10() !void {
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();
    var alloc = arena.allocator();

    const path = "./src/inputs/day10.txt";
    const buffer = try utils.readFile(path, &alloc);
    const dirs: [4][2]i64 = .{
        .{ 1, 0 },
        .{ 0, 1 },
        .{ -1, 0 },
        .{ 0, -1 },
        // .{ -1, -1 },
        // .{ 1, 1 },
        // .{ 1, -1 },
        // .{ -1, 1 },
    };
    _ = dirs;

    var lines = std.mem.split(u8, buffer, "\n");
    const nCols = lines.peek().?.len;
    const nRows = lines.rest().len / (nCols + 1);

    var grid = try std.ArrayList(std.ArrayList(i64)).initCapacity(alloc, nRows);
    for (0..nRows) |_| {
        const row = lines.next().?;
        var gridRow = try std.ArrayList(i64).initCapacity(alloc, nCols);
        for (0..nCols) |j| {
            const slice: [1]u8 = .{row[j]};
            try gridRow.append(@as(i64, @intCast(try std.fmt.parseInt(u8, &slice, 10))));
        }
        try grid.append(gridRow);
    }

    var totalPossibleTrails: usize = 0;
    for (0..nRows) |i| {
        for (0..nCols) |j| {
            if (grid.items[i].items[j] == 0) {
                var visited = std.AutoHashMap([2]i64, void).init(alloc);
                const curr = try getTotalPossibleTrails(
                    nRows,
                    nCols,
                    @as(i64, @intCast(i)),
                    @as(i64, @intCast(j)),
                    &grid,
                    &visited,
                );
                totalPossibleTrails += curr;
                // break :outer;
            }
        }
    }

    std.debug.print("Part1: {any}\n", .{totalPossibleTrails});
}
