pub const Segment = struct {
    val: SegmentType,
    pos: []u8,
    required: bool,
    description: []u8,
};

pub const SegmentType = enum {
    ST,
    BHT,
};
