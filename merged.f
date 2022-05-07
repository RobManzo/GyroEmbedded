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
HEX

\***COLOR CONSTANT***\
0 CONSTANT BLACK
FF CONSTANT BLUE
FF00 CONSTANT GREEN
FF0000 CONSTANT RED
FFFFFF CONSTANT WHITE
FF751A CONSTANT ORANGE

\***CONSTANT***\
4 CONSTANT PXSIZE
1000 CONSTANT ROWSIZE
E CONSTANT CHAR_SIZE
12 CONSTANT LINE_SIZE
10 CONSTANT SPACE_SIZE
400 CONSTANT SCREEN_WIDTH
300 CONSTANT SCREEN_HEIGHT
B4 CONSTANT HEARTH_DIM
C8 CONSTANT CANVAS_DIM

\***POSITION CONSTANT***\
3E8FA000 CONSTANT FRAMEBUFFER
3E9FC508 CONSTANT CANVAS_POSITION
3EA06530 CONSTANT HEARTH_POSITION
3EB00570 CONSTANT BARS_POSITION
3EACE570 CONSTANT VALUES_POSITION

\***UTILITY***\
: TAKE_TIMES ( -- ) 0 BEGIN 1 1+ DROP 1+ DUP F000 = UNTIL DROP ;
: DROP4 ( d c b a -- c b a ) >R >R NIP R> R> ;

\***PIXEL MANIPULATION***\
: PD ( buffer n -- buffer+n*1000 ) ROWSIZE * + ; \PIXEL DOWN
: PR ( buffer n -- buffer+n*4 ) PXSIZE * + ; \PIXEL RIGHT
: PU ( buffer n -- buffer-n*1000 ) ROWSIZE * - ; \PIXEL UP
: PL ( buffer n -- buffer-n*4 ) PXSIZE * - ; \PIXEL LEFT
: NEXT_CHAR ( buffer -- buffer+4*3 ) PXSIZE 3 * + ; \SPACE
: NEXT_LINE ( buffer -- buffer+1000*12 ) ROWSIZE LINE_SIZE * + ;
: MULTIPLE_LINE ( buffer n -- buffer+1000*12*n ) LINE_SIZE ROWSIZE * * + ;
: NEW_LINE ( buffer color -- buffernew buffernew color ) SWAP NEXT_LINE DUP ROT ;
: CHAR_SPACE ( buffer -- buffer+4*3 )  SWAP PXSIZE SPACE_SIZE * + SWAP ;
: WORDS_LENGTH ( nchar -- pixelsize ) DUP CHAR_SIZE * SWAP 1- 3 * + ;

\***DRAW FUNCTIONS***\
: PX_ON ( buffer color -- ) SWAP ! ;
: HOR_LINE ( buffer size color -- ) -ROT SWAP 0 BEGIN 2DUP PR 4 PICK PX_ON 1+ DUP 3 PICK = UNTIL 2DROP 2DROP ;
: VERT_LINE ( buffer size color -- ) -ROT SWAP 0 BEGIN 2DUP PD 4 PICK PX_ON 1+ DUP 3 PICK = UNTIL 2DROP 2DROP ;
: DRAW_RECTANGLE ( buffer width height color -- ) SWAP >R -ROT R> ROT 0 BEGIN 2DUP PD 4 PICK 6 PICK HOR_LINE 1+ DUP 3 PICK = UNTIL DROP 2DROP 2DROP ;
: DRAW_SQUARE ( buffer dim color -- ) -ROT SWAP 0 BEGIN 2DUP PD 3 PICK 5 PICK HOR_LINE 1+ DUP 3 PICK = UNTIL 2DROP 2DROP ;
: DRAW_CANVAS
    CANVAS_POSITION CANVAS_DIM WHITE HOR_LINE 
    CANVAS_POSITION CANVAS_DIM WHITE VERT_LINE 
    CANVAS_POSITION CANVAS_DIM PD CANVAS_DIM WHITE HOR_LINE
    CANVAS_POSITION CANVAS_DIM PR CANVAS_DIM WHITE VERT_LINE ;
