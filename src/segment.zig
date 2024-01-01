const std = @import("std");
const testing = std.testing;

const Segment = struct {
    val: SegmentType, // segment type
    position: []const u8, // position in the document
    required: bool, // if this segment is required
    description: []const u8, // description of the segment
    max: u8, // max use allowe

    pub fn init(val: SegmentType, position: []const u8, required: bool, description: []const u8, max: u8) Segment {
        return Segment{
            .val = val,
            .position = position,
            .required = required,
            .description = description,
            .max = max,
        };
    }

    pub fn print(self: Segment) void {
        std.debug.print("\nSegment: value={},", .{self.val});
        std.debug.print("position={s}, ", .{self.position});
        std.debug.print("required={}, ", .{self.required});
        std.debug.print("description={s},", .{self.description});
        std.debug.print("max={}\n", .{self.max});
    }
};

pub const SegmentType = enum { ST, BHT, HL, TRN, NM1, REF, N2, N3, N4, PER, PRV, DMG, INS, HI, DTP, MPI, EQ, AMT, VEH, PDR, PDP, III, TOO, SE };

test "segment1" {
    const s = Segment.init(SegmentType.ST, "0100", true, "Transaction Set Header", 1);
    try testing.expect(s.val == SegmentType.ST);
    try testing.expect(std.mem.eql(u8, s.position, "0100") == true);
    try testing.expect(s.required == true);

    s.print();
}

test "segment2" {
    const s = Segment.init(SegmentType.ST, "0200", true, "Transaction Set Header", 1);
    try testing.expect(std.mem.eql(u8, s.position, "0200") == true);

    s.print();
}

test "segment3" {
    const s = Segment.init(SegmentType.ST, "0300", true, "Transaction Set Header", 1);
    s.print();
}
