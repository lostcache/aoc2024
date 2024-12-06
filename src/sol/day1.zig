const std = @import("std");
const utils = @import("../utils.zig");

pub fn day1() !i64 {
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();
    var alloc = arena.allocator();
    const path = "./src/inputs/day1.txt";
    const buffer = try utils.readFile(path, &alloc);
    var lines = std.mem.split(u8, buffer, "\n");

    var firstNums = std.ArrayList(i64).init(alloc);
    defer firstNums.deinit();
    var secondNums = std.ArrayList(i64).init(alloc);
    defer secondNums.deinit();

    while (lines.next()) |line| {
        if (line.len == 0) continue; // Skip empty lines
        var nums = std.mem.split(u8, line, "   ");
        if (nums.next()) |num| {
            try firstNums.append(try std.fmt.parseInt(i64, num, 10));
        }
        if (nums.next()) |num| {
            try secondNums.append(try std.fmt.parseInt(i64, num, 10));
        }
    }

    std.sort.insertion(i64, firstNums.items[0..], {}, std.sort.asc(i64));
    std.sort.insertion(i64, secondNums.items[0..], {}, std.sort.asc(i64));

    var part1: i64 = 0;

    for (0..firstNums.items.len) |i| {
        const diff = firstNums.items[i] - secondNums.items[i];
        if (diff < 0) {
            part1 -= diff;
        } else {
            part1 += diff;
        }
    }

    std.debug.print("Day 1, Part 1: {d}\n", .{part1});

    var part2: i64 = 0;
    var counterMap = std.AutoHashMap(i64, u32).init(alloc);

    for (secondNums.items) |num| {
        const found = counterMap.get(num);
        if (found == null) {
            try counterMap.put(num, 1);
        } else {
            try counterMap.put(num, found.? + 1);
        }
    }

    for (firstNums.items) |num| {
        const found = counterMap.get(num);
        if (found != null) {
            part2 += num * found.?;
        }
    }

    std.debug.print("Day 1, Part 2: {d}\n", .{part2});

    return 0;
}
