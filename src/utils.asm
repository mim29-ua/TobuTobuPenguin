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
    ld hl, BACKGROUND_VIEWPORT_Y_ADDR
    ld a, [hl]
    cp 0

    jr z, .change_tilemap ; Reduce only if not at top
        dec [hl]
        ret

    .change_tilemap:

        ld hl, rLCDC
        bit 3, [hl]
        
        jr nz, .change_maps
        call change_vram_tilemap
        ret

        .change_maps:
            ld a, %10110100
            call set_palettes_47_48
            call lcd_off
                call print_finals_map
                call change_vram_tilemap
            call lcd_on
ret

change_vram_tilemap::
    call change_window_map
    call move_background_window_bottom
ret

; Move the background window down to bottom position
move_background_window_bottom::
    ld a, 111
    ld [BACKGROUND_VIEWPORT_Y_ADDR], a
ret

change_window_map::
    ld a, %00001000
    xor [hl]
    ld [hl], a
ret

; Returns a random x-position
random_position:
    ld a, [$FF04]
    srl a
    add 9
ret

; Check if in vblank, wait if not until vblank
check_vblank::
    push hl
    ld hl, rLY
    ld a, VBLANK_START_LINE
    cp [hl]
    jr c, .in_vblank
    
    ; Esperar hasta vblank
    .wait_loop:
        cp [hl]
        jr nz, .wait_loop
    
    .in_vblank:
        pop hl
ret

; INPUT
;   hl: source
;   de: destination
;    b: bytes
memcpy256::
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
    ei 
ret

lcd_on::
    ld hl, rLCDC
    ld a, $97
    ld [hl], a
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
    ld [hl+], a
    dec b
    jr nz, print_row
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
