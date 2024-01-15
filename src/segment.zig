const std = @import("std");
const testing = std.testing;

pub const Segment = struct {
    val: SegmentType, // segment type
    name: []const u8, // name of the segment
    description: []const u8, // description of the segment

    pub fn init(val: SegmentType, name: []const u8, description: []const u8) Segment {
        return Segment{
            .val = val,
            .name = name,
            .description = description,
        };
    }

    pub fn print(self: Segment) void {
        std.debug.print("\nSegment: value={},", .{self.val});
        std.debug.print("name={s}, ", .{self.name});
        std.debug.print("description={s}\n", .{self.description});
    }
};

pub const SegmentType = enum {
    IEA,
    ISA,
};

pub const Segments = struct {
    pub fn interchangeControlHeader() Segment {
        return Segment{ .val = SegmentType.IEA, .name = "Interchange Control Trailer", .description = "To define the end of an interchange of zero or more functional groups and interchange-related control segments" };
    }

    pub fn interchangeControlTrailer() Segment {
        return Segment{ .val = SegmentType.ISA, .name = "Interchange Control Header", .description = "To start and identify an interchange of zero or more functional groups and interchange-related control segments" };
    }
};
