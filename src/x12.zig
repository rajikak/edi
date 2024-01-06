const std = @import("std");
const seg = @import("segment.zig");
const tok = @import("lexer.zig");

const SegmentType = seg.SegmentType;
const Segment = seg.Segment;

const Token = tok.Token;

pub const transaction_set = struct {
    header: Segment,
    trailer: Segment,
    segments: std.ArrayList(Segment),

    pub fn init() transaction_set {
        return transaction_set{
            .header = Segment.init(),
            .trailer = Segment.init(),
            .segments = std.ArrayList(Segment).init(),
        };
    }
};

pub const functional_grp = struct {
    header: Segment,
    trailer: Segment,
    transactions: std.ArrayList(transaction_set),

    pub fn init() functional_grp {
        return functional_grp{
            .header = Segment.init(),
            .trailer = Segment.init(),
            .transactions = std.ArrayList(transaction_set).init(),
        };
    }
};

pub const interchange_ctrl = struct {
    header: Segment,
    trailer: Segment,
    fun_grps: std.ArrayList(functional_grp),

    pub fn init() interchange_ctrl {
        return interchange_ctrl{
            .header = Segment.init(),
            .trailer = Segment.init(),
            .fun_grps = std.ArrayList(functional_grp).init(),
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
