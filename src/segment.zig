const std = @import("std");
const testing = std.testing;

pub const SegmentType = enum {
    IEA,
    ISA,
    GS,
    GE,
};

// not very scalable approach - seperate data from data strctures
pub const InterchangeControlTrailer = struct {
    typ: SegmentType,
    name: []const u8,
    description: []const u8,

    pub fn init() InterchangeControlTrailer {
        return InterchangeControlTrailer{ .typ = SegmentType.IEA, .name = "Interchange Control Trailer", .description = "To define the end of an interchange of zero or more functional groups and interchange-related control segments" };
    }

    pub fn print(self: InterchangeControlTrailer) void {
        _ = self;
        std.debug.print("type: IEA, name: Interchange Control Trailer\n", .{});
    }
};

pub const InterchangeControlHeader = struct {
    typ: SegmentType,
    name: []const u8,
    description: []const u8,

    pub fn init() InterchangeControlHeader {
        return InterchangeControlHeader{ .typ = SegmentType.ISA, .name = "Interchange Control Header", .description = "To define the end of an interchange of zero or more functional groups and interchange related control segments" };
    }

    pub fn print(self: InterchangeControlHeader) void {
        _ = self;
        std.debug.print("type: ISA, name: Interchange Control Header\n", .{});
    }
};

pub const FunctionalGroupHeader = struct {
    typ: SegmentType,
    name: []const u8,
    description: []const u8,

    pub fn init() FunctionalGroupHeader {
        return FunctionalGroupHeader{ .typ = SegmentType.GS, .name = "Functional Group Header", .description = "To indicate the beginning of a functional group and to provide control information" };
    }
};

pub const FunctionalGroupTrailer = struct {
    typ: SegmentType,
    name: []const u8,
    description: []const u8,

    pub fn init() FunctionalGroupTrailer {
        return FunctionalGroupTrailer{ .typ = SegmentType.GE, .name = "Functional Group Trailer", .description = "To indicate the end of a functional group and to provide control information" };
    }

    pub fn print(self: FunctionalGroupTrailer) void {
        _ = self;
        std.debug.print("type: GE, name: Functional Group Trailer\n", .{});
    }
};
