include "constants.inc"

section "Animation Variables", WRAM0

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
    bit PADB_DOWN, a
    jr z, .falling

    .not_falling:
        call flying_animation
    ret

    .falling:
        call set_jumping_sprite
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

; Check the enemy type and set the appropriate animation
;
; Input
; a  -> enemy tile
; hl -> enemy tile address
check_enemy_type::
    ld h, CMP_SPRITE_H
    ld a, l
    add CMP_SPRI_L_TILE
    ld l, a

    ld a, [hl]

    cp WINDMILL_INITIAL_TILE
    jr nc, .windmill_animation

    cp OWL_INITIAL_TILE
    jr nc, .owl_animation

    cp OVNI_INITIAL_TILE
    jr nc, .ovni_animation
    
    cp GHOST_INITIAL_TILE
    jr nc, .ghost_animation

    cp AIRSHIP_INITIAL_TILE
    jp nc, .airship_movement

    jp .exit

    .windmill_animation:
        ld b, WINDMILL_INITIAL_TILE
        call two_frames_animation_symmetric
    jr .exit

    .owl_animation:
        ld b, OWL_INITIAL_TILE
        call two_frames_animation_symmetric
    jr .exit

    .ovni_animation:
        call four_frames_animation_symmetric
    jr .exit

    .ghost_animation:
        ld b, GHOST_INITIAL_TILE + 2
        dec hl
        call ghost_movement
        inc hl
        ld a, [hl]
        call two_frames_animation_only_right
    jr .exit

    .airship_movement:
        dec hl
        call airship_movement
        inc hl

    .airship_exit:
        ld h, CMP_INFO_H
        ld a, l
        add SIZEOF_SPRI_CMP - CMP_SPRI_L_TILE
        ld l, a
    ret

    .exit:
        ld h, CMP_INFO_H
        ld a, l
        add SIZEOF_SPRI_CMP - CMP_SPRI_R_TILE
        ld l, a
ret

; WINDMILL AND OWL ANIMATION
;
; Input
; hl -> enemy tile address
; a  -> enemy tile
; b  -> enemy initial tile
two_frames_animation_symmetric::
    ld de, 4
    cp b
    
    jr z, .first_frame
        ld a, b
        ld [hl], a      ; Left sprite
        add hl, de
        ld [hl], a      ; Right sprite
    ret

    .first_frame:
        add 2
        ld [hl], a      ; Left sprite
        add hl, de
        ld [hl], a      ; Right sprite
ret

; GHOST ANIMATION
;
; Input
; hl -> enemy tile address
; a  -> enemy tile
; b  -> enemy initial tile
two_frames_animation_only_right::
    ld de, CMP_SPRI_R_TILE - CMP_SPRI_L_TILE
    add hl, de
    ld a, [hl]
    cp b
    
    jr z, .first_frame
        ld a, b
        ld [hl], a      ; Right sprite
    ret

    .first_frame:
        add 2
        ld [hl], a      ; Right sprite
ret

; Input
; hl -> enemy x address
airship_movement::

    ld d, CMP_INFO_H
    ld e, l
    dec de               ; de = enemy info component address

    ld a, [hl]
    cp LEFT_WALL_PIXEL
    jr z, .change_direction_to_right
    cp RIGHT_WALL_PIXEL
    jr z, .change_direction_to_left

    ld h, CMP_PHYSICS_H
    bit 0, [hl]                 ; 0 = moving right - 1 = moving left
    jr z, .move_right
    .move_left:
        call move_entity_left
        ret

    .move_right:
        call move_entity_right
        ret

    .change_direction_to_right:
        ld h, CMP_PHYSICS_H
        res 0, [hl]
        ld h, CMP_SPRITE_H
        jr .move_right

    .change_direction_to_left:
        ld h, CMP_PHYSICS_H
        set 0, [hl]
        ld h, CMP_SPRITE_H
        jr .move_left
ret

; Input
; hl -> enemy x address
ghost_movement::

    ld d, CMP_INFO_H
    ld e, l
    dec de               ; de = enemy info component address

    ld a, [hl]
    ld c, a              ; c = actual x position
    
    ld h, CMP_PHYSICS_H
    ld a, [hl]           ; a = initial x position
    ld h, CMP_SPRITE_H
    
    sub 8                               ; a = min x position
    cp c
    jr z, .change_direction_to_right    ; At min x, go right

    add 24                              ; a = max x position
    cp c
    jr z, .change_direction_to_left     ; At max x, go left

    ld h, CMP_PHYSICS_H
    bit 0, [hl]                 ; 0 = moving right - 1 = moving left
    jr z, .move_right
    .move_left:
        call move_entity_left
        ret

    .move_right:
        call move_entity_right
        ret

    .change_direction_to_right:
        ld h, CMP_PHYSICS_H
        res 0, [hl]
        ld h, CMP_SPRITE_H
        jr .move_right

    .change_direction_to_left:
        ld h, CMP_PHYSICS_H
        set 0, [hl]
        ld h, CMP_SPRITE_H
        jr .move_left
ret

; OVNI ANIMATION
;
; Input
; hl -> enemy tile address
; a  -> enemy tile
four_frames_animation_symmetric::
    ld de, 4
    cp OVNI_INITIAL_TILE + 6

    jr z, .frame_four
        add 2
        ld [hl], a      ; Left sprite
        add hl, de
        ld [hl], a      ; Right sprite
    ret

    .frame_four:
        ld a, OVNI_INITIAL_TILE
        ld [hl], a      ; Left sprite
        add hl, de
        ld [hl], a      ; Right sprite
ret

;; ------------------------------------
;  OBJECT ANIMATION

animate_object::
    ld hl, OBJECT_INFO_ADDR
    ld a, [hl]
    cp CMP_RESERVED
    ret nz

    ld h, CMP_SPRITE_H
    ld a, l
    add CMP_SPRI_L_TILE - CMP_SPRI_L_Y
    ld l, a

    ld a, [hl] ; a = actual tile

    ld b, CLOCK_INITIAL_TILE
    cp b
    jr z, .second_tile
    
    .first_tile:
        ld a, $BE
        ld [hl], a

        ld a, l
        add CMP_SPRI_R_TILE - CMP_SPRI_L_TILE
        ld l, a

        ld a, $C0
        ld [hl], a
    ret
    
    .second_tile:

        ld a, $C2
        ld [hl], a

        ld a, l
        add CMP_SPRI_R_TILE - CMP_SPRI_L_TILE
        ld l, a

        ld a, $C4
        ld [hl], a
ret
        
