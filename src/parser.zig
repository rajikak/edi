const std = @import("std");

const lex = @import("lexer.zig");
const seg = @import("segment.zig");
const lib = @import("lib.zig");
const x12 = @import("x12.zig");

const Token = lex.Token;
const TokenType = lex.TokenType;
const LexerOptions = lex.LexerOptions;
const Lexer = lex.Lexer;

const Element = seg.Element;
const Segment = seg.Segment;
const SegmentType = seg.SegmentType;
const InterchangeControlTrailer = seg.InterchangeControlTrailer;
const InterchangeControlHeader = seg.InterchangeControlHeader;

const X12Document = x12.X12Document;

const testing = std.testing;
const expect = testing.expect;
const allocator = std.heap.page_allocator;

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

        var segbuf = std.ArrayList(Segment).init(std.heap.page_allocator);
        defer segbuf.deinit();

        var elebuf = std.ArrayList(Element).init(std.heap.page_allocator);
        defer elebuf.deinit();

        for (lexer.tbuffer().items) |token| {
            if (token.typ == TokenType.ele_separator) {
                continue;
            } else if (token.typ == TokenType.eof or token.typ == TokenType.seg_separator or token.typ == TokenType.new_line) {
                const s = Segment.fromElements(elebuf);
                segbuf.append(s) catch @panic("out of memory");
                elebuf.clearAndFree();
            } else {
                elebuf.append(Element.fromToken(token)) catch @panic("out of memory");
            }
        }

        for (segbuf.items) |s| {
            std.debug.print("segment: ", .{});
            s.print();
            std.debug.print("\n", .{});
        }
    }
};

test "parser.string" {
    //const s = "GS*SH~12*34~XY*ZT~KLMBO";
    //const s = "GS*SH~1234*AB*CD";
    const s = "GS*SH*4405197800*999999999*20111206~1045*00*\n004060";

    const p = Parser.init(s, '*', '~');
    const r = p.parse();
    _ = r;
}

test "parser.file" {
    _ = "../assets/x12.base.loop.txt";
}
