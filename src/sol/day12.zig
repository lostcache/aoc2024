const std = @import("std");
const utils = @import("../utils.zig");

const Grid = std.ArrayList(std.ArrayList(u8));
const VisitedCache = std.AutoHashMap([2]usize, void);

fn getSides(i: i64, j: i64, plantType: u8, nRows: usize, nCols: usize, grid: *Grid, visited: *VisitedCache) usize {
    const aboveRow = i - 1;
    const belowRow = i + 1;
    const leftCol = j - 1;
    const rightCol = j + 1;

    var sides: usize = 0;

    // if found perimeter above
    if (aboveRow < 0 or plantType != grid.items[@as(usize, @intCast(aboveRow))].items[@as(usize, @intCast(j))]) {
        var left: i64 = j - 1;
        var right: i64 = j + 1;
        var isSideVisited = false;

        checkingLeft: while (left >= 0 and
            plantType == grid.items[@as(usize, @intCast(i))].items[@as(usize, @intCast(left))] and
            (aboveRow < 0 or plantType != grid.items[@as(usize, @intCast(aboveRow))].items[@as(usize, @intCast(left))]))
        {
            if (visited.get(.{ @as(usize, @intCast(i)), @as(usize, @intCast(left)) }) != null) {
                isSideVisited = true;
                break :checkingLeft;
            }
            left -= 1;
        }

        checkingRight: while (isSideVisited == false and
            right < nCols and
            plantType == grid.items[@as(usize, @intCast(i))].items[@as(usize, @intCast(right))] and
            (aboveRow < 0 or plantType != grid.items[@as(usize, @intCast(aboveRow))].items[@as(usize, @intCast(right))]))
        {
            if (visited.get(.{ @as(usize, @intCast(i)), @as(usize, @intCast(right)) }) != null) {
                isSideVisited = true;
                break :checkingRight;
            }
            right += 1;
        }

        if (isSideVisited == false) {
            sides += 1;
        }
    }

    // if found perimeter below
    if (belowRow >= nRows or plantType != grid.items[@as(usize, @intCast(belowRow))].items[@as(usize, @intCast(j))]) {
        var left: i64 = j - 1;
        var right: i64 = j + 1;
        var isSideVisited = false;

        checkingLeft: while (left >= 0 and
            plantType == grid.items[@as(usize, @intCast(i))].items[@as(usize, @intCast(left))] and
            (belowRow >= nRows or plantType != grid.items[@as(usize, @intCast(belowRow))].items[@as(usize, @intCast(left))]))
        {
            if (visited.get(.{ @as(usize, @intCast(i)), @as(usize, @intCast(left)) }) != null) {
                isSideVisited = true;
                break :checkingLeft;
            }
            left -= 1;
        }

        checkingRight: while (isSideVisited == false and
            right < nCols and
            plantType == grid.items[@as(usize, @intCast(i))].items[@as(usize, @intCast(right))] and
            (belowRow >= nRows or plantType != grid.items[@as(usize, @intCast(belowRow))].items[@as(usize, @intCast(right))]))
        {
            if (visited.get(.{ @as(usize, @intCast(i)), @as(usize, @intCast(right)) }) != null) {
                isSideVisited = true;
                break :checkingRight;
            }
            right += 1;
        }

        if (isSideVisited == false) {
            sides += 1;
        }
    }

    // if found perimeter left
    if (leftCol < 0 or plantType != grid.items[@as(usize, @intCast(i))].items[@as(usize, @intCast(leftCol))]) {
        var up: i64 = i - 1;
        var down: i64 = i + 1;
        var isSideVisited = false;

        checkingUp: while (up >= 0 and
            plantType == grid.items[@as(usize, @intCast(up))].items[@as(usize, @intCast(j))] and
            (leftCol < 0 or plantType != grid.items[@as(usize, @intCast(up))].items[@as(usize, @intCast(leftCol))]))
        {
            if (visited.get(.{ @as(usize, @intCast(up)), @as(usize, @intCast(j)) }) != null) {
                isSideVisited = true;
                break :checkingUp;
            }
            up -= 1;
        }

        checkingDown: while (isSideVisited == false and
            down < nRows and
            plantType == grid.items[@as(usize, @intCast(down))].items[@as(usize, @intCast(j))] and
            (leftCol < 0 or plantType != grid.items[@as(usize, @intCast(down))].items[@as(usize, @intCast(leftCol))]))
        {
            if (visited.get(.{ @as(usize, @intCast(down)), @as(usize, @intCast(j)) }) != null) {
                isSideVisited = true;
                break :checkingDown;
            }
            down += 1;
        }

        if (isSideVisited == false) {
            sides += 1;
        }
    }

    // if found perimeter right
    if (rightCol >= nCols or plantType != grid.items[@as(usize, @intCast(i))].items[@as(usize, @intCast(rightCol))]) {
        var up: i64 = i - 1;
        var down: i64 = i + 1;
        var isSideVisited = false;

        checkingUp: while (up >= 0 and
            plantType == grid.items[@as(usize, @intCast(up))].items[@as(usize, @intCast(j))] and
            (rightCol >= nCols or plantType != grid.items[@as(usize, @intCast(up))].items[@as(usize, @intCast(rightCol))]))
        {
            if (visited.get(.{ @as(usize, @intCast(up)), @as(usize, @intCast(j)) }) == null) {
                isSideVisited = true;
                break :checkingUp;
            }
            up -= 1;
        }

        checkingDown: while (isSideVisited == false and
            down < nRows and
            plantType == grid.items[@as(usize, @intCast(down))].items[@as(usize, @intCast(j))] and
            (rightCol >= nCols or plantType != grid.items[@as(usize, @intCast(down))].items[@as(usize, @intCast(rightCol))]))
        {
            if (visited.get(.{ @as(usize, @intCast(down)), @as(usize, @intCast(j)) }) == null) {
                isSideVisited = true;
                break :checkingDown;
            }
            down += 1;
        }

        if (isSideVisited == false) {
            sides += 1;
        }
    }

    return sides;
}

