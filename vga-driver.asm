; ****************************************************************************************
; **** LUCIDSCIENCE.COM - VGA GENERATOR ANIMATION TEST BY RADBRAD
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

sbi ddrb,0 ; HORIZONTAL SYNC PULSE
sbi ddrb,1 ; VERTICAL SYNC PULSE
cbi ddrb,2 ; TEST PUSH BUTTON

 

; ****************************************************************************************
; **** IO PORT C SETUP
; ****************************************************************************************

sbi ddrc,0 ; RED BIT 0
sbi ddrc,1 ; RED BIT 1
sbi ddrc,2 ; GRN BIT 0
sbi ddrc,3 ; GRN BIT 1
sbi ddrc,4 ; BLU BIT 0
sbi ddrc,5 ; BLU BIT 1
sbi ddrc,6 ; INT BIT 0
sbi ddrc,7 ; INT BIT 1

 

; ****************************************************************************************
; **** STARTUP SEQUENCE
; ****************************************************************************************

; STACK POINTER
ldi r16,low(ramend)
out spl,r16
ldi r16,high(ramend)
out sph,r16

; SET TIMER1 TO SCLK WITH RESET
ldi r16,(1<<CS10 | 1<<WGM12)
sts tccr1b,r16

; SET TIMER1 MATCH A INTERRUPT
ldi r16,(1<<OCIE1A)
sts timsk1,r16

; SET TIMER1 INTERRUPT TIME A VALUE
ldi r16,high(636) ;$$$
sts ocr1ah,r16
ldi r16,low(636) ;$$$
sts ocr1al,r16

; RESET VARIABLES
ldi xl,low(256)
ldi xh,high(256)
clr r16
st x+,r16
st x+,r16
st x+,r16
st x+,r16

; RESET ALL REGISTERS
clr r0
clr r16
clr r17
clr r18
clr r19
clr r20
clr r21
clr r22
clr r23
clr r24
clr r25
clr xl
clr xh
clr yl
clr yh
clr zl
clr zh

; TURN ON GLOBAL INTERRUPTS
sei

 

; ****************************************************************************************
; **** MAIN PROGRAM LOOP
; ****************************************************************************************
main:

; INCREMENT FRAME COUNT
inc r25

cpi r25,1
brne FR1
ldi zl,low(2*FRAME1)
ldi zh,high(2*FRAME1)
FR1:
cpi r25,2
brne FR2
ldi zl,low(2*FRAME2)
ldi zh,high(2*FRAME2)
FR2:
cpi r25,3
brne FR3
ldi zl,low(2*FRAME3)
ldi zh,high(2*FRAME3)
FR3:
cpi r25,4
brne FR4
ldi zl,low(2*FRAME4)
ldi zh,high(2*FRAME4)
FR4:
cpi r25,5
brne FR5
ldi zl,low(2*FRAME5)
ldi zh,high(2*FRAME5)
FR5:
cpi r25,6
brne FR6
ldi zl,low(2*FRAME6)
ldi zh,high(2*FRAME6)
FR6:
cpi r25,7
brne FR7
ldi zl,low(2*FRAME7)
ldi zh,high(2*FRAME7)
FR7:
cpi r25,8
brne FR8
ldi zl,low(2*FRAME8)
ldi zh,high(2*FRAME8)
FR8:
cpi r25,9
brne FR9
ldi zl,low(2*FRAME9)
ldi zh,high(2*FRAME9)
FR9:
cpi r25,10
brne FR10
ldi zl,low(2*FRAME10)
ldi zh,high(2*FRAME10)
clr r25
FR10:

; DRAW WORMHOLE FRAME
ldi xl,low(260)
ldi xh,high(260)
ldi r23,56
ldi r24,60
FRAME:
lpm r19,z+
st x+,r19
dec r23
brne FRAME
ldi r23,56
dec r24
brne FRAME

; PRINT TEXT ON BUTTON PUSH
sbic pinb,2
rjmp NOTEXT

ldi r19,6
mov r15,r19
TM1:

ldi zl,low(2*SINE)
ldi zh,high(2*SINE)
add zl,r10
adc zh,r1
inc r10
ldi xl,8 ; XLOC
lpm xh,z
lsr xh
lsr xh
lsr xh
lsr xh
ldi r19,12 ; YLOC
add xh,r19

ldi r19,12 ;L
mov r23,xl
mov r24,xh
call print

ldi r19,21 ;U
mov r23,xl
ldi zl,8
add r23,zl
mov r24,xh
call print

