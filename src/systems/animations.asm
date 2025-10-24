include "constants.inc"

section "Animation Variables", wram0

flying_animation_counter: ds 1 ; Game loops between tiles swaping when animating

section "Animations", ROM0

;; Initializes animation variables
animations_init::
    ld a, ANIMATION_SPEED
    ld [flying_animation_counter], a
ret

;; Performs the corresponding animations for each game loop
animate::
    ld a, [last_input]
    bit PADB_UP, a
    call z, flying_animation
    ld a, [last_input]
    bit PADB_UP, a
    call nz, set_jumping_sprite
ret

;; Sets the jumping sprite for the penguin
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

;; Sets the idle sprite for the penguin
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

;; Performs the flying animation (idle-jumping tiles swap)
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