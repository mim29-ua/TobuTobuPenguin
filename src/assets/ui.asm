include "constants.inc"

section "Internal UI Data", WRAM0

internal_ui_clock: ds 1
internal_active_clock_configuration: ds 1
internal_dash_counter: ds 1
internal_energy_counter: ds 1

section "UI Assets", ROM0

; TIEMPO RESTANTE (ESTE ES DIFÍCIL DE EXPLICAR PERO LO INTENTO, ES UN 
; CIRCULO DE 2 SPRITES PERO CREO QUE SE ENTIENDE QUE AMBAS MITADES 
; COMPARTE SPRITES, COMO SE VA RESTANDO DE OCTAVO EN OCTAVO HAY 5 
; TIPOS DE SPRITES, UNO QUE ES UN SEMICICULO COMPLETO, OTRO UN 
; SEMICIRCULO MENOS UN OCTAVO, OTRO UN CUARTO Y BLANCO, OTRO UN OCTAVO 
; Y BLANCO Y POR ÚLTIMO UNO BLANCO COMPLETO)

first_clock_configurations: ; 8/8
    db 16, UI_COORD_X_INITIAL, $84, 16
    db 16, UI_COORD_X_INITIAL + 8, $88, 16
    db 32, UI_COORD_X_INITIAL, $84, %01010000
    db 32, UI_COORD_X_INITIAL + 8, $88, %01010000

second_clock_configurations: ; 7/8
    db 16, UI_COORD_X_INITIAL, $84, 16
    db 16, UI_COORD_X_INITIAL + 8, $BB, 16 
    db 32, UI_COORD_X_INITIAL, $84, %01010000
    db 32, UI_COORD_X_INITIAL + 8, $88, %01010000

third_clock_configurations: ; 6/8
    db 16, UI_COORD_X_INITIAL, $84, 16 
    db 16, UI_COORD_X_INITIAL + 8, $8A, 16
    db 32, UI_COORD_X_INITIAL, $84, %01010000
    db 32, UI_COORD_X_INITIAL + 8, $88, %01010000

fourth_clock_configurations: ; 5/8
    db 16, UI_COORD_X_INITIAL, $84, 16 
    db 16, UI_COORD_X_INITIAL + 8, $8A, 16
    db 32, UI_COORD_X_INITIAL, $84, %01010000
    db 32, UI_COORD_X_INITIAL + 8, $BC, 16

fifth_clock_configurations: ; 4/8
    db 16, UI_COORD_X_INITIAL, $84, 16
    db 16, UI_COORD_X_INITIAL + 8, $8A, 16
    db 32, UI_COORD_X_INITIAL, $84, %01010000
    db 32, UI_COORD_X_INITIAL + 8, $8A, %01010000

sixth_clock_configurations: ; 3/8
    db 16, UI_COORD_X_INITIAL, $84, 16
    db 16, UI_COORD_X_INITIAL + 8, $8A, 16
    db 32, UI_COORD_X_INITIAL, $B8, 16
    db 32, UI_COORD_X_INITIAL + 8, $8A, %01010000

seventh_clock_configurations: ; 2/8
    db 16, UI_COORD_X_INITIAL, $84, 16
    db 16, UI_COORD_X_INITIAL + 8, $8A, 16
    db 32, UI_COORD_X_INITIAL, $86, %01010000
    db 32, UI_COORD_X_INITIAL + 8, $8A, %01010000

eighth_clock_configurations: ; 1/8
    db 16, UI_COORD_X_INITIAL, $B6, 16
    db 16, UI_COORD_X_INITIAL + 8, $8A, 16
    db 32, UI_COORD_X_INITIAL, $86, %01010000
    db 32, UI_COORD_X_INITIAL + 8, $8A, %01010000

nineth_clock_configurations: ; 0/8
    db 16, UI_COORD_X_INITIAL, $86, 16
    db 16, UI_COORD_X_INITIAL + 8, $8A, 16
    db 32, UI_COORD_X_INITIAL, $86, %01010000
    db 32, UI_COORD_X_INITIAL + 8, $8A, %01010000

three_dashes_configuration::
    db 144, UI_COORD_X_INITIAL, $B0, 16
    db 144, UI_COORD_X_INITIAL + 8, $B2, 16

two_dashes_configuration::
    db 144, UI_COORD_X_INITIAL, $AC, 16
    db 144, UI_COORD_X_INITIAL + 8, $AE, 16

