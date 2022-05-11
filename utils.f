HEX

: '(' [ CHAR ( ] LITERAL ;
: ')' [ CHAR ) ] LITERAL ;
: '"' [ CHAR " ] LITERAL ;

: ( IMMEDIATE 1 BEGIN KEY DUP '(' = IF DROP 1+ ELSE ')' = IF 1- THEN THEN DUP 0= UNTIL DROP ;
: ALIGNED ( c-addr -- a-addr )
  3 + 3 INVERT AND ;
: ALIGN HERE @ ALIGNED HERE ! ;
: C, HERE @ C! 1 HERE +! ;
: H/L AND 0 > ;
: S" IMMEDIATE ( -- addr len )
	STATE @ IF
		' LITS , HERE @ 0 ,
		BEGIN KEY DUP '"'
                <> WHILE C, REPEAT
		DROP DUP HERE @ SWAP - 4- SWAP ! ALIGN
	ELSE
		HERE @
		BEGIN KEY DUP '"'
                <> WHILE OVER C! 1+ REPEAT
		DROP HERE @ - HERE @ SWAP
	THEN
;
: ." IMMEDIATE ( -- )
	STATE @ IF
		[COMPILE] S" ' TELL ,
	ELSE
		BEGIN KEY DUP '"' = IF DROP EXIT THEN EMIT AGAIN
	THEN ;

\*****se-ansforth*****
: JF-HERE HERE ;
: JF-CREATE CREATE ;
: JF-FIND FIND ;
: JF-WORD WORD ;
: HERE JF-HERE @ ;
: ALLOT HERE + JF-HERE ! ;
: ['] ' LIT , ; IMMEDIATE
: ' JF-WORD JF-FIND >CFA ;
: CELL+ 4 + ;
: ALIGNED 3 + 3 INVERT AND ;
: ALIGN JF-HERE @ ALIGNED JF-HERE ! ;
: DOES>CUT LATEST @ >CFA @ DUP JF-HERE @ > IF JF-HERE ! ;
: CREATE JF-WORD JF-CREATE DOCREATE , ;
: (DODOES-INT) ALIGN JF-HERE @ LATEST @ >CFA ! DODOES> ['] LIT ,  LATEST @ >DFA , ;
: (DODOES-COMP) (DODOES-INT) ['] LIT , , ['] FIP! , ;
: DOES>COMP ['] LIT , HERE 3 CELLS + , ['] (DODOES-COMP) , ['] EXIT , ;
: DOES>INT (DODOES-INT) LATEST @ HIDDEN ] ;
: DOES> STATE @ 0= IF DOES>INT ELSE DOES>COMP THEN ; IMMEDIATE
DROP
\*****************\

: MASK ( pos -- ) 1 SWAP LSHIFT ;
: GET_BIT ( posBit addr -- value ) @ SWAP RSHIFT 2 MOD  ;
: PIN ( addr -- addr ) DUP CONSTANT 4 + ;
: SKIP ( addr -- addr ) 4 + ;
: RETURN_TRUE ( -- value value ) 1 1 ;
: RETURN_FALSE ( -- value value ) 0 1 ;
: INCREMENT ( addr -- ) DUP @ 1 + SWAP ! ;
: DECREMENT ( addr -- ) DUP @ 1 - SWAP ! ;
: INCREMENT_RETURN ( addr -- value ) DUP @ 1 + OVER ! @ ;
: 4DUP ( n1 n2 n3 n4 -- n1 n2 n3 n4 n1 n2 n3 n4) 2OVER 2OVER ;
: -6ROT ( n1 n2 n3 n4 n5 n6 -- n6 n1 n2 n3 n4 n5) SWAP >R SWAP >R SWAP >R -ROT R> R> R> ;
: ATOI ( ascii -- number ) 30 - ;

7E000000 CONSTANT BASEADDR
