; ****************************************************************************************
; **** LUCIDSCIENCE.COM - VGA DUAL BUFFER DEMO BY RADBRAD
; ****************************************************************************************

; COMPILER SETTINGS
.INCLUDE "M644pDEF.INC" ; This version needs more than 32K flash and more than 2K SRAM

; INTERRUPT VECTORS
.org 0
rjmp RESET
.org oc1aaddr
rjmp VIDEO ;2
RESET:

 

; ****************************************************************************************
; **** IO PORT A SETUP
; ****************************************************************************************

sbi ddra,0 ; ADDRESS BIT 00
sbi ddra,1 ; ADDRESS BIT 01
sbi ddra,2 ; ADDRESS BIT 02
sbi ddra,3 ; ADDRESS BIT 03
sbi ddra,4 ; ADDRESS BIT 04
sbi ddra,5 ; ADDRESS BIT 05
sbi ddra,6 ; ADDRESS BIT 06
sbi ddra,7 ; ADDRESS BIT 07

 

; ****************************************************************************************
; **** IO PORT C SETUP
; ****************************************************************************************

sbi ddrc,0 ; ADDRESS BIT 08
sbi ddrc,1 ; ADDRESS BIT 09
sbi ddrc,2 ; ADDRESS BIT 12
sbi ddrc,3 ; ADDRESS BIT 11
sbi ddrc,4 ; ADDRESS BIT 12
sbi ddrc,5 ; ADDRESS BIT 13
sbi ddrc,6 ; ADDRESS BIT 14
sbi ddrc,7 ; ADDRESS BIT 15

 

; ****************************************************************************************
; **** IO PORT D SETUP
; ****************************************************************************************

sbi ddrd,0 ; RED BIT 0
sbi ddrd,1 ; RED BIT 1
sbi ddrd,2 ; GRN BIT 0
sbi ddrd,3 ; GRN BIT 1
sbi ddrd,4 ; BLU BIT 0
sbi ddrd,5 ; BLU BIT 1
sbi ddrd,6 ; INT BIT 0
sbi ddrd,7 ; INT BIT 1

 

; ****************************************************************************************
; **** IO PORT B SETUP
; ****************************************************************************************

sbi ddrb,0 ; HORIZONTAL SYNC PULSE
sbi ddrb,1 ; VERTICAL SYNC PULSE
sbi ddrb,2 ; VIDEO DAC ENABLE
sbi ddrb,3 ; SRAM WRITE ENABLE
sbi ddrb,4 ; SRAM OUTPUT ENABLE
sbi ddrb,5 ; SRAM PAGE CONTROL
sbi ddrb,6 ; JOYSTICK READ ENABLE
cbi ddrb,7 ; SOUND OUTPUT PIN

; ****************************************************************************************
; **** DEFINE MAIN LOOP REGISTERS
; ****************************************************************************************
.def sn = r2 ; SOUND FREQUENCY
.def sx = r16 ; SCREEN LOCATION X
.def sy = r17 ; SCREEN LOCATION Y
.def px = r18 ; SCREEN PIXEL COLOR
.def t1 = r19 ; TEMP REGISTER 1
.def t2 = r20 ; TEMP REGISTER 2
.def t3 = r21 ; TEMP REGISTER 3
.def t4 = r22 ; TEMP REGISTER 4
.def t5 = r23 ; TEMP REGISTER 5
.def t6 = r24 ; TEMP REGISTER 6
.def mr = r25 ; MEMREADY FLAG

; CLEAR ALL REGISTERS
clr r0
clr r1
clr sn
clr sx
clr sy
clr px
clr t1
clr t2
clr t3
clr t4
clr t5
clr t6
clr xl
clr xh
clr yl
clr yh
clr zl
clr zh

 

; ****************************************************************************************
; **** STARTUP SEQUENCE
; ****************************************************************************************

; STACK POINTER
ldi r24,low(ramend)
out spl,r24
ldi r24,high(ramend)
out sph,r24

; SET TIMER1 TO SCLK WITH RESET
ldi r24,(1<<CS10 | 1<<WGM12)
sts tccr1b,r24

; SET TIMER1 MATCH INTERRUPT
ldi r24,(1<<OCIE1A)
sts timsk1,r24

; SET TIMER1 INTERRUPT TIME
ldi r24,high(636)
sts ocr1ah,r24
ldi r24,low(636)
sts ocr1al,r24

