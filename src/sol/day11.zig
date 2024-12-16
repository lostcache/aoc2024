const std = @import("std");
const utils = @import("../utils.zig");

const Stone = struct {
    value: u64,
    strValue: []u8,
    prev: ?*Stone,
    next: ?*Stone,
};

fn getStonesAfterNBlinks(stoneValStr: []const u8, blinks: usize) !usize {
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();
    var alloc = arena.allocator();

    var firstStone = try alloc.create(Stone);
    firstStone.* = Stone{
        .value = try std.fmt.parseInt(u64, stoneValStr, 10),
        .strValue = try std.fmt.allocPrint(alloc, "{s}", .{stoneValStr}),
        .prev = null,
        .next = null,
    };

    for (0..blinks) |i| {
        std.debug.print("Iteration: {d}\n", .{i});
        var stonePtr: ?*Stone = firstStone;
        while (stonePtr) |currStone| {
            // std.debug.print("currStone.strValue {s}\n", .{currStone.strValue});
            const strLen = currStone.strValue.len;
            // std.debug.print("currStone.strValue.len: {d}\n", .{strLen});
            if (strLen % 2 == 0) {
                const split1 = try alloc.create(Stone);
                const split1StrValue = currStone.strValue[0 .. strLen / 2];
                const split1Val = try std.fmt.parseInt(u64, split1StrValue, 10);
                split1.* = Stone{
                    .value = split1Val,
                    .strValue = try std.fmt.allocPrint(alloc, "{d}", .{split1Val}),
                    .prev = currStone.prev,
                    .next = null,
                };

                const split2 = try alloc.create(Stone);
                const split2StrValue = currStone.strValue[strLen / 2 ..];
                const split2Val = try std.fmt.parseInt(u64, split2StrValue, 10);
                split2.* = Stone{
                    .value = split2Val,
                    .strValue = try std.fmt.allocPrint(alloc, "{d}", .{split2Val}),
                    .prev = split1,
                    .next = currStone.next,
                };

                split1.next = split2;

                if (currStone.prev != null) {
                    currStone.prev.?.next = split1;
                } else {
                    firstStone = split1;
                }

                if (currStone.next != null) {
                    currStone.next.?.prev = split2;
                }
            } else {
                if (currStone.value == 0) {
                    currStone.value = 1;
                } else {
                    currStone.value = currStone.value * 2024;
                }
                currStone.strValue = try std.fmt.allocPrint(alloc, "{d}", .{currStone.value});
            }

            stonePtr = currStone.next;
        }

        // var debug = prevStone;
        // // std.debug.print("{d} ", .{debug.value});
        // while (debug.next) |currStone| {
        //     // std.debug.print("{d} ", .{currStone.value});
        //     debug = currStone;
        // }
        // std.debug.print("\n", .{});
    }

    var stoneCounter: usize = 0;
    var counterStonePtr: ?*Stone = firstStone;
    while (counterStonePtr) |currStone| {
        stoneCounter += 1;
        counterStonePtr = currStone.next;
    }

    return stoneCounter;
}

pub fn day11() !void {
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();
    var alloc = arena.allocator();

    const path = "./src/inputs/day11.txt";

    const buffer = try utils.readFile(path, &alloc);

    var lines = std.mem.split(u8, buffer, "\n");

    const line = lines.next().?;

    var stones = std.mem.split(u8, line, " ");

    var part1: usize = 0;
    // var part2: usize = 0;
    while (stones.next()) |stone| {
        part1 += try getStonesAfterNBlinks(stone, 25);
        // part2 += try getStonesAfterNBlinks(stone, 75);
    }

    std.debug.print("Part 1: {d}\n", .{part1});
    // std.debug.print("Part 1: {d}\n", .{part2});
}
