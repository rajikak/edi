const std = @import("std");
const testing = std.testing;
const expect = testing.expect;
const mem = std.mem;

const eof: u8 = -1;
const segment_sep: u8 = '~';
const element_sep: u8 = '*';

const ItemType = enum {
    err, // error occured; value is the text of error
    eof,
    identifier, // elemenet identifier
    val, // a value

    fn asstr(self: ItemType) []const u8 {
        if (self == ItemType.err) {
            return "ItemType => err";
        } else if (self == ItemType.eof) {
            return "ItemType => eof";
        } else if (self == ItemType.identifier) {
            return "ItemType => identifier";
        } else if (self == ItemType.val) {
            return "ItemType => val";
        } else {
            return "ItemType => uknown";
        }
    }
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
        std.debug.print("item{{type = {s}, ", .{self.typ.asstr()});
        std.debug.print("val = {s}, ", .{self.val});
        std.debug.print("line = {d}\n", .{self.line});
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
    fn next(self: *Lexer) Item {
        const line: u8 = 0;
        while (true) : (self.pos += 1) {
            const itemv: []const u8 = self.input[self.start..self.pos];
            if (self.pos >= self.input.len) {
                self.at_eof = true;
                return Item.init(ItemType.eof, self.pos, itemv, line);
            }
            if (self.input[self.pos] == element_sep) {
                //std.debug.print("token: {s}\n", .{itemv});
                self.pos += 1; // skip element seperator
                self.start = self.pos;
                return Item.init(ItemType.val, self.pos, itemv, line);
            }

            //if (self.input[self.pos] == segment_sep) {
            //    self.pos += 1; // skip segment seperator
            //    self.start = self.pos;
            //    return Item.init()
            //}
        }
    }

    fn tokens(self: *Lexer, store: *std.ArrayList(Item)) void {
        var lexer = init(self.input, 0, 0, false);

        while (true) {
            const token: Item = lexer.next();
            store.append(token) catch std.debug.print("out of memory occured\n", .{});
            if (token.typ == ItemType.eof) {
                break;
            }
        }
    }
};

test "segments" {
    const result = struct {
        len: u8,
        head: []const u8,
        tail: []const u8,
    };
    const tst = struct {
        input: []const u8,
        expected: result,
    };

    const tests = [_]tst{
        tst{ .input = "TST", .expected = result{ .len = 1, .head = "TST", .tail = "TST" } },
        tst{ .input = "TST*123", .expected = result{ .len = 2, .head = "TST", .tail = "123" } },
        //tst{ .input = "TST*123~", .expected = result{ .len = 2, .head = "TST", .tail = "123" } },
        tst{ .input = "DXS*9251230013*DX*004010UCS*1*9254850000", .expected = result{ .len = 6, .head = "DXS", .tail = "9254850000" } },
    };

    std.debug.print("\n", .{});
    for (tests) |t| {
        var buffer = std.ArrayList(Item).init(testing.allocator);
        defer buffer.deinit();

        var lexer = Lexer.init(t.input, 0, 0, false);
        lexer.tokens(&buffer);

        try expect(t.expected.len == buffer.items.len);

        std.debug.print("getLast() = {s}\n", .{buffer.getLast().val});
        try expect(std.mem.eql(u8, t.expected.tail, buffer.getLast().val) == true);
    }
}

test "large segments" {
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
