include "constants.inc"

section "Sprites creation configurations", ROM0
; Sprite cmp (+0)
; y, x, tile, properties (Enemies don't use static x, they use a random x position. And y is always zero when created.)

; Physics cmp (+8)
; y, x, vy, vx

penguin_entity:
    db 48,80,LEFT_PENGUIN_TILE_IDLE,0
    db 48,88,LEFT_PENGUIN_TILE_JUMPING,0
    db 32,24,0,0
    db 32,32,0,0

ovni_entity:
    db $12, 16
    db $12, %00110000
    db 0,0
    db 0,0

airship_entity:
    db $08, 16
    db $0A, 16
    db 0,0
    db 0,0

ghost_entity:
    db $0C, 16
    db $0E, 16
    db 0,0
    db 0,0

owl_entity:
    db $1A, 16
    db $1A, %00110000
    db 0,0
    db 0,0

windmill_entity:
    db $1E, 16
    db $1E, %01110000
    db 0,0
    db 0,0

section "Entities Assets", ROM0

entities_tiles::
normal_penguin::
    db $0F,$0F,$10,$11,$0D,$12,$1F,$00,$1F,$05,$1F,$0F,$1F,$06,$3F,$20
    db $5F,$60,$9F,$E0,$7F,$60,$0F,$10,$0F,$10,$17,$18,$1B,$1C,$38,$38
    db $E0,$E0,$10,$F0,$C8,$38,$E8,$18,$E8,$18,$E8,$18,$C4,$3C,$E2,$1E
    db $E1,$1F,$F9,$0F,$F5,$0F,$F7,$0F,$F4,$0C,$F4,$1C,$F8,$38,$70,$70

jumping_penguin::
    db $0F,$0F,$10,$11,$0D,$12,$1F,$00,$1F,$05,$DF,$CF,$B9,$E1,$9F,$E6
    db $5F,$60,$3F,$20,$1F,$00,$0F,$10,$77,$78,$77,$78,$30,$30,$00,$00
    db $E0,$E0,$10,$F0,$C8,$38,$EB,$1B,$ED,$1F,$E9,$1F,$C1,$3F,$E2,$1E
    db $E4,$1C,$EC,$1C,$E4,$1C,$E4,$1C,$F4,$7C,$F8,$78,$30,$30,$00,$00

airship::
    db $03,$03,$EC,$EF,$9B,$FC,$D7,$FB,$6C,$7F,$57,$78,$7F,$7F,$57,$78
    db $6C,$7F,$D7,$FB,$9B,$FC,$EC,$EF,$03,$03,$02,$03,$02,$03,$01,$01
    db $F0,$F0,$08,$F8,$F4,$0C,$FA,$F6,$0D,$FF,$FB,$07,$FF,$FF,$FB,$07
    db $0D,$FF,$FA,$F6,$F4,$0C,$08,$F8,$F0,$F0,$10,$F0,$20,$E0,$C0,$C0

ghost_1::
    db $03,$03,$06,$05,$67,$64,$9F,$FA,$DF,$BA,$7F,$4A,$7F,$40,$3F,$21
    db $3F,$21,$1F,$10,$1F,$10,$0F,$08,$09,$0E,$04,$07,$03,$03,$01,$01
    db $C0,$C0,$20,$E0,$96,$76,$DA,$BE,$D2,$BE,$D4,$BC,$C4,$3C,$C8,$38
    db $E8,$18,$F0,$10,$DE,$3E,$F1,$1F,$F3,$0F,$E4,$1C,$58,$B8,$E0,$E0

; (SU ANIMACIÓN SOLO CAMBIA EL TILE 4 POR ESO EN LA PARTE 2 SOLO VERÁS 
; 2 VRAM_TILE_DATA_START SUFICIENTES PARA PODER HACER SU SPRITE)
ghost_2::
    db $C0,$C0,$20,$E0,$96,$76,$DA,$BE,$D2,$BE,$D4,$BC,$C4,$3C,$C8,$38
    db $E8,$18,$D0,$30,$D6,$36,$DD,$3F,$FD,$03,$F2,$0E,$1C,$FC,$E0,$E0

; (ESTÁ COMPUESTO POR 2 SPRITES PERO SON SIMETRICOS POR LO QUE SOLO SE 
; ESCRIBEN DOS VRAM_TILE_DATA_START Y SE CREAN DOS,UNO DE ELLOS CON XFLIP,HAY 4 ANIMACIONES)
ovni_1::
    db $03,$03,$04,$07,$0B,$0C,$17,$18,$1F,$1F,$67,$78,$9F,$E0,$FF,$FF
    db $23,$3C,$1F,$1F,$03,$04,$07,$08,$0F,$10,$1F,$20,$3F,$40,$7F,$80

ovni_2::
    db $03,$03,$04,$07,$0B,$0C,$17,$18,$1F,$1F,$67,$78,$9F,$E0,$FF,$FF
    db $23,$3C,$1F,$1F,$03,$04,$07,$08,$0F,$10,$1F,$20,$00,$00,$00,$00

ovni_3::
    db $03,$03,$04,$07,$0B,$0C,$17,$18,$1F,$1F,$67,$78,$9F,$E0,$FF,$FF
    db $23,$3C,$1F,$1F,$03,$04,$07,$08,$00,$00,$00,$00,$00,$00,$00,$00

ovni_4::
    db $03,$03,$04,$07,$0B,$0C,$17,$18,$1F,$1F,$67,$78,$9F,$E0,$FF,$FF
    db $23,$3C,$1F,$1F,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00

owl_1:
    db $80,$80,$6E,$EE,$31,$FF,$1E,$F1,$1F,$F4,$8F,$F4,$8F,$F1,$81,$FF
    db $80,$FF,$88,$FF,$6C,$7F,$1F,$1B,$07,$05,$02,$02,$00,$00,$00,$00

owl_2:
    db $00,$00,$0E,$0E,$11,$1F,$1E,$11,$1F,$14,$1F,$14,$3F,$31,$41,$7F
    db $80,$FF,$88,$FF,$8C,$FF,$9F,$FB,$97,$F5,$42,$72,$40,$60,$20,$20

windmill_1:
    db $00, $00, $00, $00, $01, $01, $63, $63, $75, $57, $79, $4F, $3D, $27, $3F, $23
    db $3F, $3F, $11, $1F, $0B, $0E, $07, $04, $0F, $08, $1F, $13, $1C, $1C, $00, $00

windmill_2:
    db $03, $03, $07, $05, $0F, $09, $0F, $11, $1F, $19, $17, $1D, $13, $1F, $11, $1F
    db $FF, $FF, $FE, $83, $7C, $47, $38, $2F, $1F, $1F, $00, $00, $00, $00, $00, $00