: DRAW_HEARTH HEARTH_POSITION HEARTH_DIM RED DRAW_SQUARE ;
: DRAW_VFIELD 
    BARS_POSITION 32 WHITE HOR_LINE
    BARS_POSITION 64 PR 32 WHITE HOR_LINE ;
: GRAPHIC DRAW_CANVAS DRAW_HEARTH DRAW_VFIELD ;

\***CLEAR FUNCTIONS***\
: SCREEN_BLACK ( -- ) FRAMEBUFFER SCREEN_WIDTH SCREEN_HEIGHT BLACK DRAW_RECTANGLE ;
: CLR_WORDS ( buffer nchar --  ) WORDS_LENGTH CHAR_SIZE 2 + BLACK DRAW_RECTANGLE ;
: CLR_RESULT ( -- ) RESULT_POSITION B CLR_WORDS ;
: CLR_MENU ( -- ) MENU_POSITION 0 BEGIN SWAP DUP 1C CLR_WORDS NEXT_LINE SWAP 1+ DUP 6 = UNTIL 2DROP ;
: CLR_CHOICE ( -- ) MENU_POSITION DUP 2F CLR_WORDS NEXT_LINE NEXT_LINE DUP 1E CLR_WORDS NEXT_LINE 1B CLR_WORDS ;
: CLR_PIJ ( -- ) FRAMEBUFFER 3 PR BB 20 BLACK DRAW_RECTANGLE ;
: CLR_INDICATIONS ( -- ) INDICATIONS_POSITION DUP F CLR_WORDS NEXT_LINE E CLR_WORDS ;
: CLR_MESSAGE ( -- ) BARS_POSITION 17 CLR_WORDS ;

\***NUMBERS***\
: N_1 ( buffer color -- buffer color ) SWAP 1 PR
    DUP 1 PD 3 3 PICK VERT_LINE         1 PR
    DUP 4 3 PICK VERT_LINE                  
    DUP C PD 2 3 PICK VERT_LINE         1 PR
    DUP 3 3 PICK VERT_LINE                  
    DUP C PD 2 3 PICK VERT_LINE         1 PR
    DUP 3 3 PICK VERT_LINE                  
    DUP C PD 2 3 PICK VERT_LINE         1 PR
    DUP E 3 PICK VERT_LINE              1 PR
    DUP E 3 PICK VERT_LINE              1 PR
    DUP E 3 PICK VERT_LINE              1 PR
    DUP E 3 PICK VERT_LINE              1 PR
    DUP C PD 2 3 PICK VERT_LINE         1 PR
    DUP C PD 2 3 PICK VERT_LINE         1 PR
    DUP C PD 2 3 PICK VERT_LINE         1 PR
    NEXT_CHAR SWAP ;
: N_2 ( buffer color -- buffer color ) SWAP 1 PR
    DUP 2 PD 2 3 PICK VERT_LINE         1 PR
    DUP 1 PD 3 3 PICK VERT_LINE         
    DUP A PD 4 3 PICK VERT_LINE         1 PR
    DUP 4 3 PICK VERT_LINE                  
    DUP 9 PD 5 3 PICK VERT_LINE         1 PR
    DUP 3 3 PICK VERT_LINE                  
    DUP 8 PD 6 3 PICK VERT_LINE         1 PR
    DUP 3 3 PICK VERT_LINE                  
    DUP 7 PD 7 3 PICK VERT_LINE         1 PR
    DUP 3 3 PICK VERT_LINE                  
    DUP 6 PD 8 3 PICK VERT_LINE         1 PR
    DUP 3 3 PICK VERT_LINE                  
    DUP 5 PD 5 3 PICK VERT_LINE         
    DUP B PD 3 3 PICK VERT_LINE         1 PR
    DUP 3 3 PICK VERT_LINE                  
    DUP 4 PD 5 3 PICK VERT_LINE         
    DUP B PD 3 3 PICK VERT_LINE         1 PR
    DUP 8 3 PICK VERT_LINE                  
    DUP B PD 3 3 PICK VERT_LINE         1 PR
    DUP 1 PD 6 3 PICK VERT_LINE
    DUP B PD 3 3 PICK VERT_LINE         1 PR
    DUP 2 PD 4 E PICK VERT_LINE
    DUP B PD 3 3 PICK VERT_LINE         1 PR
    NEXT_CHAR SWAP ;
