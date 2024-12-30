const std = @import("std");
const utils = @import("../utils.zig");

fn parseInput(buffer: *[]const u8, outSeq: *std.ArrayList([]const u8)) !void {
    var lineIter = std.mem.split(u8, buffer.*, "\n");

    while (lineIter.next()) |line| {
        if (line.len == 0) continue;
        try outSeq.*.append(line);
    }
}

fn prepDirPadIndices(dirPadIndices: *std.AutoHashMap(u8, [2]usize)) !void {
    try dirPadIndices.put('<', .{ 1, 0 });
    try dirPadIndices.put('>', .{ 1, 2 });
    try dirPadIndices.put('^', .{ 0, 1 });
    try dirPadIndices.put('v', .{ 1, 1 });
    try dirPadIndices.put('A', .{ 0, 2 });
}

fn prepNumPadIndices(numPadIndices: *std.AutoHashMap(u8, [2]usize)) !void {
    try numPadIndices.put('0', .{ 3, 1 });
    try numPadIndices.put('1', .{ 2, 0 });
    try numPadIndices.put('2', .{ 2, 1 });
    try numPadIndices.put('3', .{ 2, 2 });
    try numPadIndices.put('4', .{ 1, 0 });
    try numPadIndices.put('5', .{ 1, 1 });
    try numPadIndices.put('6', .{ 1, 2 });
    try numPadIndices.put('7', .{ 0, 0 });
    try numPadIndices.put('8', .{ 0, 1 });
    try numPadIndices.put('9', .{ 0, 2 });
    try numPadIndices.put('A', .{ 3, 2 });
}

fn getCostOnNumPad(initialPos: [2]usize, finalPos: [2]usize, nextTargetSeqs: *std.ArrayList([]const u8)) usize {
    _ = nextTargetSeqs;
    const initialX = @as(i8, @intCast(initialPos[0]));
    const initialY = @as(i8, @intCast(initialPos[1]));
    const finalX = @as(i8, @intCast(finalPos[0]));
    const finalY = @as(i8, @intCast(finalPos[1]));
    return @abs(finalX - initialX) + @abs(finalY - initialY);
}

pub fn day21() !void {
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();
    var alloc = arena.allocator();

    const path = "./src/inputs/day21.txt";

    var buffer = try utils.readFile(path, &alloc);

    var outSeq = std.ArrayList([]const u8).init(alloc);

    var dirPadIndices = std.AutoHashMap(u8, [2]usize).init(alloc);
    var numPadIndices = std.AutoHashMap(u8, [2]usize).init(alloc);

    try parseInput(&buffer, &outSeq);
    try prepDirPadIndices(&dirPadIndices);
    try prepNumPadIndices(&numPadIndices);

    var totalCost: usize = 0;
    for (0..4) |_| {
        var tagetSeqes = outSeq;
        var nextTargetSeqs = std.ArrayList([]const u8).init(alloc);
        for (tagetSeqes.items) |seq| {
            var initialPos = numPadIndices.get('A').?;
            for (seq) |char| {
                const finalPos = numPadIndices.get(char).?;
                const cost = getCostOnNumPad(initialPos, finalPos, &nextTargetSeqs);
                initialPos = finalPos;
                totalCost += cost;
            }
        }
        tagetSeqes = nextTargetSeqs;
    }

    std.debug.print("Total cost: {}\n", .{totalCost});
}
