const std = @import("std");
const testing = std.testing;

const Segment = struct {
    val: SegmentType, // segment type
    position: []u8, // position in the document
    required: bool, // if this segment is required
    description: []u8, // description of the segment

    pub fn init(val: SegmentType, position: []u8, required: bool, description: []u8) Segment {
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

const SegmentType = enum {
    ST, // Transaction Set Header
    BHT, // Begining of Hierachical Transaction
    HL, // Hierachical Level
    TRN, // Trace
    NM1, // Invidual or Organizational Name
    REF, // Reference Information
    N2, // Additional Name Information
    N3, // Party Location
};

pub fn transaction_set() std.AutoArrayHashMap {
    const ts = std.AutoArrayHashMap(SegmentType, Segment).init();

    ts.put(SegmentType.ST, Segment.init(SegmentType.ST, "0100", true, "Transaction Set Header"));

    return ts;
}

test "segment" {
    const s = transaction_set();

    const val = s.get(SegmentType.ST);
    if (val) |v| {
        v.print();
    }
    //try expect(s.)
}
