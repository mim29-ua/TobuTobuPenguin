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

    ;call print_initials_maps
    call move_background_window_bottom
    call load_ui_background_map
    call enable_window

    ; Clear OAM and enable sprites
    call clear_oam
    call enable_sprites
    call load_ui_sprites
    call print_initial_map

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

move_scene_down:
    call move_background
    ld hl, move_entity_down
    call man_entity_for_each_not_penguin
ret

;; -------------------------------------------------
;  TILES

load_entities_tiles::
    ld hl, entities_tiles
    ld de, $8000
    ld bc, 546
    call memcpy65536
    ld hl, internal_enemy_creation_counter
    ld a, ENEMY_INITIAL_DISTANCE
    ld [hl], a
    ld hl, internal_enemy_distance
    ld [hl], a
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
    ld bc, 79 * 16
    call memcpy65536
ret

load_objects_tiles::
    ld hl, objects_tiles
    ld de, $8D20
    ld b, 16 * 8
    call memcpy256
ret

;; -------------------------------------------------
;  MAPS

print_initial_map::
    
    ld hl, internal_background_addr
    ld de, initial_tilemap

    ld [hl], d                          ; Guarda la dirección para saber donde seguir leyendo
    inc hl
    ld [hl], e

    ld hl, initial_tilemap
    ld de, $99A0

    call print_map

    ld hl, internal_scrolll_counter
        ld a, 8
        ld [hl], a
ret

; Input
;
; hl -> Source address of the map
; de -> Destination address in VRAM
; bc -> Bytes number
;
print_map::
    ld c, 19

    .loop
        call print_row_map

        ld a, $12
        add l
        ld l, a
        jr nc, .no_carry_l
            inc h

        .no_carry_l:
        dec c
    jr nz, .loop 
ret

; Input
;
; hl -> Source address
; de -> VRAM direction where copy the row
print_row_map::
    ld b, 18
    call memcpy256
    
    ld a, 18
    add e
    ld e, a
    jr nc, .no_carry
        inc d
    
    .no_carry:
        ld a, $22
        ld b, 14
        call print_row
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

    ; Physics component

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

        ld a, [bc]
        ld [hl+], a
        inc bc

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

    call set_entity_as_object

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