; SET SRAM TO IDLE
sbi portb,3
sbi portb,4

; CLEAR VIDEO VARIABLES
clr r24
sts 256,r24
sts 257,r24
sts 258,r24

; DRAW IMAGE TO PAGE 0
cbi portb,5
ldi px,0
call CLEARSCREEN
ldi zl,low(2*pic)
ldi zh,high(2*pic)
call DRAWSPRITE

; DRAW IMAGE TO PAGE 1
sbi portb,5
ldi px,0
call CLEARSCREEN
ldi zl,low(2*pic)
ldi zh,high(2*pic)
call DRAWSPRITE

; TURN ON GLOBAL INTERRUPTS
sei

; DELAY TO SHOW IMAGE
ldi t1,50
DLY1:
clr xl
clr xh
DLY2:
sbiw xl:xh,1
brne DLY2
dec t1
brne DLY1

ldi t1,0 ; BALL X DIRECTION
ldi t2,0 ; BALL Y DIRECTION

; TURN ON SOUND
sbi ddrb,7

; DRAW TEXT ACROSS SCREEN
ldi px,255
ldi t2,80
ldi sy,116

; PRINT CHARACTERS WITH BLIP SOUND
ldi sx,47+8*0
ldi t1,0
call BLIPCHAR ; SPACE
ldi sx,47+8*1
ldi t1,12
call BLIPCHAR ; L
ldi sx,47+8*2
ldi t1,21
call BLIPCHAR ; U
ldi sx,47+8*3
ldi t1,3
call BLIPCHAR ; C
ldi sx,47+8*4
ldi t1,9
call BLIPCHAR ; I
ldi sx,47+8*5
ldi t1,4
call BLIPCHAR ; D
ldi sx,47+8*6
ldi t1,19
call BLIPCHAR ; S
ldi sx,47+8*7
ldi t1,3
call BLIPCHAR ; C
ldi sx,47+8*8
ldi t1,9
call BLIPCHAR ; I
ldi sx,47+8*9
ldi t1,5
call BLIPCHAR ; E
ldi sx,47+8*10
ldi t1,14
call BLIPCHAR ; N
ldi sx,47+8*11
ldi t1,3
call BLIPCHAR ; C
ldi sx,47+8*12
ldi t1,5
call BLIPCHAR ; E
ldi sx,47+8*13
ldi t1,76
call BLIPCHAR ; DOT
ldi sx,47+8*14
ldi t1,29
call BLIPCHAR ; c
ldi sx,47+8*15
ldi t1,41
call BLIPCHAR ; o
ldi sx,47+8*16
ldi t1,39
call BLIPCHAR ; m
ldi sx,47+8*17
ldi t1,0
call BLIPCHAR ; SPACE

 

; ****************************************************************************************
; **** MAIN PROGRAM LOOP
; ****************************************************************************************
main:

; DRAW BALL BOUNCE ANIMATION
inc t3
sbrs t3,0
rjmp SLOW

; MOVE BALL DOWN
cpi t1,0
brne BY1
mov px,sy
lsr px
lsr px
lsr px
lsr px
inc px
add sy,px
cpi sy,216
brlo BY1
ldi t1,1
BY1:

; MOVE BALL UP
cpi t1,1
brne BY2
mov px,sy
lsr px
lsr px
lsr px
lsr px
inc px
sub sy,px
cpi sy,0
brne BY2
ldi t1,0
BY2:

; MOVE BALL RIGHT
inc sx

; SET SOUND TO BALL Y
mov r2,sy
SLOW:

; PRINT TEXT MESSAGE
push t1
push t2
push sx
push sy

; SET TEXT COLORS
ldi px,255
ldi t2,80
ldi sy,116

