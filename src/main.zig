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
    // use flags
    const use_default = true;
    const use_file = false;

    const s1 = "GS*SH*4405197800*999999999*20111206*1045*00*X*004060";

    const file = "../assets/x12.base.one.txt";
    const s2 = try lib.readfile(file, allocator);

    var ele_sep: u8 = '_';
    var seg_sep: u8 = '^';
    if (use_default) {
        ele_sep = lex.default_element_sep;
        seg_sep = lex.default_segment_sep;
    }

    if (use_file) {
        const p = Parser.init(s2, ele_sep, seg_sep);
        p.parse();
    } else {
        const p = Parser.init(s1, ele_sep, seg_sep);
        p.parse();
    }
}
