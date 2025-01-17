const std = @import("std");
const readDayFile = @import("utils.zig").readDayFile;

pub fn d17(allocator: std.mem.Allocator) !void {
    var program = try getProgram(allocator);
    const inst = program.program.items;
    defer program.program.deinit();
    var out = std.ArrayList(u8).init(allocator);
    defer out.deinit();
    while (program.pc < inst.len) {
        const opcode = inst[program.pc];
        const operand = inst[program.pc + 1];
        try operation(&program, &out, opcode, operand);
    }
    std.log.debug("d17 q1: {any}", .{out.items});
}

fn operation(noalias program: *Program, noalias out: *std.ArrayList(u8), opcode: u8, operand: u8) !void {
    switch (opcode) {
        '0' => {
            const combo = getCombo(program, operand);
            const denominator = std.math.pow(u64, 2, combo);
            program.reg[0] = @divTrunc(program.reg[0], denominator);
        },
        '1' => {
            const num = getLiteral(operand);
            program.reg[1] ^= @intCast(num);
        },
        '2' => {
            program.reg[1] = @mod(getCombo(program, operand), 8);
        },
        '3' => {
            if (program.reg[0] == 0) {
                program.pc += 2;
                return;
            }
            program.pc = getLiteral(operand);
            return;
        },
        '4' => {
            program.reg[1] ^= program.reg[2];
        },
        '5' => {
            const combo = getCombo(program, operand);
            const out_val = @mod(combo, 8);
            try out.append(@intCast(out_val));
        },
        '6' => {
            const combo = getCombo(program, operand);
            const denominator = std.math.pow(u64, 2, combo);
            program.reg[1] = @divTrunc(program.reg[0], denominator);
        },
        '7' => {
            const combo = getCombo(program, operand);
            const denominator = std.math.pow(u64, 2, combo);
            program.reg[2] = @divTrunc(program.reg[0], denominator);
        },
        else => unreachable,
    }
    program.pc += 2;
}

fn getLiteral(operand: u8) u8 {
    return operand - '0';
}

fn getCombo(program: *Program, operand: u8) u64 {
    return switch (operand) {
        '0'...'3' => |val| getLiteral(val),
        '4' => program.reg[0],
        '5' => program.reg[1],
        '6' => program.reg[2],
        else => {
            @panic("wrong operand");
        },
    };
}

const Program = struct {
    reg: [3]u64,
    program: std.ArrayList(u8),
    pc: usize,
};

fn getProgram(allocator: std.mem.Allocator) !Program {
    var file = try readDayFile(17);
    defer file.close();
    var reg: [3]u64 = .{0} ** 3;
    for (0..3) |i| {
        const line = try file.reader().readUntilDelimiterAlloc(allocator, '\n', std.math.maxInt(usize));
        defer allocator.free(line);
        var tokens = std.mem.tokenizeAny(u8, line, " ");
        var last: []u8 = undefined;
        while (tokens.next()) |token| {
            last = @constCast(token);
        }
        const num = try std.fmt.parseInt(u64, last, 10);
        reg[i] = num;
    }
    const line = try file.reader().readUntilDelimiterAlloc(allocator, '\n', std.math.maxInt(usize));
    defer allocator.free(line);
    const program_line = try file.reader().readUntilDelimiterAlloc(allocator, '\n', std.math.maxInt(usize));
    defer allocator.free(program_line);
    var tokens = std.mem.tokenizeAny(u8, program_line, " ,");
    var program = std.ArrayList(u8).init(allocator);
    var i: usize = 0;
    while (tokens.next()) |token| {
        i += 1;
        if (i == 1) continue;
        try program.append(token[0]);
    }
    return Program{ .reg = reg, .program = program, .pc = 0 };
}