ldi r19,3 ;C
mov r23,xl
ldi zl,16
add r23,zl
mov r24,xh
call print

ldi r19,9 ;I
mov r23,xl
ldi zl,24
add r23,zl
mov r24,xh
call print

ldi r19,4 ;D
mov r23,xl
ldi zl,32
add r23,zl
mov r24,xh
call print

dec r15
brne TM1

ldi r19,6
mov r15,r19
TM2:

ldi zl,low(2*SINE)
ldi zh,high(2*SINE)
add zl,r10
adc zh,r1
ldi xl,0 ; XLOC
lpm xh,z
lsr xh
lsr xh
lsr xh
lsr xh
ldi r19,20 ; YLOC
add xh,r19

ldi r19,19 ;S
mov r23,xl
mov r24,xh
call print

ldi r19,3 ;C
mov r23,xl
ldi zl,8
add r23,zl
mov r24,xh
call print

ldi r19,9 ;I
mov r23,xl
ldi zl,16
add r23,zl
mov r24,xh
call print

ldi r19,5 ;E
mov r23,xl
ldi zl,24
add r23,zl
mov r24,xh
call print

ldi r19,14 ;N
mov r23,xl
ldi zl,32
add r23,zl
mov r24,xh
call print

ldi r19,3 ;C
mov r23,xl
ldi zl,40
add r23,zl
mov r24,xh
call print

ldi r19,5 ;E
mov r23,xl
ldi zl,48
add r23,zl
mov r24,xh
call print

dec r15
brne TM2
NOTEXT:

; END OF MAIN LOOP
rjmp main

 

; ****************************************************************************************
; **** PRINT TEXT CHARACTER
; ****************************************************************************************
PRINT:

; STACK OPERATION
push xl
push xh

; SET SCREEN LOCATION (R23,R24)
ldi xl,low(260)
ldi xh,high(260)
add xl,r23
ldi zl,56
mul r24,zl
add xl,r0
adc xh,r1

; SET CHARACTER CODE (r19)
ldi zl,low(2*CHARS)
ldi zh,high(2*CHARS)
ldi r23,8
mul r19,r23
add zl,r0
adc zh,r1

; DRAW CHARACTER
ldi r23,8
ldi r24,255 ; COLOR
CBITS:

;READ CHARACTER BYTE
lpm r19,z+

; SHIFT CHARACTER BITS
sbrc r19,0
st x,r24
adiw xh:xl,1
sbrc r19,1
st x,r24
adiw xh:xl,1
sbrc r19,2
st x,r24
adiw xh:xl,1
sbrc r19,3
st x,r24
adiw xh:xl,1
sbrc r19,4
st x,r24
adiw xh:xl,1
sbrc r19,5
st x,r24
adiw xh:xl,1
sbrc r19,6
st x,r24
adiw xh:xl,1
sbrc r19,7
st x,r24
adiw xh:xl,1

; MOVE TO NEXT LINE
adiw xh:xl,48

; COMPLETE CHARACTER
dec r23
brne CBITS

; STACK OPERATION
pop xh
pop xl
ret

 

; ****************************************************************************************
; **** VIDEO RENDERING INTERRUPT
; ****************************************************************************************
VIDEO:

; -------------------------
; HORIZONTAL CLOCK TIMING
; -------------------------
;HFP:12 (0-11)
;HSP:76 (12-87)
;HBP:36 (88-123)
;HPX:512 (124-635)
;TOT:636

; -------------------------
; VERTICAL LINE TIMING
; -------------------------
;VSP:2 (0-1)
;VBP:32 (2-33)
;VLN:480 (34-513)
;VFP:11 (514-524)
;TOT:525 LINES

 

; ****************************************************************************************
; **** HORIZONTAL FRONT PORCH = 12 CYCLES
; ****************************************************************************************

; SAVE STATUS REGISTER
in r16,sreg ;1
push r16 ;2

; EQUALIZE INTERRUPT LATENCY
lds r16,tcnt1l ;2
cpi r16,10 ;1
brlo LATFIX1 ;1/2
LATFIX1:
cpi r16,11 ;1
brlo LATFIX2 ;1/2
LATFIX2:
cpi r16,12 ;1
brlo LATFIX3 ;1/2
LATFIX3:
cpi r16,13 ;1
brlo LATFIX4 ;1/2
LATFIX4:

 

; ****************************************************************************************
; **** HORIZONTAL AND VERTICAL SYNC = 76 CYCLES
; ****************************************************************************************

