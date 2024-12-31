const std = @import("std");
const utils = @import("../utils.zig");

const AdjList = std.StringHashMap(std.StringHashMap(void));

const Networks = std.StringHashMap(void);

fn parseInput(buffer: *const []u8, adjList: *AdjList, alloc: *std.mem.Allocator) !void {
    var lineIter = std.mem.split(u8, buffer.*, "\n");
    while (lineIter.next()) |line| {
        if (line.len == 0) continue;

        var nodeIter = std.mem.split(u8, line, "-");
        const node1 = nodeIter.next().?;
        const node2 = nodeIter.next().?;

        const maybeNei1 = adjList.get(node1);
        var nei1 = if (maybeNei1 != null) maybeNei1.? else std.StringHashMap(void).init(alloc.*);
        try nei1.put(node2, {});
        try adjList.put(node1, nei1);

        const maybeNei2 = adjList.get(node2);
        var nei2 = if (maybeNei2 != null) maybeNei2.? else std.StringHashMap(void).init(alloc.*);
        try nei2.put(node1, {});
        try adjList.put(node2, nei2);
    }
}

fn lessThanFn(_: void, a: []const u8, b: []const u8) bool {
    return std.mem.order(u8, a, b) == .lt;
}

fn collectNodes(threeSizedNet: *Networks, stack: *std.ArrayList([]const u8)) !void {
    const stackClone = try stack.clone();
    std.mem.sort([]const u8, stackClone.items, {}, lessThanFn);
    const netStr = try std.fmt.allocPrint(threeSizedNet.allocator, "{s},{s},{s}", .{ stackClone.items[0], stackClone.items[1], stackClone.items[2] });
    try threeSizedNet.put(netStr, {});
}

fn getThreeNodeCycleRec(
    root: []const u8,
    currNode: []const u8,
    paren: ?[]const u8,
    depth: usize,
    stack: *std.ArrayList([]const u8),
    threeSizedNet: *Networks,
    adjList: *AdjList,
) !void {
    if (depth > 2) return;

    try stack.append(currNode);
    defer _ = stack.pop();

    const maybeNei = adjList.*.get(currNode);
    if (maybeNei == null) return;
    var neiIter = maybeNei.?.iterator();

    while (neiIter.next()) |neiEntry| {
        const nei = neiEntry.key_ptr.*;

        if (paren != null and std.mem.eql(u8, nei, paren.?) == true) {
            continue;
        }

        if (depth == 2 and std.mem.eql(u8, root, nei) == true) {
            try collectNodes(threeSizedNet, stack);
            continue;
        }

        try getThreeNodeCycleRec(root, nei, currNode, depth + 1, stack, threeSizedNet, adjList);
    }
}

fn getAllThreeNodeCycles(
    adjList: *AdjList,
    threeSizedNet: *Networks,
) !void {
    var nodeIterator = adjList.iterator();

    while (nodeIterator.next()) |nodeEntry| {
        var iterArena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
        defer iterArena.deinit();
        const iterAlloc = iterArena.allocator();

        const node = nodeEntry.key_ptr.*;
        var stack = std.ArrayList([]const u8).init(iterAlloc);
        try getThreeNodeCycleRec(node, node, null, 0, &stack, threeSizedNet, adjList);
    }
}

fn intersection(
    setA: *const std.StringHashMap(void),
    setB: *const std.StringHashMap(void),
    intersectionSet: *std.StringHashMap(void),
) !void {
    var iterA = setA.iterator();
    while (iterA.next()) |entry| {
        const key = entry.key_ptr.*;
        if (setB.get(key) != null) {
            try intersectionSet.put(key, {});
        }
    }
}

fn bronKerbosche(
    currClique: *std.StringHashMap(void),
    candidates: *std.StringHashMap(void),
    processed: *std.StringHashMap(void),
    cliques: *std.ArrayList(std.StringHashMap(void)),
    adjList: *AdjList,
    currMax: *usize,
) !void {
    if (candidates.count() == 0 and processed.count() == 0) {
        if (currClique.count() > currMax.*) {
            currMax.* = currClique.count();
            try cliques.append(try currClique.clone());
        }
        return;
    }

    var candidateIter = candidates.iterator();
    while (candidateIter.next()) |candidateEntry| {
        const candidate = candidateEntry.key_ptr.*;

        var newClique = try currClique.clone();
        try newClique.put(candidate, {});

        const maybeNei = adjList.get(candidate);
        const nei = if (maybeNei != null) maybeNei.? else std.StringHashMap(void).init(adjList.allocator);

        var newCandidates = std.StringHashMap(void).init(candidates.allocator);
        try intersection(candidates, &nei, &newCandidates);

        var newProcessed = std.StringHashMap(void).init(processed.allocator);
        try intersection(processed, &nei, &newProcessed);

        try bronKerbosche(&newClique, &newCandidates, &newProcessed, cliques, adjList, currMax);

        _ = candidates.remove(candidate);
        try processed.put(candidate, {});
    }
}

pub fn day23() !void {
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();
    var alloc = arena.allocator();

    var adjList = AdjList.init(alloc);

    const path = "./src/inputs/day23.txt";

    const buffer = try utils.readFile(path, &alloc);

    try parseInput(&buffer, &adjList, &alloc);

    var threeSizedNetwords = Networks.init(alloc);

    try getAllThreeNodeCycles(&adjList, &threeSizedNetwords);

    var beginsWitht: usize = 0;
    var netsIter = threeSizedNetwords.iterator();
    while (netsIter.next()) |netEntry| {
        var nodeIter = std.mem.split(u8, netEntry.key_ptr.*, ",");
        while (nodeIter.next()) |node| {
            if (std.mem.startsWith(u8, node, "t") == true) {
                beginsWitht += 1;
                break;
            }
        }
    }

    std.debug.print("part1: {}\n", .{beginsWitht});

    var nodeIter = adjList.iterator();
    var nodes = std.StringHashMap(void).init(alloc);
    while (nodeIter.next()) |nodeEntry| {
        const node = nodeEntry.key_ptr.*;
        try nodes.put(node, {});
    }

    var currMaxClique: usize = 0;
    var candidates = try nodes.clone();
    var cliques = std.ArrayList(std.StringHashMap(void)).init(alloc);
    var processed = std.StringHashMap(void).init(alloc);
    var currClique = std.StringHashMap(void).init(alloc);
    try bronKerbosche(&currClique, &candidates, &processed, &cliques, &adjList, &currMaxClique);

    for (cliques.items) |clique| {
        var cliqueIter = clique.iterator();
        var nodeArr = std.ArrayList([]const u8).init(alloc);
        while (cliqueIter.next()) |entry| {
            const key = entry.key_ptr.*;
            try nodeArr.append(key);
        }
        std.mem.sort([]const u8, nodeArr.items, {}, lessThanFn);
        std.debug.print("clique: {s}\n", .{nodeArr.items});
    }

    std.debug.print("---end---\n", .{});
}
