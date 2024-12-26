const std = @import("std");
const utils = @import("../utils.zig");

fn parseInput(buffer: *[]const u8, nums: *std.ArrayList(i8)) !void {
    var numIter = std.mem.split(u8, buffer.*, "\n");

    while (numIter.next()) |numStr| {
        if (numStr.len == 0) continue;
        try nums.append(try std.fmt.parseInt(i8, numStr, 10));
    }
}

fn getSecret(num: i8) i8 {
    var initialNum = num;

    initialNum = @mod(((initialNum * 64) ^ initialNum), 16777216);

    initialNum = @mod(((initialNum / 32) ^ initialNum), 16777216);

    initialNum = @mod(((initialNum * 2048) ^ initialNum), 16777216);

    return initialNum;
}

fn processData(num: i8, alloc: *std.mem.Allocator) !void {
    var diffArr = try std.ArrayList(i8).initCapacity(alloc.*, 2000);
    var currNum = num;
    for (0..2000) |_| {
        const secret = getSecret(currNum);
        diffArr.append(secret - currNum);
        currNum = secret;
    }
}

pub fn day22() !void {
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();
    var alloc = arena.allocator();

    const path = "./src/inputs/day22.txt";

    var buffer = try utils.readFile(path, &alloc);
    var nums = std.ArrayList(i8).init(alloc);

    try parseInput(&buffer, &nums);

    var part1: usize = 0;
    for (nums.items) |num| {
        part1 += getFinalSecret(num);
    }

    std.debug.print("Part1: {}\n", .{part1});

    for (nums.items) |num| {
        try processData(num, &alloc);
    }
}
