INCLUDE "constants.inc"

SECTION "Entry point", ROM0[$150]

load_character_sprite_left:
    ld a, 32
    ld [$FE00], a ;; Y pos (pixels, right-down corner)
    ld a, 24
    ld [$FE01], a ;; X pos (pixels, right-down corner)
    ld a, $1C
    ld [$FE02], a ;; Tile index
    ld a, %00000000
    ld [$FE03], a ;; Attributes
    ret

load_character_sprite_right:
    ld a, 32
    ld [$FE04], a ;; Y pos (pixels, right-down corner)
    ld a, 32
    ld [$FE05], a ;; X pos (pixels, right-down corner)
    ld a, $1E
    ld [$FE06], a ;; Tile index
    ld a, %00000000
    ld [$FE07], a ;; Attributes
    ret

copy_tiles:
    call vblank
    ld hl, normal_penguin
    ld de, $81C0
    ld b, 64
    call copy_tile

    call vblank
    ld hl, jumping_penguin
    ld de, $8200
    ld b, 64
    call copy_tile

    ret

main::
    call vblank
    call clear_nintendo

    ld a, DEF_PALETTE
    call set_palettes

    call copy_tiles

    ; Configure sprites

    call vblank
    call clear_oam
    call enable_sprites
    call load_character_sprite_left
    call load_character_sprite_right

    ; Initialize variables

    ld a, ANIMATION_SPEED
    ld [counter], a

    ; Game

    .mainloop:
        call vblank

        call get_pad_input
        call decode_dpad
        
        jr .mainloop

    di     ;; Disable Interrupts
    halt   ;; Halt the CPU (stop procesing here)
