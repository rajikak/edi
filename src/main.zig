const std = @import("std");
const lex = @import("lexer.zig");
const seg = @import("segment.zig");
const lib = @import("lib.zig");
const parser = @import("parser.zig");
const allocator = std.heap.page_allocator;

const SegmentType = seg.SegmentType;
const Segment = seg.Segment;
const LexerOptions = lex.LexerOptions;
const Lexer = lex.Lexer;
const Token = lex.Token;

const Parser = parser.Parser;

pub fn main() !void {
    const ele_sep: u8 = '_';
    const seg_sep: u8 = '^';

    const s = "GS*SH*4405197800*999999999*20111206*1045*00*X*004060";

    const p = Parser.init(s, ele_sep, seg_sep);
    const x12 = p.parse();
    x12.print();
}
