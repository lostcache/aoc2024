const std = @import("std");
const utils = @import("../utils.zig");

const Op = enum { AND, OR, XOR };

fn getOp(opStr: []const u8) Op {
    if (std.mem.eql(u8, opStr, "AND") == true) return Op.AND;
    if (std.mem.eql(u8, opStr, "OR") == true) return Op.OR;
    return Op.XOR;
}

fn parseIntput(
    buffer: *[]const u8,
    gateVals: *std.StringHashMap(usize),
    adjList: *std.StringHashMap(std.StringHashMap(void)),
    opSet: *std.StringHashMap(Op),
    zNodes: *std.StringHashMap(void),
) !void {
    var sections = std.mem.split(u8, buffer.*, "\n\n");

    const gateValSec = sections.next().?;
    const gateEqns = sections.next().?;

    var gateValIter = std.mem.split(u8, gateValSec, "\n");
    while (gateValIter.next()) |gateValEntry| {
        if (gateValEntry.len == 0) continue;
        var entryIter = std.mem.split(u8, gateValEntry, " ");
        const gate = entryIter.next().?[0..3];
        const val = try std.fmt.parseInt(usize, entryIter.next().?, 10);
        try gateVals.put(gate, val);
    }

    var gateEqnIter = std.mem.split(u8, gateEqns, "\n");
    while (gateEqnIter.next()) |gateEqnEntry| {
        if (gateEqnEntry.len == 0) continue;
        var gateEntryIter = std.mem.split(u8, gateEqnEntry, " ");
        const op1 = gateEntryIter.next().?;
        const op = gateEntryIter.next().?;
        const op2 = gateEntryIter.next().?;
        _ = gateEntryIter.next().?;
        const res = gateEntryIter.next().?;

        var oprSet = std.StringHashMap(void).init(adjList.allocator);
        try oprSet.put(op1, {});
        try oprSet.put(op2, {});
        try adjList.put(res, oprSet);

        try opSet.put(res, getOp(op));

        if (std.mem.startsWith(u8, res, "z") == true) {
            try zNodes.put(res, {});
        }
    }
}

fn lessThanFn(_: void, lhs: []const u8, rhs: []const u8) bool {
    return std.mem.order(u8, lhs, rhs) == .lt;
}

fn getResValue(op: Op, op1: usize, op2: usize) usize {
    switch (op) {
        Op.OR => return op1 | op2,
        Op.AND => return op1 & op2,
        Op.XOR => return op1 ^ op2,
    }
}

fn getValue(
    root: []const u8,
    gateVals: *std.StringHashMap(usize),
    adjList: *std.StringHashMap(std.StringHashMap(void)),
    opSet: *std.StringHashMap(Op),
) usize {
    const maybeVal = gateVals.get(root);
    if (maybeVal != null) return maybeVal.?;

    const adjNodes = adjList.get(root).?;
    var adjIter = adjNodes.iterator();

    const op1GateName = adjIter.next().?.key_ptr.*;
    const op1Value = getValue(op1GateName, gateVals, adjList, opSet);

    const op2GateName = adjIter.next().?.key_ptr.*;
    const op2Value = getValue(op2GateName, gateVals, adjList, opSet);

    const op = opSet.get(root).?;

    return getResValue(op, op1Value, op2Value);
}

pub fn day24() !void {
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();
    var alloc = arena.allocator();

    const path = "./src/inputs/day24.txt";

    var buffer = try utils.readFile(path, &alloc);

    var gateVals = std.StringHashMap(usize).init(alloc);
    var adjList = std.StringHashMap(std.StringHashMap(void)).init(alloc);
    var opSet = std.StringHashMap(Op).init(alloc);
    var zNodes = std.StringHashMap(void).init(alloc);

    try parseIntput(&buffer, &gateVals, &adjList, &opSet, &zNodes);

    var zNodeArr = std.ArrayList([]const u8).init(alloc);
    var zNodesIter = zNodes.iterator();
    while (zNodesIter.next()) |zNodeEntry| {
        try zNodeArr.append(zNodeEntry.key_ptr.*);
    }

    std.mem.sort([]const u8, zNodeArr.items, {}, lessThanFn);

    var part1: usize = 0;
    for (zNodeArr.items, 0..) |zNode, i| {
        const val = getValue(zNode, &gateVals, &adjList, &opSet);
        try gateVals.put(zNode, val);
        part1 += std.math.pow(usize, 2, i) * val;
    }

    std.debug.print("Part 1: {}\n", .{part1});
    std.debug.print("end\n", .{});
}
