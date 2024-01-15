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
const X12Document = x12.X12Document;

// parse and produce an x12 document from an EDI stream
pub const Parser = struct {
    s: []const u8,
    options: LexerOptions,

    pub fn init(s: []const u8, ele_sep: u8, seg_sep: u8) Parser {
        var options = LexerOptions.init(seg_sep, ele_sep);
        return Parser{ .s = s, .options = options };
    }

    pub fn parse(self: Parser) X12Document {
        var lexer = Lexer.init(self.s, self.options);
        lexer.tokens();

        var doc = X12Document.init();

        return doc;
    }
};

test "string" {
    _ = "GS*SH*4405197800*999999999*20111206*1045*00*X*004060";
    return error.SkipZigTest;
}

test "file" {
    _ = "../assets/x12.base.loop.txt";
    return error.SkipZigtest;
}
