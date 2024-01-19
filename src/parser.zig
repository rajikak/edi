const std = @import("std");

const lex = @import("lexer.zig");
const seg = @import("segment.zig");
const lib = @import("lib.zig");
const x12 = @import("x12.zig");

const LexerOptions = lex.LexerOptions;
const Lexer = lex.Lexer;
const SegmentType = seg.SegmentType;
const InterchangeControlTrailer = seg.InterchangeControlTrailer;
const InterchangeControlHeader = seg.InterchangeControlHeader;

const Token = lex.Token;
const TokenType = lex.TokenType;
const X12Document = x12.X12Document;

const testing = std.testing;
const expect = testing.expect;

// parse and produce an x12 document from an EDI stream
pub const Parser = struct {
    s: []const u8,
    ele_separator: u8,
    seg_separator: u8,

    pub fn init(s: []const u8, ele_separator: u8, seg_separator: u8) Parser {
        return Parser{ .s = s, .ele_separator = ele_separator, .seg_separator = seg_separator };
    }

    pub fn parse(self: Parser) void {
        var options = LexerOptions.init(self.seg_separator, self.ele_separator);
        var lexer = Lexer.init(self.s, options);
        lexer.tokens();

        const buf = lexer.tbuffer();

        var segbuf = std.ArrayList([]const u8).init(std.heap.page_allocator);
        defer segbuf.deinit();

        var segs = std.ArrayList([][]const u8).init(std.heap.page_allocator);
        defer segs.deinit();

        for (buf.items) |token| {
            if (token.typ == TokenType.eof or token.typ == TokenType.seg_sep or token.typ == TokenType.new_line) {
                segs.append(segbuf.items) catch @panic("out of memory occured while saving the segment");
                segbuf.clearAndFree();
            } else {
                segbuf.append(token.val) catch @panic("out of memory occured while generating segment");
            }
        }
    }
};

test "parser.string" {
    const s = "GS*SH*4405197800*999999999*20111206~1045*00*\n004060";

    const p = Parser.init(s, '*', '~');
    const r = p.parse();
    _ = r;
}

test "parser.file" {
    _ = "../assets/x12.base.loop.txt";
}
