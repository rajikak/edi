const std = @import("std");
const testing = std.testing;

const lex = @import("lexer.zig");

const Token = lex.Token;
const Allocator = std.heap.page_allocator;

// represent an element in a segment
pub const Element = struct {
    id: []const u8 = "",
    val: []const u8,

    pub fn fromToken(t: Token) Element {
        return Element{ .val = t.val };
    }
};

// represent any segment
pub const Segment = struct {
    ty: SegmentType = SegmentType.ISA,
    elements: std.ArrayList(Element),

    pub fn fromElements(elems: std.ArrayList(Element)) Segment {
        var elements = std.ArrayList(Element).init(Allocator);

        for (elems.items) |e| {
            elements.append(e) catch @panic("out of memory");
        }

        return Segment{ .elements = elements };
    }

    pub fn print(self: Segment) void {
        for (self.elements.items) |element| {
            std.debug.print("{s} ", .{element.val});
        }
        std.debug.print("\n", .{});
    }

    pub fn deinit(self: Segment) void {
        defer self.elements.deinit();
    }
};

pub const SegmentType = enum {
    IEA,
    ISA,
    GS,
    GE,
    ST,
    SE,
};

pub const InterchangeControlHeader = struct {
    ty: SegmentType = SegmentType.ISA,

    // ISA-01
    auth_info_qualifier: []const u8,

    // ISA-02
    auth_info: []const u8,

    // ISA-03
    sec_info_qualifier: []const u8,

    // ISA-04
    sec_info: []const u8,

    // ISA-05
    interchange_id_qualifier: []const u8,

    // ISA-06
    interchange_sender_id: []const u8,

    // ISA-07
    interchange_id_qualifier2: []const u8,

    // ISA-08
    interchange_receiver_id: []const u8,

    // ISA-09
    interchange_date: []const u8,

    // ISA-10
    interchange_time: []const u8,

    // ISA-11
    interchange_ctrl_std_id: []const u8,

    // ISA-12
    interchange_ctrl_version: []const u8,

    // ISA-13
    interchange_ctrl_num: []const u8,

    // ISA-14
    ack_requested: bool,

    // ISA-15
    usage_indicator: []const u8,

    // ISA-16
    ele_separator: []const u8,

    pub fn init(auth_info_qualifier: []const u8, auth_info: []const u8, sec_info_qualifier: []const u8, sec_info: []const u8, interchange_id_qualifier: []const u8, interchange_sender_id: []const u8, interchange_id_qualifier2: []const u8, interchange_receiver_id: []const u8, interchange_date: []const u8, interchange_time: []const u8, interchange_ctrl_std_id: []const u8, interchange_ctrl_version: []const u8, interchange_ctrl_num: []const u8, ack_reqeusted: bool, usage_indicator: []const u8, ele_separator: []const u8) InterchangeControlHeader {
        return InterchangeControlTrailer{
            .auth_info_qualifier = auth_info_qualifier,
            .auth_info = auth_info,
            .sec_info_qualifier = sec_info_qualifier,
            .sec_info = sec_info,
            .interchange_id_qualifier = interchange_id_qualifier,
            .interchange_sender_id = interchange_sender_id,
            .interchange_id_qualifier2 = interchange_id_qualifier2,
            .interchange_receiver_id = interchange_receiver_id,
            .interchange_date = interchange_date,
            .interchange_time = interchange_time,
            .interchange_ctrl_std_id = interchange_ctrl_std_id,
            .interchange_ctrl_version = interchange_ctrl_version,
            .interchange_ctrl_num = interchange_ctrl_num,
            .ack_reqeusted = ack_reqeusted,
            .usage_indicator = usage_indicator,
            .ele_separator = ele_separator,
        };
    }

    pub fn print(self: InterchangeControlHeader) void {
        _ = self;
        std.debug.print("type: IEA, name: Interchange Control Trailer\n", .{});
    }
};

pub const InterchangeControlTrailer = struct {
    ty: SegmentType = SegmentType.IEA,

    // IEA-01
    num_of_functional_grps: usize,

    // IEA-02
    interchange_ctrl_num: []const u8,

    pub fn init(num_of_functional_grps: usize, interchange_ctrl_num: []const u8) InterchangeControlTrailer {
        return InterchangeControlTrailer{ .num_of_functional_grps = num_of_functional_grps, .interchange_ctlr_num = interchange_ctrl_num };
    }

    pub fn print(self: InterchangeControlTrailer) void {
        _ = self;
        std.debug.print("type: ISA, name: Interchange Control Header\n", .{});
    }
};

pub const FunctionalGroupHeader = struct {
    ty: SegmentType = SegmentType.GS,

    pub fn init() FunctionalGroupHeader {
        return FunctionalGroupHeader{};
    }
};

pub const FunctionalGroupTrailer = struct {
    typ: SegmentType = SegmentType.SE,

    pub fn init() FunctionalGroupTrailer {
        return FunctionalGroupTrailer{};
    }

    pub fn print(self: FunctionalGroupTrailer) void {
        _ = self;
        std.debug.print("type: GE, name: Functional Group Trailer\n", .{});
    }
};

pub const TransactionSetHeader = struct {
    ty: SegmentType = SegmentType.ST,

    pub fn init() TransactionSetHeader {
        return TransactionSetHeader{};
    }
};

pub const TransactionSetTrailer = struct {
    ty: SegmentType = SegmentType.SE,

    pub fn init() TransactionSetTrailer {
        return TransactionSetTrailer{};
    }
};
