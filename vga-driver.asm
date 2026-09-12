
; ****************************************************************************************
; **** LUCIDSCIENCE.COM - VGA GENERATOR SYNC TEST BY RADBRAD
; ****************************************************************************************

; COMPILER SETTINGS
#include "m328Pdef.inc"

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
sbi ddrb,2 ; TEST LED

 

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
ldi r16,high(636)
sts ocr1ah,r16
ldi r16,low(636)
sts ocr1al,r16

; RESET VARIABLES
ldi xl,low(256)
ldi xh,high(256)
clr r16
st x+,r16
st x+,r16
st x+,r16
st x+,r16

; TURN ON GLOBAL INTERRUPTS
sei

 

; ****************************************************************************************
; **** RESET REGISTERS
; ****************************************************************************************
clr r19
clr r22

 

; ****************************************************************************************
; **** MAIN PROGRAM LOOP
; ****************************************************************************************
main:

; LED FLASH TIMER
inc r20
brne ff
inc r21
ff:

; LED ON
cpi r21,127
brne l1
sbi portb,2
l1:

; LED OFF
cpi r21,0
brne l2
cbi portb,2
l2:

rjmp main

 

; ****************************************************************************************
; **** VIDEO RENDERING INTERRUPT
; ****************************************************************************************
VIDEO:

; HORIZONTAL CLOCK TIMING
;HFP:12 (0-11)
;HSP:76 (12-87)
;HBP:36 (88-123)
;HPX:512 (124-635)
;TOT:636

; VERTICAL LINE TIMING
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

 

; ****************************************************************************************
; **** HORIZONTAL AND VERTICAL SYNC = 76 CYCLES
; ****************************************************************************************

; HORIZONTAL SYNC LOW
cbi portb,0 ;2

; LOAD REGISTERS FROM SRAM
; TIME = 14 CYCLES
push r26 ;2
push r27 ;2
ldi r26,low(256) ;1
ldi r27,high(256) ;1
ld r17,x+ ;2
ld r18,x+ ;2
ld r28,x+ ;2
ld r29,x+ ;2

; LINE COUNTER AND VERTICAL SYNC ON
; TIME = 12 CYCLES
adiw r29:r28,1 ;2
ldi r16,low(525) ;1
ldi r17,high(525) ;1
cp r16,r28 ;1
cpc r17,r29 ;1
breq s7 ;1/2
nop ;1
nop ;1
nop ;1
rjmp s8 ;2
s7:
clr r28 ;1
clr r29 ;1
cbi portb,1 ;2
s8:

; VERTICAL SYNC OFF AT LINE 2
; TIME = 8 CYCLES
ldi r16,low(2) ;1
ldi r17,high(2) ;1
cp r16,r28 ;1
cpc r17,r29 ;1
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
cp r16,r28 ;1
cpc r17,r29 ;1
brne s5 ;1/2
ldi r18,1 ;1
s5:

; ACTIVE PIXELS OFF AT LINE 514
; TIME = 6 CYCLES
ldi r16,low(514) ;1
ldi r17,high(514) ;1
cp r16,r28 ;1
cpc r17,r29 ;1
brne s6 ;1/2
ldi r18,0 ;1
s6:

nop ;1
nop ;1
nop ;1
nop ;1
nop ;1
nop ;1
nop ;1
nop ;1
nop ;1

; SAVE REGISTERS TO SRAM
; TIME = 12 CYCLES
st -x,r29 ;2
st -x,r28 ;2
st -x,r18 ;2
st -x,r17 ;2
pop r27 ;2
pop r26 ;2

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
nop ;1
nop ;1
nop ;1
nop ;1
nop ;1
nop ;1
nop ;1
nop ;1
nop ;1
nop ;1
nop ;1
nop ;1

; GENERATE 16X15 PALETTE BLOCKS
cpi r22,30 ;1
brne PAL1 ;1/2
clr r22 ;1
PAL1:
brne PAL2 ;1/2
subi r19,240 ;1
PAL2:
inc r22 ;1

; ****************************************************************************************
; **** HORIZONTAL ACTIVE LINE = 512 CYCLES / 2 = 256 PIXELS
; ****************************************************************************************

