const std = @import("std");
const utils = @import("../utils.zig");

fn parseInput(buffer: *[]const u8, nums: *std.ArrayList(i64)) !void {
    var numIter = std.mem.split(u8, buffer.*, "\n");

    while (numIter.next()) |numStr| {
        if (numStr.len == 0) continue;
        try nums.append(try std.fmt.parseInt(i64, numStr, 10));
    }
}

fn getSecret(num: i64) i64 {
    var initialNum = num;

    initialNum = @mod(((initialNum * 64) ^ initialNum), 16777216);

    initialNum = @mod((@divTrunc(initialNum, 32) ^ initialNum), 16777216);

    initialNum = @mod(((initialNum * 2048) ^ initialNum), 16777216);

    return initialNum;
}

fn processData(
    num: i64,
    diffArr: *std.ArrayList(i8),
    seqHeap: *std.PriorityQueue([5]i8, void, compareFn),
    seqMap: *std.AutoHashMap([4]i8, i8),
) !void {
    var currNum = num;
    var currNumOnesDigit = @mod(currNum, 10);
    for (0..2000) |i| {
        const secret = getSecret(currNum);
        const secretOnesDigit = @mod(secret, 10);
        try diffArr.append(@as(i8, @intCast(secretOnesDigit - currNumOnesDigit)));
        currNum = secret;
        currNumOnesDigit = secretOnesDigit;

        if (i > 2) {
            if (seqMap.get(.{
                diffArr.items[i - 3],
                diffArr.items[i - 2],
                diffArr.items[i - 1],
                diffArr.items[i],
            }) == null) {
                try seqMap.put(
                    .{
                        diffArr.items[i - 3],
                        diffArr.items[i - 2],
                        diffArr.items[i - 1],
                        diffArr.items[i],
                    },
                    @as(i8, @intCast(secretOnesDigit)),
                );
            }
            try seqHeap.add(.{
                diffArr.items[i - 3],
                diffArr.items[i - 2],
                diffArr.items[i - 1],
                diffArr.items[i],
                @as(i8, @intCast(secretOnesDigit)),
            });
        }
    }
}

fn compareFn(_: void, a: [5]i8, b: [5]i8) std.math.Order {
    if (a[4] < b[4]) return .gt;
    if (a[4] > b[4]) return .lt;
    return .eq;
}

pub fn day22() !void {
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();
    var alloc = arena.allocator();

    const path = "./src/inputs/day22.txt";

    var buffer = try utils.readFile(path, &alloc);
    var nums = std.ArrayList(i64).init(alloc);

    try parseInput(&buffer, &nums);

    var diffData = try std.ArrayList(std.ArrayList(i8)).initCapacity(alloc, 1800);
    var seqHeaps = try std.ArrayList(std.PriorityQueue([5]i8, void, compareFn)).initCapacity(alloc, 1800);
    var seqMaps = try std.ArrayList(std.AutoHashMap([4]i8, i8)).initCapacity(alloc, 1800);
    for (nums.items) |num| {
        var diffArr = try std.ArrayList(i8).initCapacity(alloc, 2000);
        var seqHeap = std.PriorityQueue([5]i8, void, compareFn).init(alloc, {});
        var seqMap = std.AutoHashMap([4]i8, i8).init(alloc);
        try processData(num, &diffArr, &seqHeap, &seqMap);
        try diffData.append(diffArr);
        try seqHeaps.append(seqHeap);
        try seqMaps.append(seqMap);
    }

    const nBuyers = diffData.items.len;

    var maxPrice: usize = 0;
    for (0..nBuyers) |i| {
        var localMaxPrice: usize = 0;
        var seqHeap = seqHeaps.items[i];
        if (seqHeap.removeOrNull()) |maxPriceSeq| {
            const seq = .{ maxPriceSeq[0], maxPriceSeq[1], maxPriceSeq[2], maxPriceSeq[3] };
            for (0..nBuyers) |j| {
                const seqMap = seqMaps.items[j];
                const maybePriceOfSeqForBuyer = seqMap.get(seq);
                const priceOfSeqForBuyer = if (maybePriceOfSeqForBuyer != null) maybePriceOfSeqForBuyer.? else 0;
                localMaxPrice += @as(usize, @intCast(priceOfSeqForBuyer));
            }
        }

        if (localMaxPrice > maxPrice) {
            maxPrice = localMaxPrice;
        }
    }

    std.debug.print("Part2: {any}\n", .{maxPrice});
}
