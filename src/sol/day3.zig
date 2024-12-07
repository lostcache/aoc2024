const std = @import("std");
const utils = @import("../utils.zig");

pub fn day3() !void {
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();
    var alloc = arena.allocator();

    const path = "./src/inputs/day3.txt";

    const buffer = try utils.readFile(path, &alloc);

    const mulPattern = "mul(D,D)";
    const enabledPattern = "do()";
    const disabledPattern = "don't()";
    var enabled = true;
    var part1: u64 = 0;
    var endPtr: usize = 0;
    while (endPtr < buffer.len) {
        var mulPatternPtr: usize = 0;
        var enablePatternPtr: usize = 0;
        var disablePatternPtr: usize = 0;

        var num1: u64 = 0;
        var num2: u64 = 0;

        if (buffer[endPtr] != mulPattern[mulPatternPtr] and buffer[endPtr] != enabledPattern[enablePatternPtr] and buffer[endPtr] != disabledPattern[disablePatternPtr]) {
            endPtr += 1;
            continue;
        }

        var enableMoved: usize = 0;
        while (buffer[endPtr + enableMoved] == enabledPattern[enablePatternPtr]) {
            enableMoved += 1;
            enablePatternPtr += 1;
        }
        if (enableMoved == enabledPattern.len) {
            enabled = true;
            endPtr += enableMoved;
            continue;
        }

        var disableMoved: usize = 0;
        while (buffer[endPtr + disableMoved] == disabledPattern[disablePatternPtr]) {
            disableMoved += 1;
            disablePatternPtr += 1;
        }
        if (disableMoved == disabledPattern.len) {
            enabled = false;
            endPtr += disableMoved;
            continue;
        }

        if (!enabled) {
            endPtr += 1;
            continue;
        }

        while (mulPatternPtr < mulPattern.len and endPtr < buffer.len and mulPattern[mulPatternPtr] == buffer[endPtr]) {
            endPtr += 1;
            mulPatternPtr += 1;
        }

        if (mulPatternPtr < mulPattern.len and mulPattern[mulPatternPtr] == 'D') {
            var num1Buffer: [3]u8 = .{ 11, 11, 11 };
            var num1Ptr: usize = 0;
            while (endPtr < buffer.len and std.ascii.isDigit(buffer[endPtr])) {
                num1Buffer[num1Ptr] = try std.fmt.parseInt(u8, buffer[endPtr .. endPtr + 1], 10);
                num1Ptr += 1;
                endPtr += 1;
            }
            mulPatternPtr += 1;
            std.debug.print("num1: {any}\n", .{num1Buffer});

            num1Ptr = 3;
            var multiplier: u32 = 1;
            while (num1Ptr > 0) : (num1Ptr -= 1) {
                const val = num1Buffer[num1Ptr - 1];
                if (val < 11) {
                    num1 = num1 + val * multiplier;
                    multiplier *= 10;
                }
            }
        }

        while (mulPatternPtr < mulPattern.len and endPtr < buffer.len and buffer[endPtr] == ',') {
            endPtr += 1;
            mulPatternPtr += 1;
        }

        if (mulPatternPtr < mulPattern.len and mulPattern[mulPatternPtr] == 'D') {
            var num2Buffer: [3]u8 = .{ 11, 11, 11 };
            var num2Ptr: usize = 0;
            while (endPtr < buffer.len and std.ascii.isDigit(buffer[endPtr])) {
                num2Buffer[num2Ptr] = try std.fmt.parseInt(u8, buffer[endPtr .. endPtr + 1], 10);
                num2Ptr += 1;
                endPtr += 1;
            }
            std.debug.print("num2: {any}\n", .{num2Buffer});
            mulPatternPtr += 1;

            num2Ptr = 3;
            var multiplier: u32 = 1;
            while (num2Ptr > 0) : (num2Ptr -= 1) {
                const val = num2Buffer[num2Ptr - 1];
                if (val < 11) {
                    num2 = num2 + val * multiplier;
                    multiplier *= 10;
                }
            }
        }

        while (mulPatternPtr < mulPattern.len and endPtr < buffer.len and buffer[endPtr] == ')') {
            endPtr += 1;
            mulPatternPtr += 1;
        }

        std.debug.print("num1: {}, num2: {}, patternPtr: {}\n", .{ num1, num2, mulPatternPtr });

        // std.debug.print("endPtr: {}\n", .{endPtr});

        if (mulPatternPtr == mulPattern.len) {
            part1 += num1 * num2;
        }
    }

    // std.debug.print("Part 1: {}\n", .{part1});
    std.debug.print("Part 2: {}\n", .{part1});
}
