const std = @import("std");
const lib = @import("lib.zig");
const mem = std.mem;
const allocator = std.heap.page_allocator;

const testing = std.testing;
const expect = testing.expect;
const test_allocator = std.testing.allocator;

pub const eof = "-1";
pub const default_segment_sep = '~';
pub const default_segment_sep_as_str: []const u8 = "~";

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
        } else if (self == TokenType.seg_sep) {
            return "ItemType => segment seperator";
        } else if (self == TokenType.ele_sep) {
            return "ItemType => element seperator";
        } else {
            return "ItemType => uknown";
        }
    }
};

// token represents a token of a text string returned from the scanner
pub const Token = struct {
    typ: TokenType, // the type of this token.
    pos: usize, // the starting position, in bytes, of this item in the input string.
    val: []const u8, // the value of this item.
    line: usize, // the line number at the start of this item.

    pub fn init(typ: TokenType, pos: usize, val: []const u8, line: usize) Token {
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
    start: usize, // start position of the item
    pos: usize, // current position of the input
    at_eof: bool, // we have hit the end of input and returned eof
    options: LexerOptions, // configuration for lexer
    buffer: std.ArrayList(Token), // buffer to hold tokens

    pub fn init(input: []const u8, options: LexerOptions) Lexer {
        const start_at = 0;
        const start_position = 0;
        var buf = std.ArrayList(Token).init(std.heap.page_allocator);
        return Lexer{ .input = input, .start = start_at, .pos = start_position, .at_eof = false, .options = options, .buffer = buf };
    }

    pub fn deinit(self: Lexer) void {
        defer self.buffer.deinit();
    }

    pub fn plexstr(self: Lexer) void {
        std.debug.print("EDI: {s}\n", .{self.input});
    }

    pub fn pbuffer(self: Lexer) void {
        for (self.buffer.items) |item| {
            item.print();
        }
    }

    pub fn size(self: Lexer) usize {
        return self.buffer.items.len;
    }

    fn peek(self: Lexer) u8 {
        if (self.pos + 1 < self.input.len) {
            return self.input[self.pos + 1];
        }
        return 0;
    }

    fn value(self: Lexer) []const u8 {
        var str: []const u8 = "";
        for (self.buffer.items) |item| {
            if (item.typ == TokenType.eof) {
                continue;
            }
            str = std.fmt.allocPrint(allocator, "{s}{s}", .{ str, item.val }) catch "format failed";
        }
        return str;
    }

    // return the next token, loop ends when the token is TokenType.eof
    fn next(self: *Lexer) Token {
        var line: u8 = 0;

        const ele_sep = std.fmt.allocPrint(std.heap.page_allocator, "{c}", .{self.options.ele_sep}) catch default_element_sep_as_str;

        const seg_sep = std.fmt.allocPrint(std.heap.page_allocator, "{c}", .{self.options.seg_sep}) catch default_segment_sep_as_str;

        // ST*
        // ST
        // ST\n
        // AS*ST
        // AS*\nST
        // ST*AAA
        // TST*123

        while (true) : (self.pos += 1) {
            if (self.pos == self.input.len) {
                self.at_eof = true;
                return Token.init(TokenType.eof, self.pos, eof, line);
            }
            const char = self.input[self.pos];
            if (char == '\n' or char == self.options.seg_sep) {
                if (char == '\n') {
                    line += 1;
                }
                self.pos += 1;
                self.start = self.pos;
                // consider '\n' as a segement seperator
                return Token.init(TokenType.seg_sep, self.pos, seg_sep, line);
            } else if (char == self.options.ele_sep) {
                self.pos += 1;
                self.start = self.pos;
                return Token.init(TokenType.ele_sep, self.pos, ele_sep, line);
            } else if (self.pos + 1 < self.input.len) {
                const next_char: u8 = self.peek();
                if (next_char == self.options.ele_sep or next_char == self.options.seg_sep) {
                    const tv: []const u8 = self.input[self.start .. self.pos + 1];
                    self.pos += 1;
                    self.start = self.pos;
                    return Token.init(TokenType.identifier, self.pos, tv, line);
                } else {
                    continue;
                }
            } else {
                const tv: []const u8 = self.input[self.start .. self.pos + 1];
                self.pos += 1;
                self.start = self.pos;
                return Token.init(TokenType.identifier, self.pos, tv, line);
            }
        }
    }

    pub fn tokens(self: *Lexer) void {
        while (true) {
            const token: Token = self.next();
            self.buffer.append(token) catch @panic("out of memory occured");
            if (token.typ == TokenType.eof) {
                break;
            }
        }
    }
};

test "segments" {
    const result = struct {
        len: u8,
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
        tst{ .input = input{ .s = "ST*", .default_sep = true }, .expected = result{ .len = 2 } },
        //tst{ .input = input{ .s = "ST*\n", .default_sep = true }, .expected = result{ .len = 1 } },
        tst{ .input = input{ .s = "ST*AAA*0001", .default_sep = true }, .expected = result{ .len = 5 } },
        tst{ .input = input{ .s = "TST", .default_sep = true }, .expected = result{ .len = 1 } },
        tst{ .input = input{ .s = "TST~", .default_sep = true }, .expected = result{ .len = 2 } },
        tst{ .input = input{ .s = "TST*123", .default_sep = true }, .expected = result{ .len = 3 } },
        tst{ .input = input{ .s = "TST*123~", .default_sep = true }, .expected = result{ .len = 4 } },
        tst{ .input = input{ .s = "DXS*9251230013*DX*004010UCS*1*9254850000", .default_sep = true }, .expected = result{ .len = 11 } },
        tst{ .input = input{ .s = "DXS_9251230013_DX_004010UCS_1_9254850000", .default_sep = false }, .expected = result{ .len = 11 } },
    };

    for (tests) |t| {
        var ele_sep: u8 = '_';

        if (t.input.default_sep) {
            ele_sep = default_element_sep;
        }
        var options = LexerOptions.init(default_segment_sep, ele_sep);
        var lexer = Lexer.init(t.input.s, options);
        lexer.tokens();

        try expect(t.expected.len == lexer.size() - 1);
        try expect(std.mem.eql(u8, t.input.s, lexer.value()) == true);
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
        //tst{ .input = input{ .file = "../assets/x12.base.loop-1.txt", .default_sep = true }, .expected = result{ .lines = 2 } },
        //tst{ .input = input{ .file = "../assets/x12.base.loop.txt", .default_sep = true }, .expected = result{ .len = 10, .last = "000000049" } },
        //tst{ .input = input{ .file = "../assets/x12.base.no.line.breaks.empty.line.txt", .default_sep = true }, .expected = result{ .len = 10, .last = "000000049" } },
        //tst{ .input = input{ .file = "../assets/x12.base.no.line.breaks.odd.char.txt", .default_sep = true }, .expected = result{ .len = 10, .last = "000000049" } },
        //tst{ .input = input{ .file = "../assets/x12.base.one.txt", .default_sep = true }, .expected = result{ .len = 10, .last = "000000049" } },
        //tst{ .input = input{ .file = "../assets/x12.base.txt", .default_sep = true }, .expected = result{ .len = 10, .last = "000000049" } },
    };

    for (tests) |t| {
        var ele_sep: u8 = '_';
        if (t.input.default_sep) {
            ele_sep = default_element_sep;
        }
        const content = try lib.read_file(t.input.file, test_allocator);
        defer test_allocator.free(content);
        var options = LexerOptions.init(default_segment_sep, ele_sep);
        var lexer = Lexer.init(content, options);
        lexer.tokens();

        std.debug.print("content: {s}\n", .{content});
        std.debug.print("lexer: {s}\n", .{lexer.value()});
        //try expect(std.mem.eql(u8, content, lexer.value()) == true);
    }
}
