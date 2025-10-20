include "constants.inc"

section "Animation Variables", wram0

flying_animation_counter: ds 1

section "Animations", ROM0

animations_init::
    ld a, ANIMATION_SPEED
    ld [flying_animation_counter], a
ret

animate::
    bit PADB_UP, b
    call z, flying_animation
    bit PADB_UP, b
    call nz, set_jumping_sprite
ret

set_jumping_sprite:
    ; Checks if sprite is already set
    ld a, [LEFT_PENGUIN_TILE_INDEX]
    cp $20
    ret z

    ; Set sprite
    ld a, $20
    ld [LEFT_PENGUIN_TILE_INDEX], a
    ld a, $22
    ld [RIGHT_PENGUIN_TILE_INDEX], a
ret

set_idle_sprite:
    ; Checks if sprite is already set
    ld a, [LEFT_PENGUIN_TILE_INDEX]
    cp $1C
    ret z

    ; Set sprite
    ld a, $1C
    ld [LEFT_PENGUIN_TILE_INDEX], a
    ld a, $1E
    ld [RIGHT_PENGUIN_TILE_INDEX], a
ret

flying_animation:
    ld hl, flying_animation_counter
    dec [hl]
    ret nz

    ; Check if sprite is already set
    ld a, [LEFT_PENGUIN_TILE_INDEX]
    cp $1C
    jr z, .set_jumping_sprite

    .set_idle_sprite:
        call set_idle_sprite
        jr .update_counter

    .set_jumping_sprite:
        call set_jumping_sprite

    .update_counter:
        ld [hl], ANIMATION_SPEED
ret