out portc,r19 ;1
nop ;1
nop ;1
nop ;1
nop ;1
nop ;1
nop ;1
nop ;1
nop ;1
nop ;1
nop ;1
nop ;1
nop ;1
nop ;1
nop ;1
nop ;1
nop ;1
nop ;1
nop ;1
nop ;1
nop ;1
nop ;1
nop ;1
nop ;1
nop ;1
nop ;1
nop ;1
nop ;1
nop ;1
nop ;1
nop ;1
inc r19 ;1

out portc,r19 ;1
nop ;1
nop ;1
nop ;1
nop ;1
nop ;1
nop ;1
nop ;1
nop ;1
nop ;1
nop ;1
nop ;1
nop ;1
nop ;1
nop ;1
nop ;1
nop ;1
nop ;1
nop ;1
nop ;1
nop ;1
nop ;1
nop ;1
nop ;1
nop ;1
nop ;1
nop ;1
nop ;1
nop ;1
nop ;1
nop ;1
inc r19 ;1

out portc,r19 ;1
nop ;1
nop ;1
nop ;1
nop ;1
nop ;1
nop ;1
nop ;1
nop ;1
nop ;1
nop ;1
nop ;1
nop ;1
nop ;1
nop ;1
nop ;1
nop ;1
nop ;1
nop ;1
nop ;1
nop ;1
nop ;1
nop ;1
nop ;1
nop ;1
nop ;1
nop ;1
nop ;1
nop ;1
nop ;1
nop ;1
inc r19 ;1

out portc,r19 ;1
nop ;1
nop ;1
nop ;1
nop ;1
nop ;1
nop ;1
nop ;1
nop ;1
nop ;1
nop ;1
nop ;1
nop ;1
nop ;1
nop ;1
nop ;1
nop ;1
nop ;1
nop ;1
nop ;1
nop ;1
nop ;1
nop ;1
nop ;1
nop ;1
nop ;1
nop ;1
nop ;1
nop ;1
nop ;1
nop ;1
inc r19 ;1

out portc,r19 ;1
nop ;1
nop ;1
nop ;1
nop ;1
nop ;1
nop ;1
nop ;1
nop ;1
nop ;1
nop ;1
nop ;1
nop ;1
nop ;1
nop ;1
nop ;1
nop ;1
nop ;1
nop ;1
nop ;1
nop ;1
nop ;1
nop ;1
nop ;1
nop ;1
nop ;1
nop ;1
nop ;1
nop ;1
nop ;1
nop ;1
inc r19 ;1

out portc,r19 ;1
nop ;1
nop ;1
nop ;1
nop ;1
nop ;1
nop ;1
nop ;1
nop ;1
nop ;1
nop ;1
nop ;1
nop ;1
nop ;1
nop ;1
nop ;1
nop ;1
nop ;1
nop ;1
nop ;1
nop ;1
nop ;1
nop ;1
nop ;1
nop ;1
nop ;1
nop ;1
nop ;1
nop ;1
nop ;1
nop ;1
inc r19 ;1

out portc,r19 ;1
nop ;1
nop ;1
nop ;1
nop ;1
nop ;1
nop ;1
nop ;1
nop ;1
nop ;1
nop ;1
nop ;1
nop ;1
nop ;1
nop ;1
nop ;1
nop ;1
nop ;1
nop ;1
nop ;1
nop ;1
nop ;1
nop ;1
nop ;1
nop ;1
nop ;1
nop ;1
nop ;1
nop ;1
nop ;1
nop ;1
inc r19 ;1

out portc,r19 ;1
nop ;1
nop ;1
nop ;1
nop ;1
nop ;1
nop ;1
nop ;1
nop ;1
nop ;1
nop ;1
nop ;1
nop ;1
nop ;1
nop ;1
nop ;1
nop ;1
nop ;1
nop ;1
nop ;1
nop ;1
nop ;1
nop ;1
nop ;1
nop ;1
nop ;1
nop ;1
nop ;1
nop ;1
nop ;1
nop ;1
inc r19 ;1

