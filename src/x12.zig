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
};

pub const functional_grp = struct {
    header: Segment,
    trailer: Segment,
    transactions: std.ArrayList(transaction_set),
};

pub const interchange_ctrl = struct {
    header: Segment,
    trailer: Segment,
    fun_grps: std.ArrayList(functional_grp),
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
