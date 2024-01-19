const std = @import("std");
const seg = @import("segment.zig");
const tok = @import("lexer.zig");

const Segment = seg.Segment;
const SegmentType = seg.SegmentType;
const InterchangeControlTrailer = seg.InterchangeControlTrailer;
const InterchangeControlHeader = seg.InterchangeControlHeader;
const FunctionalGroupHeader = seg.FunctionalGroupHeader;
const FunctionalGroupTrailer = seg.FunctionalGroupTrailer;
const TransactionSetHeader = seg.TransactionSetHeader;
const TransactionSetTrailer = seg.TransactionSetTrailer;

const Token = tok.Token;

pub const TransactionSet = struct {
    buffer: std.ArrayList(Segment),
    head: TransactionSetHeader,
    trail: TransactionSetTrailer,

    pub fn init() TransactionSet {
        return TransactionSet{
            .buffer = std.ArrayList(TransactionSet).init(std.heap.page_allocator),
            .head = TransactionSetHeader.init(),
            .trail = TransactionSetTrailer.init(),
        };
    }
};

pub const FunctionalGroup = struct {
    buffer: std.ArrayList(TransactionSet),
    head: FunctionalGroupHeader,
    trail: FunctionalGroupTrailer,

    pub fn init() FunctionalGroup {
        return FunctionalGroup{
            .buffer = std.ArrayList(TransactionSet).init(std.heap.page_allocator),
            .head = FunctionalGroupHeader.init(),
            .trail = FunctionalGroupTrailer.init(),
        };
    }
};

pub const X12Document = struct {
    // keep track by functional group in order
    buffer: std.ArrayList(FunctionalGroup),
    head: InterchangeControlHeader,
    trail: InterchangeControlTrailer,

    pub fn init(head: InterchangeControlHeader, trail: InterchangeControlTrailer) X12Document {
        return X12Document{ .head = head, .trail = trail };
    }

    // functional group at
    pub fn fg_at(self: X12Document, index: usize) std.ArrayList {
        _ = self;
        _ = index;
    }

    pub fn header(self: X12Document) InterchangeControlHeader {
        return self.head;
    }

    pub fn trailer(self: X12Document) InterchangeControlTrailer {
        return self.trail;
    }
};
