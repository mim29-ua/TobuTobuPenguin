include "constants.inc"
include "man/man_entity.inc"

section "Space Scene Sprites", rom0
penguin_entity:
    ; Sprite cmp (+0)
    ; y, x, tile, properties
    db 32,24,$1C,0
    db 32,32,$1E,0
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
    call load_penguin_tiles
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
load_penguin_tiles:
    ; Left penguin tiles
    call wait_vblank
    ld hl, normal_penguin
    ld de, $81C0
    ld b, 64
    call memcpy256
    ; Right penguin tiles
    call wait_vblank
    ld hl, jumping_penguin
    ld de, $8200
    ld b, 64
    call memcpy256
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
