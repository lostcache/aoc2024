const std = @import("std");
const utils = @import("../utils.zig");

fn parseInput(buffer: *[]const u8, coords: *std.ArrayList([2]i32)) !void {
    var lines = std.mem.split(u8, buffer.*, "\n");
    while (lines.next()) |line| {
        if (line.len == 0) continue;

        var nums = std.mem.split(u8, line, ",");
        const x = try std.fmt.parseInt(i32, nums.next().?, 10);
        const y = try std.fmt.parseInt(i32, nums.next().?, 10);
        try coords.append(.{ x, y });
    }
}

const dirs: [4][2]i8 = .{
    .{ -1, 0 },
    .{ 0, -1 },
    .{ 1, 0 },
    .{ 0, 1 },
};

fn compareFn(_: void, a: [3]i32, b: [3]i32) std.math.Order {
    if (a[2] < b[2]) return .lt;
    if (a[2] > b[2]) return .gt;
    return .eq;
}

fn getObstaclesUptoNBytes(
    seconds: usize,
    coords: *std.ArrayList([2]i32),
    obstacleMap: *std.AutoHashMap([2]i32, void),
) !void {
    for (0..seconds + 1) |i| {
        try obstacleMap.put(coords.items[i], {});
    }
}

fn dikstrasShortestPath(maxX: i32, maxY: i32, obstacles: *std.AutoHashMap([2]i32, void), alloc: *std.mem.Allocator) !i32 {
    var minHeap = std.PriorityQueue([3]i32, void, compareFn).init(alloc.*, {});
    var costMap = std.AutoHashMap([2]i32, i32).init(alloc.*);

    try minHeap.add(.{ 0, 0, 0 });

    while (minHeap.removeOrNull()) |currState| {
        const currX = currState[0];
        const currY = currState[1];
        const currCost = currState[2];

        if (currX == maxX and currY == maxY) return currCost;

        for (dirs) |dir| {
            const nextX = currX + dir[0];
            const nextY = currY + dir[1];

            if (nextX < 0 or nextY < 0 or nextX > maxX or nextY > maxY) continue;

            const nextCost = currCost + 1;

            if (obstacles.get(.{ nextX, nextY })) |_| continue;

            if (costMap.get(.{ nextX, nextY })) |cost| {
                if (nextCost >= cost) continue;
            }

            try minHeap.add(.{ nextX, nextY, nextCost });
            try costMap.put(.{ nextX, nextY }, nextCost);
        }
    }

    return std.math.maxInt(i32);
}

pub fn day18() !void {
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();
    var alloc = arena.allocator();

    const path = "./src/inputs/day18.txt";

    var buffer = try utils.readFile(path, &alloc);
    var coords = std.ArrayList([2]i32).init(alloc);
    try parseInput(&buffer, &coords);

    const maxX: i32 = 70;
    const maxY: i32 = 70;

    var left: usize = 0;
    var right: usize = 3449;
    while (left < right) {
        var iterArena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
        defer iterArena.deinit();
        var iterAlloc = arena.allocator();

        const middle = (left + right) / 2;
        var corruptedAfterNBytes = std.AutoHashMap([2]i32, void).init(iterAlloc);
        try getObstaclesUptoNBytes(middle, &coords, &corruptedAfterNBytes);
        const minCost = try dikstrasShortestPath(maxX, maxY, &corruptedAfterNBytes, &iterAlloc);
        std.debug.print("left: {}, right: {}, middle: {any}, cost: {}\n", .{ left, right, middle, minCost });
        if (minCost == std.math.maxInt(i32)) {
            right = middle - 1;
        } else {
            left = middle + 1;
        }
    }

    std.debug.print("index: {}, Part2: {any}\n", .{ right, coords.items[right] });
}
