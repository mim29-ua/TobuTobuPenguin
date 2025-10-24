;; ---------------------------------------------------
;; VALUES

def DEFAULT_PAL equ %11100100
def P1F_GET_NONE equ 0
def ANIMATION_SPEED equ 10
def VBLANK_START_LINE equ $90
def VRAM_TILE_SIZE equ $10
def TMAP_LINE_SIZE equ $20
def PENGUIN_METASPRITE_SIZE equ 4
def METASPRITE_DIMENSIONS equ 8

def LEFT_WALL_PIXEL equ 8
def RIGHT_WALL_PIXEL equ 136
def UP_WALL_PIXEL equ 16
def DOWN_WALL_PIXEL equ 144

def LEFT_MOVE_PENGU_PXLS equ 8 
def RIGHT_MOVE_PENGU_PXLS equ 9
def UP_PENGU_SIZE_PXLS equ 16
def DOWN_PENGU_SIZE_PXLS equ 0

; 0 -> Down
; 1 -> Up
; 2 -> Left
; 3 -> Right
def DOWN equ 0
def UP equ 1
def LEFT equ 2
def RIGHT equ 3

def DIRECTIONAL_PIXELS_OFFSET equ 16
def NON_DIRECTIONAL_PIXELS_OFFSET equ 15

; ---------------------------------------------------
; BACKGROUND

def MAP_DIMENSION equ 32
def BACKGROUND_VIEWPORT_Y_ADDR equ $FF42
def TILE_ROW_19_ADDR equ $9A40
def MIDDLE_SCREEN_Y_PIXELS equ 96

; ---------------------------------------------------
; ENEMIES

def ENEMIES_TYPES_NUMBER equ 5
def RANDOM_CLOCK_ADDR equ $FF04
def FIRST_ENEMIES_ADDR_L equ $08

def AIRSHIP_INITIAL_TILE equ $08

def OVNI_INITIAL_TILE equ $12

def GHOST_INITIAL_TILE equ $0C

def OWL_INITIAL_TILE equ $1A

def WINDMILL_INITIAL_TILE equ $1E

; ---------------------------------------------------
; JOYPAD

def P1F_GET_DPAD equ %00100000
def P1F_GET_BTN equ %00010000

def PADB_DOWN equ $07
def PADB_UP equ $06
def PADB_LEFT equ $05
def PADB_RIGHT equ $04
def PADB_START equ $03
def PADB_SELECT equ $02
def PADB_B equ $01
def PADB_A equ $00

;; ---------------------------------------------------
;; MEMORY ADDRESSES

def VRAM_TILE_DATA_START equ $8000
def TMAP0 equ $9800
def TMAP1 equ $9C00

;; ---------------------------------------------------
;; OAM

def OAM_START equ $FE00

;; ---------------------------------------------------
;; HARDWARE REGISTERS

def rP1 equ $FF00
def rLCDC equ $FF40 ; LCD control
def rLY equ $FF44 ; Current horizontal line
def rBGP equ $FF47 ; BG palette
def rOBP0 equ $FF48 ; OBJ palette 0
def rOBP1 equ $FF49 ; OBJ palette 1

;; ---------------------------------------------------
;; ENTITY MANAGER

; CMP Info fields
rsreset
def CMP_INFO_CMPS rb 1
def CMP_INFO_TYPE rb 1
def CMP_INFO_FREE0 rb 1
def CMP_INFO_FREE1 rb 1
def CMP_INFO_FREE2 rb 1
def CMP_INFO_FREE3 rb 1
def CMP_INFO_FREE4 rb 1
def CMP_INFO_FREE5 rb 1
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
def CMP_BIT_ENEMY equ 3 ; Determines if the entity is enemy or not

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

;; ---------------------------------------------------
;; ENTITIES

def PENGUIN_INFO_CMPS equ $C000

def LEFT_PENGUIN_Y equ $C100
def LEFT_PENGUIN_X equ $C101
def LEFT_PENGUIN_TILE_INDEX equ $C102
def LEFT_PENGUIN_TILE_IDLE equ $00
def LEFT_PENGUIN_TILE_JUMPING equ $04
def LEFT_PENGUIN_ATRS equ $C103

def RIGHT_PENGUIN_Y equ $C104
def RIGHT_PENGUIN_X equ $C105
def RIGHT_PENGUIN_TILE_INDEX equ $C106
def RIGHT_PENGUIN_TILE_IDLE equ $02
def RIGHT_PENGUIN_TILE_JUMPING equ $06
def RIGHT_PENGUIN_ATRS equ $C107
