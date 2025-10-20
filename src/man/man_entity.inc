; CMP Info fields
rsreset
def CMP_INFO_CMPS rb 1
def CMP_INFO_TYPE rb 1
def CMP_INFO_FREE1 rb 1
def CMP_INFO_FREE2 rb 1
def SIZEOF_INFO_CMP rb 0

; CMP Sprite fields
rsreset
def CMP_SPRI_L_Y rb 1
def CMP_SPRI_L_X rb 1
def CMP_SPRI_L_TILE rb 1
def CMP_SPRI_L_ATRS rb 1
def CMP_SPRI_R_Y rb 1
def CMP_SPRI_R_X rb 1
def CMP_SPRI_R_TILE rb 1
def CMP_SPRI_R_ATRS rb 1
def SIZEOF_SPRI_CMP rb 0

; CMP Physics fields
rsreset
def CMP_PHYS_Y rb 1
def CMP_PHYS_X rb 1
def CMP_PHYS_VY rb 1
def CMP_PHYS_VX rb 1
def SIZEOF_PHYS_CMP rb 0

; Entity component bit INFO
def CMP_BIT_SENTINEL equ 7 ; Por si el valor de algun componente coincide con el del centinela, que no pase nada
def CMP_BIT_ALIVE equ 6
def CMP_BIT_PHYSICS equ 5
def CMP_BIT_RENDER equ 4

; Entity Manager
def NUM_ENTITIES equ 10
def CMP_SENTINEL equ $FF
def CMP_FREE equ 0
def SIZEOF_ARRAY_CMP equ NUM_ENTITIES * SIZEOF_INFO_CMP
def CMP_RESERVED equ (1 << CMP_BIT_ALIVE) ; Para activar el bit 6

; Component HIGH hl values
def CMP_INFO_H equ $C0
def CMP_SPRITE_H equ $C1
def CMP_PHYSICS_H equ $C2
