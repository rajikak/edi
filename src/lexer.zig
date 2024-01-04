const std = @import("std");
const testing = std.testing;
const expect = testing.expect;
const mem = std.mem;

const eof: u8 = -1;
const segment_sep: u8 = '~';
const element_sep: u8 = '*';

const TokenType = enum {
    err, // error occured; value is the text of error
    eof,
    identifier, // elemenet identifier
    val, // a value
    seg_sep, // segment seperator
    ele_sep, // element seperator

    fn asstr(self: TokenType) []const u8 {
        if (self == TokenType.err) {
            return "ItemType => err";
        } else if (self == TokenType.eof) {
            return "ItemType => eof";
        } else if (self == TokenType.identifier) {
            return "ItemType => identifier";
        } else if (self == TokenType.val) {
            return "ItemType => val";
        } else {
            return "ItemType => uknown";
        }
    }
};

// token represents a token of a text string returned from the scanner
const Token = struct {
    typ: TokenType, // the type of this iterm.
    pos: u8, // the starting position, in bytes, of this item in the input string.
    val: []const u8, // the value of this item.
    line: u8, // the line number at the start of this item.

    pub fn init(typ: TokenType, pos: u8, val: []const u8, line: u8) Token {
        return Token{ .typ = typ, .pos = pos, .val = val, .line = line };
    }

    pub fn print(self: Token) void {
        std.debug.print("item{{type = {s}, ", .{self.typ.asstr()});
        std.debug.print("val = {s}, ", .{self.val});
        std.debug.print("line = {d}\n", .{self.line});
    }
};

const LexerOptions = struct {
    seg_sep: u8,
    ele_sep: u8,

    fn init(seg_sep: u8, ele_sep: u8) LexerOptions {
        return LexerOptions{ .seg_sep = seg_sep, .ele_sep = ele_sep };
    }
};

const Lexer = struct {
    input: []const u8,
    start: u8, // start position of the item
    pos: u8, // current position of the input
    at_eof: bool, // we have hit the end of input and returned eof
    options: LexerOptions, // configuration for lexer

    fn init(input: []const u8, start: u8, pos: u8, at_eof: bool, options: LexerOptions) Lexer {
        return Lexer{ .input = input, .start = start, .pos = pos, .at_eof = at_eof, .options = options };
    }

    fn print(self: Lexer) void {
        std.debug.print("EDI: {s}\n", .{self.input});
    }

    fn peek(self: Lexer) u8 {
        if (self.pos + 1 < self.input.len) {
            return self.input[self.pos + 1];
        }
        return 0;
    }

    // return the next token
    fn next(self: *Lexer) Token {
        const line: u8 = 0;

        const ele_sep = self.options.ele_sep;
        const ele_sep_str = "*";

        const seg_sep = self.options.seg_sep;
        const seg_sep_str = "~";

        while (true) : (self.pos += 1) {
            //const itemv: []const u8 = self.input[self.start..self.pos];
            //if (self.pos >= self.input.len) {
            //    self.at_eof = true;
            //    return Token.init(TokenType.eof, self.pos, itemv, line);
            //}
            //if (self.input[self.pos] == element_sep) {
            //std.debug.print("token: {s}\n", .{itemv});
            //    self.pos += 1; // skip element seperator
            //    self.start = self.pos;
            //    return Token.init(TokenType.val, self.pos, itemv, line);
            //}

            if (self.pos + 1 == self.input.len) {
                self.at_eof = true;
                const tv: []const u8 = self.input[self.start .. self.pos + 1];
                return Token.init(TokenType.eof, self.pos, tv, line);
            }

            const ch: u8 = self.peek();
            if (ch == self.options.ele_sep or ch == self.options.seg_sep) {
                const tv: []const u8 = self.input[self.start..self.pos];
                self.pos += 1;
                self.start = self.pos;
                return Token.init(TokenType.identifier, self.pos, tv, line);
            } else if (self.input[self.pos] == ele_sep) {
                self.pos += 1;
                self.start = self.pos;
                return Token.init(TokenType.ele_sep, self.pos, ele_sep_str, line);
            } else if (self.input[self.pos] == seg_sep) {
                self.pos += 1;
                self.start = self.pos;
                return Token.init(TokenType.seg_sep, self.pos, seg_sep_str, line);
            } else {
                continue;
            }
        }
    }

    fn tokens(self: *Lexer, store: *std.ArrayList(Token)) void {
        while (true) {
            const token: Token = self.next();
            store.append(token) catch std.debug.print("out of memory occured\n", .{});
            if (token.typ == TokenType.eof) {
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
        tst{ .input = "TST~", .expected = result{ .len = 2, .head = "TST", .tail = "~" } },
        tst{ .input = "TST*123", .expected = result{ .len = 3, .head = "TST", .tail = "123" } },
        tst{ .input = "TST*123~", .expected = result{ .len = 4, .head = "TST", .tail = "~" } },
        tst{ .input = "DXS*9251230013*DX*004010UCS*1*9254850000", .expected = result{ .len = 11, .head = "DXS", .tail = "9254850000" } },
    };

    std.debug.print("\n", .{});
    for (tests) |t| {
        var buffer = std.ArrayList(Token).init(testing.allocator);
        defer buffer.deinit();

        var options = LexerOptions.init(segment_sep, element_sep);
        var lexer = Lexer.init(t.input, 0, 0, false, options);
        lexer.tokens(&buffer);

        std.debug.print("len = {d}\n", .{buffer.items.len});
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
    var options = LexerOptions.init(segment_sep, element_sep);
    _ = Lexer.init(s, 0, 0, false, options);
}
