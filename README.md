EDI parser and library using Zig lang.

## Example
```
ST*270*1234*005010X279A1~
BHT*0022*13*10001234*20060501*1319~
HL*1**20*1~
NM1*PR*2*ABC COMPANY*****PI*842610001~
HL*2*1*21*1~
NM1*1P*2*BONE AND JOINT CLINIC*****SV*2000035~
HL*3*2*22*0~
TRN*1*93175-012547*9877281234~
NM1*IL*1*SMITH*ROBERT****MI*11122333301~
DMG*D8*19430519~
DTP*291*D8*20060501~
EQ*30~
SE*13*1234~
```

## Parser
Convert an X12 document into Zig data structures. 
* Lexer 
```
LIN*1*VP*1003200-01-R***CH*US~
```

Token Definition
```
// itemType identifies the type of lex items.
type itemType int

const (
	itemError                      // error occurred; value is text of error
	itemEOF
	itemField      // alphanumeric identifier starting with '.'
	itemIdentifier // alphanumeric identifier not starting with '.'
	itemLeftDelim  // left action delimiter
	itemNumber     // umber
	itemText       // plain text
	itemBreak    // break keyword
	itemContinue // continue keyword
	itemDot      // the cursor, spelled '.'
	itemDefine   // define keyword
	itemElse     // else keyword
	itemEnd      // end keyword
	itemIf       // if keyword
	itemNil      // the untyped nil constant, easiest to treat as a keyword
	itemRange    // range keyword
	itemTemplate // template keyword
	itemWith     // with keyword
)

```

```
var key = map[string]itemType{
	".":        itemDot,
	"block":    itemBlock,
	"break":    itemBreak,
	"continue": itemContinue,
	"define":   itemDefine,
	"else":     itemElse,
	"end":      itemEnd,
	"if":       itemIf,
	"range":    itemRange,
	"nil":      itemNil,
	"template": itemTemplate,
	"with":     itemWith,
}

const eof = -1
```

```
type lexer struct {
	name         string // the name of the input; used only for error reports
	input        string // the string being scanned
	leftDelim    string // start of action marker
	rightDelim   string // end of action marker
	pos          Pos    // current position in the input
	start        Pos    // start position of this item
	atEOF        bool   // we have hit the end of input and returned eof
	line         int    // 1+number of newlines seen
	startLine    int    // start line of this item
	item         item   // item to return to parser
	insideAction bool   // are we inside an action?
}
```

```
// item represents a token or text string returned from the scanner.
type item struct {
	typ  itemType // The type of this item.
	pos  Pos      // The starting position, in bytes, of this item in the input string.
	val  string   // The value of this item.
	line int      // The line number at the start of this item.
}
```

```
type - identifier, seperator
value - value of the token (LIN, 1, VP)
column - location in the segment (for error reporting)
line - linue number in the X12 document (for error reporting)
file - X12 document name (for error reporting)
```

* Parser
Generate parsing errors as per X12 document strctures and transaction set validation rules.
```
syntax error: invalid element defintion `VX` at line 2, column 3 in file benefits.edi
```

```
syntax error: missing element definition for `LIN` segment at line 3, column 3 in file benefits.edi
```
  
## Library 
Generate an X12 document from Zig data strctures.
