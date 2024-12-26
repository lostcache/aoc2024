const std = @import("std");
const utils = @import("../utils.zig");

fn parseInput(buffer: *[]const u8, nums: *std.ArrayList(i64)) !void {
    var numIter = std.mem.split(u8, buffer.*, "\n");

    while (numIter.next()) |numStr| {
        if (numStr.len == 0) continue;
        try nums.append(try std.fmt.parseInt(i64, numStr, 10));
    }
}

fn getSecret(num: i64) i64 {
    var initialNum = num;

    initialNum = @mod(((initialNum * 64) ^ initialNum), 16777216);

    initialNum = @mod((@divTrunc(initialNum, 32) ^ initialNum), 16777216);

    initialNum = @mod(((initialNum * 2048) ^ initialNum), 16777216);

    return initialNum;
}

fn processData(num: i64, diffArr: *std.ArrayList(i8), seqMap: *std.AutoHashMap([4]i8, usize)) !void {
    var currNum = num;
    var currNumOnesDigit = @mod(currNum, 10);
    for (0..2000) |i| {
        const secret = getSecret(currNum);
        const secretOnesDigit = @mod(secret, 10);
        try diffArr.append(@as(i8, @intCast(secretOnesDigit - currNumOnesDigit)));
        currNum = secret;
        currNumOnesDigit = secretOnesDigit;

        if (@mod(i + 1, 4) == 0) {
            const seq = .{ diffArr.items[i - 3], diffArr.items[i - 2], diffArr.items[i - 1], diffArr.items[i] };
            try seqMap.put(seq, i);
        }
    }
}

pub fn day22() !void {
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();
    var alloc = arena.allocator();

    const path = "./src/inputs/day22.txt";

    var buffer = try utils.readFile(path, &alloc);
    var nums = std.ArrayList(i64).init(alloc);

    try parseInput(&buffer, &nums);

    var diffData = try std.ArrayList(std.ArrayList(i8)).initCapacity(alloc, 1800);
    var seqMaps = try std.ArrayList(std.AutoHashMap([4]i8, usize)).initCapacity(alloc, 1800);
    for (nums.items) |num| {
        var diffArr = try std.ArrayList(i8).initCapacity(alloc, 2000);
        var seqMap = std.AutoHashMap([4]i8, usize).init(alloc);
        try processData(num, &diffArr, &seqMap);
        try diffData.append(diffArr);
        try seqMaps.append(seqMap);
    }
}
