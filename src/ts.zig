const std = @import("std");

pub const TransactionSet270 = struct {

    store: std.AutoArrayHashMap,

    pub fn init() TransactionSet270 {
        return TransactionSet270 {
            .store = transaction_set270(),
        };
    }
};

fn transaction_set270() std.AutoArrayHashMap {
    const ts = std.AutoArrayHashMap(SegmentType, Segment).init();

    ts.put(SegmentType.ST, Segment.init(SegmentType.ST, "0100", true, "Transaction Set Header"));
    ts.put(SegmentType.BHT, Segment.init(SegmentType.ST, "0200", true, "Begininf of Hierarchical Transaction"));
    ts.put(SegmentType.HL, Segment.init(SegmentType.HL, "0100", true, "Hierarchical Level"));
    ts.put(SegmentType.TRN, Segment.init(SegmentType.TRN, "0200", false, "Trace"));
    ts.put(SegmentType.NM1, Segment.init(SegmentType.NM1, "0300", true, "Invidual or Organizational Name"));
    ts.put(SegmentType.REF, Segment.init(SegmentType.REF, "0400", false, "Reference Information"));
    ts.put(SegmentType.N2, Segment.init(SegmentType.N2, "0500", false, "Additional Name Information"));
    ts.put(SegmentType.S3, Segment.init(SegmentType.S3, "0600", false, "Party Location"));

    return ts;
}

test "ts-270" {
    const ts = TransactionSet270.init();
}
