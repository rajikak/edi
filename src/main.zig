const std = @import("std");
const lex = @import("lexer.zig");
const seg = @import("segment.zig");
const lib = @import("lib.zig");

const SegmentType = seg.SegmentType;
const Segment = seg.Segment;
const LexerOptions = lex.LexerOptions;
const Lexer = lex.Lexer;

const Token = lex.Token;

pub fn main() !void {
    const allocator = std.heap.page_allocator;
    var buffer = std.ArrayList(Token).init(allocator);
    defer buffer.deinit();

    // use flags
    const use_default = true;
    const use_file = false;
    const file = "assets/x12.base.one.txt";

    var ele_sep: u8 = '_';
    if (use_default) {
        ele_sep = lex.default_element_sep;
    }

    var options = LexerOptions.init(lex.default_segment_sep, ele_sep);
    if (use_file) {
        const content = try lib.read_file(file, allocator);
        var lexer = Lexer.init(content, 0, 0, false, options);
        lexer.tokens(&buffer);
    } else {
        const s = "GS*SH*4405197800*999999999*20111206*1045*00*X*004060";
        var lexer = Lexer.init(s, 0, 0, false, options);
        lexer.tokens(&buffer);
    }
}
