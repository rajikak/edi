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
    ele_sep: u8,
    seg_sep: u8,

    pub fn init(s: []const u8, ele_sep: u8, seg_sep: u8) Parser {
        return Parser{ .s = s, .ele_sep = ele_sep, .seg_sep = seg_sep };
    }

    pub fn parse(self: Parser) X12Document {
        var options = LexerOptions.init(self.seg_sep, self.ele_sep);
        var lexer = Lexer.init(self.s, options);
        lexer.tokens();

        const buf = lexer.tbuffer();

        var segbuf = std.ArrayList(Token).init(std.heap.page_allocator);

        for (buf.items) |token| {
            if (token.typ == TokenType.eof or token.typ == TokenType.seg_sep or token.typ == TokenType.new_line) {
                std.debug.print("\nsegment: ", .{});
                for (segbuf.items) |token2| {
                    std.debug.print("{s}", .{token2.val});
                }
                std.debug.print("\n", .{});
                segbuf.clearAndFree();
            } else {
                segbuf.append(token) catch @panic("out of memory occured while generating segment buffer");
            }
        }
        var doc = X12Document.init();

        return doc;
    }
};

test "parser.string" {
    const s = "GS*SH*4405197800*999999999*20111206~1045*00*\n004060";

    const p = Parser.init(s, '*', '~');
    const r = p.parse();

    try expect(r.header().typ() == SegmentType.ISA);
}

test "parser.file" {
    _ = "../assets/x12.base.loop.txt";
}
