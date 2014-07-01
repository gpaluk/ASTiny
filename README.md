ASTiny
======================

A Tiny Language compiler written in AS3


__WIP - Known issues.__
- Compiler fails to compile.

```
var tiny:ASTTiny = ASTTiny.getInstance();
tiny.init();
```

ASTiny accepts a Tiny Programming Language source (Example included atm) and compiles it to 68000 assembly.

* http://en.wikipedia.org/wiki/Tiny_programming_language

__Example Program__

```
{
	Test program for the Tiny language v1.2
	As described in LET'S BUILD A COMPILER! by Jack W. Crenshaw, Ph.D.
	http://compilers.iecc.com/crenshaw
	Based on Parts 11 & 12 with procedures as described in Part 13 (Pass by value only)
			
	Michael Rychlik 9th May 2008
}
			
{ Comments look like this }
{ Comments can be nested { which is nice } }
			
{ Data declarations: all VARs are unsigned 32 bits }
			
VAR data00;
VAR data01;
			
{ Procedure declaration, paramaters are pass by value }
PROCEDURE BAR (formal00, formal01)
	VAR	counter
			
BEGIN							{ Program statements are bracketed by BEGIN END }
	counter = formal01
			
	WHILE counter > 0
		WRITE (counter)
		counter = counter + 1
	ENDWHILE
			
END;
	
{
FUNCTION FIBO (n)
	VAR result
BEGIN
	IF n < 2
		result = n
	ELSE
{
		result = FIBO(n - 1) + FIBO(n - 2)
}
	ENDIF
END;
}
			
{
	Note: 	Semi-colons are optional at the end of statements and have no effect
	Keywords are in upper case.
	Variable and procedure names are case sensitive.
}
		
{ Main program starts here }
PROGRAM FOO
BEGIN							{ Program statements are bracketed by BEGIN END }
	data00 = 254
	data01 = 255
	WHILE 1
		BAR(data00, data01)		{ A procedure call }
	ENDWHILE
END
.							{ Program is ended with a full stop }
```
