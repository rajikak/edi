const std = @import("std");

const lex = @import("lexer.zig");
const seg = @import("segment.zig");
const lib = @import("lib.zig");
const x12 = @import("x12.zig");

const SegmentType = seg.SegmentType;
const Segment = seg.Segment;
const LexerOptions = lex.LexerOptions;
const Lexer = lex.Lexer;

const Token = lex.Token;

// parse and produce an x12 document from an EDI stream
pub const Parser = struct {
    s: []const u8,
    options: LexerOptions,

    pub fn init(s: []const u8, ele_sep: u8, seg_sep: u8) Parser {
        var options = LexerOptions.init(seg_sep, ele_sep);
        return Parser{ .s = s, .options = options };
    }

    pub fn parse(self: Parser) void {
        var lexer = Lexer.init(self.s, self.options);
        lexer.tokens();
        lexer.pbuffer();
    }
};

// implement tests for using parser from a string and file
