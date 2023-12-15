pub const ItemType = enum {
    err,
    eof,
    transaction_set,
};

pub const Lexer = struct {
    seg_term: c_char, // segment terminator
    ele_delm: c_char, // element terminator
};
