const std = @import("std");
const utils = @import("../utils.zig");

fn getOperandValue(operandCode: u64, registers: *std.AutoHashMap(u8, u64)) !u64 {
    if (operandCode < 4) return operandCode;

    return try switch (operandCode) {
        4 => registers.get('a').?,
        5 => registers.get('b').?,
        6 => registers.get('c').?,
        7 => error.InvalidOperand,
        else => unreachable,
    };
}

const Operation = enum(u64) {
    adv = 0,
    bxl = 1,
    bst = 2,
    jnz = 3,
    bxc = 4,
    out = 5,
    bdv = 6,
    cdv = 7,
};

fn executeOperation(programCounter: *usize, program: *std.ArrayList(u64), registers: *std.AutoHashMap(u8, u64), out: *std.ArrayList(u64)) !void {
    const opCode = program.items[programCounter.*];
    programCounter.* += 1;

    var operandCode: ?u64 = null;
    if (programCounter.* < program.*.items.len) {
        operandCode = program.items[programCounter.*];
        programCounter.* += 1;
    }

    const operand = try getOperandValue(operandCode.?, registers);

    _ = switch (@as(Operation, @enumFromInt(opCode))) {
        Operation.adv => {
            // division operation
            const numer = registers.get('a').?;
            const denom = std.math.pow(u64, 2, operand);
            const res = numer / denom;
            _ = try registers.put('a', res);
        },
        Operation.bxl => {
            // bitwise XOR
            const op1 = registers.get('b').?;
            const op2 = operand;
            const res = op1 ^ op2;
            _ = try registers.put('b', res);
        },
        Operation.bst => {
            // mod 8
            const op1 = operand;
            const op2 = 8;
            const res = @mod(op1, op2);
            _ = try registers.put('b', res);
        },
        Operation.jnz => {
            // jump if a not 0
            const a = registers.get('a').?;
            if (a == 0) {
                return;
            }

            programCounter.* = operand;
        },
        Operation.bxc => {
            // xor b and c ignore operand
            const b = registers.get('b').?;
            const c = registers.get('c').?;
            const res = b ^ c;
            _ = try registers.put('b', res);
        },
        Operation.out => {
            // out operand mod 8
            const op1 = operand;
            const op2 = 8;
            const res = @mod(op1, op2);
            try out.*.append(res);
        },
        Operation.bdv => {
            // division operation
            const numer = registers.get('a').?;
            const denom = std.math.pow(u64, 2, operand);
            const res = numer / denom;
            _ = try registers.put('b', res);
        },
        Operation.cdv => {
            // division operation
            const numer = registers.get('a').?;
            const denom = std.math.pow(u64, 2, operand);
            const res = numer / denom;
            _ = try registers.put('c', res);
        },
    };
}

