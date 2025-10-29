include "constants.inc"

section "Tools", ROM0

wait_vblank::
    push hl
    ld hl, rLY
    ld a, VBLANK_START_LINE
    .vblank_loop:
        cp [hl]
        jr nz, .vblank_loop
    pop hl
ret

move_background::
    ld hl, internal_scrolll_counter
    ld a, [hl]
    dec a
    cp 0
    jr nz, .no_reset
        ld a, 9
        ld [hl], a
        call add_new_row_to_background
        
        ld hl, internal_enemy_creation_counter
        ld a, [hl]
        dec a
        cp 0
        jr nz, .no_reset_enemy_counter
            push hl
            ld hl, internal_enemy_distance
            ld a, [hl]
            pop hl
            ld [hl], a
            call generate_random_enemy
            ret

        .no_reset_enemy_counter:
        ld [hl], a
        
        cp 3
        ret nz
            call generate_x_random_object
            
        ret
    
    .no_reset:
        ld [hl], a
        ld hl, BACKGROUND_VIEWPORT_Y_ADDR
        dec [hl]
ret

add_new_row_to_background::
    
    ; Get current background address
    ld hl, internal_background_addr
    ld a, [hl+]
    ld d, a

    ld a, [hl]
    sub 18
    ld e, a
    jr nc, .no_carry
        dec d
    .no_carry:

    ld bc, background_tiles_end
    ld a, d
    cp b
    jr nz, .continue
        ld a, e
        cp c
        push af
        push hl
        ld hl, BACKGROUND_VIEWPORT_Y_ADDR
        ld a, [hl]
        cp 0
        jr nz, .end
            call level_up
        .end:
        pop hl
        pop af
        ret z

    .continue:

    ld [hl], e
    dec hl
    ld [hl], d
    push de

    ; Copy new row to VRAM
    ld hl, BACKGROUND_VIEWPORT_Y_ADDR
    ld a, [hl]
    srl a
    srl a
    srl a

    cp 0
    jr nz, .skip_reset
        ld a, 31
        jr .add_loop

    .skip_reset:
        dec a

    .add_loop:
    ld h, $98
    ld l, 0
    ld d, 0
    ld e, $20
    .loop:
        cp 0
        jr z, .end_loop

        add hl, de

        dec a
    jr .loop

    .end_loop:
    
    ld d, h
    ld e, l ; de = destination in VRAM
    pop hl  ; hl = source address
    ld b, 18
    call memcpy256_vblank

    ld a, $22
    ld b, 2
    call print_row
ret

; Move the background window down to bottom position
move_background_window_bottom::
    ld a, 111
    ld [BACKGROUND_VIEWPORT_Y_ADDR], a
ret

; Returns a random x-position
random_position:
    ld a, [$FF04]
    srl a
    add 9
ret

; INPUT
;   hl: source
;   de: destination
;    b: bytes
memcpy256::
    push de
    push hl
    push bc

    ; Check if 0
    dec b 
    inc b
    ret z
    ; Loop
    .loop:
        ld a, [hl]
        ld [de], a
        inc hl
        inc de
        dec b
    jr nz, .loop

    pop bc
    pop hl
    pop de
ret

; INPUT
;   hl: source
;   de: destination
;   bc: bytes
memcpy65536::
    ; Check if 0
    ld a, c
    or b
    ret z

    ; Loop
    .loop:

        ld a, [hl+]
        ld [de], a
        inc de
        
        dec c
        jr nz, .loop
        
        ld a, c ; Check if 0
        or b
        ret z

        dec c
        dec b
    jr .loop
ret

memcpy256_vblank::
    ; Check if 0
    dec b 
    inc b
    ret z
    ; Loop
    call wait_vblank
    di
    .loop:  
        ld a, [hl]
        ld [de], a
        inc hl
        inc de
        dec b
        jr nz, .loop
    ei
ret
; INPUT
;   hl: source
;    b: bytes
;    a: value to set
memset256::
    ld [hl+], a
    dec b
    jr nz, memset256
