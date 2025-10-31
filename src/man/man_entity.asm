include "constants.inc"

section "Entity Manager Data", WRAM0

num_entities_alive: ds 1 ; Counter of alive entities
next_free_entity: ds 1 ; Address of the next free entity

section "Component Info", WRAM0[$C000]
info_cmps_start:: ds SIZEOF_ARRAY_CMP ; Info components start address
section "Component Sprite", WRAM0[$C100]
sprite_cmps_start:: ds SIZEOF_ARRAY_CMP ; Sprite components start address
section "Component Physics", WRAM0[$C200]
physics_cmps_start:: ds SIZEOF_ARRAY_CMP ; Physics components start address

section "Entity Manager Code", ROM0

;; Prepares al the Entity Manager components memory space ($C000 - $CXFF)
;; Initializes Entity Manager variables
man_entity_init::
    ; Set the array of entities sprites components to 0
    ld hl, sprite_cmps_start
    ld b, SIZEOF_ARRAY_CMP
    xor a
    call memset256

    call free_all_entities_slots
    call zero_all_info_components
    call zero_all_sprite_components

    ; Init values
    ld [next_free_entity], a
    ld [num_entities_alive], a
ret

;; Reserves next free INFO components space
;;
;; RETURN
;;   hl: memory address of sprite component
man_entity_alloc::
    call man_entity_find_first_free
    ld a, h
    cp $FF
    ret z ; No free entity found
    ld [hl], CMP_RESERVED
ret

man_object_alloc::
    ld hl, OBJECT_INFO_ADDR
    ld a, [hl]
    cp CMP_FREE
    ret nz ; No free object found
    ld [hl], CMP_RESERVED
ret

;; Finds next INFO components free space
;; and returns its address
;;
;; RETURN
;;   hl -> Free entity address
man_entity_find_first_free::
    ld hl, info_cmps_start
    ld de, SIZEOF_INFO_CMP

    .check_if_free:
        ld a, l
        cp SIZEOF_ARRAY_CMP - NUM_OBJECTS * SIZEOF_INFO_CMP
        jr z, .exit

        ld a, CMP_FREE
        cp [hl]
        ret z

        ; next:
        add hl, de
    jr .check_if_free

    .exit:
        ld h, $FF ; No free entity found
ret

;; Applies a given function to all entities
;; TODO: pending of testing
;;
;; INPUT
;;   hl -> Process routine address
man_entity_for_each::
    ld de, info_cmps_start
    .loop:
        ; Check not traspassing end of cmps memory section
        ld a, e
        cp SIZEOF_ARRAY_CMP
        ret z
        ; Check reserved/alive entity
        ld a, [de]
        bit CMP_BIT_ALIVE, a
        jr z, .next
        ; process:
        push de
        push hl
        call helper_call_hl
        ; return:
        pop hl
        pop de
        .next:
            ld a, e
            add SIZEOF_INFO_CMP
            ld e, a
            jr nc, .loop
            inc d
    jr .loop
ret

;; Applies a given multi-entity function to one entity with the other ones
;;
;; INPUT
;;   hl -> Process routine address
;;   bc -> Main entity to compare with
;; OUTPUT
;;   de -> Address of the colliding entity
;;   c or nc flag -> c == clloision, nc == not collision
man_entity_for_one_for_each::
    ld de, info_cmps_start
    .loop:
        ; Check not traspassing pysx cmps
        ld a, e
        cp SIZEOF_ARRAY_CMP
        ret z

        ; check bc != de
        call cp_bc_de
        jr z, .next

        ; Check reserved/alive entity
        ld a, [de]
        bit CMP_BIT_ALIVE, a
        jr z, .next

        ; process:
        push de
        push hl
        call helper_call_hl

        ; return:
        pop hl
        pop de
        ret c ; WARNING, ONLY APPLIES FOR CHECKING COLLIIONS, ACTION NEEDED

        .next:
            ld a, e
            add SIZEOF_INFO_CMP
            ld e, a
            jr nc, .loop
            inc d
    jr .loop
ret

