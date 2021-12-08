; 6502 KB Controller - HBC-56
;
; Copyright (c) 2021 Troy Schrapel
;
; This code is licensed under the MIT license
;
; https://github.com/visrealm/hbc-56
;
; Dependencies:
;  - hbc56.asm


; -------------------------
; Constants
; -------------------------
KB_IO_PORT	= $81

KB_FLAGS        = $7e81

KB_SHIFT_DOWN   = %00000001
KB_CTRL_DOWN    = %00000010
KB_ALT_DOWN     = %00000100
KB_CAPS_LOCK    = %00001000
KB_NUM_LOCK     = %00010000

KB_RELEASE      = $f0

KB_SCANCODE_LEFT_SHIFT   = $12
KB_SCANCODE_RIGHT_SHIFT  = $59
KB_SCANCODE_CAPS_LOCK    = $58

; IO Ports
KB_IO_ADDR     = IO_PORT_BASE_ADDRESS | KB_IO_PORT

!macro kbBranchIfNotPressed .buttonMask, addr {
        jsr kbReadAscii
        cmp #.buttonMask
        bne addr
}

; -----------------------------------------------------------------------------
; kbWaitData: Not sure how much delay we need so make a macro for now
; -----------------------------------------------------------------------------
!macro kbWaitData {
        ldy #16
        jsr hbc56CustomDelay        
}

kbWaitData:
	ldy #0
-
	dey
	bne -
        rts

; -----------------------------------------------------------------------------
; kbInit: Initialise the keyboard
; -----------------------------------------------------------------------------
kbInit:
        lda #$00
        sta KB_FLAGS
        rts

; -----------------------------------------------------------------------------
; kbWaitForKey: Wait for a key press
; -----------------------------------------------------------------------------
kbWaitForKey:
        jsr kbReadAscii
        cmp #$ff
        beq kbWaitForKey
        rts

.kbReadByte:        
        +kbWaitData
        ldx KB_IO_ADDR

        ldy #32
-
	dey
	bne -

        lda KB_IO_ADDR
        rts

; -----------------------------------------------------------------------------
; kbRead: Read keyboard buffer
; -----------------------------------------------------------------------------
; Outputs:
;   A: Value of the buffer
kbReadAscii:
        jsr .kbReadByte
        cpx #KB_RELEASE
        bne .keyPressed

        jsr .kbReadByte  ; read the released key

        cpx #KB_SCANCODE_LEFT_SHIFT
        beq .shiftReleased
        cpx #KB_SCANCODE_RIGHT_SHIFT
        beq .shiftReleased
        jmp +

.shiftReleased:
        lda #$ff
        eor #KB_SHIFT_DOWN
        and KB_FLAGS
        sta KB_FLAGS
+
        lda #$ff
        rts

.keyPressed:
        cpx #KB_SCANCODE_LEFT_SHIFT
        beq .shiftPressed
        cpx #KB_SCANCODE_RIGHT_SHIFT
        beq .shiftPressed
        cpx #KB_SCANCODE_CAPS_LOCK
        beq .capsLockPressed
        jmp +

.shiftPressed:
        lda #KB_SHIFT_DOWN
        ora KB_FLAGS
        sta KB_FLAGS
        lda #$ff
        jmp .endKbReadAscii
.capsLockPressed:
        lda #KB_CAPS_LOCK
        eor KB_FLAGS
        sta KB_FLAGS
        lda #$ff
        jmp .endKbReadAscii

+
        lda #KB_SHIFT_DOWN
        bit KB_FLAGS
        beq ++
        lda KEY_MAP_SHIFTED, x
        jmp .haveKey
++
        lda KEY_MAP, x
.haveKey
        ;jmp .endKbReadAscii
        tax
        cmp #$ff
        beq +
        lda #KB_CAPS_LOCK
        bit KB_FLAGS
        beq +
        txa
        and #$40
        beq +
        txa
        eor #$20
        rts
+
        txa

.endKbReadAscii
        rts


KEY_MAP:
;      0   1   2   3   4   5   6   7   8   9   a   b   c   d   e   f
!byte $ff,$88,$ff,$84,$82,$80,$81,$8b,$ff,$89,$87,$85,$83,$09,$60,$ff; 0
!byte $ff,$ff,$ff,$ff,$ff,$71,$31,$ff,$ff,$ff,$7a,$73,$61,$77,$32,$ff; 1
!byte $ff,$63,$78,$64,$65,$34,$33,$ff,$ff,$20,$76,$66,$74,$72,$35,$ff; 2
!byte $ff,$6e,$62,$68,$67,$79,$36,$ff,$ff,$ff,$6d,$6a,$75,$37,$38,$ff; 3
!byte $ff,$2c,$6b,$69,$6f,$30,$39,$ff,$ff,$2e,$2f,$6c,$3b,$70,$2d,$ff; 4
!byte $ff,$ff,$27,$ff,$5b,$3d,$ff,$ff,$ff,$ff,$0d,$5d,$ff,$5c,$ff,$ff; 5
!byte $ff,$ff,$ff,$ff,$ff,$ff,$08,$ff,$ff,$31,$ff,$34,$37,$ff,$ff,$ff; 6
!byte $30,$ff,$32,$35,$36,$38,$1b,$ff,$8a,$ff,$33,$2d,$ff,$39,$ff,$ff; 7

KEY_MAP_SHIFTED:
;      0   1   2   3   4   5   6   7   8   9   a   b   c   d   e   f
!byte $ff,$88,$ff,$84,$82,$80,$81,$8b,$ff,$89,$87,$85,$83,$09,$7e,$ff; 0
!byte $ff,$ff,$ff,$ff,$ff,$51,$21,$ff,$ff,$ff,$5a,$53,$41,$57,$40,$ff; 1
!byte $ff,$43,$58,$44,$45,$24,$23,$ff,$ff,$20,$56,$46,$54,$52,$25,$ff; 2
!byte $ff,$4e,$42,$48,$47,$59,$5e,$ff,$ff,$ff,$4d,$4a,$55,$26,$2a,$ff; 3
!byte $ff,$3c,$4b,$49,$4f,$29,$28,$ff,$ff,$3e,$3f,$4c,$3a,$50,$5f,$ff; 4
!byte $ff,$ff,$22,$ff,$7b,$2b,$ff,$ff,$ff,$ff,$0d,$7d,$ff,$7c,$ff,$ff; 5
!byte $ff,$ff,$ff,$ff,$ff,$ff,$08,$ff,$ff,$31,$ff,$34,$37,$ff,$ff,$ff; 6
!byte $30,$ff,$32,$35,$36,$38,$1b,$ff,$8a,$ff,$33,$2d,$ff,$39,$ff,$ff; 7