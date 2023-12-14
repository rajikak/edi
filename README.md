EDI parser and library using Zig lang.

## Parser
Convert an X12 document into Zig data structures. 
* Lexer 
```
LIN*1*VP*1003200-01-R***CH*US~
```

* Token
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
