const std = @import("std");
const seg = @import("segment.zig");
const SegmentType = seg.SegmentType;
const Segment = seg.Segment;
const testing = std.testing;

pub const TransactionSet270 = struct {
    store: std.AutoArrayHashMap,

    pub fn init() TransactionSet270 {
        return TransactionSet270{
            .store = transaction_set270(),
        };
    }
};

fn transaction_set270() std.AutoArrayHashMap {
    const ts = std.AutoArrayHashMap(SegmentType, Segment).init();

    ts.put(SegmentType.ST, Segment.init(SegmentType.ST, "0100", true, "Transaction Set Header", 1));
    ts.put(SegmentType.BHT, Segment.init(SegmentType.ST, "0200", true, "Begininf of Hierarchical Transaction"), 1);
    ts.put(SegmentType.HL, Segment.init(SegmentType.HL, "0100", true, "Hierarchical Level"), 1);
    ts.put(SegmentType.TRN, Segment.init(SegmentType.TRN, "0200", false, "Trace"), 9);
    ts.put(SegmentType.NM1, Segment.init(SegmentType.NM1, "0300", true, "Invidual or Organizational Name"), 1);
    ts.put(SegmentType.REF, Segment.init(SegmentType.REF, "0400", false, "Reference Information"), 9);
    ts.put(SegmentType.N2, Segment.init(SegmentType.N2, "0500", false, "Additional Name Information"), 1);
    ts.put(SegmentType.N3, Segment.init(SegmentType.N3, "0600", false, "Party Location"), 1);

    return ts;
}

test "ts-270" {
    const ts = TransactionSet270.init();

    var value = ts.get(SegmentType.ST);
    if (value) |v| {
        try testing.expect(v.val == SegmentType.ST);
    } else {}
}
