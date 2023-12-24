const print = @import("std").debug.print;

pub const ItemType = enum {
    err,
    eof,
    transaction_set,
};

// item represents a token of a text string returned from the scanner
const Item = struct {
    typ: ItemType, // the type of this iterm.
    pos: u8, // the starting position, in bytes, of this item in the input string.
    val: []const u8, // the value of this item.
    line: u8, // the line number at the start of this item.
};

test "lexer" {
    // a sample EDI
    const s =
        \\ ST*270*1234*005010X279A1~
        \\ BHT*0022*13*10001234*20060501*1319~
        \\ HL*1**20*1~
        \\ NM1*PR*2*ABC COMPANY*****PI*842610001~
        \\ HL*2*1*21*1~
        \\ NM1*1P*2*BONE AND JOINT CLINIC*****SV*2000035~
        \\ HL*3*2*22*0~
        \\ TRN*1*93175-012547*9877281234~
        \\ NM1*IL*1*SMITH*ROBERT****MI*11122333301~
        \\ DMG*D8*19430519~
        \\ DTP*291*D8*20060501~
        \\ EQ*30~
        \\ SE*13*1234~
    ;

    print("lexer string: {}", .{s});
}
