const std = @import("std");
const testing = std.testing;

const Segment = struct {
    val: SegmentType, // segment type
    position: []const u8, // position in the document
    required: bool, // if this segment is required
    description: []const u8, // description of the segment

    pub fn init(val: SegmentType, position: []const u8, required: bool, description: []const u8) Segment {
        return Segment{
            .val = val,
            .position = position,
            .required = required,
            .description = description,
        };
    }

    pub fn print(self: Segment) []const u8 {
        //std.debug.print("Segment: value={},", {.self.val});
        //std.debug.print("position={}, ", {.self.position});
        //std.debug.print("required={}, ", {.self.required});
        //std.debug.print("description={}\n", {.self.description});
        return self.val;
    }
};

pub const SegmentType = enum {
    ST,
    BHT,
    HL,
    TRN,
    NM1,
    REF,
    N2,
    N3,
};

test "segment" {
    const s = Segment.init(SegmentType.ST, "0100", true, "Transaction Set Header");
    try testing.expect(s.val == SegmentType.ST);
    try testing.expect(std.mem.eql(u8, s.position, "0100") == true);
    try testing.expect(s.required == true);
}
