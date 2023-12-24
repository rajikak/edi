pub const Segment = struct {
    val: SegmentType,
    pos: []u8,
    required: bool,
    description: []u8,
};

pub const SegmentType = enum {
    ST, // Transaction Set Header
    BHT, // Begining of Hierachical Transaction
    HL, // Hierachical Level
    TRN, // Trace
    NM1, // Invidual or Organizational Name
    REF, // Reference Information
    N2, // Additional Name Information
    N3, // Party Location

};