;; Checks if any entity is colliding with the penguin
;;
;; OUTPUT:
;;      de -> Address of the colliding entity
;;      c or nc flag -> c == clloision, nc == not collision
check_colliding_entities_with_penguin::
    push bc
    ld hl, are_boxes_colliding
    ld b, CMP_INFO_H
    ld c, 0 ; SKIP PENGUIN ENTITIES
    call man_entity_for_one_for_each
    pop bc
ret

;; Checks if colliding with clock or enemy
;;
;; INPUT:
;;      de -> Entity INFO cmp address
check_if_clock_or_death::
    call check_if_entity_is_clock
    jr nz, .clock

    .death:
        call kill_penguin
    ret

    .clock:
        call kill_entity
        call restart_internal_active_clock_configuration

ret

;; Checks if colliding with clock or enemy (jump)
;;
;; INPUT:
;;      de -> Entity INFO cmp address
check_if_clock_or_jump::
    call check_if_entity_is_clock
    jr nz, .clock

    .jump:
        ld a, DEFAULT_JUMP_HEIGHT
        ld [jump_remaining_height], a
    ret

    .clock:
        call kill_entity
        call restart_internal_active_clock_configuration

ret

;; Checks if colliding with clock or enemy (jump)
;;
;; INPUT:
;;      de -> Entity INFO cmp address
check_if_clock_or_jump_or_death::
    call check_if_entity_is_clock
    jr nz, .clock

    call check_if_entity_is_not_killable_enemy
    call nz, kill_penguin

    .jump:
        ld a, DEFAULT_JUMP_HEIGHT
        ld [jump_remaining_height], a
    ret

    .clock:
        call kill_entity
        call restart_internal_active_clock_configuration

ret

;; Checks if colliding with clock or enemy (kill it)
;;
;; INPUT:
;;      de -> Entity INFO cmp address
check_if_clock_or_kill::
    call check_if_entity_is_clock
    jr nz, .clock

    .kill:
        ; Kill corresponding entity
        ld h, d
        ld l, e
        bit CMP_BIT_NOT_KILLABLE_ENEMY, [hl]
        jr nz, .kill_penguin
        call kill_entity
        ; Start jump animation
        ld a, DEFAULT_JUMP_HEIGHT
        ld [jump_remaining_height], a
        ; Increase dash counter
        call inc_dash_counter
        ; Increase energy counter
        call inc_energy_counter
    ret

    .kill_penguin:
        call kill_penguin
    ret

    .clock:
        call kill_entity
        call restart_internal_active_clock_configuration

ret

;; Checks if the the given entity is a clock
;;
;; INPUT:
;;      de -> Entity INFO cmp address
;; OUTPUT:
;;      nz -> Colliding with clock
;;      z  -> Not colliding with clock
check_if_entity_is_clock::
    ld a, [de]
    bit CMP_BIT_OBJECT, a
ret

;; Checks if the the given entity is not killable enemy
;;
;; INPUT:
;;      de -> Entity INFO cmp address
;; OUTPUT:
;;      nz -> Colliding with enemy
;;      z  -> Not colliding with enemy
check_if_entity_is_not_killable_enemy::
    ld a, [de]
    bit CMP_BIT_NOT_KILLABLE_ENEMY, a
ret

;; Applies a given function to all entities but the penguin
;;
;; INPUT
;;   hl -> Process routine address
man_entity_for_each_not_penguin::
    ld de, info_cmps_start
    .loop:
        ; Check not traspassing end of cmps memory section
        ld a, e
        cp SIZEOF_ARRAY_CMP
        ret z

        ; Check reserved/alive entity
        ld a, [de]
        bit CMP_BIT_ALIVE, a
        jr z, .next

        ; Check entity is not penguin
        ld a, [de]
        bit CMP_BIT_PENGUIN, a
        jr nz, .next

        ; process:
        push de
        push hl
        call helper_call_hl

        ; return:
        pop hl
        pop de

        .next:
            ld a, e
            add SIZEOF_INFO_CMP
            ld e, a
            jr nc, .loop
            inc d
    jr .loop
ret

;; Sets the enemy bit of the given entity
;;
;; INPUT:
;;      hl -> Entity INFO component start address
set_entity_as_enemy::
    set CMP_BIT_ENEMY, [hl]
ret

