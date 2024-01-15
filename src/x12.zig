const std = @import("std");
const seg = @import("segment.zig");
const tok = @import("lexer.zig");

const SegmentType = seg.SegmentType;
const InterchangeControlTrailer = seg.InterchangeControlTrailer;
const InterchangeControlHeader = seg.InterchangeControlHeader;

const Token = tok.Token;

pub const X12Document = struct {
    // keep track by functional group index => functional group segments
    //buffer: std.AutoArrayHashMap(SegmentType, Segment),
    header: InterchangeControlHeader,
    trailer: InterchangeControlTrailer,

    pub fn init() X12Document {
        //const alloc = std.heap.page_allocator;
        return X12Document{
            //.buffer = std.AutoArrayHashMap(SegmentType, Segment).init(alloc),
            .header = InterchangeControlHeader.init(),
            .trailer = InterchangeControlTrailer.init(),
        };
    }

    // functional group at
    pub fn fg_at(self: X12Document, index: usize) std.ArrayList {
        _ = self;
        _ = index;
    }

    pub fn header(self: X12Document) InterchangeControlHeader {
        return self.header;
    }

    pub fn trailer(self: X12Document) InterchangeControlTrailer {
        return self.trailer;
    }

    pub fn print(self: X12Document) void {
        _ = self;
        std.debug.print("x12 document\n", .{});
    }
};
