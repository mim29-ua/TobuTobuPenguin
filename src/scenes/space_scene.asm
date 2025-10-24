include "constants.inc"

section "Space Scene Entities", rom0

section "Space Scene", ROM0

space_scene_init::
    ; Set palette
    call wait_vblank
    ld a, DEFAULT_PAL
    call set_palettes
    ; Load animations variables
    call wait_vblank
    call animations_init

    call lcd_off

    ; Load tiles into VRAM
    call load_entities_tiles
    call load_background_tiles
    call load_ui_tiles

    call print_initials_maps
    call move_background_window_bottom

    ; Clear OAM and enable sprites
    call clear_oam
    call enable_sprites
    call load_ui_sprites

    ; Load entities
    call penguin_entity_init
    call lcd_on
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
    ld hl, sprite_cmps_start
    ld de, OAM_START
    ld b, SIZEOF_ARRAY_CMP
    call memcpy256
ret

;; -------------------------------------------------
;  TILES

load_entities_tiles::
    ld hl, entities_tiles
    ld de, $8000
    ld bc, 546
    call memcpy65536
ret

load_background_tiles::
    ld hl, background_tiles
    ld de, $8220
    ld bc, 1574
    call memcpy65536
ret

load_ui_tiles::
    ld hl, ui_tiles
    ld de, $8840
    ld bc, 38 * 16
    call memcpy65536

;; -------------------------------------------------
;  MAPS

print_initials_maps::
    call print_first_map
    call print_second_map
ret

print_finals_map::
    call print_third_map
ret

print_first_map::
    ld hl, TMAP0
    ld de, primer_tilemap
    ld bc, MAP_DIMENSION * MAP_DIMENSION

    call print_map
ret

print_second_map::
    ld hl, TMAP1
    ld de, segundo_tilemap
    ld bc, MAP_DIMENSION * MAP_DIMENSION

    call print_map
ret

print_third_map::
    ld hl, TMAP0
    ld de, tercer_tilemap
    ld bc, MAP_DIMENSION * MAP_DIMENSION

    call print_map
ret

; Input
;
; hl -> VRAM direction where copy the map
; de -> Source address
; bc -> Bytes number
;
print_map::
    .print_map_loop:
        ld a, [de]
        inc de

        ld [hl+], a

        dec bc
        ld a, c
        or b
        jr nz, .print_map_loop
ret

;; -------------------------------------------------
;  ENEMIES

generate_random_enemy:
    ld a, [$FF04]
    and $0F

    .loop::
        cp ENEMIES_TYPES_NUMBER
        jr c, .end
        sub ENEMIES_TYPES_NUMBER
        jr .loop
    .end

    cp 0
    jr z, .ovni_enemy

    cp 1
    jr z, .airship_enemy

    cp 2
    jr z, .ghost_enemy

    cp 3
    jr z, .owl_enemy

    cp 4
    jr z, .windmill_enemy

    ret

    .ovni_enemy
        ld bc, ovni_entity
        jr .continue

    .airship_enemy
        ld bc, airship_entity
        jr .continue

    .ghost_enemy
        ld bc, ghost_entity
        jr .continue

    .owl_enemy
        ld bc, owl_entity
        jr .continue
    
    .windmill_enemy
        ld bc, windmill_entity
        jr .continue

    .continue
        call generate_random_x_entity   
ret

; Generate a new enemy
;
; Input
; bc -> enemy config address
generate_random_x_entity:

    call man_entity_alloc
    
    ; Sprite component
    
    ld h, CMP_SPRITE_H    ; Man-entity destination address
    
    ld a, $20
    ld [hl+], a            ; y position

    call random_position
    ld [hl+], a
    ld d, a                ; x position

    ld e, SIZEOF_SPRI_CMP  ; Tile and properties
    sra e
    dec e
    dec e
    .loop_sprite_left:
        ld a, [bc]
        ld [hl+], a
        inc bc
        dec e
    jr nz, .loop_sprite_left

    ld a, $20
    ld [hl+], a

    ld a, d
    add 8
    ld [hl+], a             ; x position (again, for right sprite)

    ld e, SIZEOF_SPRI_CMP   ; Tile and properties
    sra e
    dec e
    dec e
    .loop_sprite_right:
        ld a, [bc]
        ld [hl+], a
        inc bc
        dec e
    jr nz, .loop_sprite_right

    ;; Physics component

    ld h, CMP_PHYSICS_H

    xor a
    ld [hl+], a             ; y position

    ld a, d
    ld [hl+], a             ; x position

    ld e, SIZEOF_PHYS_CMP   ; vy and vx
    dec e
    dec e
    .loop_physics:
        ld a, [bc]
        ld [hl+], a
        inc bc
        dec e
    jr nz, .loop_physics
ret

;; -------------------------------------------------
;  ENTITIES

penguin_entity_init::
    ; Init penguin sprite cmp
    call man_entity_alloc
    ld d, CMP_SPRITE_H
    ld e, l
    ld hl, (penguin_entity + 0)
    ld b, SIZEOF_SPRI_CMP
    call memcpy256
    ; Init penguin physics cmp
    ld d, CMP_PHYSICS_H
    ld e, l
    ld hl, (penguin_entity + SIZEOF_SPRI_CMP)
    ld b, SIZEOF_PHYS_CMP
    call memcpy256
ret

dead::
    ld hl, $C103
    set 6, [hl]
    ld hl, $C107
    set 6, [hl]
    call wait_vblank
    call man_entity_draw
    call wait_vblank
    di
    halt
ret
