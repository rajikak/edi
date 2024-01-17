const std = @import("std");
const lex = @import("lexer.zig");
const seg = @import("segment.zig");
const lib = @import("lib.zig");
const parser = @import("parser.zig");
const x12 = @import("x12.zig");

const allocator = std.heap.page_allocator;

const SegmentType = seg.SegmentType;

const LexerOptions = lex.LexerOptions;
const Lexer = lex.Lexer;
const Token = lex.Token;

const X12Document = x12.X12Document;

pub fn main() !void {
    const ele_sep: u8 = '_';
    const seg_sep: u8 = '^';

    const s = "GS*SH*4405197800*999999999*20111206*1045*00*X*004060";

    const Parser = parser.Parser;
    const p = Parser.init(s, ele_sep, seg_sep);
    const r = p.parse();
    r.header().print();
    r.trailer().print();
}