fn getPerimeter(i: i64, j: i64, plantType: u8, nRows: usize, nCols: usize, grid: *Grid) usize {
    const aboveRow = i - 1;
    const belowRow = i + 1;
    const leftCol = j - 1;
    const rightCol = j + 1;

    var perimeter: usize = 0;

    // if found perimeter above
    if (aboveRow < 0 or plantType != grid.items[@as(usize, @intCast(aboveRow))].items[@as(usize, @intCast(j))]) {
        perimeter += 1;
    }

    // if found perimeter below
    if (belowRow >= nRows or plantType != grid.items[@as(usize, @intCast(belowRow))].items[@as(usize, @intCast(j))]) {
        perimeter += 1;
    }

    // if found perimeter left
    if (leftCol < 0 or plantType != grid.items[@as(usize, @intCast(i))].items[@as(usize, @intCast(leftCol))]) {
        perimeter += 1;
    }

    // if found perimeter right
    if (rightCol >= nCols or plantType != grid.items[@as(usize, @intCast(i))].items[@as(usize, @intCast(rightCol))]) {
        perimeter += 1;
    }

    return perimeter;
}

fn getAreaAndPerimeterAndSides(i: i64, j: i64, plantType: u8, nRow: usize, nCols: usize, grid: *Grid, visited: *VisitedCache) ![3]usize {
    if (i < 0 or i >= nRow or j < 0 or j >= nCols) {
        return .{ 0, 0, 0 };
    }

    const rowIndex = @as(usize, @intCast(i));
    const colIndex = @as(usize, @intCast(j));
    const pos = [2]usize{ rowIndex, colIndex };

    if (visited.get(pos) != null) {
        return .{ 0, 0, 0 };
    }

    if (grid.items[rowIndex].items[colIndex] != plantType) {
        return .{ 0, 0, 0 };
    }

    _ = try visited.put(pos, {});

    var area: usize = 1;
    var perimeter: usize = getPerimeter(i, j, plantType, nRow, nCols, grid);
    var sides = getSides(i, j, plantType, nRow, nCols, grid, visited);

    const leftAreaAndPerimeter = try getAreaAndPerimeterAndSides(i, j - 1, plantType, nRow, nCols, grid, visited);
    const rightAreaAndPerimeter = try getAreaAndPerimeterAndSides(i, j + 1, plantType, nRow, nCols, grid, visited);
    const upAreaAndPerimeter = try getAreaAndPerimeterAndSides(i - 1, j, plantType, nRow, nCols, grid, visited);
    const downAreaAndPerimeter = try getAreaAndPerimeterAndSides(i + 1, j, plantType, nRow, nCols, grid, visited);

    area = area + leftAreaAndPerimeter[0] + rightAreaAndPerimeter[0] + upAreaAndPerimeter[0] + downAreaAndPerimeter[0];
    perimeter = perimeter + leftAreaAndPerimeter[1] + rightAreaAndPerimeter[1] + upAreaAndPerimeter[1] + downAreaAndPerimeter[1];
    sides = sides + leftAreaAndPerimeter[2] + rightAreaAndPerimeter[2] + upAreaAndPerimeter[2] + downAreaAndPerimeter[2];

    return .{ area, perimeter, sides };
}

pub fn day12() !void {
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();
    var alloc = arena.allocator();

    const path = "./src/inputs/day12.txt";
    const buffer = try utils.readFile(path, &alloc);

    var grid = std.ArrayList(std.ArrayList(u8)).init(alloc);
    var lines = std.mem.split(u8, buffer, "\n");

    while (lines.next()) |line| {
        if (line.len == 0) {
            continue;
        }
        var row = std.ArrayList(u8).init(alloc);
        for (line) |c| {
            try row.append(c);
        }
        try grid.append(row);
    }

    var visited = std.AutoHashMap([2]usize, void).init(alloc);
    defer visited.deinit();

    const nRows = grid.items.len;
    const nCols = grid.items[0].items.len;

    var cost: usize = 0;
    var discountedCost: usize = 0;
    for (grid.items, 0..) |row, i| {
        for (row.items, 0..) |plant, j| {
            const areaAndPerimeter = try getAreaAndPerimeterAndSides(@as(i64, @intCast(i)), @as(i64, @intCast(j)), plant, nRows, nCols, &grid, &visited);
            cost += areaAndPerimeter[0] * areaAndPerimeter[1];
            discountedCost += areaAndPerimeter[0] * areaAndPerimeter[2];
        }
    }

    std.debug.print("Part1: {d}\n", .{cost});
    std.debug.print("Part2: {d}\n", .{discountedCost});
}
