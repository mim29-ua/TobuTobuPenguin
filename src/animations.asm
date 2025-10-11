INCLUDE "constants.inc"

SECTION "Animations", ROM0

set_jumping_sprite::
    ; Check if sprite is already set
    ld a, [$FE02]
    cp $20
    jr z, .exit

    ; Set sprite
    ld a, $20
    ld [$FE02], a
    ld a, $22
    ld [$FE06], a

    .exit:
    ret

set_idle_sprite::
    ; Check if sprite is already set
    ld a, [$FE02]
    cp $1C
    jr z, .exit

    ; Set sprite
    ld a, $1C
    ld [$FE02], a
    ld a, $1E
    ld [$FE06], a

    .exit:
    ret

; Switches left and right penguin sprites
switch_sprites::
    ld a, [$FE02]
    ld b, a
    ld a, [$FE06]
    ld [$FE02], a
    ld a, b
    ld [$FE06], a
    ret


set_right_sprite::
    ; Flip sprites
    ld hl, $FE03
    set X_FLIP, [hl]
    ld hl, $FE07
    set X_FLIP, [hl]

    ; Change tiles
    ld a, $1E
    ld [$FE02], a ;; Tile index


    ret

set_left_sprite::
    ; Flip sprites
    ld hl, $FE03
    res X_FLIP, [hl]
    ld hl, $FE07
    res X_FLIP, [hl]

    ; Change tiles
    ld a, $1C
    ld [$FE02], a ;; Tile index
    ld a, $1E
    ld [$FE06], a ;; Tile index

    ret

flying_animation::
    ld hl, counter
    dec [hl]
    jr nz, .exit

    ; Check if sprite is already set
    ld a, [$FE02]
    cp $1C
    jr z, .set_jumping_sprite
    jr nz, .set_idle_sprite

    .set_jumping_sprite:
        call set_jumping_sprite
        jr .update_counter
    .set_idle_sprite:
        call set_idle_sprite
        jr .update_counter

    .update_counter:
        ld [hl], ANIMATION_SPEED

    .exit:
    ret