EDI parser and library using Zig lang.

## Parser
Generate parsing errors as per X12 document strctures and transaction set validation rules.
```
syntax error: invalid element defintion `VX` at line 2, column 3 in file benefits.edi
```

```
syntax error: missing element definition for `LIN` segment at line 3, column 3 in file benefits.edi
```
  
## Library 
Generate an X12 document from Zig data strctures.

### API Examples 
```
Document Zig library API
```


## Supported Transaction Sets

|X12 Transaction Set| Description| X12 Version(s)|Status|
|-------------------|------------|---------------|------|
|270 |Eligibility, Coverage or Benefit Inquiry| X12 8040|In development|

