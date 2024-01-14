const std = @import("std");
const seg = @import("segment.zig");
const tok = @import("lexer.zig");

const SegmentType = seg.SegmentType;
const Segment = seg.Segment;

const Token = tok.Token;

pub const TransactionSet = struct {
    header: Segment,
    trailer: Segment,
    segments: std.ArrayList(Segment),

    pub fn init() TransactionSet {
        return TransactionSet{
            .header = Segment.init(),
            .trailer = Segment.init(),
            .segments = std.ArrayList(Segment).init(),
        };
    }
};

pub const FunctionalGroup = struct {
    header: Segment,
    trailer: Segment,
    transactions: std.ArrayList(TransactionSet),

    pub fn init() FunctionalGroup {
        return FunctionalGroup{
            .header = Segment.init(),
            .trailer = Segment.init(),
            .transactions = std.ArrayList(TransactionSet).init(),
        };
    }
};

pub const InterchangeCtrl = struct {
    header: Segment,
    trailer: Segment,
    fun_grps: std.ArrayList(FunctionalGroup),

    pub fn init() InterchangeCtrl {
        return InterchangeCtrl{
            .header = Segment.init(),
            .trailer = Segment.init(),
            .fun_grps = std.ArrayList(FunctionalGroup).init(),
        };
    }
};

pub const x12 = struct {
    // keep track by functional group index => functional group segments
    buffer: std.AutotArratHashMap,
    ctrl_header: Segment,
    ctrl_trailer: Segment,

    pub fn init(tokens: std.ArrayList(Token)) x12 {
        _ = tokens;
        return x12{ .buffer = std.AutoArrayHashMap(usize, std.ArraList).init() };
    }

    // functional group at
    pub fn fg_at(self: x12, index: usize) *std.ArrayList {
        _ = self;
        _ = index;
    }

    pub fn header(self: x12) Segment {
        return self.ctrl_header;
    }

    pub fn trailer(self: x12) Segment {
        return self.ctrl_trailer;
    }
};
