const std = @import("std");
const utils = @import("../utils.zig");

const ValueList = std.ArrayList([2]usize);
const maxUsizeValue = std.math.maxInt(usize);

const AButtonCost = 3;
const BButtonCost = 1;

fn parseInputs(buffer: []const u8, aButtonVals: *ValueList, bButtonVals: *ValueList, prizeVals: *ValueList) !void {
    var machines = std.mem.split(u8, buffer, "\n\n");

    while (machines.next()) |machine| {
        if (machine.len == 0) {
            continue;
        }

        var lines = std.mem.split(u8, machine, "\n");

        var left: usize = 0;
        var right: usize = 0;
        const buttonALine = lines.next().?;
        var buttonAXVals: usize = undefined;
        var buttonAYVals: usize = undefined;
        for (0..2) |i| {
            while (std.ascii.isDigit(buttonALine[left]) == false) {
                left += 1;
                right += 1;
            }
            while (right < buttonALine.len and std.ascii.isDigit(buttonALine[right])) {
                right += 1;
            }
            if (i == 0) {
                buttonAXVals = try std.fmt.parseInt(usize, buttonALine[left..right], 10);
            } else {
                buttonAYVals = try std.fmt.parseInt(usize, buttonALine[left..right], 10);
            }
            left = right;
        }
        try aButtonVals.*.append(.{ buttonAXVals, buttonAYVals });

        left = 0;
        right = 0;
        const buttonBLine = lines.next().?;
        var buttonBX: usize = undefined;
        var buttonBY: usize = undefined;
        for (0..2) |i| {
            while (std.ascii.isDigit(buttonBLine[left]) == false) {
                left += 1;
                right += 1;
            }
            while (right < buttonBLine.len and std.ascii.isDigit(buttonBLine[right])) {
                right += 1;
            }
            if (i == 0) {
                buttonBX = try std.fmt.parseInt(usize, buttonBLine[left..right], 10);
            } else {
                buttonBY = try std.fmt.parseInt(usize, buttonBLine[left..right], 10);
            }
            left = right;
        }
        try bButtonVals.*.append(.{ buttonBX, buttonBY });

        left = 0;
        right = 0;
        const prizeLine = lines.next().?;
        var prizeX: usize = undefined;
        var prizeY: usize = undefined;
        for (0..2) |i| {
            while (std.ascii.isDigit(prizeLine[left]) == false) {
                left += 1;
                right += 1;
            }
            while (right < prizeLine.len and std.ascii.isDigit(prizeLine[right])) {
                right += 1;
            }
            if (i == 0) {
                prizeX = try std.fmt.parseInt(usize, prizeLine[left..right], 10);
            } else {
                prizeY = try std.fmt.parseInt(usize, prizeLine[left..right], 10);
            }
            left = right;
        }

        try prizeVals.*.append(.{ prizeX, prizeY });
    }
}

fn getLeastCost(
    aButtonVal: [2]usize,
    bButtonVal: [2]usize,
    aButtonPresses: usize,
    bButtonPresses: usize,
    currPos: [2]usize,
    prizePos: [2]usize,
    cache: *std.AutoHashMap([2]usize, usize),
) !usize {
    const maybeVisited = cache.get(.{ currPos[0], currPos[1] });

    if (maybeVisited != null) {
        return maybeVisited.?;
    }

    if (currPos[0] > prizePos[0] or currPos[1] > prizePos[1]) {
        _ = try cache.put(.{ currPos[0], currPos[1] }, maxUsizeValue);
        return maxUsizeValue;
    }

    if (currPos[0] == prizePos[0] and currPos[1] == prizePos[1]) {
        const cost = aButtonPresses * AButtonCost + bButtonPresses * BButtonCost;
        _ = try cache.put(.{ currPos[0], currPos[1] }, maxUsizeValue);
        return cost;
    }

    const aPressCost = try getLeastCost(
        aButtonVal,
        bButtonVal,
        aButtonPresses + 1,
        bButtonPresses,
        .{ currPos[0] + aButtonVal[0], currPos[1] + aButtonVal[1] },
        prizePos,
        cache,
    );

    const bPressCost = try getLeastCost(
        aButtonVal,
        bButtonVal,
        aButtonPresses,
        bButtonPresses + 1,
        .{ currPos[0] + bButtonVal[0], currPos[1] + bButtonVal[1] },
        prizePos,
        cache,
    );

    var minCost: usize = undefined;

    if (aPressCost < bPressCost) {
        minCost = aPressCost;
    } else {
        minCost = bPressCost;
    }

    _ = try cache.put(.{ currPos[0], currPos[1] }, minCost);

    return minCost;
}

pub fn day13() !void {
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();
    var alloc = arena.allocator();

    const path = "./src/inputs/day13.txt";
    var aButtonVals: ValueList = std.ArrayList([2]usize).init(alloc);
    var bButtonVals: ValueList = std.ArrayList([2]usize).init(alloc);
    var PrizeVals: ValueList = std.ArrayList([2]usize).init(alloc);

    const buffer = try utils.readFile(path, &alloc);

    try parseInputs(buffer, &aButtonVals, &bButtonVals, &PrizeVals);

    const numMachines = aButtonVals.items.len;

    var totalCost: usize = 0;
    for (0..numMachines) |machineIndex| {
        var cache = std.AutoHashMap([2]usize, usize).init(alloc);
        const machineCost = try getLeastCost(
            aButtonVals.items[machineIndex],
            bButtonVals.items[machineIndex],
            0,
            0,
            .{ 0, 0 },
            PrizeVals.items[machineIndex],
            &cache,
        );
        if (machineCost == maxUsizeValue) {
            continue;
        }
        totalCost += machineCost;
    }

    std.debug.print("Total cost: {}\n", .{totalCost});
}
