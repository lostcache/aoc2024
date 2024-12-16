const std = @import("std");
const utils = @import("../utils.zig");

const Dir = enum {
    Up,
    Right,
    Down,
    Left,
};

const Instructions = std.ArrayList(Dir);
const Grid = std.ArrayList(std.ArrayList(u8));

fn parseForWareHouse1(
    buffer: []const u8,
    grid: *Grid,
    instructions: *Instructions,
    alloc: *std.mem.Allocator,
) ![2]usize {
    var sections = std.mem.split(u8, buffer, "\n\n");

    const gridSection = sections.next().?;
    var roboPos: [2]usize = undefined;

    var gridLines = std.mem.split(u8, gridSection, "\n");
    const nCols = gridLines.peek().?.len;
    const nRows = gridLines.rest().len / nCols;

    for (0..nRows) |i| {
        const gridLine = gridLines.next().?;
        if (gridLine.len == 0) continue;
        var gridRow = try std.ArrayList(u8).initCapacity(alloc.*, nCols);
        for (gridLine, 0..) |c, j| {
            if (c == '@') {
                roboPos = .{ i, j };
            }
            try gridRow.append(c);
        }
        if (gridRow.items.len == 0) continue;
        try grid.append(gridRow);
    }

    const instructionSection = sections.next().?;
    var instructionLines = std.mem.split(u8, instructionSection, "\n");
    while (instructionLines.next()) |instructionLine| {
        for (instructionLine) |c| {
            const dir = switch (c) {
                '^' => Dir.Up,
                '>' => Dir.Right,
                'v' => Dir.Down,
                '<' => Dir.Left,
                else => unreachable,
            };
            try instructions.append(dir);
        }
    }

    return roboPos;
}

fn getGridVal(i: usize, j: usize, grid: *Grid) u8 {
    return grid.items[i].items[j];
}