; PRINT CHARACTERS
ldi sx,47+8*0
ldi t1,0
call PRINTCHAR ; SPACE
ldi sx,47+8*1
ldi t1,12
call PRINTCHAR ; L
ldi sx,47+8*2
ldi t1,21
call PRINTCHAR ; U
ldi sx,47+8*3
ldi t1,3
call PRINTCHAR ; C
ldi sx,47+8*4
ldi t1,9
call PRINTCHAR ; I
ldi sx,47+8*5
ldi t1,4
call PRINTCHAR ; D
ldi sx,47+8*6
ldi t1,19
call PRINTCHAR ; S
ldi sx,47+8*7
ldi t1,3
call PRINTCHAR ; C
ldi sx,47+8*8
ldi t1,9
call PRINTCHAR ; I
ldi sx,47+8*9
ldi t1,5
call PRINTCHAR ; E
ldi sx,47+8*10
ldi t1,14
call PRINTCHAR ; N
ldi sx,47+8*11
ldi t1,3
call PRINTCHAR ; C
ldi sx,47+8*12
ldi t1,5
call PRINTCHAR ; E
ldi sx,47+8*13
ldi t1,76
call PRINTCHAR ; DOT
ldi sx,47+8*14
ldi t1,29
call PRINTCHAR ; c
ldi sx,47+8*15
ldi t1,41
call PRINTCHAR ; o
ldi sx,47+8*16
ldi t1,39
call PRINTCHAR ; m
ldi sx,47+8*17
ldi t1,0
call PRINTCHAR ; SPACE

pop sy
pop sx
pop t2
pop t1

; DRAW BALL SPRITE TO SCREEN
ldi zl,low(2*BALL)
ldi zh,high(2*BALL)
call DRAWSPRITE

; FLIP PAGES ON VERTICAL SYNC
call PAGEFLIP

; END OF MAIN LOOP
rjmp main

 

; ****************************************************************************************
; **** PRINT CHARACTERS WITH BLIP AND DELAY
; ****************************************************************************************
BLIPCHAR:

; SEND CHARACTER
call PRINTCHAR
call PAGEFLIP
call PRINTCHAR
call PAGEFLIP

; MAKE BLIP SOUND
clr xl
clr xh
BLP1:
mov r2,xh
sbiw xh:xl,2
brne BLP1
ret

 

; ****************************************************************************************
; **** FLIP VIDEO PAGES
; ****************************************************************************************
PAGEFLIP:

; STACK OPERATION
push t1

; WAIT FOR VSYNC
PFVS:
sbic portb,1
rjmp PFVS

; SWAP BUFFERS
in t1,portb
sbrc t1,5
cbi portb,5
sbrs t1,5
sbi portb,5

; STACK OPERATION
pop t1
ret

 

; ****************************************************************************************
; **** READ SCREEN PIXEL / SX=XLOC / SY=YLOC / RETURNS PX=COLOR
; ****************************************************************************************
READPIXEL:

; STACK OPERATION
push t1

; WAIT FOR MEMREADY
RPMR:
sbrc mr,0
rjmp RPMR

; SET SCREEN ADDRESS
out porta,sx
out portc,sy

; SET DATA PORT INPUT
clr t1
out ddrd,t1

; SRAM OUTPUT ENABLE
cbi portb,4

; TURNAROUND DELAY
nop

; READ DATA BYTE
in px,pind

; SRAM OUTPUT DISABLE
sbi portb,4

; SET DATA PORT OUTPUT
ser t1
out ddrd,t1

; STACK OPERATION
pop t1
ret

 

; ****************************************************************************************
; **** COPY SPRITE TO SCREEN / SX=XLOC / SY=YLOC
; ****************************************************************************************
DRAWSPRITE:

; STACK OPERATION
push xh
push xl
push yh
push yl
push zh
push zl
push t1

; READ SPRITE SIZE DATA
lpm xl,z+
lpm xh,z+

; SET SCREEN LOCATION
add xl,sx
add xh,sy
mov yh,sy

; COUNT Y BYTES
DSYL:
mov yl,sx

; WAIT FOR MEMREADY
DSMR:
sbrc mr,0
rjmp DSMR

; COUNT X BYTES
DSXL:
lpm t1,z+
cpi t1,0

; SKIP BLANK PIXELS
breq DSBL

; SEND SPRITE DATA
out portd,t1
out porta,yl
out portc,yh
cbi portb,3
sbi portb,3

; COMPLETE LOOP
DSBL:
inc yl
cp yl,xl
brne DSXL
inc yh
cp yh,xh
brne DSYL

; STACK OPERATION
pop t1
pop zl
pop zh
pop yl
pop yh
pop xl
pop xh
ret

 

; ****************************************************************************************
; **** COPY IMAGE TO SCREEN / SX=XLOC / SY=YLOC
; ****************************************************************************************
DRAWIMAGE:

; STACK OPERATION
push t1
push xl
push xh
push yl
push yh
push zl
push zh

