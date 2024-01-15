const std = @import("std");
const testing = std.testing;

pub const SegmentType = enum {
    IEA,
    ISA,
};

pub const InterchangeControlTrailer = struct {
    typ: SegmentType,
    name: []const u8,
    description: []const u8,

    pub fn init() InterchangeControlTrailer {
        return InterchangeControlTrailer{ .typ = SegmentType.IEA, .name = "Interchange Control Trailer", .description = "To define the end of an interchange of zero or more functional groups and interchange-related control segments" };
    }
};

// not very scalable approach - seperate data from data strctures
pub const InterchangeControlHeader = struct {
    typ: SegmentType,
    name: []const u8,
    description: []const u8,

    pub fn init() InterchangeControlHeader {
        return InterchangeControlHeader{ .typ = SegmentType.ISA, .name = "Interchange Control Trailer", .description = "To define the end of an interchange of zero or more functional groups and interchange related control segments" };
    }
};
