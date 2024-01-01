const std = @import("std");
const testing = std.testing;
const mem = std.mem;

pub const ItemType = enum {
    err,
    eof,
    transaction_set,
};

// item represents a token of a text string returned from the scanner
const Item = struct {
    typ: ItemType, // the type of this iterm.
    pos: u8, // the starting position, in bytes, of this item in the input string.
    val: []const u8, // the value of this item.
    line: u8, // the line number at the start of this item.
};

const Lexer = struct {
    input: []const u8,
    start: u8, // start position of the item
    pos: u8, // current position of the input

    pub fn init(input: []const u8) Lexer {
        return Lexer{ .input = input, .start = 0, .pos = 0 };
    }

    pub fn print(self: Lexer) void {
        std.debug.print("EDI: {s}\n", .{self.input});
    }

    // return the next token
    pub fn next(self: Lexer) void {
        var index: u8 = 0;
        while (true) : (index += 1) {
            if (index >= self.input.len) {
                break;
            }
            if (self.input[index] == '*') {
                std.debug.print("token: {s}\n", .{self.input[0..index]});
            }
        }
    }
};

test "str" {
    const s = "TST*123";
    const lexer = Lexer.init(s);
    lexer.next();
}

test "str2" {
    // a sample EDI
    const s =
        \\ ST*270*1234*005010X279A1~
        \\ BHT*0022*13*10001234*20060501*1319~
        \\ HL*1**20*1~
        \\ NM1*PR*2*ABC COMPANY*****PI*842610001~
        \\ HL*2*1*21*1~
        \\ NM1*1P*2*BONE AND JOINT CLINIC*****SV*2000035~
        \\ HL*3*2*22*0~
        \\ TRN*1*93175-012547*9877281234~
        \\ NM1*IL*1*SMITH*ROBERT****MI*11122333301~
        \\ DMG*D8*19430519~
        \\ DTP*291*D8*20060501~
        \\ EQ*30~
        \\ SE*13*1234~
    ;
    _ = Lexer.init(s);
}
