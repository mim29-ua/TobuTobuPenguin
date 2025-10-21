; ---------------------------------------------------
; VALUES

def DEFAULT_PAL equ %11100100
def P1F_GET_NONE equ 0
def ANIMATION_SPEED equ 10
def VBLANK_START_LINE equ $90
def VRAM_TILE_SIZE equ $10
def TMAP_LINE_SIZE equ $20
def PENGUIN_METASPRITE_SIZE equ 4
def METASPRITE_DIMENSIONS equ 16 

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

; ---------------------------------------------------
; MEMORY ADDRESSES

def VRAM_TILE_DATA_START equ $8000
def TMAP0 equ $9800
def TMAP1 equ $9C00

; ---------------------------------------------------
; OAM

def OAM_START equ $FE00

def LEFT_PENGUIN_Y equ $FE00
def LEFT_PENGUIN_X equ $FE01
def LEFT_PENGUIN_TILE_INDEX equ $C102
def LEFT_PENGUIN_TILE_IDLE equ $02
def LEFT_PENGUIN_TILE_JUMPING equ $06
def LEFT_PENGUIN_ATRS equ $FE03

def RIGHT_PENGUIN_Y equ $FE04
def RIGHT_PENGUIN_X equ $FE05
def RIGHT_PENGUIN_TILE_INDEX equ $C106
def RIGHT_PENGUIN_TILE_IDLE equ $04
def RIGHT_PENGUIN_TILE_JUMPING equ $08
def RIGHT_PENGUIN_ATRS equ $FE07

; ---------------------------------------------------
; HARDWARE REGISTERS

def rP1 equ $FF00
def rLCDC equ $FF40 ; LCD control
def rLY equ $FF44 ; Current horizontal line
def rBGP equ $FF47 ; BG palette
def rOBP0 equ $FF48 ; OBJ palette 0
def rOBP1 equ $FF49 ; OBJ palette 1