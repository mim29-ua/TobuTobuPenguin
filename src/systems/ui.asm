include "constants.inc"

section "Time Interruption", ROM0[$0050] ; Don't change this section

time_interruption_handler::
    push af
    push hl
    push bc
    push de
    ld hl, internal_ui_clock
    ld a, [hl]
    inc a
    cp 32
    jr c, .continue

        xor a
        ld [hl], a
        call z, update_sprite_clock
        jr .end

    .continue:
        ld [hl], a

    .end:
        pop de
        pop bc
        pop hl
        pop af
reti

section "UI", ROM0

update_sprite_clock::
    ld hl, internal_active_clock_configuration
    ld a, [hl]
    call check_clock_configuration
ret

; Check the current clock configuration
;
; INPUT:
; a -> current clock value (0-23)
check_clock_configuration:

    inc a
    ld [hl], a

    cp 8
    jr z, .nineth_clock

    cp 7
    jr z, .eighth_clock

    cp 6
    jr z, .seventh_clock

    cp 5
    jr z, .sixth_clock

    cp 4
    jr z, .fifth_clock

    cp 3
    jr z, .fourth_clock

    cp 2
    jr z, .third_clock

    cp 1
    jr z, .second_clock

    jp .first_clock

    .first_clock:
        xor a
        ld [hl], a
        ld hl, first_clock_configurations
        jp .copy_configuration

    .second_clock:
        ld hl, second_clock_configurations
        jp .copy_configuration

    .third_clock:
        ld hl, third_clock_configurations
        jp .copy_configuration

    .fourth_clock:
        ld hl, fourth_clock_configurations
        jp .copy_configuration

    .fifth_clock:
        ld hl, fifth_clock_configurations
        jp .copy_configuration

    .sixth_clock:
        ld hl, sixth_clock_configurations
        jp .copy_configuration

    .seventh_clock:
        ld hl, seventh_clock_configurations
        jp .copy_configuration

    .eighth_clock:
        ld hl, eighth_clock_configurations
        jp .copy_configuration

    .nineth_clock:
        ld hl, nineth_clock_configurations
        jp .copy_configuration

    .copy_configuration:
        ld de, FIRST_CLOCK_SPRITE_ADDR
        ld b, 16
        call memcpy256_vblank

    ld hl, internal_ui_clock
ret

load_ui_sprites::
    ld de, $FE50
    ld hl, ui_sprites
    ld b, 8 * 4
    call memcpy256
ret

load_ui_background_map::
    ld hl, ui_tilemap
    ld de, TMAP1
    ld c, 18
    .loop:
        ld b, 2
        call memcpy256

        ld a, $20
        add e
        ld e, a
        jr nc, .no_carry_l
            inc d
        .no_carry_l:

        inc hl
        inc hl

        dec c
    jr nz, .loop

ret

start_internal_ui_variables::
    ld hl, internal_ui_clock
    xor a
    ld [hl], a

    ld hl, internal_active_clock_configuration
    ld [hl], a

    ld hl, internal_dash_counter
    ld a, 3
    ld [hl], a

    ld hl, internal_energy_counter
    ld a, 7
    ld [hl], a
ret

inc_energy_counter::
    ld hl, internal_energy_counter
    ld a, [hl]
    cp 7
    ret z
    
    ; Incs energy counter the defined amount
    ld a, [internal_energy_counter]
    add DEFAULT_ENERGY_COUNTER_INC
    cp MAX_ENERGY_COUNTER
    jr c, .not_maxed
    ld a, MAX_ENERGY_COUNTER
    .not_maxed: 
    ld [hl], a

    call update_energy_counter_sprite
ret

dec_energy_counter::
    ld hl, internal_energy_counter
    ld a, [hl]
    cp 0
    ret z
    dec [hl]
    call update_energy_counter_sprite
ret

;; Checks if energy counter has to be decreased
check_dec_energy_counter::
    ; Check variable
    ld a, [amount_of_cycles_before_energy_dec]
    dec a
    ld [amount_of_cycles_before_energy_dec], a
    cp 0
    ret nz
    ; Restart variable
    ld a, DEFAULT_CYCLES_BEFORE_ENERGY_DEC
    ld [amount_of_cycles_before_energy_dec], a
    ; Decrease energy counter
    call dec_energy_counter
ret

update_energy_counter_sprite::
    
    ld a, [hl]

    cp 7
    jr z, .seven_energy

    cp 6
    jr z, .six_energy

    cp 5
    jr z, .five_energy

    cp 4
    jr z, .four_energy

    cp 3
    jr z, .three_energy

    cp 2
    jr z, .two_energy

    cp 1
    jr z, .one_energy

    jp .zero_energy

    .seven_energy:
        ld hl, first_energy_configuration
        jp .copy_energy_configuration

    .six_energy:
        ld hl, second_energy_configuration
        jp .copy_energy_configuration

    .five_energy:
        ld hl, third_energy_configuration
        jp .copy_energy_configuration

    .four_energy:
        ld hl, fourth_energy_configuration
        jp .copy_energy_configuration

    .three_energy:
        ld hl, fifth_energy_configuration
        jp .copy_energy_configuration

    .two_energy:
        ld hl, sixth_energy_configuration
        jp .copy_energy_configuration

    .one_energy:
        ld hl, seventh_energy_configuration
        jp .copy_energy_configuration
    
    .zero_energy:
        ld hl, eighth_energy_configuration
        jp .copy_energy_configuration

    .copy_energy_configuration:
        ld de, ENERGY_SPRITE_ADDR
        ld b, 2 * 4
        call memcpy256_vblank
ret

inc_dash_counter::
    ld hl, internal_dash_counter
    ld a, [hl]
    cp 3
    ret z
    inc [hl]
    call update_dash_counter_sprite
ret

dec_dash_counter::
    ld hl, internal_dash_counter
    ld a, [hl]
    cp 0
    ret z
    dec [hl]
    call update_dash_counter_sprite
ret

update_dash_counter_sprite::
    
    ld a, [hl]

    cp 3
    jr z, .three_dashes

    cp 2
    jr z, .two_dashes

    cp 1
    jr z, .one_dash

    jp .zero_dashes

    .three_dashes:
        ld hl, three_dashes_configuration
        jp .copy_dash_configuration

    .two_dashes:
        ld hl, two_dashes_configuration
        jp .copy_dash_configuration

    .one_dash:
        ld hl, one_dash_configuration
        jp .copy_dash_configuration

    .zero_dashes:
        ld hl, zero_dashes_configuration
        jp .copy_dash_configuration

    .copy_dash_configuration:
        ld de, FIRST_DASHES_COUNTER_SPRITE_ADDR
        ld b, 2 * 4
        call memcpy256_vblank
ret