pub fn day17() !void {
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();
    var alloc = arena.allocator();

    const path = "./src/inputs/day17.txt";

    const buffer = try utils.readFile(path, &alloc);

    var sections = std.mem.split(u8, buffer, "\n\n");

    const registerSection = sections.next().?;
    var registerIter = std.mem.split(u8, registerSection, "\n");
    const registerA = registerIter.next().?;
    var numStartPtr: usize = 0;
    var numEndPtr: usize = 0;
    while (numStartPtr < registerA.len and std.ascii.isDigit(registerA[numStartPtr]) == false) {
        numStartPtr += 1;
        numEndPtr += 1;
    }

    while (numEndPtr < registerA.len and std.ascii.isDigit(registerA[numEndPtr]) == true) {
        numEndPtr += 1;
    }

    const registerAValue = try std.fmt.parseInt(u64, registerA[numStartPtr..numEndPtr], 10);
    std.debug.print("Register A: {}\n", .{registerAValue});

    const registerB = registerIter.next().?;
    numStartPtr = 0;
    numEndPtr = 0;
    while (numStartPtr < registerB.len and std.ascii.isDigit(registerB[numStartPtr]) == false) {
        numStartPtr += 1;
        numEndPtr += 1;
    }

    while (numEndPtr < registerB.len and std.ascii.isDigit(registerB[numEndPtr]) == true) {
        numEndPtr += 1;
    }

    const registerBValue = try std.fmt.parseInt(u64, registerB[numStartPtr..numEndPtr], 10);
    std.debug.print("Register B: {}\n", .{registerBValue});

    const registerC = registerIter.next().?;
    numStartPtr = 0;
    numEndPtr = 0;
    while (numStartPtr < registerC.len and std.ascii.isDigit(registerC[numStartPtr]) == false) {
        numStartPtr += 1;
        numEndPtr += 1;
    }

    while (numEndPtr < registerC.len and std.ascii.isDigit(registerC[numEndPtr]) == true) {
        numEndPtr += 1;
    }

    const registerCValue = try std.fmt.parseInt(u64, registerC[numStartPtr..numEndPtr], 10);
    std.debug.print("Register C: {}\n", .{registerCValue});

    const programSection = sections.next().?;
    var program = std.ArrayList(u64).init(alloc);
    numStartPtr = 0;
    numEndPtr = 0;

    while (numEndPtr < programSection.len) {
        if (numEndPtr == programSection.len - 1) {
            break;
        }
        while (numEndPtr < programSection.len and std.ascii.isDigit(programSection[numEndPtr]) == false) {
            numStartPtr += 1;
            numEndPtr += 1;
        }

        while (numEndPtr < programSection.len and std.ascii.isDigit(programSection[numEndPtr]) == true) {
            numEndPtr += 1;
        }

        const num = try std.fmt.parseInt(u64, programSection[numStartPtr..numEndPtr], 10);
        try program.append(num);

        numStartPtr = numEndPtr;
    }

    std.debug.print("Program: {any}\n", .{program.items});

    var registers = std.AutoHashMap(u8, u64).init(alloc);
    _ = try registers.put('a', registerAValue);
    _ = try registers.put('b', registerBValue);
    _ = try registers.put('c', registerCValue);
    var programPointer: usize = 0;
    var out = std.ArrayList(u64).init(alloc);
    while (programPointer < program.items.len) {
        try executeOperation(&programPointer, &program, &registers, &out);
    }

    var registerMapIter = registers.iterator();

    while (registerMapIter.next()) |entry| {
        std.debug.print("{c} -> {any}\n", .{ entry.key_ptr.*, entry.value_ptr.* });
    }

    if (out.items.len > 0) {
        var part1 = try std.fmt.allocPrint(alloc, "{}", .{out.items[0]});

        for (1..out.items.len) |i| {
            part1 = try std.mem.concat(alloc, u8, &[_][]const u8{ part1, try std.fmt.allocPrint(alloc, ",{}", .{out.items[i]}) });
        }

        std.debug.print("Part1: {s}\n", .{part1});
    }

    // var registerWithEstimatedAVal = std.AutoHashMap(u8, u64).init(alloc);
    // _ = try registerWithEstimatedAVal.put('b', 0);
    // _ = try registerWithEstimatedAVal.put('c', 0);
    // // 134600000
    // for (0..200000000) |a| {
    //     const requiredOut = "2,4,1,3,7,5,4,1,1,3,0,3,5,5,3,0";
    //     var iterOut = std.ArrayList(u64).init(alloc);
    //     _ = try registerWithEstimatedAVal.put('a', a);

    //     var programCounter: usize = 0;
    //     while (programCounter < program.items.len) {
    //         try executeOperation(&programCounter, &program, &registerWithEstimatedAVal, &iterOut);
    //     }

    //     if (iterOut.items.len > 0) {
    //         var part1 = try std.fmt.allocPrint(alloc, "{}", .{iterOut.items[0]});

    //         for (1..iterOut.items.len) |i| {
    //             part1 = try std.mem.concat(alloc, u8, &[_][]const u8{ part1, try std.fmt.allocPrint(alloc, ",{}", .{iterOut.items[i]}) });
    //         }

    //         if (std.mem.eql(u8, part1, requiredOut) == true) {
    //             std.debug.print("FOUND IT!!! -> {any}\n", .{a});
    //             return;
    //         }
    //     }

    //     if (@mod(a, 100000) == 0) {
    //         std.debug.print("Completed {} iterations\n", .{a});
    //     }
    // }
}