;; Sets the enemy and not killable bits of the given entity
;;
;; INPUT:
;;      hl -> Entity INFO component start address
set_entity_as_not_killable_enemy::
    set CMP_BIT_ENEMY, [hl]
    set CMP_BIT_NOT_KILLABLE_ENEMY, [hl]
ret

;; Sets the penguin bit of the given entity
;;
;; INPUT:
;;      hl -> Entity INFO component start address
set_entity_as_penguin::
    set CMP_BIT_PENGUIN, [hl]
ret

;; Sets the object bit of the given entity
;;
;; INPUT:
;;      hl -> Entity INFO component start address
set_entity_as_object::
    set CMP_BIT_OBJECT, [hl]
ret

;; ---------------------------------------------------
;; MEMORY MANAGEMENT
;; ---------------------------------------------------

;; Free one entity slots
;;
;; INPUT:
;;      hl -> Entity INFO cmp address
free_entity_slot::
    ; ld [hl], CMP_FREE

    
ret

;; Free all entities (set CMP_FREE for all info cmps)
free_all_entities_slots::
    ld hl, info_cmps_start
    ld de, SIZEOF_INFO_CMP
    ld b, CMP_SPRITE_H
    ld c, 0
    .free_all_cmps_loop:
        call free_entity_slot
        add hl, de
    
        ; Check we're not getting into sprite cmps
        ld a, h
        cp b
        jr nz, .free_all_cmps_loop
        ld a, l
        cp c
        jr nz, .free_all_cmps_loop
ret

;; Set all SPRITE components to zero
zero_all_sprite_components::
    ld hl, sprite_cmps_start
    ld b, SIZEOF_ARRAY_CMP
    xor a
    call memset256
ret

;; Set all INFO components to zero
zero_all_info_components::
    ld hl, info_cmps_start
    ld b, SIZEOF_ARRAY_CMP
    xor a
    call memset256
ret

;; Set all entity cmps to zero
;;
;; INPUT:
;;      hl -> Entity INFO cmp address
zero_whole_entity::
    push hl
    push bc
    push de

    ld e, l ; Store l into e as backup for later
    ld b, SIZEOF_INFO_CMP
    xor a
    call memset256

    ld h, CMP_SPRITE_H
    ld l, e
    ld b, SIZEOF_SPRI_CMP
    xor a
    call memset256

    pop de
    pop bc
    pop hl
ret

;; memcpy256 function variant for copying
;; all alive entities into oam
memcpy256_sprites_only_alive::
    push de
    push hl
    push bc

    ; Load addresses
    ld de, OAM_START
    ld hl, info_cmps_start

    .loop:
        ; Check if alive
        bit CMP_BIT_ALIVE, [hl]
        jr z, .next

        ; Perform copy
        ld h, CMP_SPRITE_H
        ld b, SIZEOF_SPRI_CMP
        call memcpy256
        ld h, CMP_INFO_H

        ; Move to next addresses
        .next:
        ld a, l
        add SIZEOF_INFO_CMP
        ld l, a
        ld a, e
        add SIZEOF_SPRI_CMP
        ld e, a

        ; Check if end of cmps
        ld a, l
        cp SIZEOF_ARRAY_CMP
    jr nz, .loop

    pop bc
    pop hl
    pop de
ret

;; ---------------------------------------------------
;; ENTITIES STATE MANAGEMENT
;; ---------------------------------------------------

;; Kill an entity
;;
;; INPUT:
;;      de -> Address of the entity to kill
kill_entity::
    push de
    push hl

    ; Set entity as not alive
    ld h, d
    ld l, e
    call zero_whole_entity

    pop hl
    pop de
ret

;; Kill penguin
kill_penguin::
    ld de, PENGUIN_INFO_CMPS
    call kill_entity

    call wait_vblank

    ; Flip left sprite
    ld hl, OAM_PENGUIN_LEFT_SPRITE_PROPIERTIES
    set SPRRITES_ATTRIBUTES_BIT_Y_FLIP, [hl]

    ; Flip right sprite
    ld hl, OAM_PENGUIN_RIGHT_SPRITE_PROPIERTIES
    set SPRRITES_ATTRIBUTES_BIT_Y_FLIP, [hl]

    call press_start_to_start
ret

