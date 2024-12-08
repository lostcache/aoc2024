const std = @import("std");
const utils = @import("../utils.zig");

fn putAtPosAndBubbleEverythinElse(arr: *std.ArrayList(i64), insertPos: usize, currPos: usize) void {
    const val = arr.items[currPos];
    var i = currPos;
    while (i > 0 and i - 1 >= insertPos) {
        arr.items[i] = arr.items[i - 1];
        i -= 1;
    }
    arr.items[insertPos] = val;
}

fn printHashMap(comptime K: type, comptime V: type, map: *std.AutoHashMap(K, V)) void {
    var iterator = map.iterator();
    while (iterator.next()) |entry| {
        std.debug.print("{any} -> ", .{entry.key_ptr.*});
        std.debug.print("val: {any}\n", .{entry.value_ptr.*});
    }
}

pub fn day5() !void {
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();
    var alloc = arena.allocator();

    const path = "./src/inputs/day5.txt";
    const buffer = try utils.readFile(path, &alloc);

    var sections = std.mem.split(u8, buffer, "\n\n");

    var nextPagesMap = std.AutoHashMap(i64, std.AutoHashMap(i64, void)).init(alloc);
    var prevPagesMap = std.AutoHashMap(i64, std.AutoHashMap(i64, void)).init(alloc);
    const rules = sections.next().?;
    var ruleIterator = std.mem.split(u8, rules, "\n");
    while (ruleIterator.next()) |rule| {
        if (rule.len == 0) {
            continue;
        }

        var ruleParts = std.mem.split(u8, rule, "|");
        const prevPage = try std.fmt.parseInt(i64, ruleParts.next().?, 10);
        const nextPage = try std.fmt.parseInt(i64, ruleParts.next().?, 10);

        const maybeNextPages = nextPagesMap.get(prevPage);
        var nextPages: std.AutoHashMap(i64, void) = undefined;
        if (maybeNextPages == null) {
            nextPages = std.AutoHashMap(i64, void).init(alloc);
        } else {
            nextPages = maybeNextPages.?;
        }
        _ = try nextPages.put(nextPage, {});
        _ = try nextPagesMap.put(prevPage, nextPages);

        const maybePrevPages = prevPagesMap.get(nextPage);
        var prevPages: std.AutoHashMap(i64, void) = undefined;
        if (maybePrevPages == null) {
            prevPages = std.AutoHashMap(i64, void).init(alloc);
        } else {
            prevPages = maybePrevPages.?;
        }
        _ = try prevPages.put(prevPage, {});
        _ = try prevPagesMap.put(nextPage, prevPages);
    }

    // var prevRuleMapIterator = nextPagesMap.iterator();
    // while (prevRuleMapIterator.next()) |entry| {
    //     std.debug.print("{d} -> ", .{entry.key_ptr.*});
    //     const nextPages = entry.value_ptr.*;
    //     var nextPageIterator = nextPages.iterator();
    //     while (nextPageIterator.next()) |nextPageEntry| {
    //         std.debug.print("{d} ", .{nextPageEntry.key_ptr.*});
    //     }
    //     std.debug.print("\n", .{});
    // }

    // var nextRuleMapIterator = prevPagesMap.iterator();
    // while (nextRuleMapIterator.next()) |entry| {
    //     std.debug.print("{d} -> ", .{entry.key_ptr.*});
    //     const nextPages = entry.value_ptr.*;
    //     var prevPageIterator = nextPages.iterator();
    //     while (prevPageIterator.next()) |prevPageEntry| {
    //         std.debug.print("{d} ", .{prevPageEntry.key_ptr.*});
    //     }
    //     std.debug.print("\n", .{});
    // }

    const updates = sections.next().?;
    var updateIterator = std.mem.split(u8, updates, "\n");
    var validUpdates = std.ArrayList(std.ArrayList(i64)).init(alloc);
    var invalidUpdates = std.ArrayList(std.ArrayList(i64)).init(alloc);

    // for every update
    while (updateIterator.next()) |update| {
        var isUpdateValid = true;
        var updatedPages = std.AutoHashMap(i64, void).init(alloc);
        var updatePageArr = std.ArrayList(i64).init(alloc);
        if (update.len == 0) {
            continue;
        }

        // for every update page in the update
        var updatePageSeq = std.mem.split(u8, update, ",");
        while (updatePageSeq.next()) |updatePage| {
            const pageNumber = try std.fmt.parseInt(i64, updatePage, 10);
            _ = try updatedPages.put(pageNumber, {});
            try updatePageArr.append(pageNumber);

            const nextPages = nextPagesMap.get(pageNumber);
            if (nextPages == null) {
                continue;
            }

            var nextPageIterator = nextPages.?.iterator();
            while (nextPageIterator.next()) |nextPageEntry| {
                const nextPage = nextPageEntry.key_ptr.*;
                if (updatedPages.get(nextPage) != null) {
                    isUpdateValid = false;
                }
            }
        }

        if (isUpdateValid) {
            try validUpdates.append(updatePageArr);
        } else {
            try invalidUpdates.append(updatePageArr);
        }
    }

    var validUpdateMidPageSum: i64 = 0;
    for (validUpdates.items) |updatePageArr| {
        const arrLen = updatePageArr.items.len;
        const midPageIndex = arrLen / 2;
        validUpdateMidPageSum += updatePageArr.items[midPageIndex];
    }

    std.debug.print("Part 1: {}\n", .{validUpdateMidPageSum});

    // for (invalidUpdates.items) |updatePageArr| {
    //     std.debug.print("{any} \n", .{updatePageArr.items});
    // }

    for (invalidUpdates.items) |*updatePageArr| {
        var left: usize = 0;
        var right: usize = 1;

        while (right < updatePageArr.items.len) {
            const maybePrevPages = prevPagesMap.get(updatePageArr.items[right]);
            if (maybePrevPages == null) {
                putAtPosAndBubbleEverythinElse(updatePageArr, 0, right);
            } else {
                const prevPages = maybePrevPages.?;
                var maybePrevPage = prevPages.get(updatePageArr.items[left]);
                if (maybePrevPage == null) {
                    var newPos = @as(i64, @intCast(left));
                    while (newPos >= 0 and maybePrevPage == null) {
                        newPos -= 1;
                        if (newPos >= 0) {
                            maybePrevPage = prevPages.get(updatePageArr.items[@as(usize, @intCast(newPos))]);
                        }
                    }
                    putAtPosAndBubbleEverythinElse(updatePageArr, @as(usize, @intCast(newPos + 1)), right);
                }
            }
            left += 1;
            right += 1;
        }

        // std.debug.print("after update -> {any} \n", .{updatePageArr.items});
    }

    var nowValidUpdateMid: i64 = 0;
    for (invalidUpdates.items) |nowValidUpdate| {
        const len = nowValidUpdate.items.len;
        const midIndex = len / 2;
        nowValidUpdateMid += nowValidUpdate.items[midIndex];
    }

    std.debug.print("Part 2: {}\n", .{nowValidUpdateMid});
}

test "putAndBubbleEverytingElseAtPos should work correctly" {
    const ArrayList = std.ArrayList(i64);

    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();
    const allocator = arena.allocator();

    // Test case 1: Insert at the beginning
    var list1 = try ArrayList.initCapacity(allocator, 10);
    try list1.append(75);
    try list1.append(53);
    try list1.append(47);
    try list1.append(61);
    try list1.append(97);

    putAtPosAndBubbleEverythinElse(&list1, 0, 4);
    try std.testing.expectEqual(97, list1.items[0]);
    try std.testing.expectEqual(75, list1.items[1]);
    try std.testing.expectEqual(53, list1.items[2]);
    try std.testing.expectEqual(47, list1.items[3]);
    try std.testing.expectEqual(61, list1.items[4]);
}