; READ SPRITE SIZE DATA
lpm xl,z+
lpm xh,z+

; SET SCREEN LOCATION
add xl,sx
add xh,sy
mov yh,sy

; COUNT Y BYTES
DIYL:
mov yl,sx

; WAIT FOR MEMREADY
DIMR:
sbrc mr,0
rjmp DIMR

; COUNT X BYTES
DIXL:
lpm t1,z+

; SEND SPRITE DATA
out portd,t1
out porta,yl
out portc,yh
cbi portb,3
sbi portb,3

; COMPLETE LOOP
DIBL:
inc yl
cp yl,xl
brne DIXL
inc yh
cp yh,xh
brne DIYL

; STACK OPERATION
pop zh
pop zl
pop yh
pop yl
pop xh
pop xl
pop t1
ret

 

; ****************************************************************************************
; **** CLEAR ENTIRE VIDEO SCREEN / PX=COLOR
; ****************************************************************************************
CLEARSCREEN:

; STACK OPERATION
push xh
push xl

; RESET SCREEN ADDRESS
clr xh
clr xl

; WAIT FOR MEMREADY
CLEAR:
CSMR:
sbrc mr,0
rjmp CSMR

; SEND SCREEN DATA
out portd,px
out portc,xh
cbi portb,3
out porta,xl
inc xl
out porta,xl
inc xl
out porta,xl
inc xl
out porta,xl
inc xl
out porta,xl
inc xl
out porta,xl
inc xl
out porta,xl
inc xl
out porta,xl
inc xl
out porta,xl
inc xl
out porta,xl
inc xl
out porta,xl
inc xl
out porta,xl
inc xl
out porta,xl
inc xl
out porta,xl
inc xl
out porta,xl
inc xl
out porta,xl
inc xl
sbi portb,3

; COMPLETE LOOP
cpi xl,240
brne clear
inc xh
cpi xh,240
brne clear

; STACK OPERATION
pop xl
pop xh
ret

 

; **********************************************************************************************
; **** PRINT TEXT CHARACTER / T1=CHARACTER / SX=XLOC / SY=YLOC / PX=FORECOLOR / T2=BACKCOLOR
; **********************************************************************************************
PRINTCHAR:

; STACK OPERATION
push t3
push t4
push zl
push zh
push yl
push yh

; SET POINTER TO CHARACTER DATA
ldi zl,low(2*chars)
ldi zh,high(2*chars)
ldi t3,8
mul t1,t3
add zl,r0
adc zh,r1

; WAIT FOR MEMREADY
PCMR:
sbrc mr,0
rjmp PCMR

; LOOP
mov yh,sy
ldi t4,8
PRLY:

; READ CHARACTER BYTE
lpm t1,z+

; SET SCREEN ADDRESS
mov yl,sx
out portc,yh
ldi t3,8
PRLX:
out porta,yl

; SHIFT OUT CHARACTER BITS
out portd,px
sbrc t1,0
rjmp DOSHIFT

; SKIP PIXELS IF FCOLOR = BCOLOR
cp t2,px
breq NOSHIFT
sbrs t1,0
out portd,t2

DOSHIFT:
cbi portb,3
sbi portb,3
NOSHIFT:

; COMPLETE SHIFT LOOP
lsr t1
inc yl
dec t3
brne PRLX
inc yh
dec t4
brne PRLY

; STACK OPERATION
pop yh
pop yl
pop zh
pop zl
pop t4
pop t3
ret

 

; ****************************************************************************************
; **** VIDEO RENDERING INTERRUPT / R2=SOUND FREQUENCY / RETURNS R25=MEMREADY
; ****************************************************************************************
VIDEO:

; HORIZONTAL CLOCK TIMING
;HFP:12 (0-11)
;HSP:76 (12-87)
;HBP:36 (88-123)
;HPX:512 (124-635)
;TOT:636

; VERTICAL LINE TIMING
;VLN:480 (0-479)
;VFP:11 (480-490)
;VSP:2 (491-492)
;VBP:32 (493-524)
;TOT:525 LINES

; ****************************************************************************************
; **** HORIZONTAL AND VERTICAL SYNC = 76 CYCLES
; ****************************************************************************************

; SAVE STATUS REGISTER
push r24 ;2
in r24,sreg ;1
push r24 ;2

