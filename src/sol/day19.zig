const std = @import("std");
const utils = @import("../utils.zig");

const StrArray = std.ArrayList([]const u8);
const Cache = std.StringHashMap(void);
const DFSCache = std.StringHashMap(usize);

fn parseInput(buffer: *[]const u8, patterns: *StrArray, designs: *StrArray) !void {
    var sections = std.mem.split(u8, buffer.*, "\n\n");

    const availablePatternSection = sections.next().?;

    var patternIter = std.mem.split(u8, availablePatternSection, ", ");
    while (patternIter.next()) |pattern| {
        try patterns.append(pattern);
    }

    const desiredDesignsSection = sections.next().?;

    var designIter = std.mem.split(u8, desiredDesignsSection, "\n");
    while (designIter.next()) |design| {
        if (design.len == 0) continue;
        try designs.append(design);
    }
}

fn compareByLen(_: void, a: []const u8, b: []const u8) std.math.Order {
    if (a.len < b.len) return .gt;

    if (a.len > b.len) return .lt;

    return .eq;
}

fn checkIfPossible(design: *const []const u8, patterns: *StrArray, cache: *Cache, alloc: *std.mem.Allocator) !bool {
    var minHeap = std.PriorityQueue([]const u8, void, compareByLen).init(alloc.*, {});

    const copyBuffer = try alloc.alloc(u8, design.len);
    std.mem.copyForwards(u8, copyBuffer, design.*);
    _ = try minHeap.add(copyBuffer);

    while (minHeap.removeOrNull()) |remainingDesign| {
        const maybeVisited = cache.get(remainingDesign);
        if (maybeVisited != null) {
            continue;
        }

        for (patterns.items) |pattern| {
            if (std.mem.startsWith(u8, remainingDesign, pattern)) {
                const remainingLen = remainingDesign.len - pattern.len;

                if (remainingLen == 0) {
                    return true;
                }

                const remainingDesignCpy = try alloc.alloc(u8, remainingDesign.len - pattern.len);
                std.mem.copyForwards(u8, remainingDesignCpy, remainingDesign[pattern.len..]);
                _ = try minHeap.add(remainingDesignCpy);
            }
        }

        _ = try cache.put(remainingDesign, {});
    }

    return false;
}

fn countPossiblePathsDFS(design: *const []const u8, patterns: *StrArray, cache: *DFSCache, alloc: *std.mem.Allocator, index: usize) !usize {
    const maybeVisited = cache.get(design.*[index..]);
    if (maybeVisited != null) return maybeVisited.?;

    if (index > design.len) {
        _ = try cache.put(design.*[index..], 0);
        return 0;
    }

    if (index == design.len) {
        _ = try cache.put(design.*[index..], 1);
        return 1;
    }

    var pathCount: usize = 0;
    for (patterns.items) |pattern| {
        if (std.mem.startsWith(u8, design.*[index..], pattern)) {
            pathCount += try countPossiblePathsDFS(design, patterns, cache, alloc, index + pattern.len);
        }
    }

    _ = try cache.put(design.*[index..], pathCount);

    return pathCount;
}

pub fn day19() !void {
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();
    var allocator = arena.allocator();

    const path = "./src/inputs/day19.txt";

    var patterns = StrArray.init(allocator);
    defer patterns.deinit();

    var designs = StrArray.init(allocator);
    defer designs.deinit();

    var buffer = try utils.readFile(path, &allocator);
    defer allocator.free(buffer);

    try parseInput(&buffer, &patterns, &designs);

    var possibleDesignCounter: usize = 0;
    for (designs.items) |design| {
        var iterArena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
        defer iterArena.deinit();

        var iterAlloc = iterArena.allocator();
        var cache = Cache.init(iterAlloc);
        defer cache.deinit();

        const isPossible = try checkIfPossible(&design, &patterns, &cache, &iterAlloc);
        if (isPossible) {
            possibleDesignCounter += 1;
        }
    }

    std.debug.print("Part1: {}\n", .{possibleDesignCounter});

    var allPossiblePaths: usize = 0;
    for (designs.items) |design| {
        var iterArena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
        defer iterArena.deinit();

        var iterAlloc = iterArena.allocator();
        var cache = DFSCache.init(iterAlloc);
        defer cache.deinit();

        allPossiblePaths += try countPossiblePathsDFS(&design, &patterns, &cache, &iterAlloc, 0);
    }

    std.debug.print("Part2: {}\n", .{allPossiblePaths});
}
