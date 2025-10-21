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
    cp LEFT_PENGUIN_TILE_JUMPING
    ret z

    ; Set sprite
    ld a, LEFT_PENGUIN_TILE_JUMPING
    ld [LEFT_PENGUIN_TILE_INDEX], a
    ld a, RIGHT_PENGUIN_TILE_JUMPING
    ld [RIGHT_PENGUIN_TILE_INDEX], a
ret

set_idle_sprite:
    ; Checks if sprite is already set
    ld a, [LEFT_PENGUIN_TILE_INDEX]
    cp LEFT_PENGUIN_TILE_IDLE
    ret z

    ; Set sprite
    ld a, LEFT_PENGUIN_TILE_IDLE
    ld [LEFT_PENGUIN_TILE_INDEX], a
    ld a, RIGHT_PENGUIN_TILE_IDLE
    ld [RIGHT_PENGUIN_TILE_INDEX], a
ret

flying_animation:
    ld hl, flying_animation_counter
    dec [hl]
    ret nz

    ; Check if sprite is already set
    ld a, [LEFT_PENGUIN_TILE_INDEX]
    cp LEFT_PENGUIN_TILE_IDLE
    jr z, .set_jumping_sprite

    .set_idle_sprite:
        call set_idle_sprite
        jr .update_counter

    .set_jumping_sprite:
        call set_jumping_sprite

    .update_counter:
        ld [hl], ANIMATION_SPEED
ret