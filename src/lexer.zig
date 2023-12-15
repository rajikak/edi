const Type = enum {
	error,
	eof,
	transaction_set,
};

const Lexer = struct {
	seg_term: char, // segment terminator
	ele_delm: char, // element terminator
};
