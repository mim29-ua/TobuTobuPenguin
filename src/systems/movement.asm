include "constants.inc"
include "man/man_entity.inc"

section "Movement", ROM0

; Movement works by updating the CMP_SPRI 
; coordinates according to the DPAD inputs

move::
    ; Decode D-PAD input
    bit PADB_DOWN, b
    call z, move_down
    bit PADB_UP, b
    call z, move_up
    bit PADB_LEFT, b
    call z, move_left
    bit PADB_RIGHT, b
    call z, move_right

    ; Gravity (not applies if UP pressed)
    bit PADB_UP, b
    ret z
    call move_down
ret

move_right:
    ld h, CMP_SPRITE_H
    ld l, CMP_SPRI_L_X
    inc [hl]
    ld l, CMP_SPRI_R_X
    inc [hl]
ret

move_left:
    ld h, CMP_SPRITE_H
    ld l, CMP_SPRI_L_X
    dec [hl]
    ld l, CMP_SPRI_R_X
    dec [hl]
ret

move_down:
    ld h, CMP_SPRITE_H
    ld l, CMP_SPRI_L_Y
    inc [hl]
    ld l, CMP_SPRI_R_Y
    inc [hl]
ret

move_up:
    ld h, CMP_SPRITE_H
    ld l, CMP_SPRI_L_Y
    dec [hl]
    ld l, CMP_SPRI_R_Y
    dec [hl]
ret