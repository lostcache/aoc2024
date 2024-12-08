const std = @import("std");
const utils = @import("../utils.zig");

fn containsVal(arr: *std.ArrayList(usize), val: usize) bool {
    for (arr.items) |item| {
        if (item == val) {
            return true;
        }
    }
    return false;
}

fn getUniquePosVisited(
    visitedAndRight: *std.AutoHashMap([2]i64, std.ArrayList(usize)),
    startPos: [2]i64,
    startDir: usize,
    nRows: usize,
    nCols: usize,
    dirSeq: *const [4][2]i64,
    grid: *std.ArrayList(std.ArrayList(u8)),
    alloc: *std.mem.Allocator,
    maybeNewBlockedPos: ?[2]i64,
) !u64 {
    var uniquePosVisited: u64 = 0;
    var dirPtr = startDir;
    var pos = startPos;

    while (pos[0] >= 0 and pos[0] < nRows and pos[1] >= 0 and pos[1] < nCols) {
        const nextRow = pos[0] + dirSeq[dirPtr][0];
        const nextCol = pos[1] + dirSeq[dirPtr][1];

        if (nextRow < 0 or nextRow >= nRows or nextCol < 0 or nextCol >= nCols) {
            uniquePosVisited += 1;
            break;
        }

        const nextRowIndex = @as(usize, @intCast(nextRow));
        const nextColIndex = @as(usize, @intCast(nextCol));
        if ((grid.items[nextRowIndex].items[nextColIndex] == '#') or (maybeNewBlockedPos != null and nextRowIndex == maybeNewBlockedPos.?[0] and nextColIndex == maybeNewBlockedPos.?[1])) {
            dirPtr = (dirPtr + 1) % 4;
            continue;
        }

        const maybeVisistedDirs = visitedAndRight.get(pos);
        if (maybeVisistedDirs == null) {
            var dirArray = try std.ArrayList(usize).initCapacity(alloc.*, 4);
            try dirArray.append(dirPtr);
            _ = try visitedAndRight.put(pos, dirArray);
            uniquePosVisited += 1;
        } else {
            var visistedDirPtrs = maybeVisistedDirs.?;
            if (containsVal(&visistedDirPtrs, dirPtr)) {
                return error.NoWayOut;
            }

            try visistedDirPtrs.append(dirPtr);
            _ = try visitedAndRight.put(pos, visistedDirPtrs);
        }

        pos = .{ nextRow, nextCol };
    }

    return uniquePosVisited;
}

pub fn day6() !void {
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();
    var alloc = arena.allocator();

    const path = "./src/inputs/day6.txt";
    const buffer = try utils.readFile(path, &alloc);

    var lines = std.mem.split(u8, buffer, "\n");
    const nCols = lines.peek().?.len;
    const nRows = lines.rest().len / (nCols + 1);

    var grid = try std.ArrayList(std.ArrayList(u8)).initCapacity(alloc, nRows);
    var pos: [2]i64 = undefined;
    var startPos: [2]i64 = undefined;
    for (0..nRows) |i| {
        const row = lines.next().?;
        var gridRow = try std.ArrayList(u8).initCapacity(alloc, nCols);
        for (0..nCols) |j| {
            if (row[j] == '^') {
                pos = .{ @as(i64, @intCast(i)), @as(i64, @intCast(j)) };
                startPos = pos;
            }
            try gridRow.append(row[j]);
        }
        try grid.append(gridRow);
    }

    const dirSeq: [4][2]i64 = .{ .{ -1, 0 }, .{ 0, 1 }, .{ 1, 0 }, .{ 0, -1 } };
    var visistedWithDir = std.AutoHashMap([2]i64, std.ArrayList(usize)).init(alloc);
    const uniquePosVisited = try getUniquePosVisited(
        &visistedWithDir,
        pos,
        0,
        nRows,
        nCols,
        &dirSeq,
        &grid,
        &alloc,
        null,
    );
    std.debug.print("Part 1: {}\n", .{uniquePosVisited});

    var iterator = visistedWithDir.iterator();
    var trappedCounter: usize = 0;
    while (iterator.next()) |entry| {
        const visitedPos = entry.key_ptr.*;
        const facingDirPtrs = entry.value_ptr.*;

        for (facingDirPtrs.items) |dirPtr| {
            const blockedPos = .{ visitedPos[0] + dirSeq[dirPtr][0], visitedPos[1] + dirSeq[dirPtr][1] };
            if (blockedPos[0] < 0 or blockedPos[0] >= nRows or blockedPos[1] < 0 or blockedPos[1] >= nCols) {
                continue;
            }
            var localVisistedWithDir = std.AutoHashMap([2]i64, std.ArrayList(usize)).init(alloc);
            const rightDirPtr = (dirPtr + 1) % 4;
            const res = getUniquePosVisited(
                &localVisistedWithDir,
                visitedPos,
                rightDirPtr,
                nRows,
                nCols,
                &dirSeq,
                &grid,
                &alloc,
                blockedPos,
            );

            if (res == error.NoWayOut) {
                // std.debug.print("Blocked pos: {any}, from: {}, to: {}\n", .{ blockedPos, dirPtr, rightDirPtr });
                trappedCounter += 1;
            }
        }
    }

    std.debug.print("Part 2: {}\n", .{trappedCounter});
}
