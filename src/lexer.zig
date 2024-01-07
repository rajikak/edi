const std = @import("std");
const lib = @import("lib.zig");
const testing = std.testing;
const expect = testing.expect;
const mem = std.mem;
const test_allocator = std.testing.allocator;

pub const eof: u8 = -1;
pub const default_segment_sep: u8 = '~';
const default_segment_sep_as_str: []const u8 = "~";

pub const default_element_sep: u8 = '*';
const default_element_sep_as_str: []const u8 = "*";

pub const TokenType = enum {
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
pub const Token = struct {
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

pub const LexerOptions = struct {
    seg_sep: u8,
    ele_sep: u8,

    pub fn init(seg_sep: u8, ele_sep: u8) LexerOptions {
        return LexerOptions{ .seg_sep = seg_sep, .ele_sep = ele_sep };
    }
};

pub const Lexer = struct {
    input: []const u8,
    start: u8, // start position of the item
    pos: u8, // current position of the input
    at_eof: bool, // we have hit the end of input and returned eof
    options: LexerOptions, // configuration for lexer

    pub fn init(input: []const u8, start: u8, pos: u8, at_eof: bool, options: LexerOptions) Lexer {
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
        var line: u8 = 0;

        const ele_sep = self.options.ele_sep;
        const ele_sep_str = std.fmt.allocPrint(std.heap.page_allocator, "{c}", .{ele_sep}) catch default_element_sep_as_str;

        const seg_sep = self.options.seg_sep;
        const seg_sep_str = std.fmt.allocPrint(std.heap.page_allocator, "{c}", .{seg_sep}) catch default_segment_sep_as_str;

        while (true) : (self.pos += 1) {
            if (self.pos == self.input.len) {
                self.at_eof = true;
                return Token.init(TokenType.eof, self.pos, "", line);
            }
            if (self.pos + 1 == self.input.len) {
                const tv: []const u8 = self.input[self.start .. self.pos + 1];
                self.pos += 1;
                return Token.init(TokenType.identifier, self.pos, tv, line);
            }

            if (self.input[self.pos] == '\n') {
                line += 1;
                self.start = self.pos;
            }

            const ch: u8 = self.peek();
            if (ch == self.options.ele_sep or ch == self.options.seg_sep) {
                const tv: []const u8 = self.input[self.start .. self.pos + 1];
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

    pub fn tokens(self: *Lexer, store: *std.ArrayList(Token)) void {
        while (true) {
            const token: Token = self.next();
            store.append(token) catch @panic("out of memory occured");
            if (token.typ == TokenType.eof) {
                break;
            }
        }
    }
};

pub fn print_buffer(s: []const u8, buffer: std.ArrayList(Token)) void {
    std.debug.print("\n{s}\n", .{s});
    for (buffer.items) |item| {
        item.print();
    }
}

test "segments" {
    const result = struct {
        len: u8,
        last: []const u8,
    };

    const input = struct {
        s: []const u8,
        default_sep: bool,
    };

    const tst = struct {
        input: input,
        expected: result,
    };

    const tests = [_]tst{
        tst{ .input = input{ .s = "TST", .default_sep = true }, .expected = result{ .len = 1, .last = "TST" } },
        tst{ .input = input{ .s = "TST~", .default_sep = true }, .expected = result{ .len = 2, .last = "~" } },
        tst{ .input = input{ .s = "TST*123", .default_sep = true }, .expected = result{ .len = 3, .last = "123" } },
        tst{ .input = input{ .s = "TST*123~", .default_sep = true }, .expected = result{ .len = 4, .last = "~" } },
        tst{ .input = input{ .s = "DXS*9251230013*DX*004010UCS*1*9254850000", .default_sep = true }, .expected = result{ .len = 11, .last = "9254850000" } },
        tst{ .input = input{ .s = "DXS_9251230013_DX_004010UCS_1_9254850000", .default_sep = false }, .expected = result{ .len = 11, .last = "9254850000" } },
    };

    for (tests) |t| {
        var buffer = std.ArrayList(Token).init(test_allocator);
        defer buffer.deinit();

        var ele_sep: u8 = '_';

        if (t.input.default_sep) {
            ele_sep = default_element_sep;
        }
        var options = LexerOptions.init(default_segment_sep, ele_sep);
        var lexer = Lexer.init(t.input.s, 0, 0, false, options);
        lexer.tokens(&buffer);

        try expect(t.expected.len == buffer.items.len - 1);
        try expect(std.mem.eql(u8, t.expected.last, buffer.getLast().val) == true);

        print_buffer(t.input.s, buffer);
    }
}

test "large segments" {
    const input = struct {
        file: []const u8,
        default_sep: bool,
    };

    const result = struct {
        lines: u8,
    };

    const tst = struct {
        input: input,
        expected: result,
    };

    const tests = [_]tst{
        tst{ .input = input{ .file = "../assets/x12.base.loop-1.txt", .default_sep = true }, .expected = result{ .lines = 2 } },
        //tst{ .input = input{ .file = "../assets/x12.base.loop.txt", .default_sep = true }, .expected = result{ .len = 10, .last = "000000049" } },
        //tst{ .input = input{ .file = "../assets/x12.base.no.line.breaks.empty.line.txt", .default_sep = true }, .expected = result{ .len = 10, .last = "000000049" } },
        //tst{ .input = input{ .file = "../assets/x12.base.no.line.breaks.odd.char.txt", .default_sep = true }, .expected = result{ .len = 10, .last = "000000049" } },
        //tst{ .input = input{ .file = "../assets/x12.base.one.txt", .default_sep = true }, .expected = result{ .len = 10, .last = "000000049" } },
        //tst{ .input = input{ .file = "../assets/x12.base.txt", .default_sep = true }, .expected = result{ .len = 10, .last = "000000049" } },
    };

    const allocator = std.heap.page_allocator;
    for (tests) |t| {
        var buffer = std.ArrayList(Token).init(test_allocator);
        defer buffer.deinit();

        var ele_sep: u8 = '_';
        if (t.input.default_sep) {
            ele_sep = default_element_sep;
        }
        const content = try lib.read_file(t.input.file, allocator);
        var options = LexerOptions.init(default_segment_sep, ele_sep);
        var lexer = Lexer.init(content, 0, 0, false, options);
        lexer.tokens(&buffer);

        //print_buffer(content, buffer);
    }
}