one_dash_configuration::
    db 144, UI_COORD_X_INITIAL, $A8, 16
    db 144, UI_COORD_X_INITIAL + 8, $AA, 16

zero_dashes_configuration::
    db 144, UI_COORD_X_INITIAL, $A4, 16
    db 144, UI_COORD_X_INITIAL + 8, $A6, 16

first_energy_configuration::    ; 7/7
    db 128, UI_COORD_X_INITIAL, $BE, 16
    db 128, UI_COORD_X_INITIAL + 8, $B4, 16

second_energy_configuration::   ; 6/7
    db 128, UI_COORD_X_INITIAL, $C0, 16
    db 128, UI_COORD_X_INITIAL + 8, $B4, 16

third_energy_configuration::   ; 5/7
    db 128, UI_COORD_X_INITIAL, $C2, 16
    db 128, UI_COORD_X_INITIAL + 8, $B4, 16

fourth_energy_configuration::  ; 4/7
    db 128, UI_COORD_X_INITIAL, $C4, 16
    db 128, UI_COORD_X_INITIAL + 8, $B4, 16

fifth_energy_configuration::   ; 3/7
    db 128, UI_COORD_X_INITIAL, $C6, 16
    db 128, UI_COORD_X_INITIAL + 8, $C8, 16

sixth_energy_configuration::   ; 2/7
    db 128, UI_COORD_X_INITIAL, $C6, 16
    db 128, UI_COORD_X_INITIAL + 8, $CA, 16

seventh_energy_configuration:: ; 1/7
    db 128, UI_COORD_X_INITIAL, $C6, 16
    db 128, UI_COORD_X_INITIAL + 8, $CC, 16

eighth_energy_configuration::  ; 0/7
    db 128, UI_COORD_X_INITIAL, $C6, 16
    db 128, UI_COORD_X_INITIAL + 8, $CE, 16

ui_sprites::

    ; Clock - Left part
    db 16, UI_COORD_X_INITIAL, $84, 16
    db 32, UI_COORD_X_INITIAL, $84, %01010000

    ; Clock - Right part
    db 16, UI_COORD_X_INITIAL + 8, $88, 16
    db 32, UI_COORD_X_INITIAL + 8, $88, %01010000

    ; Dashes - Left part
    db 144, UI_COORD_X_INITIAL, $B0, 16

    ; Dashes - Right part
    db 144, UI_COORD_X_INITIAL + 8, $B2, 16

    ; Energy - Left part
    db 128, UI_COORD_X_INITIAL, $BE, 16

    ; Energy - Right part
    db 128, UI_COORD_X_INITIAL + 8, $B4, 16

ui_tilemap:
    db $40, $40 ;9C00
    db $40, $40 ;9C20
    db $40, $40 ;9C40
    db $87, $8B ;9C60
    db $8C, $8E ;9C80
    db $8D, $8F ;9CA0
    db $90, $92 ;9CC0
    db $90, $92
    db $90, $92
    db $90, $92
    db $90, $92
    db $D0, $D1
    db $9C, $9E
    db $9D, $9F
    db $40, $40
    db $40, $40
    db $40, $40
    db $40, $40

progress_bar_ui_tilemap:
    db $90, $92

marker_ui_tilemap:
    db $D0, $D1

