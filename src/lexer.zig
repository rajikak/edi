const std = @import("std");
const testing = std.testing;
const mem = std.mem;

const eof: u8 = -1;
const segment_sep: u8 = '~';
const element_sep: u8 = '*';

pub const ItemType = enum {
    err, // error occured; value is the text of error
    eof,
    identifier, // elemenet identifier
    val, // a value
};

// item represents a token of a text string returned from the scanner
const Item = struct {
    typ: ItemType, // the type of this iterm.
    pos: u8, // the starting position, in bytes, of this item in the input string.
    val: []const u8, // the value of this item.
    line: u8, // the line number at the start of this item.

    pub fn init(typ: ItemType, pos: u8, val: []const u8, line: u8) Item {
        return Item{ .typ = typ, .pos = pos, .val = val, .line = line };
    }

    pub fn print(self: Item) void {
        std.debug.print("item{type = {}, }}", .{self.typ});
        std.debug.print("pos = {}, ", .{self.pos});
        std.debug.print("val = {}, ", .{self.pos});
        std.debug.print("line = {}\n", .{self.line});
    }
};

const Lexer = struct {
    input: []const u8,
    start: u8, // start position of the item
    pos: u8, // current position of the input
    at_eof: bool, // we have hit the end of input and returned eof

    fn init(input: []const u8, start: u8, pos: u8, at_eof: bool) Lexer {
        return Lexer{ .input = input, .start = start, .pos = pos, .at_eof = at_eof };
    }

    fn print(self: Lexer) void {
        std.debug.print("EDI: {s}\n", .{self.input});
    }

    // return the next token
    pub fn next(self: *Lexer) Item {
        const line: u8 = 0;
        std.debug.print("input={s}\n", .{self.input});
        while (true) : (self.pos += 1) {
            std.debug.print("start = {}, ", .{self.start});
            std.debug.print("pos = {}\n", .{self.pos});
            if (self.pos >= self.input.len) {
                self.at_eof = true;
                return Item.init(ItemType.eof, self.pos, "", line);
            }
            if (self.input[self.pos] == element_sep) {
                const itemv = self.input[self.start..self.pos];
                std.debug.print("token: {s}\n", .{itemv});
                self.pos += 1; // skip element seperator
                self.start = self.pos;
                return Item.init(ItemType.val, self.pos, itemv, line);
            }
        }
    }
};

test "str" {
    _ = "DXS*9251230013*DX*004010UCS*1*9254850000";
    const s = "TST*123";
    var lexer = Lexer.init(s, 0, 0, false);
    const t1 = lexer.next();
    t1.print();

    const t2 = lexer.next();
    t2.print();
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
    _ = Lexer.init(s, 0, 0, false);
}
