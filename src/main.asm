;;----------LICENSE NOTICE-------------------------------------------------------------------------------------------------------;;
;;  This file is part of GBTelera: a Gameboy Development Framework                                                               ;;
;;  Copyright (C) 2024 ronaldo / Cheesetea / ByteRealms (@FranGallegoBR)                                                         ;;
;;                                                                                                                               ;;
;; Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation    ;;
;; files (the “Software”), to deal in the Software without restriction, including without limitation the rights to use, copy,    ;;
;; modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the         ;;
;; Softwareis furnished to do so, subject to the following conditions:                                                           ;;
;;                                                                                                                               ;;
;; The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.;;
;;                                                                                                                               ;;
;; THE SOFTWARE IS PROVIDED “AS IS”, WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE          ;;
;; WARRANTIES OF MERCHANTABILITY, FITNESS FOR a PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR         ;;
;; COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE,   ;;
;; ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.                         ;;
;;-------------------------------------------------------------------------------------------------------------------------------;;

INCLUDE "constants.inc"

SECTION "Entry point", ROM0[$150]

load_character_sprite_left::
    ld a, 32
    ld [$FE00], a ;; Y pos (pixels, right-down corner)
    ld a, 24
    ld [$FE01], a ;; X pos (pixels, right-down corner)
    ld a, $1C
    ld [$FE02], a ;; Tile index
    ld a, %00000000
    ld [$FE03], a ;; Attributes
    ret

load_character_sprite_right::
    ld a, 32
    ld [$FE04], a ;; Y pos (pixels, right-down corner)
    ld a, 32
    ld [$FE05], a ;; X pos (pixels, right-down corner)
    ld a, $1E
    ld [$FE06], a ;; Tile index
    ld a, %00000000
    ld [$FE07], a ;; Attributes
    ret

copy_tiles::
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

animate_character::
    ld a, [$FE02]
    cp $1C
    jr nz, .idle_tile

    ;; .move_tile
    ld a, $20
    ld [$FE02], a
    ld a, $22
    ld [$FE06], a
    ret

    .idle_tile:
        ld a, $1C
        ld [$FE02], a
        ld a, $1E
        ld [$FE06], a
    ret

main::
    call vblank
    call clear_nintendo

    ld a, DEF_PALETTE
    call set_palettes

    call copy_tiles

    ;; Configure sprite

    call vblank
    call clear_oam
    call enable_sprites
    call load_character_sprite_left
    call load_character_sprite_right

    ;; Game

    ld d, 20 ; Animate every 20 loops
    .mainloop:
        call vblank

        ld a, READ_DPAD
        call input

        dec d
        jr nz, .mainloop
        call animate_character
        ld d, 20
        jr .mainloop

    di     ;; Disable Interrupts
    halt   ;; Halt the CPU (stop procesing here)
