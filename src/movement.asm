INCLUDE "constants.inc"

SECTION "Movement", ROM0

decode_dpad::
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
    jr z, .exit
    call move_down
    .exit:
    
    ret

move_right:
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

move_left:
    ; Check collision
    ld a, [$FE01]
    cp 8
    jr z, .exit

    ; Move
    ld hl, $FE01
    dec [hl]
    ld l, $05
    dec [hl]

    .exit:
    ret

move_down:
    ; Check collision
    ld a, [$FE00]
    cp 144
    jr z, .landed

    ; While falling
    call set_jumping_sprite

    ; Move
    ld hl, $FE00
    inc [hl]
    ld l, $04
    inc [hl]
    jr .exit

    .landed:
        call set_idle_sprite

    .exit:
    ret

move_up:
    call flying_animation

    ; Check collision
    ld a, [$FE00]
    cp 16
    jr z, .exit

    ; Move
    ld hl, $FE00
    dec [hl]
    ld l, $04
    dec [hl]

    .exit:
    ret