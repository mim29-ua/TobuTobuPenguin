include "man/man_entity.inc"
include "constants.inc"

section "Entity Manager Data", WRAM0
num_entities_alive: ds 1
next_free_entity: ds 1

section "Component Info", WRAM0[$C000]
components::
component_info:: ds SIZEOF_ARRAY_CMP
section "Component Sprite", WRAM0[$C100]
cmp_sprite:: ds SIZEOF_ARRAY_CMP
section "Component Physics", WRAM0[$C200]
component_physics:: ds SIZEOF_ARRAY_CMP

section "Entity Manager Code", ROM0

man_entity_init::
    ; Set the array of entities sprites components to 0
    ld hl, cmp_sprite
    ld b, SIZEOF_ARRAY_CMP
    xor a
    call memset256

    call free_all_cmps
    call zero_all_sprite_components

    ; Init values
    ld [next_free_entity], a
    ld [num_entities_alive], a
ret

; RETURN
;   hl: memory address of sprite component
man_entity_alloc::
    call man_entity_find_first_free
    ld [hl], CMP_RESERVED
ret

; RETURN
;   hl -> Free entity address
man_entity_find_first_free::
    ld hl, component_info
    ld de, SIZEOF_INFO_CMP
    ld a, CMP_FREE
    
    .check_if_free:
        cp [hl]
        ret z
    .next:
        add hl, de
    jr .check_if_free
ret

; INPUT
;   hl -> Process routine address
man_entity_for_each::
    ld de, components
    .loop:
    .check_sentinel:
        ld a, [de]
        cp CMP_SENTINEL
        ret z
    .process:
        push de
        push hl
        call helper_call_hl
    .return:
        pop hl
        pop de
    .next:
        ld a, e
        add SIZEOF_INFO_CMP
    jr .loop
ret

; Free all components
free_all_cmps::
    ld hl, components
    ld de, SIZEOF_INFO_CMP
    ld a, CMP_SENTINEL
    .free_all_cmps_loop:
        ld [hl], CMP_FREE
        add hl, de
        cp [hl]
    jr nz, .free_all_cmps_loop
ret

; Set all sprite components to zero
zero_all_sprite_components::
    ld hl, cmp_sprite
    ld b, SIZEOF_ARRAY_CMP
    xor a
    call memset256
ret