ret

lcd_off::
    di 
    call wait_vblank
    ld hl, rLCDC
    res 7, [hl]
ret

lcd_on::
    ld hl, rLCDC
    set 7, [hl]
    ei
ret

clear_oam::
    ld hl, OAM_START
    ld b, 160 ; Until $FE9F
    xor a
    .clear_oam:
        ld [hl+], a
        dec b
        jr nz, .clear_oam
ret

set_palettes::
    ld [$FF47], a
    ld [$FF48], a
    ld [$FF49], a
ret

set_palettes_47_48::
    ld [$FF47], a
    ld [$FF48], a
ret

enable_sprites::
    ld hl, rLCDC
    set 1, [hl]
    set 2, [hl]
ret

print_row::
    ld [de], a
    inc de
    dec b
    jr nz, print_row
ret

enable_window::
    ld a, [rLCDC]
    set 6, a
    set 5, a
    ld [rLCDC], a

    ld a, 0
    ld [$FF4A], a ; Window Y position

    ld a, UI_COORD_X_INITIAL - 1
    ld [$FF4B], a ; Window X position

ret

print_column:
    ld de, $20
    .print_column_loop:
        ld [hl], a
        add hl, de
        dec b
        jr nz, .print_column_loop
ret

helper_call_hl::
    jp hl

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; 📥 INPUT:
;; bc
;; de
;; 🔙 OUTPUT:
;; Z  flag: bc == de
;; NZ flag: bc != de
cp_bc_de::
    ; cp b and d
    ld a, b
    cp d
    ret nz

    ; cp c and e
    ld a, c
    cp e
ret

inc_de_contents::
    ld a, [de]
    inc a
    ld [de], a
ret

dec_de_contents::
    ld a, [de]
    dec a
    ld [de], a
ret

check_min_max_x::
    di
    ld a, l
    sub CMP_PHYS_VX - CMP_PHYS_X
    ld l, a

    ld a, [hl]
    
    sub 8
    cp LEFT_WALL_PIXEL
    jr nc, .continue
        ld a, LEFT_WALL_PIXEL + 8
        ld [hl], a
        ld h, CMP_SPRITE_H
        ld [hl], a
        ld de, CMP_SPRI_R_X-CMP_SPRI_L_X
        add hl, de
        add 8
        ld [hl], a
        ret

    .continue:
        
        add 24
        cp RIGHT_WALL_PIXEL
        ret c
            ld a, RIGHT_WALL_PIXEL - 24
            ld [hl], a
            ld h, CMP_SPRITE_H
            ld [hl], a
            ld de, CMP_SPRI_R_X-CMP_SPRI_L_X
            add hl, de
            add 8
            ld [hl], a

    ei
ret

; Inputs
;
; hl -> sprite-L Tile address
flip_sprite_horizontally::
    push de
    push bc
    ld de, CMP_SPRI_R_TILE - CMP_SPRI_L_TILE

    ld a, [hl]
    ld c, a
    push hl

    add hl, de
    ld a, [hl]
    ld b, a
    ld a, c
    ld [hl+], a ; Change R tile

    pop hl
    ld a, b
    ld [hl+], a ; Change L tile
    
    bit 5, [hl] ; Change flip bit
    jr z, .set_flip_l
        res 5, [hl]
        jr .continue

    .set_flip_l:
        set 5, [hl]

    .continue:
    ld de, CMP_SPRI_R_ATRS - CMP_SPRI_L_ATRS
    add hl, de

    bit 5, [hl] ; Change flip bit
    jr z, .set_flip_r
        res 5, [hl]
        jr .end

    .set_flip_r:
        set 5, [hl]
    
    .end:

    pop bc
    pop de
ret


active_time_interruption::
    ld a, [INTERRUPTIONS_ADDR]
    or %00000100
    ld [INTERRUPTIONS_ADDR], a

    ld a, [TIMER_CONTROL_ADDR]
    or %00000100
    and %11111100
    ld [TIMER_CONTROL_ADDR], a

ret