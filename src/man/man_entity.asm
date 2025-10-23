include "constants.inc"

section "Entity Manager Data", WRAM0
num_entities_alive: ds 1
next_free_entity: ds 1

section "Component Info", WRAM0[$C000]
info_cmps_start:: ds SIZEOF_ARRAY_CMP
section "Component Sprite", WRAM0[$C100]
sprite_cmps_start:: ds SIZEOF_ARRAY_CMP
section "Component Physics", WRAM0[$C200]
physics_cmps_start:: ds SIZEOF_ARRAY_CMP

section "Entity Manager Code", ROM0

man_entity_init::
    ; Set the array of entities sprites components to 0
    ld hl, sprite_cmps_start
    ld b, SIZEOF_ARRAY_CMP
    xor a
    call memset256

    call free_all_cmps
    call zero_all_sprite_components

    ; Init values
    ld [next_free_entity], a
    ld [num_entities_alive], a
ret

;; RETURN
;;   hl: memory address of sprite component
man_entity_alloc::
    call man_entity_find_first_free
    ld [hl], CMP_RESERVED
ret

;; RETURN
;;   hl -> Free entity address
man_entity_find_first_free::
    ld hl, info_cmps_start
    ld de, SIZEOF_INFO_CMP
    ld a, CMP_FREE
    
    .check_if_free:
        cp [hl]
        ret z
        ; next:
        add hl, de
    jr .check_if_free
ret

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

;; Set all sprite components to zero
zero_all_sprite_components::
    ld hl, sprite_cmps_start
    ld b, SIZEOF_SPRI_CMP
    xor a
    call memset256
ret

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
        ret c

        .next:
            ld a, e
            add SIZEOF_INFO_CMP
            ld e, a
            jr nc, .loop
            inc d
    jr .loop
ret

check_colliding_entities_with_penguin::
    ld hl, are_boxes_colliding
    ld b, CMP_INFO_H
    ld c, 0 ; SKIP PENGUIN ENTITIES
    call man_entity_for_one_for_each
ret