: N_3 ( buffer color -- buffer color ) SWAP 1 PR
    DUP 3 3 PICK VERT_LINE         
    DUP B PD 3 3 PICK VERT_LINE         1 PR
    DUP 3 3 PICK VERT_LINE         
    DUP B PD 3 3 PICK VERT_LINE         1 PR
    DUP 3 3 PICK VERT_LINE         
    DUP B PD 3 3 PICK VERT_LINE         1 PR
    DUP 3 3 PICK VERT_LINE
    DUP 6 PD 2 3 PICK VERT_LINE         
    DUP B PD 3 3 PICK VERT_LINE         1 PR
    DUP 3 3 PICK VERT_LINE
    DUP 6 PD 2 3 PICK VERT_LINE          
    DUP B PD 3 3 PICK VERT_LINE         1 PR
    DUP 3 3 PICK VERT_LINE
    DUP 5 PD 4 3 PICK VERT_LINE          
    DUP B PD 3 3 PICK VERT_LINE         1 PR
    DUP E 3 PICK VERT_LINE              1 PR
    DUP E 3 PICK VERT_LINE              1 PR
    DUP 1 PD 5 3 PICK VERT_LINE
    DUP 8 PD 5 3 PICK VERT_LINE         1 PR
    DUP 2 PD 3 3 PICK VERT_LINE
    DUP 9 PD 3 3 PICK VERT_LINE         1 PR
    NEXT_CHAR SWAP ;
: N_4 ( buffer color -- buffer color ) SWAP 1 PR
    DUP 6 PD 5 3 PICK VERT_LINE         1 PR
    DUP 5 PD 6 3 PICK VERT_LINE         1 PR
    DUP 4 PD 7 3 PICK VERT_LINE         1 PR
    DUP 3 PD 4 3 PICK VERT_LINE         
    DUP 8 PD 3 3 PICK VERT_LINE         1 PR
    DUP 2 PD 4 3 PICK VERT_LINE         
    DUP 8 PD 3 3 PICK VERT_LINE         1 PR
    DUP 1 PD 4 3 PICK VERT_LINE         
    DUP 8 PD 3 3 PICK VERT_LINE         1 PR
    DUP E 3 PICK VERT_LINE              1 PR
    DUP E 3 PICK VERT_LINE              1 PR
    DUP E 3 PICK VERT_LINE              1 PR
    DUP 8 PD 3 3 PICK VERT_LINE         1 PR
    NEXT_CHAR SWAP ;
