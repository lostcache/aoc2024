const std = @import("std");
const utils = @import("../utils.zig");

const Operation = enum {
    Add,
    Subtract,
    Multiply,
    Divide,
};

fn canReachHelper(target: i64, currRes: i64, operandArray: *std.ArrayList(i64), currIndex: usize, alloc: *std.mem.Allocator) !bool {
    if (currIndex == operandArray.items.len) {
        return target == currRes;
    }

    const resWithAdd = try canReachHelper(target, currRes + operandArray.items[currIndex], operandArray, currIndex + 1, alloc);

    const resWithMul = try canReachHelper(target, currRes * operandArray.items[currIndex], operandArray, currIndex + 1, alloc);

    const left = try std.fmt.allocPrint(alloc.*, "{}", .{currRes});
    const right = try std.fmt.allocPrint(alloc.*, "{}", .{operandArray.items[currIndex]});
    const parts: [2][]const u8 = .{ left, right };
    const concetnated = try std.mem.concat(alloc.*, u8, &parts);
    const concetnetedRes = try std.fmt.parseInt(i64, concetnated, 10);

    const resWithConcat = try canReachHelper(target, concetnetedRes, operandArray, currIndex + 1, alloc);

    return resWithAdd or resWithMul or resWithConcat;
}

fn canReachTarget(target: i64, operandArray: *std.ArrayList(i64), alloc: *std.mem.Allocator) !bool {
    return try canReachHelper(target, operandArray.*.items[0], operandArray, 1, alloc);
}

pub fn day7() !void {
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();
    var alloc = arena.allocator();

    const path = "./src/inputs/day7.txt";

    const buffer = try utils.readFile(path, &alloc);

    var lines = std.mem.split(u8, buffer, "\n");

    var sumTarget: i64 = 0;
    while (lines.next()) |line| {
        if (line.len == 0) {
            continue;
        }

        var sections = std.mem.split(u8, line, ":");
        const target = try std.fmt.parseInt(i64, sections.next().?, 10);
        const operands = sections.next().?;

        var operandArray = try std.ArrayList(i64).initCapacity(alloc, 100);
        var operandIter = std.mem.split(u8, operands, " ");
        _ = operandIter.next();

        while (operandIter.next()) |operand| {
            try operandArray.append(try std.fmt.parseInt(i64, operand, 10));
        }

        if (try canReachTarget(target, &operandArray, &alloc)) {
            sumTarget += target;
        }
    }

    std.debug.print("Part 1: {}\n", .{sumTarget});
}