fn executeInstructionsForWareHouse1(grid: *Grid, roboPos: [2]usize, instructions: *Instructions) void {
    const nRows = grid.items.len;
    const nCols = grid.items[0].items.len;
    const leftLimit = 0;
    const rightLimit = nCols - 1;
    const topLimit = 0;
    const bottomLimit = nRows - 1;
    var leftPtr = .{ roboPos[0], roboPos[1] };
    var rightPtr = .{ roboPos[0], roboPos[1] };

    std.debug.print("grid dim: ({d}, {d})\n", .{ nRows, nCols });

    for (instructions.*.items) |instruction| {
        switch (instruction) {
            Dir.Up => {
                while ((rightPtr[0] - 1) > topLimit and
                    getGridVal(rightPtr[0] - 1, rightPtr[1], grid) == 'O')
                {
                    rightPtr = .{ rightPtr[0] - 1, rightPtr[1] };
                }

                if (getGridVal(rightPtr[0] - 1, rightPtr[1], grid) == '#') {
                    rightPtr = .{ leftPtr[0], leftPtr[1] };
                    continue;
                }

                if (rightPtr[0] - 1 > topLimit) {
                    grid.items[leftPtr[0]].items[leftPtr[1]] = '.';
                    rightPtr = .{ rightPtr[0] - 1, rightPtr[1] };
                    leftPtr = .{ leftPtr[0] - 1, leftPtr[1] };
                    grid.items[leftPtr[0]].items[leftPtr[1]] = '@';
                }

                for (rightPtr[0]..leftPtr[0]) |i| {
                    grid.items[i].items[rightPtr[1]] = 'O';
                }
            },
            Dir.Right => {
                while ((rightPtr[1] + 1) < rightLimit and
                    getGridVal(rightPtr[0], rightPtr[1] + 1, grid) == 'O')
                {
                    rightPtr = .{ rightPtr[0], rightPtr[1] + 1 };
                }

                if (getGridVal(rightPtr[0], rightPtr[1] + 1, grid) == '#') {
                    rightPtr = .{ leftPtr[0], leftPtr[1] };
                    continue;
                }

                if (rightPtr[1] + 1 < rightLimit) {
                    grid.items[leftPtr[0]].items[leftPtr[1]] = '.';
                    rightPtr = .{ rightPtr[0], rightPtr[1] + 1 };
                    leftPtr = .{ leftPtr[0], leftPtr[1] + 1 };
                    grid.items[leftPtr[0]].items[leftPtr[1]] = '@';
                }

                for ((leftPtr[1] + 1)..(rightPtr[1] + 1)) |j| {
                    grid.items[rightPtr[0]].items[j] = 'O';
                }
            },
            Dir.Down => {
                while ((rightPtr[0] + 1) < bottomLimit and
                    getGridVal(rightPtr[0] + 1, rightPtr[1], grid) == 'O')
                {
                    rightPtr = .{ rightPtr[0] + 1, rightPtr[1] };
                }

                if (getGridVal(rightPtr[0] + 1, rightPtr[1], grid) == '#') {
                    rightPtr = .{ leftPtr[0], leftPtr[1] };
                    continue;
                }

                if (rightPtr[0] + 1 < bottomLimit) {
                    grid.items[leftPtr[0]].items[leftPtr[1]] = '.';
                    rightPtr = .{ rightPtr[0] + 1, rightPtr[1] };
                    leftPtr = .{ leftPtr[0] + 1, leftPtr[1] };
                    grid.items[leftPtr[0]].items[leftPtr[1]] = '@';
                }

                for ((leftPtr[0] + 1)..(rightPtr[0] + 1)) |i| {
                    grid.items[i].items[rightPtr[1]] = 'O';
                }
            },
            Dir.Left => {
                while ((rightPtr[1] - 1) > leftLimit and
                    getGridVal(rightPtr[0], rightPtr[1] - 1, grid) == 'O')
                {
                    rightPtr = .{ rightPtr[0], rightPtr[1] - 1 };
                }

                if (getGridVal(rightPtr[0], rightPtr[1] - 1, grid) == '#') {
                    rightPtr = .{ leftPtr[0], leftPtr[1] };
                    continue;
                }

                if (rightPtr[1] - 1 > leftLimit) {
                    grid.items[leftPtr[0]].items[leftPtr[1]] = '.';
                    rightPtr = .{ rightPtr[0], rightPtr[1] - 1 };
                    leftPtr = .{ leftPtr[0], leftPtr[1] - 1 };
                    grid.items[leftPtr[0]].items[leftPtr[1]] = '@';
                }

                for (rightPtr[1]..leftPtr[1]) |j| {
                    grid.items[rightPtr[0]].items[j] = 'O';
                }
            },
        }

        rightPtr = .{ leftPtr[0], leftPtr[1] };
    }
}

fn parseForWareHouse2(buffer: []const u8, wareHouse2: *Grid, alloc: *std.mem.Allocator) ![2]usize {
    var sections = std.mem.split(u8, buffer, "\n\n");

    const gridSection = sections.next().?;
    var roboPos: [2]usize = undefined;

    var gridLines = std.mem.split(u8, gridSection, "\n");
    const nCols = gridLines.peek().?.len;
    const nRows = gridLines.rest().len / nCols;

    for (0..nRows) |_| {
        const gridLine = gridLines.next().?;
        if (gridLine.len == 0) continue;
        var gridRow = try std.ArrayList(u8).initCapacity(alloc.*, nCols * 2);
        for (gridLine) |c| {
            switch (c) {
                '@' => {
                    try gridRow.append('@');
                    try gridRow.append('.');
                },
                'O' => {
                    try gridRow.append('[');
                    try gridRow.append(']');
                },
                '.' => {
                    try gridRow.append('.');
                    try gridRow.append('.');
                },
                '#' => {
                    try gridRow.append('#');
                    try gridRow.append('#');
                },
                else => unreachable,
            }
        }
        if (gridRow.items.len == 0) continue;
        try wareHouse2.append(gridRow);
    }

    for (wareHouse2.items, 0..) |row, i| {
        for (row.items, 0..) |c, j| {
            if (c == '@') {
                roboPos = .{ i, j };
            }
            std.debug.print("{c}", .{c});
        }
        std.debug.print("\n", .{});
    }

    return roboPos;
}

