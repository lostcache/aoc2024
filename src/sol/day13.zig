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

fn compareFn(_: void, a: [3]usize, b: [3]usize) std.math.Order {
    if (a[2] < b[2]) return .lt;
    if (a[2] > b[2]) return .gt;
    return .eq;
}

fn getLeastCostDikstras(
    aButtonVal: [2]usize,
    bButtonVal: [2]usize,
    target: [2]usize,
    alloc: *std.mem.Allocator,
) !usize {
    var cache = std.AutoHashMap([2]usize, void).init(alloc.*);
    var minHeap = std.PriorityQueue([3]usize, void, compareFn).init(alloc.*, {});
    _ = try minHeap.add(.{ 0, 0, 0 });

    while (minHeap.removeOrNull()) |state| {
        const currX = state[0];
        const currY = state[1];
        const currrCost = state[2];

        const maybeVisited = cache.get(.{ currX, currY });
        if (maybeVisited != null) continue;

        if (currX == target[0] and currY == target[1]) {
            return currrCost;
        }

        if (currX > target[0] or currY > target[1]) {
            continue;
        }

        _ = try minHeap.add(.{ currX + aButtonVal[0], currY + aButtonVal[1], currrCost + 3 });

        _ = try minHeap.add(.{ currX + bButtonVal[0], currY + bButtonVal[1], currrCost + 1 });

        _ = try cache.put(.{ currX, currY }, {});
    }

    return maxUsizeValue;
}

fn solveEquations(aButtonVal: [2]usize, bButtonVal: [2]usize, prizeVal: [2]usize) usize {
    const ax = aButtonVal[0];
    const ay = aButtonVal[1];
    var bx = bButtonVal[0];
    var by = bButtonVal[1];
    var xx = prizeVal[0];
    var yy = prizeVal[1];

    bx = bx * ay;
    xx = xx * ay;

    by = by * ax;
    yy = yy * ax;

    var bn: usize = undefined;
    if (bx > by) {
        if (yy > xx) return 0;
        bn = (xx - yy) / (bx - by);
    } else {
        if (xx > yy) return 0;
        bn = (yy - xx) / (by - bx);
    }

    if (bn * bButtonVal[0] > prizeVal[0]) return 0;

    const an: usize = (prizeVal[0] - (bn * bButtonVal[0])) / ax;

    if ((an * aButtonVal[0] + bn * bButtonVal[0]) == prizeVal[0] and (an * aButtonVal[1] + bn * bButtonVal[1]) == prizeVal[1]) {
        return an * 3 + bn * 1;
    }

    return 0;
}

pub fn day13() !void {
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();
    var alloc = arena.allocator();

    const path = "./src/inputs/day13.txt";
    var aButtonVals: ValueList = std.ArrayList([2]usize).init(alloc);
    var bButtonVals: ValueList = std.ArrayList([2]usize).init(alloc);
    var prizeVals: ValueList = std.ArrayList([2]usize).init(alloc);

    const buffer = try utils.readFile(path, &alloc);

    try parseInputs(buffer, &aButtonVals, &bButtonVals, &prizeVals);

    const numMachines = aButtonVals.items.len;

    var totalCost: usize = 0;
    // for (0..numMachines) |machineIndex| {
    //     const machineCost = solveEquations(
    //         aButtonVals.items[machineIndex],
    //         bButtonVals.items[machineIndex],
    //         prizeVals.items[machineIndex],
    //     );

    //     totalCost += machineCost;
    // }

    // std.debug.print("Part1: {}\n", .{totalCost});

    for (0..prizeVals.items.len) |i| {
        prizeVals.items[i][0] = prizeVals.items[i][0] + 10000000000000;
        prizeVals.items[i][1] = prizeVals.items[i][1] + 10000000000000;
    }

    totalCost = 0;
    for (0..numMachines) |machineIndex| {
        std.debug.print("Machine: {}\n", .{machineIndex});
        const machineCost = solveEquations(
            aButtonVals.items[machineIndex],
            bButtonVals.items[machineIndex],
            prizeVals.items[machineIndex],
        );

        totalCost += machineCost;
    }

    std.debug.print("Part2; {}\n", .{totalCost});
}
