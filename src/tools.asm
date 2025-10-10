INCLUDE "constants.inc"

SECTION "Tools", ROM0

vblank::
    ld hl, rLY
    ld a, $90
    .vblank_loop:
        cp [hl]
        jr nz, .vblank_loop
    ret

copy_tile::
    ld a, [hl]
    ld [de], a
    inc hl
    inc de
    dec b
    jr nz, copy_tile
    ret

clear_nintendo::
    xor a
    ld h, $99

    ; First row
    ld l, $04
    ld b, 13
    .clear_first_row:
        ld [hl+], a
        dec b
    jr nz, .clear_first_row

    ; Second row
    ld l, $24
    ld b, 12
    .clear_second_row:
        ld [hl+], a
        dec b
    jr nz, .clear_second_row

    ret

clear_oam::
    ld hl, $FE00
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