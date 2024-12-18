const std = @import("std");
const utils = @import("../utils.zig");

fn parseInput(buffer: []const u8, roboPos: *std.ArrayList([2]i64), roboVel: *std.ArrayList([2]i64)) !void {
    var lines = std.mem.split(u8, buffer, "\n");

    while (lines.next()) |line| {
        if (line.len == 0) {
            continue;
        }

        var left: usize = 0;
        var right: usize = 0;

        while (std.ascii.isDigit(line[right]) == false) {
            left += 1;
            right += 1;
        }
        while (std.ascii.isDigit(line[right])) {
            right += 1;
        }
        const x = try std.fmt.parseInt(i64, line[left..right], 10);
        left = right;

        while (std.ascii.isDigit(line[right]) == false) {
            left += 1;
            right += 1;
        }
        while (std.ascii.isDigit(line[right])) {
            right += 1;
        }
        const y = try std.fmt.parseInt(i64, line[left..right], 10);
        left = right;

        var isNegative = false;
        while (std.ascii.isDigit(line[right]) == false) {
            if (line[right] == '-') {
                isNegative = true;
            }
            left += 1;
            right += 1;
        }
        while (std.ascii.isDigit(line[right])) {
            right += 1;
        }
        var vx = try std.fmt.parseInt(i64, line[left..right], 10);
        if (isNegative) {
            vx = -vx;
        }
        left = right;

        isNegative = false;
        while (std.ascii.isDigit(line[right]) == false) {
            if (line[right] == '-') {
                isNegative = true;
            }
            left += 1;
            right += 1;
        }
        while (right < line.len and std.ascii.isDigit(line[right])) {
            right += 1;
        }
        var vy = try std.fmt.parseInt(i64, line[left..right], 10);
        if (isNegative) {
            vy = -vy;
        }

        try roboPos.append(.{ x, y });
        try roboVel.append(.{ vx, vy });
    }
}

pub fn day14() !void {
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();
    var alloc = arena.allocator();
    const stdin = std.io.getStdIn().reader();

    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer std.debug.assert(gpa.deinit() == .ok);
    const gpaAllocator = gpa.allocator();

    const path = "./src/inputs/day14.txt";
    const buffer = try utils.readFile(path, &alloc);

    var roboPos = std.ArrayList([2]i64).init(alloc);
    defer roboPos.deinit();
    var roboVel = std.ArrayList([2]i64).init(alloc);
    defer roboVel.deinit();

    try parseInput(buffer, &roboPos, &roboVel);

    const nRobots: usize = roboPos.items.len;
    const nSteps: i64 = 1;
    const dimX: i64 = 101;
    const dimY: i64 = 103;

    for (1..10000) |step| {
        var userInput: [10]u8 = undefined;
        const inLen = try stdin.read(&userInput);

        if (std.mem.eql(u8, userInput[0..inLen], "q\n")) {
            break;
        }

        var grid = try std.ArrayList(std.ArrayList(u64)).initCapacity(gpaAllocator, 103);

        for (0..dimY) |_| {
            var row = try std.ArrayList(u64).initCapacity(gpaAllocator, 101);
            for (0..dimX) |_| {
                try row.append(0);
            }
            try grid.append(row);
        }

        std.debug.print("Step {}\n", .{step});
        for (0..nRobots) |i| {
            const newPosX = @mod(roboPos.items[i][0] + nSteps * roboVel.items[i][0], dimX);
            const newPosY = @mod(roboPos.items[i][1] + nSteps * roboVel.items[i][1], dimY);
            grid.items[@as(usize, @intCast(newPosY))].items[@as(usize, @intCast(newPosX))] += 1;
            roboPos.items[i] = .{ newPosX, newPosY };
        }

        for (grid.items) |row| {
            for (row.items) |cell| {
                if (cell > 0) {
                    std.debug.print("{}", .{cell});
                } else {
                    std.debug.print(".", .{});
                }
            }
            std.debug.print("\n", .{});
        }
        std.debug.print("##############################################################################################################\n", .{});

        // deinit grid
        for (grid.items) |row| {
            row.deinit();
        }

        grid.deinit();
    }

    // var quad1Count: usize = 0;
    // var quad2Count: usize = 0;
    // var quad3Count: usize = 0;
    // var quad4Count: usize = 0;

    // for (0..nRobots) |i| {
    //     const newPosX = @mod(roboPos.items[i][0] + nSteps * roboVel.items[i][0], dimX);
    //     const newPosY = @mod(roboPos.items[i][1] + nSteps * roboVel.items[i][1], dimY);

    //     std.debug.print("Robot {}: ({}, {}) -> ({}, {})\n", .{ i, roboPos.items[i][0], roboPos.items[i][1], newPosX, newPosY });

    //     if (newPosX == 50 or newPosY == 51) {
    //         continue;
    //     }

    //     // Adjust for quadrants based on 0-based grid logic
    //     if (newPosX < dimX / 2 and newPosY < dimY / 2) {
    //         quad1Count += 1; // Top-left
    //     } else if (newPosX >= dimX / 2 and newPosY < dimY / 2) {
    //         quad2Count += 1; // Top-right
    //     } else if (newPosX >= dimX / 2 and newPosY >= dimY / 2) {
    //         quad3Count += 1; // Bottom-right
    //     } else {
    //         quad4Count += 1; // Bottom-left
    //     }
    // }

    // std.debug.print("Quad 1: {}, Quad 2: {}, Quad 3: {}, Quad 4: {}\n", .{ quad1Count, quad2Count, quad3Count, quad4Count });

    // std.debug.print("Part 1: {}\n", .{quad1Count * quad2Count * quad3Count * quad4Count});
}
