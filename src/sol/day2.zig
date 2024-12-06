const std = @import("std");
const utils = @import("../utils.zig");

const Ord = enum {
    Asc,
    Desc,
    Dunno,
};

fn isWithinTollerance(line: []const u8, tollerance: i32) !bool {
    var faults: i32 = 0;
    var levels = std.mem.split(u8, line, " ");
    const maybeFirstLevel = levels.next();
    if (maybeFirstLevel == null) return false;

    var prevLevel = try std.fmt.parseInt(i64, maybeFirstLevel.?, 10);

    var ord: Ord = Ord.Dunno;
    var ordChangeCounter: u32 = 0;

    while (levels.next()) |level| {
        if (faults > tollerance) return false;

        const currLevel = try std.fmt.parseInt(i64, level, 10);

        const diff = currLevel - prevLevel;

        if (diff == 0) {
            faults += 1;
            continue;
        }

        if (diff > 3 or diff < -3) {
            faults += 1;
            continue;
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
                    ord = Ord.Desc;
                    ordChangeCounter += 1;
                    if (ordChangeCounter == 2) {
                        ordChangeCounter = 0;
                        faults += 1;
                        continue;
                    }
                }
            },
            .Desc => {
                if (diff > 0) {
                    ord = Ord.Asc;
                    ordChangeCounter += 1;
                    if (ordChangeCounter == 2) {
                        ordChangeCounter = 0;
                        faults += 1;
                        continue;
                    }
                }
            },
        }

        prevLevel = currLevel;
    }

    if (faults > tollerance) return false;

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

        const isWithinTolleranceForPart1 = try isWithinTollerance(line, 0);
        if (isWithinTolleranceForPart1) part1 += 1;

        const isWithinTolleranceForPart2 = try isWithinTollerance(line, 1);
        if (isWithinTolleranceForPart2) part2 += 1;
    }

    std.debug.print("Part 1: {}\n", .{part1});
    std.debug.print("Part 2: {}\n", .{part2});
}