: N_5 ( buffer color -- buffer color ) SWAP 1 PR
    DUP 7 3 PICK VERT_LINE         
    DUP B PD 3 3 PICK VERT_LINE         1 PR
    DUP 8 3 PICK VERT_LINE         
    DUP B PD 3 3 PICK VERT_LINE         1 PR
    DUP 3 3 PICK VERT_LINE  
    DUP 5 PD 4 3 PICK VERT_LINE       
    DUP B PD 3 3 PICK VERT_LINE         1 PR
    DUP 3 3 PICK VERT_LINE  
    DUP 5 PD 4 3 PICK VERT_LINE       
    DUP B PD 3 3 PICK VERT_LINE         1 PR
    DUP 3 3 PICK VERT_LINE  
    DUP 5 PD 4 3 PICK VERT_LINE       
    DUP B PD 3 3 PICK VERT_LINE         1 PR
    DUP 3 3 PICK VERT_LINE  
    DUP 5 PD 4 3 PICK VERT_LINE       
    DUP B PD 3 3 PICK VERT_LINE         1 PR
    DUP 3 3 PICK VERT_LINE  
    DUP 5 PD 4 3 PICK VERT_LINE       
    DUP B PD 3 3 PICK VERT_LINE         1 PR
    DUP 3 3 PICK VERT_LINE  
    DUP 5 PD 4 3 PICK VERT_LINE       
    DUP B PD 3 3 PICK VERT_LINE         1 PR
    DUP 3 3 PICK VERT_LINE         
    DUP 6 PD 8 3 PICK VERT_LINE         1 PR
    DUP 3 3 PICK VERT_LINE         
    DUP 7 PD 6 3 PICK VERT_LINE         1 PR
    NEXT_CHAR SWAP ;
: N_6 ( buffer color -- buffer color ) SWAP 1 PR
    DUP E 3 PICK VERT_LINE              1 PR
    DUP E 3 PICK VERT_LINE              1 PR
    DUP E 3 PICK VERT_LINE              1 PR
    DUP 3 3 PICK VERT_LINE  
    DUP 6 PD 3 3 PICK VERT_LINE       
    DUP B PD 3 3 PICK VERT_LINE         1 PR
    DUP 3 3 PICK VERT_LINE  
    DUP 6 PD 3 3 PICK VERT_LINE       
    DUP B PD 3 3 PICK VERT_LINE         1 PR
    DUP 3 3 PICK VERT_LINE  
    DUP 6 PD 3 3 PICK VERT_LINE       
    DUP B PD 3 3 PICK VERT_LINE         1 PR
    DUP 3 3 PICK VERT_LINE  
    DUP 6 PD 3 3 PICK VERT_LINE       
    DUP B PD 3 3 PICK VERT_LINE         1 PR
    DUP 4 3 PICK VERT_LINE         
    DUP 6 PD 8 3 PICK VERT_LINE         1 PR
    DUP 4 3 PICK VERT_LINE         
    DUP 6 PD 8 3 PICK VERT_LINE         1 PR
    DUP 4 3 PICK VERT_LINE         
    DUP 6 PD 8 3 PICK VERT_LINE         1 PR
    NEXT_CHAR SWAP ;
: N_7 ( buffer color -- buffer color ) SWAP 1 PR
    DUP 3 3 PICK VERT_LINE              1 PR
    DUP 3 3 PICK VERT_LINE              
    DUP C PD 2 3 PICK VERT_LINE         1 PR
    DUP 3 3 PICK VERT_LINE              
    DUP A PD 4 3 PICK VERT_LINE         1 PR
    DUP 3 3 PICK VERT_LINE              
    DUP 8 PD 6 3 PICK VERT_LINE         1 PR
    DUP 3 3 PICK VERT_LINE              
    DUP 6 PD 8 3 PICK VERT_LINE         1 PR
    DUP 3 3 PICK VERT_LINE              
    DUP 4 PD 8 3 PICK VERT_LINE         1 PR
    DUP A 3 PICK VERT_LINE              1 PR
    DUP 8 3 PICK VERT_LINE              1 PR
    DUP 6 3 PICK VERT_LINE              1 PR
    DUP 4 3 PICK VERT_LINE              1 PR
    NEXT_CHAR SWAP ;
