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

;; ---------------------------------
;  ENEMY ANIMATIONS

animate_enemies::
    ld h, CMP_INFO_H
    ld l, FIRST_ENEMIES_ADDR_L ; hl = $C008

    .loop:
        ld a, l
        cp NUM_ENTITIES * SIZEOF_INFO_CMP
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
    jp nc, .airship_exit

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
        ld a, [hl]
        call two_frames_animation_only_right
    jr .exit

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