include "constants.inc"
include "man/man_entity.inc"

section "Space Scene Sprites", rom0
penguin_entity:
    ; Sprite cmp (+0)
    ; y, x, tile, properties
    db 32,24,LEFT_PENGUIN_TILE_IDLE,0
    db 32,32,LEFT_PENGUIN_TILE_JUMPING,0
    ; Physics cmp (+8)
    ; y, x, vy, vx
    db 32,24,0,0
    db 32,32,0,0
section "Space Scene", ROM0

space_scene_init::
    ; Set palette
    call wait_vblank
    ld a, DEFAULT_PAL
    call set_palettes
    ; Load animations variables
    call wait_vblank
    call animations_init
    ; Load penguin tiles into VRAM
    call wait_vblank
    call load_entities_tiles
    call load_background_tiles
    ; Clear OAM and enable sprites
    call wait_vblank
    call clear_oam
    call enable_sprites

    ; Load entities
    call wait_vblank
    call entities_init
ret

; Scene/Game loop
space_scene_run::
    call wait_vblank
    call man_entity_draw
    call get_pad_input ; Returns b, don't touch it
    call move ; Uses b
    call animate ; Uses b
jr space_scene_run

; Copy entities sprites to OAM
man_entity_draw:
    ld hl, cmp_sprite
    ld de, OAM_START
    ld b, SIZEOF_ARRAY_CMP
    call memcpy256
ret

; TODO without magic numbers
load_entities_tiles::
    ; Left penguin tiles
    call wait_vblank
    ld hl, entities_tiles
    ld de, $8020
    ld bc, 418
    call memcpy65536
ret

; Call this after load entities tiles, reuse de register
load_background_tiles::
    call wait_vblank
    ld hl, background_tiles
    ld bc, 1572
    call memcpy65536
ret

entities_init::
    ; Init penguin sprite cmp
    call man_entity_alloc
    ld d, CMP_SPRITE_H
    ld e, l
    ld hl, (penguin_entity + 0)
    ld b, SIZEOF_SPRI_CMP
    call memcpy256
    ; Init penguin physics cmp
    ; call man_entity_alloc
    ld d, CMP_PHYSICS_H
    ld e, l
    ld hl, (penguin_entity + SIZEOF_SPRI_CMP)
    ld b, SIZEOF_PHYS_CMP
    call memcpy256
ret