; EQUALIZE INTERRUPT LATENCY
lds r24,tcnt1l ;2
cpi r24,10 ;1
brlo LATFIX1 ;1/2
LATFIX1:
cpi r24,11 ;1
brlo LATFIX2 ;1/2
LATFIX2:
cpi r24,12 ;1
brlo LATFIX3 ;1/2
LATFIX3:
cpi r24,13 ;1
brlo LATFIX4 ;1/2
LATFIX4:

; HORIZONTAL SYNC LOW
cbi portb,0 ;2

; PUSH REGISTERS TO STACK
push r0 ;2
push r1 ;2
push r17 ;2
push r18 ;2
push yl ;2
push yh ;2
push zl ;2
push zh ;2

; SET POINTER TO VLINE TABLE
ldi zl,low(2*VLINE) ;1
ldi zh,high(2*VLINE) ;1

; LOAD VLINE COUNTER
lds yl,256 ;2
lds yh,257 ;2
lds r17,258 ;2

; SET VLINE TABLE POSITION
add zl,yl ;1
adc zh,yh ;1

; READ VLINE TABLE BYTE
lpm r24,z ;3

; INCREMENT VERTICAL ADDRESS
sbrs r24,3 ;1/2
inc r17 ;1

; RESET VERTICAL ADDRESS
sbrc r24,0 ;1/2
ser r17 ;1

; INCREMENT VLINE COUNTER
adiw yh:yl,1 ;1

; RESET VLINE COUNTER
sbrc r24,0 ;1/2
clr yl ;1
sbrc r24,0 ;1/2
clr yh ;1

; SAVE VLINE COUNTER
sts 256,yl ;2
sts 257,yh ;2
sts 258,r17 ;2

; VERTICAL SYNC CONTROL
sbrc r24,1 ;1/2
cbi portb,1 ;2
sbrs r24,1 ;1/2
sbi portb,1 ;2

; SET MEMREADY FLAG (R25)
sbrc r24,4 ;1/2
clr r25 ;1
sbrs r24,4 ;1/2
ser r25 ;1

; HORIZONTAL SYNC HIGH
sbi portb,0 ;2

 

; ****************************************************************************************
; **** HORIZONTAL BACK PORCH = 36 CYCLES
; ****************************************************************************************

; SET VERTICAL ADDRESS
sbrc r24,2 ;1/2
out portc,r17 ;1

; LOAD SOUND COUNTER
push r3 ;2
lds r3,259 ;2

; SEND SOUND DATA
dec r3 ;1
cp r2,r3 ;1
brne ns ;1/2
clr r3 ;1
ns:
brne n1 ;1/2
sbi portb,7 ;2
n1:
breq n2 ;1/2
cbi portb,7 ;2
n2:

; SAVE SOUND COUNTER
sts 259,r3 ;2
pop r3 ;2

; POP REGISTERS FROM STACK
pop zh ;2
pop zl ;2
pop yh ;2
pop yl ;2
pop r18 ;2
pop r17 ;2
pop r1 ;2
pop r0 ;2

; CONTROL ACTIVE LINES
sbrs r24,2 ;1/2
rjmp NOVID ;2

; SET SRAM TO IDLE
sbi portb,3 ;2
sbi portb,4 ;2

; RELEASE DATA BUS
clr r24 ;1
out ddrd,r24 ;1

; SET SRAM TO READ
cbi portb,4 ;2

 

; ****************************************************************************************
; **** HORIZONTAL ACTIVE LINE = 512 CYCLES - 32 / 2 = 240 PIXELS
; ****************************************************************************************

; SET TO FRONT BUFFER
in r24,portb ;1
sbrc r24,5 ;1/2
cbi portb,5 ;2
sbrs r24,5 ;1/2
sbi portb,5 ;2

; RESET HORIZONTAL ADDRESS
clr r24 ;1
out porta,r24 ;1

; TURN ON VIDEO DAC
cbi portb,2 ;2

