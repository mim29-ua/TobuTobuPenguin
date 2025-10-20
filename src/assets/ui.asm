section "UI Assets", ROM0

; TIEMPO RESTANTE (ESTE ES DIFÍCIL DE EXPLICAR PERO LO INTENTO, ES UN 
; CIRCULO DE 2 SPRITES PERO CREO QUE SE ENTIENDE QUE AMBAS MITADES 
; COMPARTE SPRITES, COMO SE VA RESTANDO DE OCTAVO EN OCTAVO HAY 5 
; TIPOS DE SPRITES, UNO QUE ES UN SEMICICULO COMPLETO, OTRO UN 
; SEMICIRCULO MENOS UN OCTAVO, OTRO UN CUARTO Y BLANCO, OTRO UN OCTAVO 
; Y BLANCO Y POR ÚLTIMO UNO BLANCO COMPLETO)

four_eighths_clock::
    db $03,$07,$0F,$1F,$1F,$3F,$3F,$7F,$7F,$7F,$7F,$FF,$FF,$FF,$FF,$FF
    db $FF,$FF,$FF,$FF,$7F,$FF,$7F,$7F,$3F,$7F,$1F,$3F,$0F,$1F,$03,$07

three_eighths_clock::
    db $00,$00,$00,$00,$00,$00,$60,$20,$70,$70,$78,$F8,$FC,$FC,$FE,$FE
    db $FF,$FF,$FF,$FF,$7F,$FF,$7F,$7F,$3F,$7F,$1F,$3F,$0F,$1F,$03,$07

two_eighths_clock::
    db $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
    db $FF,$FF,$FF,$FF,$7F,$FF,$7F,$7F,$3F,$7F,$1F,$3F,$0F,$1F,$03,$07

one_eighth_clock::
    db $00,$00,$00,$00,$00,$00,$60,$20,$70,$70,$78,$F8,$FC,$FC,$FE,$FE
    db $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00

empty_clock::
    db $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
    db $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00