fn executeInstructionsForWareHouse2(grid: *Grid, roboPos: [2]usize, instructions: *Instructions) void {
    const nRows = grid.items.len;
    const nCols = grid.items[0].items.len;
    const leftLimit = 1;
    const rightLimit = 2 * (nCols - 1);
    const topLimit = 0;
    // const bottomLimit = nRows - 1;
    var currPos = .{ roboPos[0], roboPos[1] };
    std.debug.print("grid dim: ({d}, {d}) lol\n", .{ nRows, nCols });

    executingInstruction: for (instructions.*.items) |instruction| {
        std.debug.print("initial currPos: ({d}, {d}), inst: {any}\n", .{ currPos[0], currPos[1], instruction });
        switch (instruction) {
            Dir.Up => {
                if (currPos[0] - 1 == topLimit) {
                    continue :executingInstruction;
                }
                var leftPtr = currPos[1];
                var rightPtr = currPos[1];
                var topPtr = currPos[0];
                var minLeftPtr: usize = 0;
                var maxRightPtr: usize = 0;

                checkingBoxesAbove: while ((topPtr - 1) > topLimit) {
                    var newLeft: ?usize = null;
                    var newRight: ?usize = null;
                    for (leftPtr..rightPtr + 1) |j| {
                        if (newLeft == null and
                            (getGridVal(topPtr - 1, j, grid) == ']' or getGridVal(topPtr - 1, j, grid) == '['))
                        {
                            newLeft = j;
                        }

                        if (getGridVal(topPtr - 1, j, grid) == ']' or getGridVal(topPtr - 1, j, grid) == '[') {
                            newRight = j;
                        }
                    }

                    if (newLeft == null and newRight == null) {
                        break :checkingBoxesAbove;
                    }

                    topPtr = topPtr - 1;

                    if (getGridVal(topPtr, newLeft.?, grid) == ']') {
                        newLeft = newLeft.? - 1;
                    }
                    if (getGridVal(topPtr, newRight.?, grid) == '[') {
                        newRight = newRight.? + 1;
                    }

                    leftPtr = newLeft.?;
                    if (leftPtr < minLeftPtr) {
                        minLeftPtr = leftPtr;
                    }

                    rightPtr = newRight.?;
                    if (rightPtr > maxRightPtr) {
                        maxRightPtr = rightPtr;
                    }
                }

                var iterPtr: usize = topPtr - 1;
                while (iterPtr < currPos[0]) : (iterPtr += 1) {
                    for (minLeftPtr..maxRightPtr + 1) |j| {
                        if (getGridVal(iterPtr, j, grid) == '#' and
                            (getGridVal(iterPtr + 1, j, grid) == '[' or getGridVal(iterPtr + 1, j, grid) == ']' or getGridVal(iterPtr + 1, j, grid) == '@'))
                        {
                            continue :executingInstruction;
                        }
                    }
                }

                iterPtr = topPtr - 1;
                while (iterPtr < currPos[0]) : (iterPtr += 1) {
                    for (minLeftPtr..maxRightPtr + 1) |j| {
                        if (getGridVal(iterPtr + 1, j, grid) == '[' or getGridVal(iterPtr + 1, j, grid) == ']' or getGridVal(iterPtr + 1, j, grid) == '@') {
                            grid.items[iterPtr].items[j] = grid.items[iterPtr + 1].items[j];
                            grid.items[iterPtr + 1].items[j] = '.';
                        }
                    }
                }

                currPos = .{ currPos[0] - 1, currPos[1] };
            },
            Dir.Right => {
                var rightPtr = currPos[1];

                while ((rightPtr + 1) < rightLimit and
                    (getGridVal(currPos[0], rightPtr + 1, grid) == ']' or
                    getGridVal(currPos[0], rightPtr + 1, grid) == '['))
                {
                    rightPtr = rightPtr + 1;
                }

                if (getGridVal(currPos[0], rightPtr + 1, grid) == '#') {
                    continue;
                }

                var iterPtr: usize = rightPtr + 1;
                while (iterPtr > currPos[1]) : (iterPtr -= 1) {
                    grid.items[currPos[0]].items[iterPtr] = grid.items[currPos[0]].items[iterPtr - 1];
                }
                grid.items[currPos[0]].items[currPos[1]] = '.';

                currPos = .{ currPos[0], currPos[1] + 1 };
            },
            Dir.Down => {
                // while ((rightPtr[0] + 1) < bottomLimit and
                //     getGridVal(rightPtr[0] + 1, rightPtr[1], grid) == 'O')
                // {
                //     rightPtr = .{ rightPtr[0] + 1, rightPtr[1] };
                // }

                // if (getGridVal(rightPtr[0] + 1, rightPtr[1], grid) == '#') {
                //     rightPtr = .{ leftPtr[0], leftPtr[1] };
                //     continue;
                // }

                // if (rightPtr[0] + 1 < bottomLimit) {
                //     grid.items[leftPtr[0]].items[leftPtr[1]] = '.';
                //     rightPtr = .{ rightPtr[0] + 1, rightPtr[1] };
                //     leftPtr = .{ leftPtr[0] + 1, leftPtr[1] };
                //     grid.items[leftPtr[0]].items[leftPtr[1]] = '@';
                // }

                // for ((leftPtr[0] + 1)..(rightPtr[0] + 1)) |i| {
                //     grid.items[i].items[rightPtr[1]] = 'O';
                // }
            },
            Dir.Left => {
                var leftPtr = currPos[1];

                while ((leftPtr - 1) > leftLimit and
                    (getGridVal(currPos[0], leftPtr - 1, grid) == ']' or
                    getGridVal(currPos[0], leftPtr - 1, grid) == '['))
                {
                    leftPtr = leftPtr - 1;
                }

                if (getGridVal(currPos[0], leftPtr - 1, grid) == '#') {
                    continue;
                }

                var iterPtr: usize = leftPtr - 1;
                while (iterPtr < currPos[1]) : (iterPtr += 1) {
                    grid.items[currPos[0]].items[iterPtr] = grid.items[currPos[0]].items[iterPtr + 1];
                }
                grid.items[currPos[0]].items[currPos[1]] = '.';
                currPos = .{ currPos[0], currPos[1] - 1 };
            },
        }
    }
}

pub fn day15() !void {
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();
    var alloc = arena.allocator();

    const path = "./src/inputs/day15.txt";
    const buffer = try utils.readFile(path, &alloc);

    var wareHouse1 = Grid.init(alloc);
    var wareHouse2 = Grid.init(alloc);

    var instructions = Instructions.init(alloc);

    const roboPos1 = try parseForWareHouse1(buffer, &wareHouse1, &instructions, &alloc);
    _ = roboPos1;

    // executeInstructionsForWareHouse1(&wareHouse1, roboPos1, &instructions);

    // var part1: usize = 0;
    // for (wareHouse1.items, 0..) |row, i| {
    //     for (row.items, 0..) |c, j| {
    //         part1 += if (c == 'O') (i * 100) + j else 0;
    //     }
    // }

    // std.debug.print("part1: {d}\n", .{part1});

    const robotPos2 = try parseForWareHouse2(buffer, &wareHouse2, &alloc);
    std.debug.print("robotPos2: ({d}, {d})\n", .{ robotPos2[0], robotPos2[1] });

    executeInstructionsForWareHouse2(&wareHouse2, robotPos2, &instructions);
}