inc r24 ;1
out porta,r24 ;1
inc r24 ;1
out porta,r24 ;1
inc r24 ;1
out porta,r24 ;1
inc r24 ;1
out porta,r24 ;1
inc r24 ;1
out porta,r24 ;1
inc r24 ;1
out porta,r24 ;1
inc r24 ;1
out porta,r24 ;1
inc r24 ;1
out porta,r24 ;1
inc r24 ;1
out porta,r24 ;1
inc r24 ;1
out porta,r24 ;1
inc r24 ;1
out porta,r24 ;1
inc r24 ;1
out porta,r24 ;1
inc r24 ;1
out porta,r24 ;1
inc r24 ;1
out porta,r24 ;1
inc r24 ;1
out porta,r24 ;1
inc r24 ;1
out porta,r24 ;1
inc r24 ;1
out porta,r24 ;1
inc r24 ;1
out porta,r24 ;1
inc r24 ;1
out porta,r24 ;1
inc r24 ;1
out porta,r24 ;1
inc r24 ;1
out porta,r24 ;1
inc r24 ;1
out porta,r24 ;1
inc r24 ;1
out porta,r24 ;1
inc r24 ;1
out porta,r24 ;1
inc r24 ;1
out porta,r24 ;1
inc r24 ;1
out porta,r24 ;1
inc r24 ;1
out porta,r24 ;1
inc r24 ;1
out porta,r24 ;1
inc r24 ;1
out porta,r24 ;1
inc r24 ;1
out porta,r24 ;1
inc r24 ;1
out porta,r24 ;1
inc r24 ;1
out porta,r24 ;1
inc r24 ;1
out porta,r24 ;1
inc r24 ;1
out porta,r24 ;1
inc r24 ;1
out porta,r24 ;1
inc r24 ;1
out porta,r24 ;1
inc r24 ;1
out porta,r24 ;1
inc r24 ;1
out porta,r24 ;1
inc r24 ;1
out porta,r24 ;1
inc r24 ;1
out porta,r24 ;1
inc r24 ;1
out porta,r24 ;1
inc r24 ;1
out porta,r24 ;1
inc r24 ;1
out porta,r24 ;1
inc r24 ;1
out porta,r24 ;1
inc r24 ;1
out porta,r24 ;1
inc r24 ;1
out porta,r24 ;1
inc r24 ;1
out porta,r24 ;1
inc r24 ;1
out porta,r24 ;1
inc r24 ;1
out porta,r24 ;1
inc r24 ;1
out porta,r24 ;1
inc r24 ;1
out porta,r24 ;1
inc r24 ;1
out porta,r24 ;1
inc r24 ;1
out porta,r24 ;1
inc r24 ;1
out porta,r24 ;1
inc r24 ;1
out porta,r24 ;1
inc r24 ;1
out porta,r24 ;1
inc r24 ;1
out porta,r24 ;1
inc r24 ;1
out porta,r24 ;1
inc r24 ;1
out porta,r24 ;1
inc r24 ;1
out porta,r24 ;1
inc r24 ;1
out porta,r24 ;1
inc r24 ;1
out porta,r24 ;1
inc r24 ;1
out porta,r24 ;1
inc r24 ;1
out porta,r24 ;1
inc r24 ;1
out porta,r24 ;1
inc r24 ;1
out porta,r24 ;1
inc r24 ;1
out porta,r24 ;1
inc r24 ;1
out porta,r24 ;1
inc r24 ;1
out porta,r24 ;1
inc r24 ;1
out porta,r24 ;1
inc r24 ;1
out porta,r24 ;1
inc r24 ;1
out porta,r24 ;1
inc r24 ;1
out porta,r24 ;1
inc r24 ;1
out porta,r24 ;1
inc r24 ;1
out porta,r24 ;1
inc r24 ;1
out porta,r24 ;1
inc r24 ;1
out porta,r24 ;1
inc r24 ;1
out porta,r24 ;1
inc r24 ;1
out porta,r24 ;1
inc r24 ;1
out porta,r24 ;1
inc r24 ;1
out porta,r24 ;1
inc r24 ;1
out porta,r24 ;1
inc r24 ;1
out porta,r24 ;1
inc r24 ;1
out porta,r24 ;1
inc r24 ;1
out porta,r24 ;1
inc r24 ;1
out porta,r24 ;1
inc r24 ;1
out porta,r24 ;1
inc r24 ;1
out porta,r24 ;1
inc r24 ;1
out porta,r24 ;1
inc r24 ;1
out porta,r24 ;1
inc r24 ;1
out porta,r24 ;1
inc r24 ;1
out porta,r24 ;1
inc r24 ;1
out porta,r24 ;1
inc r24 ;1
out porta,r24 ;1
inc r24 ;1
out porta,r24 ;1
inc r24 ;1
out porta,r24 ;1
inc r24 ;1
out porta,r24 ;1
inc r24 ;1
out porta,r24 ;1
inc r24 ;1
out porta,r24 ;1
inc r24 ;1
out porta,r24 ;1
inc r24 ;1
out porta,r24 ;1
inc r24 ;1
out porta,r24 ;1
inc r24 ;1
out porta,r24 ;1
inc r24 ;1
out porta,r24 ;1
inc r24 ;1
out porta,r24 ;1
inc r24 ;1
out porta,r24 ;1
inc r24 ;1
out porta,r24 ;1
inc r24 ;1
out porta,r24 ;1
inc r24 ;1
out porta,r24 ;1
inc r24 ;1
out porta,r24 ;1
inc r24 ;1
out porta,r24 ;1
inc r24 ;1
out porta,r24 ;1
inc r24 ;1
out porta,r24 ;1
inc r24 ;1
out porta,r24 ;1
inc r24 ;1
out porta,r24 ;1
inc r24 ;1
out porta,r24 ;1
inc r24 ;1
out porta,r24 ;1
inc r24 ;1
out porta,r24 ;1
inc r24 ;1
out porta,r24 ;1
inc r24 ;1
out porta,r24 ;1
inc r24 ;1
out porta,r24 ;1
inc r24 ;1
out porta,r24 ;1
inc r24 ;1
out porta,r24 ;1
inc r24 ;1
out porta,r24 ;1
inc r24 ;1
out porta,r24 ;1
inc r24 ;1
out porta,r24 ;1
inc r24 ;1
out porta,r24 ;1
inc r24 ;1
out porta,r24 ;1
inc r24 ;1
out porta,r24 ;1
inc r24 ;1
out porta,r24 ;1
inc r24 ;1
out porta,r24 ;1
inc r24 ;1
out porta,r24 ;1
inc r24 ;1
out porta,r24 ;1
inc r24 ;1
out porta,r24 ;1
inc r24 ;1
out porta,r24 ;1
inc r24 ;1
out porta,r24 ;1
inc r24 ;1
out porta,r24 ;1
inc r24 ;1
out porta,r24 ;1
inc r24 ;1
out porta,r24 ;1
inc r24 ;1
out porta,r24 ;1
inc r24 ;1
out porta,r24 ;1
inc r24 ;1
out porta,r24 ;1
inc r24 ;1
out porta,r24 ;1
inc r24 ;1
out porta,r24 ;1
inc r24 ;1
out porta,r24 ;1
inc r24 ;1
out porta,r24 ;1
inc r24 ;1
out porta,r24 ;1
inc r24 ;1
out porta,r24 ;1
inc r24 ;1
out porta,r24 ;1
inc r24 ;1
out porta,r24 ;1
inc r24 ;1
out porta,r24 ;1
inc r24 ;1
out porta,r24 ;1
inc r24 ;1
out porta,r24 ;1
inc r24 ;1
out porta,r24 ;1
inc r24 ;1
out porta,r24 ;1
inc r24 ;1
out porta,r24 ;1
inc r24 ;1
out porta,r24 ;1
inc r24 ;1
out porta,r24 ;1
inc r24 ;1
out porta,r24 ;1
inc r24 ;1
out porta,r24 ;1
inc r24 ;1
out porta,r24 ;1
inc r24 ;1
out porta,r24 ;1
inc r24 ;1
out porta,r24 ;1
inc r24 ;1
out porta,r24 ;1
inc r24 ;1
out porta,r24 ;1
inc r24 ;1
out porta,r24 ;1
inc r24 ;1
out porta,r24 ;1
inc r24 ;1
out porta,r24 ;1
inc r24 ;1
out porta,r24 ;1
inc r24 ;1
out porta,r24 ;1
inc r24 ;1
out porta,r24 ;1
inc r24 ;1
out porta,r24 ;1
inc r24 ;1
out porta,r24 ;1
inc r24 ;1
out porta,r24 ;1
inc r24 ;1
out porta,r24 ;1
inc r24 ;1
out porta,r24 ;1
inc r24 ;1
out porta,r24 ;1
inc r24 ;1
out porta,r24 ;1
inc r24 ;1
out porta,r24 ;1
inc r24 ;1
out porta,r24 ;1
inc r24 ;1
out porta,r24 ;1
inc r24 ;1
out porta,r24 ;1
inc r24 ;1
out porta,r24 ;1
inc r24 ;1
out porta,r24 ;1
inc r24 ;1
out porta,r24 ;1
inc r24 ;1
out porta,r24 ;1
inc r24 ;1
out porta,r24 ;1
inc r24 ;1
out porta,r24 ;1
inc r24 ;1
out porta,r24 ;1
inc r24 ;1
out porta,r24 ;1
inc r24 ;1
out porta,r24 ;1
inc r24 ;1
out porta,r24 ;1
inc r24 ;1
out porta,r24 ;1
inc r24 ;1
out porta,r24 ;1
inc r24 ;1
out porta,r24 ;1
inc r24 ;1
out porta,r24 ;1
inc r24 ;1
out porta,r24 ;1
inc r24 ;1
out porta,r24 ;1
inc r24 ;1
out porta,r24 ;1
inc r24 ;1
out porta,r24 ;1
inc r24 ;1
out porta,r24 ;1
inc r24 ;1
out porta,r24 ;1
inc r24 ;1
out porta,r24 ;1
inc r24 ;1
out porta,r24 ;1
inc r24 ;1
out porta,r24 ;1
inc r24 ;1
out porta,r24 ;1
inc r24 ;1
out porta,r24 ;1
inc r24 ;1
out porta,r24 ;1
inc r24 ;1
out porta,r24 ;1
inc r24 ;1
out porta,r24 ;1
inc r24 ;1
out porta,r24 ;1
inc r24 ;1
out porta,r24 ;1
inc r24 ;1
out porta,r24 ;1
inc r24 ;1
out porta,r24 ;1
inc r24 ;1
out porta,r24 ;1
inc r24 ;1
out porta,r24 ;1
inc r24 ;1
out porta,r24 ;1
inc r24 ;1
out porta,r24 ;1
inc r24 ;1
out porta,r24 ;1
inc r24 ;1
out porta,r24 ;1
inc r24 ;1
out porta,r24 ;1
inc r24 ;1
out porta,r24 ;1
inc r24 ;1
out porta,r24 ;1
inc r24 ;1
out porta,r24 ;1
inc r24 ;1
out porta,r24 ;1
inc r24 ;1
out porta,r24 ;1
inc r24 ;1
out porta,r24 ;1
inc r24 ;1
out porta,r24 ;1
inc r24 ;1
out porta,r24 ;1
inc r24 ;1
out porta,r24 ;1
inc r24 ;1
out porta,r24 ;1
inc r24 ;1
out porta,r24 ;1
inc r24 ;1
out porta,r24 ;1
inc r24 ;1
out porta,r24 ;1
inc r24 ;1
out porta,r24 ;1
inc r24 ;1
out porta,r24 ;1
inc r24 ;1
out porta,r24 ;1
inc r24 ;1
out porta,r24 ;1
inc r24 ;1
out porta,r24 ;1

