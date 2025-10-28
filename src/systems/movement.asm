include "constants.inc"

section "Movement Variables", WRAM0

jump_remaining_height: ds 1
stomping: ds 1

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

    ; Performs jump and disables down if necessary
    call check_penguin_jump_movement

    ; Decode D-PAD inputs
    .up:
        ld a, [last_input]
        bit PADB_A, a
        call z, check_move_penguin_up
    .left:
        ld a, [last_input]
        bit PADB_LEFT, a
        call z, check_move_penguin_left
    .right:
        ld a, [last_input]
        bit PADB_RIGHT, a
        call z, check_move_penguin_right
    .down:
        ; Check down pressed
        ld a, [last_input]
        bit PADB_B, a
        jr nz, .not_stomping
        ; When down pressed, check remaining dashes
        ld a, [internal_dash_counter]
        cp 0
        jr z, .not_stomping
        ; If requirements satisfied, call stomp
        call check_stomp
    ret


    .not_stomping:
        ; Set not stomping
        xor a
        ld [stomping], a
        ; Call gravity
        call gravity

ret

;; Initialize movement variables
movements_init::
    xor a
    ld [jump_remaining_height], a
    ld [stomping], a
ret

;; Makes penguin jump or not
check_penguin_jump_movement:
    ; Check if jump has to be performed or not
    ld a, [jump_remaining_height]
    cp 0
    ret z

    ; Decrease counter before performing jump
    push hl
    ld hl, jump_remaining_height
    dec [hl]
    pop hl

    ; Tweak inputs
    ld a, [last_input]
    res PADB_A, a ; Perform jump    
    set PADB_B, a ; Disable going down
    ld [last_input], a
    call check_move_penguin_up
ret

;; Applies gravity to the penguin
gravity:
    ; Don't apply if UP pressed
    ld a, [last_input]
    bit PADB_A, a
    ret z

    ; Don't apply if stomping
    ld a, [stomping]
    cp 1
    ret z

    ; Check other entities collision
    ld a, DOWN
    ld [actual_movement], a
    call check_colliding_entities_with_penguin
    jr nc, .continue
    ; Start jump animation
    ld a, DEFAULT_JUMP_HEIGHT
    ld [jump_remaining_height], a
    ret

    .continue:

    ; Check collsision with wall
    ld a, [LEFT_PENGUIN_Y]
    cp DOWN_WALL_PIXEL
    call z, kill_penguin

    ; Move penguin
    ld de, PENGUIN_INFO_CMPS
    call move_entity_down
ret

check_stomp:
    ; If dashes remaining, check if I was already stomping
    ld a, [stomping]
    cp 0
    call z, dec_dash_counter

    ; Set stomping
    ld a, 1
    ld [stomping], a

    ; Stomp
    call check_move_penguin_down
    call check_move_penguin_down
ret

;; ---------------------------------------------------
;; CHECK PENGUIN MOVES
;; ---------------------------------------------------
;;
;; General structure:
;;      1. Check entities collisions
;;      2. Check wall collisions
;;      3. Move penguin if adequate
;;

;; Performs right movement if possible
;; Equivalent to the left one
check_move_penguin_right:
    ; Check other entities collision
    ld a, RIGHT
    call check_penguin_collides_and_dies
    ; Check wall collision
    ld a, [LEFT_PENGUIN_X]
    cp RIGHT_WALL_PIXEL
    ret z
    ; Move penguin
    ld de, PENGUIN_INFO_CMPS
    call move_entity_right
ret

;; Performs left movement if possible
;; Equivalent to the right one
check_move_penguin_left:
    ; Check other entities collision
    ld a, LEFT
    call check_penguin_collides_and_dies
    ; Check collision with wall
    ld a, [LEFT_PENGUIN_X]
    cp LEFT_WALL_PIXEL
    ret z
    ; Move penguin
    ld de, PENGUIN_INFO_CMPS
    call move_entity_left
ret

check_move_penguin_up:
    ; Check other entities collision
    ld a, UP
    call check_penguin_collides_and_dies
    ; Check collision with wall
    ld a, [LEFT_PENGUIN_Y]
    cp UP_WALL_PIXEL
    ret z
    ; Move penguin or scene if middle of screen reached
    ld a, [LEFT_PENGUIN_Y]
    cp MIDDLE_SCREEN_Y_PIXELS
    jr nc, .move_penguin_not_scene
    .move_scene_not_penguin:
        call move_scene_down
        ret
    .move_penguin_not_scene:
        ld de, PENGUIN_INFO_CMPS
        call move_entity_up
ret

check_move_penguin_down:
    ; Check other entities collision
    ld a, DOWN
    ld [actual_movement], a
    call check_colliding_entities_with_penguin
    jr nc, .no_enemy_killed
    .enemy_killed:
        ; Kill corresponding entity
        call kill_entity
        ; Start jump animation
        ld a, DEFAULT_JUMP_HEIGHT
        ld [jump_remaining_height], a
        ; Increase dash counter
        call inc_dash_counter
        ret
    .no_enemy_killed:

    ; Check collision with wall
    ld a, [LEFT_PENGUIN_Y]
    cp DOWN_WALL_PIXEL
    call z, .dead

    ; Move penguin
    ld de, PENGUIN_INFO_CMPS
    call move_entity_down
    ret
    .dead:
        call kill_penguin
ret

;; ---------------------------------------------------
;; MOVE ENEMIES

enemies_movement::
    ld h, CMP_INFO_H
    ld l, FIRST_ENEMIES_ADDR_L

    .loop:
        ld a, l
        cp NUM_ENTITIES * SIZEOF_INFO_CMP - SIZEOF_INFO_CMP * NUM_OBJECTS
        ret z

        ld a, [hl]

        bit CMP_BIT_ENEMY, a
        jr z, .continue        ; Next iteration, if the position is free

        call check_enemy_type
        jr .loop

        .continue:              ; Next info component
            ld a, l
            add SIZEOF_INFO_CMP
            ld l, a
    jr .loop
ret

;; ---------------------------------------------------
;; MOVE ENTITIES
;; ---------------------------------------------------
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