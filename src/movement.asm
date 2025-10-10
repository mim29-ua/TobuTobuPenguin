INCLUDE "constants.inc"

SECTION "Movement", ROM0

move_right::
    ; Check collision
    ld a, [$FE05]
    cp 160
    jr z, .exit

    ; Move
    ld hl, $FE05
    inc [hl]
    ld l, $01
    inc [hl]

    .exit:
        ret

move_left::
    ; Check collision
    ld a, [$FE01]
    cp 8
    jr z, .exit

    ; Move
    ld hl, $FE01
    dec [hl]
    dec [hl]
    ld l, $05
    dec [hl]
    dec [hl]

    .exit:
        ret

move_down::
    ; Check collision
    ld a, [$FE00]
    cp 144
    jr z, .exit

    ; Move
    ld hl, $FE00
    inc [hl]
    ld l, $04
    inc [hl]

    .exit:
        ret

move_up::
    ; Check collision
    ld a, [$FE00]
    cp 16
    jr z, .exit

    ; Move
    ld hl, $FE00
    dec [hl]
    dec [hl]
    ld l, $04
    dec [hl]
    dec [hl]

    .exit:
        ret

gravity::
    jp move_down