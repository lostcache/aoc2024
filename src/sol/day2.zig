const std = @import("std");
const utils = @import("../utils.zig");

const Ord = enum {
    Asc,
    Desc,
    Dunno,
};

fn isWithinTollerance(levelArr: *std.ArrayList(i64)) !bool {
    var prevLevel = levelArr.items[0];

    var ord: Ord = Ord.Dunno;

    for (levelArr.items[1..]) |currLevel| {
        const diff = currLevel - prevLevel;

        if (diff == 0) {
            return false;
        }

        if (diff > 3 or diff < -3) {
            return false;
        }

        switch (ord) {
            .Dunno => {
                if (diff > 0) {
                    ord = Ord.Asc;
                } else {
                    ord = Ord.Desc;
                }
            },
            .Asc => {
                if (diff < 0) {
                    return false;
                }
            },
            .Desc => {
                if (diff > 0) {
                    return false;
                }
            },
        }

        prevLevel = currLevel;
    }

    return true;
}

pub fn day2() !void {
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();
    var alloc = arena.allocator();

    const path = "./src/inputs/day2.txt";

    const buffer = try utils.readFile(path, &alloc);
    var part1: i64 = 0;
    var part2: i64 = 0;

    var lines = std.mem.split(u8, buffer, "\n");
    while (lines.next()) |line| {
        if (line.len == 0) continue;

        var levelsArr = std.ArrayList(i64).init(alloc);
        var levels = std.mem.split(u8, line, " ");
        while (levels.next()) |level| {
            const persedLevel = try std.fmt.parseInt(i64, level, 10);
            _ = try levelsArr.append(persedLevel);
        }

        if (levelsArr.items.len < 2) {
            part1 += 1;
            part2 += 1;
            continue;
        }

        const isWithinTolleranceForPart1 = try isWithinTollerance(&levelsArr);
        if (isWithinTolleranceForPart1) {
            part1 += 1;
            part2 += 1;
        } else {
            for (0..levelsArr.items.len) |index| {
                var filteredArr = std.ArrayList(i64).init(alloc);
                for (0..levelsArr.items.len) |i| {
                    if (i == index) continue;
                    _ = try filteredArr.append(levelsArr.items[i]);
                }
                const isWithinTolleranceForPart2 = try isWithinTollerance(&filteredArr);
                if (isWithinTolleranceForPart2) {
                    part2 += 1;
                    break;
                }
            }
        }

        // const isWithinTolleranceForPart2 = try isWithinTollerance(line, 1);
        // if (isWithinTolleranceForPart2) part2 += 1;

        // var faults: i32 = 0;

        // var left: usize = 0;
        // var right: usize = 1;
        // var order: Ord = Ord.Dunno;

        // while (right < levelsArr.items.len) {
        //     const leftVal = levelsArr.items[left];
        //     const rightVal = levelsArr.items[right];

        //     if (order == Ord.Dunno) {
        //         if (leftVal > rightVal) {
        //             order = Ord.Desc;
        //         } else if (leftVal < rightVal) {
        //             order = Ord.Asc;
        //         } else {
        //             if (left > 0) {
        //                 left -= 1;
        //             } else {
        //                 right += 1;
        //             }
        //             faults += 1;
        //             continue;
        //         }
        //     }

        //     if (leftVal - rightVal > 3 or leftVal - rightVal < -3) {
        //         if (left > 0) {
        //             left -= 1;
        //         } else {
        //             right += 1;
        //         }
        //         order = Ord.Dunno;
        //         faults += 1;
        //         continue;
        //     }

        //     if (leftVal > rightVal and order == Ord.Asc) {
        //         if (left > 0) {
        //             left -= 1;
        //         } else {
        //             right += 1;
        //         }
        //         order = Ord.Dunno;
        //         faults += 1;
        //         continue;
        //     }

        //     if (leftVal < rightVal and order == Ord.Desc) {
        //         if (left > 0) {
        //             left -= 1;
        //         } else {
        //             right += 1;
        //         }
        //         order = Ord.Dunno;
        //         faults += 1;
        //         continue;
        //     }

        //     left += 1;
        //     right += 1;
        // }

    }

    std.debug.print("Part 1: {}\n", .{part1});

    std.debug.print("Part 2: {}\n", .{part2});
}