ui_tiles::

    DB $80, $80, $80, $80, $80, $80, $80, $80, $80, $80, $80, $80, $80, $80, $80, $80
    DB $7F, $FF, $80, $80, $83, $83, $8F, $8F, $9F, $9F, $9F, $9F, $BF, $BF, $BF, $BF
    DB $80, $80, $80, $80, $80, $80, $80, $80, $80, $80, $80, $80, $80, $80, $80, $80
    DB $7F, $FF, $80, $80, $80, $80, $80, $80, $80, $80, $80, $80, $80, $80, $80, $80
    DB $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
    DB $FF, $FF, $00, $00, $E0, $E0, $F8, $F8, $FC, $FC, $FC, $FC, $FE, $FE, $FE, $FE
    DB $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
    DB $FF, $FF, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
    DB $80, $80, $83, $83, $86, $84, $8D, $88, $89, $8D, $85, $84, $86, $84, $83, $82
    DB $81, $81, $81, $81, $81, $81, $81, $81, $81, $81, $81, $81, $81, $81, $81, $81
    DB $C0, $C0, $60, $A0, $30, $10, $D0, $90, $C8, $D8, $D8, $88, $30, $10, $60, $E0
    DB $40, $40, $40, $40, $40, $40, $40, $40, $40, $40, $40, $40, $40, $40, $40, $40
    DB $81, $81, $81, $81, $81, $81, $81, $81, $81, $81, $81, $81, $81, $81, $81, $81
    DB $81, $81, $81, $81, $81, $81, $81, $81, $81, $81, $81, $81, $81, $81, $81, $81
    DB $40, $40, $40, $40, $40, $40, $40, $40, $40, $40, $40, $40, $40, $40, $40, $40
    DB $40, $40, $40, $40, $40, $40, $40, $40, $40, $40, $40, $40, $40, $40, $40, $40
    DB $87, $87, $88, $8F, $86, $89, $8F, $80, $8F, $82, $8F, $87, $8F, $83, $9F, $90
    DB $81, $81, $81, $81, $81, $81, $81, $81, $81, $81, $81, $81, $81, $81, $81, $81
    DB $81, $81, $81, $81, $81, $81, $81, $81, $81, $81, $81, $81, $81, $81, $81, $81
    DB $87, $87, $88, $8F, $86, $89, $8F, $80, $8F, $82, $8F, $87, $8F, $83, $9F, $90
    DB $F0, $F0, $08, $F8, $E4, $1C, $F4, $0C, $F4, $8C, $F4, $8C, $E4, $1C, $F2, $0E
    DB $40, $40, $40, $40, $40, $40, $40, $40, $40, $40, $40, $40, $40, $40, $40, $40
    DB $40, $40, $40, $40, $40, $40, $40, $40, $40, $40, $40, $40, $40, $40, $40, $40
    DB $F0, $F0, $08, $F8, $E4, $1C, $F4, $0C, $F4, $8C, $F4, $8C, $E4, $1C, $F2, $0E
    DB $81, $81, $83, $82, $86, $85, $84, $86, $84, $86, $82, $83, $81, $81, $80, $80
    DB $80, $80, $80, $80, $80, $80, $80, $80, $80, $80, $80, $80, $80, $80, $7F, $FF
    DB $C0, $C0, $A0, $60, $50, $B0, $50, $B0, $50, $30, $20, $E0, $C0, $C0, $00, $00
    DB $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $FF, $FF
    DB $80, $80, $80, $80, $80, $80, $80, $80, $80, $80, $80, $80, $80, $80, $80, $80
    DB $80, $80, $80, $80, $80, $80, $80, $80, $80, $80, $80, $80, $80, $80, $80, $80
    DB $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
    DB $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
    DB $7F, $FF, $80, $80, $81, $81, $83, $83, $87, $87, $8F, $8F, $8E, $8E, $9C, $9C
    DB $9C, $9C, $9C, $9C, $9C, $9C, $8E, $8E, $8F, $8F, $87, $87, $83, $83, $80, $80
    DB $FF, $FF, $00, $00, $C0, $C0, $E0, $E0, $F0, $F0, $F8, $F8, $78, $78, $3C, $3C
    DB $3C, $3C, $3C, $3C, $38, $38, $70, $70, $F0, $F0, $E0, $E0, $C0, $C0, $00, $00
    DB $7F, $FF, $80, $80, $80, $80, $83, $83, $87, $87, $87, $87, $83, $83, $83, $83
    DB $83, $83, $83, $83, $83, $83, $83, $83, $83, $83, $83, $83, $83, $83, $80, $80
    DB $FF, $FF, $00, $00, $E0, $E0, $E0, $E0, $E0, $E0, $E0, $E0, $E0, $E0, $E0, $E0
    DB $E0, $E0, $E0, $E0, $E0, $E0, $E0, $E0, $E0, $E0, $E0, $E0, $E0, $E0, $00, $00
    DB $7F, $FF, $80, $80, $81, $81, $87, $87, $87, $87, $8F, $8F, $8F, $8F, $80, $80
    DB $80, $80, $83, $83, $87, $87, $8F, $8F, $8F, $8F, $8F, $8F, $8F, $8F, $80, $80
    DB $FF, $FF, $00, $00, $C0, $C0, $F0, $F0, $F8, $F8, $F8, $F8, $38, $38, $78, $78
    DB $F0, $F0, $E0, $E0, $C0, $C0, $F8, $F8, $F8, $F8, $F8, $F8, $F8, $F8, $00, $00
    DB $7F, $FF, $80, $80, $81, $81, $87, $87, $8F, $8F, $8F, $8F, $80, $80, $81, $81
    DB $81, $81, $81, $81, $80, $80, $8F, $8F, $8F, $8F, $87, $87, $81, $81, $80, $80
    DB $FF, $FF, $00, $00, $C0, $C0, $E0, $E0, $F0, $F0, $F8, $F8, $78, $78, $F8, $F8
    DB $E0, $E0, $F0, $F0, $78, $78, $F8, $F8, $F8, $F8, $F0, $F0, $C0, $C0, $00, $00
    DB $FF, $00, $FF, $FF, $FF, $FF, $FF, $00, $00, $00, $00, $00, $00, $00, $00, $00
    DB $FF, $00, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $00
    DB $80, $80, $80, $80, $80, $80, $80, $80, $80, $80, $80, $80, $80, $80, $80, $80
    DB $7F, $FF, $80, $80, $83, $83, $8F, $8F, $8F, $8F, $87, $87, $83, $83, $81, $81
    DB $BF, $BF, $BE, $BE, $9C, $9C, $98, $98, $80, $80, $80, $80, $80, $80, $7F, $FF
    DB $80, $80, $80, $80, $80, $80, $80, $80, $80, $80, $80, $80, $80, $80, $80, $80
    DB $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
    DB $FF, $FF, $00, $00, $00, $00, $00, $00, $18, $18, $38, $38, $7C, $7C, $FC, $FC
    DB $80, $80, $C0, $C0, $E0, $E0, $F0, $F0, $F0, $F0, $C0, $C0, $00, $00, $FF, $FF
    DB $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
    DB $7F, $80, $FF, $FF, $FF, $FF, $FF, $80, $80, $80, $80, $80, $80, $80, $80, $80
    DB $FF, $80, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $7F, $80
    DB $1F, $80, $9F, $9F, $9F, $9F, $9F, $80, $80, $80, $80, $80, $80, $80, $80, $80
    DB $9F, $80, $9F, $9F, $9F, $9F, $9F, $9F, $9F, $9F, $9F, $9F, $9F, $9F, $1F, $80
    DB $07, $80, $87, $87, $87, $87, $87, $80, $80, $80, $80, $80, $80, $80, $80, $80
    DB $87, $80, $87, $87, $87, $87, $87, $87, $87, $87, $87, $87, $87, $87, $07, $80
    DB $01, $80, $81, $81, $81, $81, $81, $80, $80, $80, $80, $80, $80, $80, $80, $80
    DB $81, $80, $81, $81, $81, $81, $81, $81, $81, $81, $81, $81, $81, $81, $01, $80
    DB $00, $80, $80, $80, $80, $80, $80, $80, $80, $80, $80, $80, $80, $80, $80, $80
    DB $80, $80, $80, $80, $80, $80, $80, $80, $80, $80, $80, $80, $80, $80, $00, $80
    DB $7F, $00, $7F, $7F, $7F, $7F, $7F, $00, $00, $00, $00, $00, $00, $00, $00, $00
    DB $7F, $00, $7F, $7F, $7F, $7F, $7F, $7F, $7F, $7F, $7F, $7F, $7F, $7F, $7F, $00
    DB $1F, $00, $1F, $1F, $1F, $1F, $1F, $00, $00, $00, $00, $00, $00, $00, $00, $00
    DB $1F, $00, $1F, $1F, $1F, $1F, $1F, $1F, $1F, $1F, $1F, $1F, $1F, $1F, $1F, $00
    DB $07, $00, $07, $07, $07, $07, $07, $00, $00, $00, $00, $00, $00, $00, $00, $00
    DB $07, $00, $07, $07, $07, $07, $07, $07, $07, $07, $07, $07, $07, $07, $07, $00
    DB $01, $00, $01, $01, $01, $01, $01, $00, $00, $00, $00, $00, $00, $00, $00, $00
    DB $01, $00, $01, $01, $01, $01, $01, $01, $01, $01, $01, $01, $01, $01, $01, $00
    DB $87, $87, $88, $8F, $86, $89, $8F, $82, $8F, $87, $8F, $83, $87, $88, $80, $87
    DB $E0, $E0, $10, $F0, $C8, $38, $E8, $98, $E8, $98, $E8, $18, $C8, $38, $10, $F0