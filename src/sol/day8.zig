const std = @import("std");
const utils = @import("../utils.zig");

fn cast(comptime F: type, comptime T: type, val: F) T {
    return @as(T, @intCast(val));
}

pub fn day8() !void {
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();
    var alloc = arena.allocator();

    const path = "./src/inputs/day8.txt";
    const buffer = try utils.readFile(path, &alloc);
    var lines = std.mem.split(u8, buffer, "\n");
    const nCols = lines.peek().?.len;
    const nRows = lines.rest().len / (nCols + 1);

    var grid = try std.ArrayList(std.ArrayList(u8)).initCapacity(alloc, nRows);
    var antennaMap = std.AutoHashMap(u8, std.ArrayList([2]usize)).init(alloc);

    for (0..nRows) |i| {
        const row = lines.next().?;
        var gridRow = try std.ArrayList(u8).initCapacity(alloc, nCols);
        for (0..nCols) |j| {
            try gridRow.append(row[j]);
            if (row[j] != '.') {
                const maybeAntennaPos = antennaMap.get(row[j]);
                var antennaPos: std.ArrayList([2]usize) = undefined;
                if (maybeAntennaPos == null) {
                    antennaPos = std.ArrayList([2]usize).init(alloc);
                } else {
                    antennaPos = maybeAntennaPos.?;
                }
                try antennaPos.append(.{ i, j });
                _ = try antennaMap.put(row[j], antennaPos);
            }
        }
        try grid.append(gridRow);
    }

    // var antennaPosIterator = antennaMap.iterator();
    // while (antennaPosIterator.next()) |entry| {
    //     const antenna = entry.key_ptr.*;
    //     const antennaPos = entry.value_ptr.*;
    //     std.debug.print("{c} -> ", .{antenna});
    //     for (antennaPos.items) |pos| {
    //         std.debug.print("({d}, {d}) ", .{ pos[0], pos[1] });
    //     }
    //     std.debug.print("\n", .{});
    // }

    var uniqueAntiNodeCounter: usize = 0;
    var antiNodeSet = std.AutoHashMap([2]i64, void).init(alloc);
    var antennaPosIterator = antennaMap.iterator();
    while (antennaPosIterator.next()) |entry| {
        const antennaPos = entry.value_ptr.*;
        if (antennaPos.items.len <= 1) {
            continue;
        }

        for (antennaPos.items, 0..) |pos, ind| {
            var other = ind + 1;
            while (other < antennaPos.items.len) {
                const otherPos = antennaPos.items[other];
                const antiNode1: [2]i64 = .{
                    cast(usize, i64, pos[0]) + (cast(usize, i64, pos[0]) - cast(usize, i64, otherPos[0])),
                    cast(usize, i64, pos[1]) + (cast(usize, i64, pos[1]) - cast(usize, i64, otherPos[1])),
                };
                if (antiNode1[0] >= 0 and antiNode1[0] < nRows and antiNode1[1] >= 0 and antiNode1[1] < nCols) {
                    const isAlreadySet = antiNodeSet.get(antiNode1);
                    if (isAlreadySet == null) {
                        _ = try antiNodeSet.put(antiNode1, {});
                        uniqueAntiNodeCounter += 1;
                    }
                }
                const antiNode2: [2]i64 = .{
                    cast(usize, i64, otherPos[0]) + (cast(usize, i64, otherPos[0]) - cast(usize, i64, pos[0])),
                    cast(usize, i64, otherPos[1]) + (cast(usize, i64, otherPos[1]) - cast(usize, i64, pos[1])),
                };
                if (antiNode2[0] >= 0 and antiNode2[0] < nRows and antiNode2[1] >= 0 and antiNode2[1] < nCols) {
                    const isAlreadySet = antiNodeSet.get(antiNode2);
                    if (isAlreadySet == null) {
                        _ = try antiNodeSet.put(antiNode2, {});
                        uniqueAntiNodeCounter += 1;
                    }
                }
                other += 1;
            }
        }
    }
    std.debug.print("Part 1: {}\n", .{uniqueAntiNodeCounter});

    var antennaPosIterator2 = antennaMap.iterator();
    var allUnquieAntiNodeCounter: usize = 0;
    var allAntiNodeSet = std.AutoHashMap([2]i64, void).init(alloc);
    while (antennaPosIterator2.next()) |entry| {
        const antennaPos = entry.value_ptr.*;
        if (antennaPos.items.len <= 1) {
            continue;
        }

        for (antennaPos.items, 0..) |pos, ind| {
            var other = ind + 1;
            while (other < antennaPos.items.len) {
                const otherPos = antennaPos.items[other];

                const posEntry = .{ cast(usize, i64, pos[0]), cast(usize, i64, pos[1]) };
                const isPosAlreadySet = allAntiNodeSet.get(posEntry);
                if (isPosAlreadySet == null) {
                    _ = try allAntiNodeSet.put(posEntry, {});
                    allUnquieAntiNodeCounter += 1;
                }

                const otherPosEntry = .{ cast(usize, i64, otherPos[0]), cast(usize, i64, otherPos[1]) };
                const isOtherPosAlreadySet = allAntiNodeSet.get(otherPosEntry);
                if (isOtherPosAlreadySet == null) {
                    _ = try allAntiNodeSet.put(otherPosEntry, {});
                    allUnquieAntiNodeCounter += 1;
                }

                var antiNode1: [2]i64 = .{
                    cast(usize, i64, pos[0]) + (cast(usize, i64, pos[0]) - cast(usize, i64, otherPos[0])),
                    cast(usize, i64, pos[1]) + (cast(usize, i64, pos[1]) - cast(usize, i64, otherPos[1])),
                };
                while (antiNode1[0] >= 0 and antiNode1[0] < nRows and antiNode1[1] >= 0 and antiNode1[1] < nCols) {
                    const isAlreadySet = allAntiNodeSet.get(antiNode1);
                    if (isAlreadySet == null) {
                        _ = try allAntiNodeSet.put(antiNode1, {});
                        allUnquieAntiNodeCounter += 1;
                    }
                    antiNode1 = .{
                        antiNode1[0] + (cast(usize, i64, pos[0]) - cast(usize, i64, otherPos[0])),
                        antiNode1[1] + (cast(usize, i64, pos[1]) - cast(usize, i64, otherPos[1])),
                    };
                }
                var antiNode2: [2]i64 = .{
                    cast(usize, i64, otherPos[0]) + (cast(usize, i64, otherPos[0]) - cast(usize, i64, pos[0])),
                    cast(usize, i64, otherPos[1]) + (cast(usize, i64, otherPos[1]) - cast(usize, i64, pos[1])),
                };
                while (antiNode2[0] >= 0 and antiNode2[0] < nRows and antiNode2[1] >= 0 and antiNode2[1] < nCols) {
                    const isAlreadySet = allAntiNodeSet.get(antiNode2);
                    if (isAlreadySet == null) {
                        _ = try allAntiNodeSet.put(antiNode2, {});
                        allUnquieAntiNodeCounter += 1;
                    }
                    antiNode2 = .{
                        antiNode2[0] + (cast(usize, i64, otherPos[0]) - cast(usize, i64, pos[0])),
                        antiNode2[1] + (cast(usize, i64, otherPos[1]) - cast(usize, i64, pos[1])),
                    };
                }
                other += 1;
            }
        }
    }

    std.debug.print("Part 2: {}\n", .{allUnquieAntiNodeCounter});
}