; TURN OFF VIDEO DAC
sbi portb,2 ;2

; SET TO BACK BUFFER
in r24,portb ;1
sbrc r24,5 ;1/2
cbi portb,5 ;2
sbrs r24,5 ;1/2
sbi portb,5 ;2

; SET SRAM TO IDLE
sbi portb,4 ;2

; ENABLE DATA BUS
ser r24 ;1
out ddrd,r24 ;1

 

; ****************************************************************************************
; **** HORIZONTAL FRONT PORCH = 12 CYCLES
; ****************************************************************************************

; BLANKING LINES EXIT POINT
NOVID:

; RESTORE STATUS REGISTER
pop r24 ;2
out sreg,r24 ;1
pop r24 ;2

; RETURN FROM INTERRUPT
reti ;4


; ****************************************************************************************
; **** VERTICAL LINE LOOKUP TABLE
; ****************************************************************************************
VLINE:
.Include "data-vline.asm"

; **********************************************************************************************
; **** ALPHANUMERIC CHARACTER SET
; **********************************************************************************************
CHARS:
.Include "data-charset.asm"
 
; ****************************************************************************************
; **** SINE WAVE TABLE DATA
; ****************************************************************************************
SINE:
.Include "data-sintable.asm"

; **********************************************************************************************
; **** 240 X 240 KING TUT FROM DPAINT
; **********************************************************************************************
PIC:
.Include "image-tuthires-data.asm"
 
; **********************************************************************************************
; **** 32 X 32 BALL SPRITE
; **********************************************************************************************
BALL:
.Include "data-ball.asm"