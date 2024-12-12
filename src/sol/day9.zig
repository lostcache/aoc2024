const std = @import("std");
const utils = @import("../utils.zig");

pub fn printEmptyPages(freeSizeToIndices: *std.AutoHashMap(usize, std.ArrayList(usize))) void {
    var freeSizeToIndicesIterator = freeSizeToIndices.*.iterator();
    while (freeSizeToIndicesIterator.next()) |indicesEntry| {
        const freeSize = indicesEntry.key_ptr.*;
        const freeIndices = indicesEntry.value_ptr.*;
        std.debug.print("{d} -> ", .{freeSize});
        for (freeIndices.items) |index| {
            std.debug.print("{d} ", .{index});
        }
        std.debug.print("\n", .{});
    }
}

pub fn day9() !void {
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();
    var alloc = arena.allocator();

    const path = "./src/inputs/day9.txt";
    const buffer = try utils.readFile(path, &alloc);
    var lines = std.mem.split(u8, buffer, "\n");
    const input = lines.next().?;
    var disk = std.ArrayList([]const u8).init(alloc);
    var fileBlockId: usize = 0;
    var diskIndex: usize = 0;
    var maxEmptySpace: usize = 0;
    var freeSizeToIndices = std.AutoHashMap(usize, std.ArrayList(usize)).init(alloc);
    for (input, 0..) |c, inputIndex| {
        const slice: [1]u8 = .{c};
        const n = try std.fmt.parseInt(u64, &slice, 10);
        if (inputIndex % 2 == 0) {
            for (0..n) |_| {
                try disk.append(try std.fmt.allocPrint(alloc, "{any}", .{fileBlockId}));
            }
            fileBlockId += 1;
        } else {
            const maybeFreeIndices = freeSizeToIndices.get(n);
            if (maybeFreeIndices == null) {
                var freeIndices = std.ArrayList(usize).init(alloc);
                _ = try freeIndices.append(diskIndex);
                _ = try freeSizeToIndices.put(n, freeIndices);
            } else {
                var freeIndices = maybeFreeIndices.?;
                _ = try freeIndices.append(diskIndex);
                _ = try freeSizeToIndices.put(n, freeIndices);
            }
            for (0..n) |_| {
                try disk.append(".");
            }
            if (n > maxEmptySpace) {
                maxEmptySpace = n;
            }
        }
        diskIndex += n;
    }

    //print disk
    // std.debug.print("Disk: {s}\n", .{disk.items});
    // std.debug.print("Initial empty pages\n", .{});
    // printEmptyPages(&freeSizeToIndices);

    // var left: usize = 0;
    // var right: usize = disk.items.len - 1;
    // while (left < right) {
    //     if (std.mem.eql(u8, ".", disk.items[left])) {
    //         while (std.mem.eql(u8, ".", disk.items[right])) {
    //             right -= 1;
    //         }
    //         const temp = disk.items[left];
    //         disk.items[left] = disk.items[right];
    //         disk.items[right] = temp;
    //         right -= 1;
    //     }
    //     left += 1;
    // }

    // var checkSum: u64 = 0;
    // for (disk.items, 0..) |c, index| {
    //     if (std.mem.eql(u8, ".", c)) {
    //         break;
    //     }
    //     const n = try std.fmt.parseInt(u64, c, 10);
    //     checkSum += n * index;
    // }

    // std.debug.print("Part1: {d}\n", .{checkSum});

    diskIndex = disk.items.len - 1;
    while (diskIndex > 0) {
        if (std.mem.eql(u8, ".", disk.items[diskIndex]) == false) {
            var size: usize = 1;
            while (diskIndex > 1 and std.mem.eql(u8, disk.items[diskIndex], disk.items[diskIndex - 1]) == true) {
                size += 1;
                diskIndex -= 1;
            }
            if (diskIndex == 1 and std.mem.eql(u8, disk.items[1], disk.items[0])) {
                size += 1;
                diskIndex -= 1;
            }

            // find right empty block
            var chosenIndex: usize = disk.items.len;
            var chosenSize: usize = undefined;
            if (maxEmptySpace >= size) {
                for (size..maxEmptySpace + 1) |rightSize| {
                    const maybeFreeIndices = freeSizeToIndices.get(rightSize);
                    if (maybeFreeIndices != null) {
                        const freeIndicesList = maybeFreeIndices.?;
                        if (freeIndicesList.items.len != 0) {
                            const freeIndex = freeIndicesList.items[0];
                            if (freeIndex < diskIndex and freeIndex < chosenIndex) {
                                chosenIndex = freeIndex;
                                chosenSize = rightSize;
                            }
                        }
                    }
                }
            }

            if (chosenIndex < disk.items.len) {
                // std.debug.print("Moving {} blocks from disk Index: {d} to disk Index: {d}\n", .{ size, diskIndex, chosenIndex });
                // move data
                for (0..size) |sizeoffset| {
                    const temp = disk.items[diskIndex + sizeoffset];
                    disk.items[diskIndex + sizeoffset] = disk.items[chosenIndex + sizeoffset];
                    disk.items[chosenIndex + sizeoffset] = temp;
                }

                // remove from bookeeping
                var chosenIndicesList = freeSizeToIndices.get(chosenSize).?;
                _ = chosenIndicesList.orderedRemove(0);

                // add fragment to bookkeeping
                if (chosenSize > size) {
                    const maybeFreeIndices = freeSizeToIndices.get(chosenSize - size);
                    if (maybeFreeIndices == null) {
                        var freeIndices = std.ArrayList(usize).init(alloc);
                        _ = try freeIndices.append(chosenIndex + size);
                        std.mem.sort(usize, freeIndices.items, {}, std.sort.asc(usize));
                        _ = try freeSizeToIndices.put(chosenSize - size, freeIndices);
                    } else {
                        var freeIndices = maybeFreeIndices.?;
                        _ = try freeIndices.append(chosenIndex + size);
                        std.mem.sort(usize, freeIndices.items, {}, std.sort.asc(usize));
                        _ = try freeSizeToIndices.put(chosenSize - size, freeIndices);
                    }
                }

                // std.debug.print("After move \n", .{});
                // printEmptyPages(&freeSizeToIndices);
            }
        }

        if (diskIndex == 0) {
            continue;
        }
        diskIndex -= 1;
    }

    // std.debug.print("Disk after: {s}\n", .{disk.items});

    var checkSumAfterMove: usize = 0;
    for (disk.items, 0..) |c, index| {
        if (std.mem.eql(u8, ".", c)) {
            continue;
        }
        const n = try std.fmt.parseInt(usize, c, 10);
        checkSumAfterMove += n * index;
    }
    std.debug.print("Part2: {d}\n", .{checkSumAfterMove});
}