; HORIZONTAL SYNC LOW
cbi portb,0 ;2

; SAVE R0 AND R1 REGISTERS
push r0 ;2
push r1 ;2

; LOAD REGISTERS FROM SRAM
; TIME = 12 CYCLES
push xl ;2
push xh ;2
lds r17,256 ;2
lds r18,257 ;2
lds yl,258 ;2
lds yh,259 ;2

; LINE COUNTER AND VERTICAL SYNC ON
; TIME = 12 CYCLES
adiw yh:yl,1 ;2
ldi r16,low(525) ;1
ldi r17,high(525) ;1
cp r16,yl ;1
cpc r17,yh ;1
breq s7 ;1/2
nop ;1
nop ;1
nop ;1
rjmp s8 ;2
s7:
clr yl ;1
clr yh ;1
cbi portb,1 ;2
s8:

; VERTICAL SYNC OFF AT LINE 2
; TIME = 8 CYCLES
ldi r16,low(2) ;1
ldi r17,high(2) ;1
cp r16,yl ;1
cpc r17,yh ;1
breq s3 ;1/2
nop ;1
rjmp s4 ;2
s3:
sbi portb,1 ;2
s4:

; ACTIVE PIXELS ON AT LINE 34
; TIME = 6 CYCLES
ldi r16,low(34) ;1
ldi r17,high(34) ;1
cp r16,yl ;1
cpc r17,yh ;1
brne s5 ;1/2
ldi r18,1 ;1
s5:

; ACTIVE PIXELS OFF AT LINE 514
; TIME = 6 CYCLES
ldi r16,low(514) ;1
ldi r17,high(514) ;1
cp r16,yl ;1
cpc r17,yh ;1
brne s6 ;1/2
ldi r18,0 ;1
s6:

; TEMP SRAM LOCATION RESET
cpi r18,0 ;1
brne TR ;1/2
clr r21 ;1
TR:
nop ;1

; SAVE REGISTERS TO SRAM
; TIME = 12 CYCLES
sts 256,r17 ;2
sts 257,r18 ;2
sts 258,yl ;2
sts 259,yh ;2
pop xh ;2
pop xl ;2

; HORIZONTAL SYNC HIGH
sbi portb,0 ;2

 

; ****************************************************************************************
; **** HORIZONTAL BACK PORCH = 36 CYCLES
; ****************************************************************************************

; EXIT ON VERTICAL BLANKING
cpi r18,0 ;1
brne s9 ;1/2
rjmp NOVID ;2
s9:

nop ;1
nop ;1
nop ;1
nop ;1
nop ;1
nop ;1

; DIVIDE VERTICAL LINES BY 8
push xl ;2
push xh ;2
inc r20 ;1
cpi r20,8 ;1
brne ML1 ;1/2
clr r20 ;1
ML1:
brne ML2 ;1/2
inc r21 ;1
ML2:

; MULTIPLY AND SET SRAM ADDRESS
ldi xl,low(260) ;1
ldi xh,high(260) ;1
ldi r16,56 ;1
mul r16,r21 ;1
add xl,r0 ;1
adc xh,r1 ;1

 

; ****************************************************************************************
; **** HORIZONTAL ACTIVE LINE = 512 CYCLES / 9 = 56 PIXELS
; ****************************************************************************************

; SEND 56 PIXELS FROM SRAM
ldi r22, 56 ;1
PIXELS:
nop ;1
nop ;1
nop ;1
ld r16,x+ ;2
out portc,r16 ;1
dec r22 ;1
brne PIXELS ;1/2
pop xh ;2
pop xl ;2

; HORIZONTAL BLANKING
clr r16 ;1
out portc,r16 ;1

;nop ;1
;nop ;1
;nop ;1
;nop ;1

; BLANK LINE EXIT POINT
NOVID:

; RESTORE R0 AND R1 REGISTERS
pop r1 ;2
pop r0 ;2

; RESTORE STATUS REGISTER
pop r16 ;2
out sreg,r16 ;1

; RETURN FROM INTERRUPT
reti ;4

; ****************************************************************************************
; **** 10 FRAME 56 X 60 WORMHOLE ANIMATION
; ****************************************************************************************
.Include "animation-lowres.asm"

; **********************************************************************************************
; **** SINE TABLE DATA
; **********************************************************************************************
SINE:
.Include "data-sintable.asm"

; **********************************************************************************************
; **** ALPHANUMERIC CHARACTER SET
; **********************************************************************************************
CHARS:
.Include "charset-simple.asm"