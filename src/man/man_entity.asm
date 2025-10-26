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

    call free_all_cmps
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
        ; check_sentinel:
        ld a, [de]
        cp CMP_SENTINEL
        ret z
        ; process:
        push de
        push hl
        call helper_call_hl
        ; return:
        pop hl
        pop de
        ; next:
        ld a, e
        add SIZEOF_INFO_CMP
        ld e, a
    jr .loop
ret

;; Free all components (set CMP_FREE for all info cmps)
free_all_cmps::
    ld hl, info_cmps_start
    ld de, SIZEOF_INFO_CMP
    ld b, CMP_SPRITE_H
    ld c, 0
    .free_all_cmps_loop:
        ld [hl], CMP_FREE
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

;; Applies a given multi-entity function to one entity with the other ones
;;
;; INPUT
;;   hl -> Process routine address
;;   bc -> Main entity to compare with
man_entity_for_one_for_each::
    ld de, info_cmps_start ;; ANTES SPRITES
    .loop:
        ; Check not traspassing pysx cmps
        ld a, d
        cp CMP_SPRITE_H
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
check_colliding_entities_with_penguin::
    ld hl, are_boxes_colliding
    ld b, CMP_INFO_H
    ld c, 0 ; SKIP PENGUIN ENTITIES
    call man_entity_for_one_for_each
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

        ; Check entity is not enemy
        ld a, [de]
        bit CMP_BIT_ENEMY, a
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

;; Sets the enemy bit of the given entity
;;
;; INPUT:
;;      hl -> Entity INFO component start address
set_entity_as_enemy::
    set CMP_BIT_ENEMY, [hl]
ret
