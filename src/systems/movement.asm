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
    call z, check_move_penguin_down
    ld a, [last_input]
    bit PADB_UP, a
    call z, check_move_penguin_up
    ld a, [last_input]
    bit PADB_LEFT, a
    call z, check_move_penguin_left
    ld a, [last_input]
    bit PADB_RIGHT, a
    call z, check_move_penguin_right

    ; Gravity (not applies if UP pressed)
    ld a, [last_input]
    bit PADB_UP, a
    ret z
    call check_move_penguin_down
ret



;; ---------------------------------------------------
;; CHECK PENGUIN MOVES

check_move_penguin_right:
    ; Check other entities collision
    ld a, RIGHT
    ld [actual_movement], a
    call check_colliding_entities_with_penguin
    call c, dead

    ; Check wall collision
    ld a, [LEFT_PENGUIN_X]
    cp RIGHT_WALL_PIXEL
    ret z

    ; Move penguin
    ld de, PENGUIN_INFO_CMPS
    call move_entity_right
ret

check_move_penguin_left:
    ; Check other entities collision
    ld a, LEFT
    ld [actual_movement], a
    call check_colliding_entities_with_penguin
    call c, dead

    ; Check collision with wall
    ld a, [LEFT_PENGUIN_X]
    cp LEFT_WALL_PIXEL
    ret z

    ; Move penguin
    ld de, PENGUIN_INFO_CMPS
    call move_entity_left
ret

check_move_penguin_down:
    ; Check other entities collision
    ld a, DOWN
    ld [actual_movement], a
    call check_colliding_entities_with_penguin
    ret c

    ; Check collision with wall
    ld a, [LEFT_PENGUIN_Y]
    cp DOWN_WALL_PIXEL
    call z, .dead

    ; Move penguin
    ld de, PENGUIN_INFO_CMPS
    call move_entity_down
    ret
    .dead:
        call dead
ret

check_move_penguin_up:
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
    jr c, .move_scene_down

    ; Move penguin
    ld de, PENGUIN_INFO_CMPS
    call move_entity_up
    ret

    .move_scene_down:
        call move_background
        ld hl, move_entity_down
        call man_entity_for_each_not_penguin
ret



;; ---------------------------------------------------
;; MOVE ENTITIES

;; Move one entity up
;;
;; INPUT:
;;      de -> Entity INFO component address
move_entity_up::
    ; Move to corresponding SPRITE component
    ld d, CMP_SPRITE_H

    ; Move to corresponding left SPRITE component Y byte
    ld a, e
    add CMP_SPRI_L_Y
    ld e, a
    call dec_de_contents

    ; Move to corresponding right SPRITE component Y byte
    ld a, e
    add (CMP_SPRI_R_Y - CMP_SPRI_L_Y)
    ld e, a
    call dec_de_contents
ret

;; Move one entity down
;;
;; INPUT:
;;      de -> Entity INFO component address
move_entity_down::
    ; Move to corresponding SPRITE component
    ld d, CMP_SPRITE_H

    ; Move to corresponding left SPRITE component Y byte
    ld a, e
    add CMP_SPRI_L_Y
    ld e, a
    call inc_de_contents

    ; Move to corresponding right SPRITE component Y byte
    ld a, e
    add (CMP_SPRI_R_Y - CMP_SPRI_L_Y)
    ld e, a
    call inc_de_contents
ret

;; Move one entity right
;;
;; INPUT:
;;      de -> Entity INFO component address
move_entity_right::
    ; Move to corresponding SPRITE component
    ld d, CMP_SPRITE_H

    ; Move to corresponding left SPRITE component X byte
    ld a, e
    add CMP_SPRI_L_X
    ld e, a
    call inc_de_contents

    ; Move to corresponding right SPRITE component X byte
    ld a, e
    add (CMP_SPRI_R_X - CMP_SPRI_L_X)
    ld e, a
    call inc_de_contents
ret

;; Move one entity left
;;
;; INPUT:
;;      de -> Entity INFO component address
move_entity_left::
    ; Move to corresponding SPRITE component
    ld d, CMP_SPRITE_H

    ; Move to corresponding left SPRITE component X byte
    ld a, e
    add CMP_SPRI_L_X
    ld e, a
    call dec_de_contents

    ; Move to corresponding right SPRITE component X byte
    ld a, e
    add (CMP_SPRI_R_X - CMP_SPRI_L_X)
    ld e, a
    call dec_de_contents
ret
