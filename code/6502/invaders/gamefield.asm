; Troy's HBC-56 - 6502 - Invaders
;
; Copyright (c) 2021 Troy Schrapel
;
; This code is licensed under the MIT license
;
; https://github.com/visrealm/hbc-56
;
; Game field definitions
;

GAMEFIELD = $1000

GAME_COLS  = 24
GAME_ROWS  = 11

; X/Y indexes as tile location in screeen tiles
; returns:
;  X/Y
tileXyToGameFieldXy:
        txa
        sec
        sbc GAMEFIELD_OFFSET_X
        lsr
        tax

        tya
        sec
        sbc GAMEFIELD_OFFSET_Y
        lsr
        tay
        rts

; Sets the TMS location for the given gamefield offset
gameFieldRowSetTmsPos:
        lda TMP_X_POSITION
        asl
        clc
        adc GAMEFIELD_OFFSET_X
        tax

        lda TMP_Y_POSITION
        clc
        adc GAMEFIELD_OFFSET_Y
        tay
        jmp tmsSetPos



; -----------------------------------------------------------------------------
; gameFieldObjectAt: Return gamefield object at given location
; -----------------------------------------------------------------------------
; TMP_X_POSITION: X Offset into gamefield
; TMP_Y_POSITION: Y Offset into gamefield
; -----------------------------------------------------------------------------
gameFieldObjectAt:
        lda TMP_Y_POSITION
        and #$fe
        asl
        asl
        asl
        clc
        adc TMP_X_POSITION
        tax
        lda GAMEFIELD, x
        rts



renderGameField:

        lda #0
        sta TMP_X_POSITION
        sta TMP_Y_POSITION
        sta TMP_GAMEFIELD_OFFSET

        jsr gameFieldRowSetTmsPos

        ; send a blank row
        ldx #GAME_COLS
        lda #0
-
        sta TMS9918_RAM
        +tmsWait
        dex
        bne -

        inc TMP_Y_POSITION

.startRow
        jsr gameFieldRowSetTmsPos
        +tmsPut 0 ; first col - 0

.renderGameObjRow0
        ; get the game object at TMP_X_POSITION, TMP_Y_POSITION
        jsr gameFieldObjectAt
        sta TMS9918_RAM
        +tmsWait
        clc
        adc #1
        sta TMS9918_RAM
        +tmsWait

        inc TMP_X_POSITION
        lda TMP_X_POSITION
        cmp #GAME_COLS
        bne .renderGameObjRow0

        +tmsPut 0 ; last col - 0
        
        inc TMP_Y_POSITION
        jsr gameFieldRowSetTmsPos
        +tmsPut 0 ; first col - 0

.renderGameObjRow1
        ; get the game object at TMP_X_POSITION, TMP_Y_POSITION
        jsr gameFieldObjectAt
        clc
        adc #2
        sta TMS9918_RAM
        +tmsWait
        clc
        adc #1
        sta TMS9918_RAM
        +tmsWait

        inc TMP_X_POSITION
        lda TMP_X_POSITION
        cmp #GAME_COLS
        bne .renderGameObjRow0

        +tmsPut 0 ; last col - 0

        inc TMP_Y_POSITION
        lda TMP_Y_POSITION
        cmp #GAME_ROWS
        bne .startRow

        rts


;initialGameFieldTiles:
;!byte 0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0
;!byte 0,136,137,136,137,136,137,136,137,136,137,136,137,136,137,136,137,136,137,136,137,136,137,  0
;!byte 0,138,139,138,139,138,139,138,139,138,139,138,139,138,139,138,139,138,139,138,139,138,139,  0
;!byte 0,132,133,132,133,132,133,132,133,132,133,132,133,132,133,132,133,132,133,132,133,132,133,  0
;!byte 0,134,135,134,135,134,135,134,135,134,135,134,135,134,135,134,135,134,135,134,135,134,135,  0
;!byte 0,132,133,132,133,132,133,132,133,132,133,132,133,132,133,132,133,132,133,132,133,132,133,  0
;!byte 0,134,135,134,135,134,135,134,135,134,135,134,135,134,135,134,135,134,135,134,135,134,135,  0
;!byte 0,128,129,128,129,128,129,128,129,128,129,128,129,128,129,128,129,128,129,128,129,128,129,  0
;!byte 0,130,131,130,131,130,131,130,131,130,131,130,131,130,131,130,131,130,131,130,131,130,131,  0
;!byte 0,128,129,128,129,128,129,128,129,128,129,128,129,128,129,128,129,128,129,128,129,128,129,  0
;!byte 0,130,131,130,131,130,131,130,131,130,131,130,131,130,131,130,131,130,131,130,131,130,131,  0

initialGameField:
!fill 11, 136
!fill 5, 0
!fill 11, 132
!fill 5, 0
!fill 11, 132
!fill 5, 0
!fill 11, 128
!fill 5, 0
!fill 11, 128
!fill 5, 0


shieldLayout:
!byte 8,9,10,0,0,0,14,15,16,0,0,0,0,20,21,22,0,0,0,26,27,28
!fill 10, 0
!byte 11,12,13,0,0,0,17,18,19,0,0,0,0,23,24,25,0,0,0,29,30,31
SHIELD_BYTES = * - shieldLayout

bunkerLayout:
!byte 176
!fill 22, 177
!byte 178
!fill 8, 0
!byte 179
!fill 22, 0
!byte 180
!fill 8, 0
!byte 181
!fill 22, 182
!byte 183
BUNKER_BYTES = * - bunkerLayout