include "constants.inc"

section "Space Scene Entities", rom0

section "Space Scene", ROM0

space_scene_init::

    call start_internal_ui_variables

    call wait_vblank
    call lcd_off

    ld a, DEFAULT_PAL
    call set_palettes
    ; Load animations variables
    call animations_init
    call movements_init

    ; Load tiles into VRAM
    call load_entities_tiles
    call load_background_tiles
    call load_ui_tiles
    call load_objects_tiles

    call print_initials_maps
    call move_background_window_bottom

    ; Clear OAM and enable sprites
    call clear_oam
    call enable_sprites
    call load_ui_sprites

    ; Load entities
    call penguin_entity_init
    call lcd_on

    call active_time_interruption
ret

; Scene/Game loop
space_scene_run::
    call wait_vblank
    call man_entity_draw
    call get_pad_input ; Returns b, don't touch it
    call move ; Uses b
    call animate ; Uses b
    call enemies_movement
    call animate_object
jr space_scene_run

; Copy entities sprites to OAM
man_entity_draw_dead_too:
    ld hl, sprite_cmps_start
    ld de, OAM_START
    ld b, SIZEOF_ARRAY_CMP
    call memcpy256
ret

; Copy LIVE entities sprites to OAM
man_entity_draw:
    di
    ld hl, sprite_cmps_start
    ld de, OAM_START
    ld b, SIZEOF_ARRAY_CMP
    call memcpy256
    ei
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
    ld bc, 58*16
    call memcpy65536
ret

load_objects_tiles::
    ld hl, objects_tiles
    ld de, $8BE0
    ld b, 16 * 8
    call memcpy256
ret

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
        call generate_random_x_entity
        call check_min_max_x
    ret

    .owl_enemy
        ld bc, owl_entity
        jr .continue
    
    .windmill_enemy
        ld bc, windmill_entity
        jr .continue

    .continue:
        call wait_vblank
        call generate_random_x_entity
ret

; Generate a new enemy
;
; Input
; bc -> enemy config address
generate_random_x_entity:

    call man_entity_alloc
    ld a, h
    cp $FF
    ret z                 ; No free entity sprite
    call set_entity_as_enemy
    
    ; Sprite component
    push hl
    ld h, CMP_SPRITE_H    ; Man-entity destination address
    
    xor a
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

    xor a
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

    pop hl
    ld h, CMP_PHYSICS_H

    .physics:

        xor a
        ld [hl+], a

        ld a, d
        ld [hl+], a

        ld a, [bc]
        ld [hl+], a
        inc bc

        ld a, [bc]
        ld [hl], a            

ret

;; -------------------------------------------------
;  ENTITIES

penguin_entity_init::
    ; Init penguin sprite cmp
    call man_entity_alloc
    call set_entity_as_penguin
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

;; ------------------------------------------------
;  OBJECTS
generate_x_random_object::

    ld bc, clock_object

    call man_object_alloc
    ret nz ; No free object found

    ld h, CMP_SPRITE_H

    push hl

    xor a
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

    xor a
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

    pop hl
    ld h, CMP_PHYSICS_H

    .physics:

        xor a
        ld [hl+], a

        ld a, d
        ld [hl+], a

        ld a, [bc]
        ld [hl+], a
        inc bc

        ld a, [bc]
        ld [hl], a
ret
