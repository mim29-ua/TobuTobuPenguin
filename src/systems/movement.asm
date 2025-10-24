include "constants.inc"

section "Movement", ROM0

;; Movement works by updating the CMP_SPRI 
;; coordinates according to the DPAD inputs
;;
;; move -> check_movement -> movement

;; Performs the corresponding movements according to pad inputs
;; and applies gravity
;;
;; INPUT:
;;      b -> DPAD input, 0 == pressed
move::
    ; Decode D-PAD input
    ld a, [last_input]
    bit PADB_DOWN, a
    call z, check_move_down
    ld a, [last_input]
    bit PADB_UP, a
    call z, check_move_up
    ld a, [last_input]
    bit PADB_LEFT, a
    call z, check_move_left
    ld a, [last_input]
    bit PADB_RIGHT, a
    call z, check_move_right

    ; Gravity (not applies if UP pressed)
    ld a, [last_input]
    bit PADB_UP, a
    ret z
    call check_move_down
ret

;; MOVE RIGHT

check_move_right:
    ; Check other entities collision
    ld a, RIGHT
    ld [actual_movement], a
    call check_colliding_entities_with_penguin
    call c, dead

    ; Check wall collision
    ld a, [LEFT_PENGUIN_X]
    cp RIGHT_WALL_PIXEL
    call nz, move_right
ret

move_right:
    ld h, CMP_SPRITE_H
    ld l, CMP_SPRI_L_X
    inc [hl]
    ld l, CMP_SPRI_R_X
    inc [hl]
ret

;; MOVE LEFT

dead:
    ld hl, $C103
    set 6, [hl]
    ld hl, $C107
    set 6, [hl]
    call wait_vblank
    call man_entity_draw
    call wait_vblank
    di
    halt
ret

check_move_left:
    ; Check other entities collision
    ld a, LEFT
    ld [actual_movement], a
    call check_colliding_entities_with_penguin
    call c, dead

    ; Check collision with wall
    ld a, [LEFT_PENGUIN_X]
    cp LEFT_WALL_PIXEL
    call nz, move_left
ret

move_left:
    ld h, CMP_SPRITE_H
    ld l, CMP_SPRI_L_X
    dec [hl]
    ld l, CMP_SPRI_R_X
    dec [hl]
ret

;; MOVE DOWN

check_move_down:
    ; Check other entities collision
    ld a, DOWN
    ld [actual_movement], a
    call check_colliding_entities_with_penguin
    ret c

    ; Check collision with wall
    ld a, [LEFT_PENGUIN_Y]
    cp DOWN_WALL_PIXEL
    call z, .dead
    call move_down
    ret
    .dead:
        call dead
ret

move_down:
    ld h, CMP_SPRITE_H
    ld l, CMP_SPRI_L_Y
    inc [hl]
    ld l, CMP_SPRI_R_Y
    inc [hl]
ret

;; MOVE UP

check_move_up:
    ; Check other entities collision
    ld a, UP
    ld [actual_movement], a
    call check_colliding_entities_with_penguin
    call c, dead

    ; Check collision with wall
    ld a, [LEFT_PENGUIN_Y]
    cp UP_WALL_PIXEL
    ret z

    ; Check middle of screen reached to make tilemap go up
    ld a, [LEFT_PENGUIN_Y]
    cp MIDDLE_SCREEN_Y_PIXELS
    jr c, .move_background
    call move_up
    ret
    .move_background:
        call move_background
ret

move_up:
    ld h, CMP_SPRITE_H
    ld l, CMP_SPRI_L_Y
    dec [hl]
    ld l, CMP_SPRI_R_Y
    dec [hl]
ret