: N_8 ( buffer color -- buffer color ) SWAP 1 PR
    DUP 2 PD 2 3 PICK VERT_LINE              
    DUP A PD 2 3 PICK VERT_LINE         1 PR
    DUP 1 PD 4 3 PICK VERT_LINE              
    DUP 9 PD 4 3 PICK VERT_LINE         1 PR
    DUP 6 3 PICK VERT_LINE              
    DUP 8 PD 6 3 PICK VERT_LINE         1 PR
    DUP E 3 PICK VERT_LINE              1 PR
    DUP 2 3 PICK VERT_LINE  
    DUP 5 PD 4 3 PICK VERT_LINE       
    DUP C PD 2 3 PICK VERT_LINE         1 PR
    DUP 2 3 PICK VERT_LINE  
    DUP 5 PD 4 3 PICK VERT_LINE       
    DUP C PD 2 3 PICK VERT_LINE         1 PR
    DUP 2 3 PICK VERT_LINE  
    DUP 5 PD 4 3 PICK VERT_LINE       
    DUP C PD 2 3 PICK VERT_LINE         1 PR
    DUP 2 3 PICK VERT_LINE  
    DUP 5 PD 4 3 PICK VERT_LINE       
    DUP C PD 2 3 PICK VERT_LINE         1 PR
    DUP E 3 PICK VERT_LINE              1 PR
    DUP 6 3 PICK VERT_LINE              
    DUP 8 PD 6 3 PICK VERT_LINE         1 PR
    DUP 1 PD 4 3 PICK VERT_LINE              
    DUP 9 PD 4 3 PICK VERT_LINE         1 PR
    DUP 2 PD 2 3 PICK VERT_LINE              
    DUP A PD 2 3 PICK VERT_LINE         1 PR
    NEXT_CHAR SWAP ;
: N_9 ( buffer color -- buffer color ) SWAP 1 PR
    DUP 8 3 PICK VERT_LINE              
    DUP A PD 4 3 PICK VERT_LINE         1 PR
    DUP 8 3 PICK VERT_LINE              
    DUP A PD 4 3 PICK VERT_LINE         1 PR
    DUP 8 3 PICK VERT_LINE              
    DUP A PD 4 3 PICK VERT_LINE         1 PR
    DUP 3 3 PICK VERT_LINE  
    DUP 5 PD 3 3 PICK VERT_LINE       
    DUP B PD 3 3 PICK VERT_LINE         1 PR
    DUP 3 3 PICK VERT_LINE  
    DUP 5 PD 3 3 PICK VERT_LINE       
    DUP B PD 3 3 PICK VERT_LINE         1 PR
    DUP 3 3 PICK VERT_LINE  
    DUP 5 PD 3 3 PICK VERT_LINE       
    DUP B PD 3 3 PICK VERT_LINE         1 PR
    DUP 3 3 PICK VERT_LINE  
    DUP 5 PD 3 3 PICK VERT_LINE       
    DUP B PD 3 3 PICK VERT_LINE         1 PR
    DUP E 3 PICK VERT_LINE              1 PR
    DUP E 3 PICK VERT_LINE              1 PR
    DUP E 3 PICK VERT_LINE              1 PR
    NEXT_CHAR SWAP ;
: N_0 ( buffer color -- buffer color ) SWAP 1 PR
    DUP E 3 PICK VERT_LINE              1 PR
    DUP E 3 PICK VERT_LINE              1 PR
    DUP E 3 PICK VERT_LINE              1 PR
    DUP 4 3 PICK VERT_LINE              
    DUP A PD 4 3 PICK VERT_LINE         1 PR
    DUP 3 3 PICK VERT_LINE              
    DUP B PD 3 3 PICK VERT_LINE         1 PR
    DUP 3 3 PICK VERT_LINE              
    DUP B PD 3 3 PICK VERT_LINE         1 PR
    DUP 4 3 PICK VERT_LINE              
    DUP A PD 4 3 PICK VERT_LINE         1 PR
    DUP E 3 PICK VERT_LINE              1 PR
    DUP E 3 PICK VERT_LINE              1 PR
    DUP E 3 PICK VERT_LINE              1 PR
    NEXT_CHAR SWAP ;

: INIT_VALUE VALUES_POSITION WHITE N_0 VALUES_POSITION WHITE N_0 ;
: INIT GRAPHIC INIT_VALUE ;
