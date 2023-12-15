pub const Segment = struct {
    val: SegmentType,
    pos: []u8,
};

pub const SegmentType = enum {
    ST,
    BHT,
};