out portc,r19 ;1
nop ;1
nop ;1
nop ;1
nop ;1
nop ;1
nop ;1
nop ;1
nop ;1
nop ;1
nop ;1
nop ;1
nop ;1
nop ;1
nop ;1
nop ;1
nop ;1
nop ;1
nop ;1
nop ;1
nop ;1
nop ;1
nop ;1
nop ;1
nop ;1
nop ;1
nop ;1
nop ;1
nop ;1
nop ;1
nop ;1
inc r19 ;1

out portc,r19 ;1
nop ;1
nop ;1
nop ;1
nop ;1
nop ;1
nop ;1
nop ;1
nop ;1
nop ;1
nop ;1
nop ;1
nop ;1
nop ;1
nop ;1
nop ;1
nop ;1
nop ;1
nop ;1
nop ;1
nop ;1
nop ;1
nop ;1
nop ;1
nop ;1
nop ;1
nop ;1
nop ;1
nop ;1
nop ;1
nop ;1
inc r19 ;1

out portc,r19 ;1
nop ;1
nop ;1
nop ;1
nop ;1
nop ;1
nop ;1
nop ;1
nop ;1
nop ;1
nop ;1
nop ;1
nop ;1
nop ;1
nop ;1
nop ;1
nop ;1
nop ;1
nop ;1
nop ;1
nop ;1
nop ;1
nop ;1
nop ;1
nop ;1
nop ;1
nop ;1
nop ;1
nop ;1
nop ;1
nop ;1
inc r19 ;1

out portc,r19 ;1
nop ;1
nop ;1
nop ;1
nop ;1
nop ;1
nop ;1
nop ;1
nop ;1
nop ;1
nop ;1
nop ;1
nop ;1
nop ;1
nop ;1
nop ;1
nop ;1
nop ;1
nop ;1
nop ;1
nop ;1
nop ;1
nop ;1
nop ;1
nop ;1
nop ;1
nop ;1
nop ;1
nop ;1
nop ;1
nop ;1
inc r19 ;1

out portc,r19 ;1
nop ;1
nop ;1
nop ;1
nop ;1
nop ;1
nop ;1
nop ;1
nop ;1
nop ;1
nop ;1
nop ;1
nop ;1
nop ;1
nop ;1
nop ;1
nop ;1
nop ;1
nop ;1
nop ;1
nop ;1
nop ;1
nop ;1
nop ;1
nop ;1
nop ;1
nop ;1
nop ;1
nop ;1
nop ;1
nop ;1
inc r19 ;1

out portc,r19 ;1
nop ;1
nop ;1
nop ;1
nop ;1
nop ;1
nop ;1
nop ;1
nop ;1
nop ;1
nop ;1
nop ;1
nop ;1
nop ;1
nop ;1
nop ;1
nop ;1
nop ;1
nop ;1
nop ;1
nop ;1
nop ;1
nop ;1
nop ;1
nop ;1
nop ;1
nop ;1
nop ;1
nop ;1
nop ;1
nop ;1
inc r19 ;1

out portc,r19 ;1
nop ;1
nop ;1
nop ;1
nop ;1
nop ;1
nop ;1
nop ;1
nop ;1
nop ;1
nop ;1
nop ;1
nop ;1
nop ;1
nop ;1
nop ;1
nop ;1
nop ;1
nop ;1
nop ;1
nop ;1
nop ;1
nop ;1
nop ;1
nop ;1
nop ;1
nop ;1
nop ;1
nop ;1
nop ;1
nop ;1
inc r19 ;1

out portc,r19 ;1
nop ;1
nop ;1
nop ;1
nop ;1
nop ;1
nop ;1
nop ;1
nop ;1
nop ;1
nop ;1
nop ;1
nop ;1
nop ;1
nop ;1
nop ;1
nop ;1
nop ;1
nop ;1
nop ;1
nop ;1
nop ;1
nop ;1
nop ;1
nop ;1
nop ;1
nop ;1
nop ;1
nop ;1
nop ;1
nop ;1
subi r19,15 ;1

; HORIZONTAL BLANKING
clr r16 ;1
out portc,r16 ;1

; BLANK LINE EXIT POINT
NOVID:

; RESTORE STATUS REGISTER
pop r16 ;2
out sreg,r16 ;1

; RETURN FROM INTERRUPT
reti ;4