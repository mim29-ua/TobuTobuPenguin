; ---------------------------------------------------
; VALUES

def P1F_GET_DPAD    equ %00100000
def P1F_GET_BTN     equ %00010000
def DEF_PALETTE     equ %11100100
def P1F_GET_NONE    equ 0
def ANIMATION_SPEED equ 10
def Y_FLIP          equ 6
def X_FLIP          equ 5

; ---------------------------------------------------
; JOYPAD

def PADB_DOWN   equ $07
def PADB_UP     equ $06
def PADB_LEFT   equ $05
def PADB_RIGHT  equ $04
def PADB_START  equ $03
def PADB_SELECT equ $02
def PADB_B      equ $01
def PADB_A      equ $00

; ---------------------------------------------------
; MEMORY ADDRESSES

def TILES   equ $8000
def TMAP0   equ $9800
def TMAP1   equ $9C00

; ---------------------------------------------------
; HARDWARE REGISTERS

def rP1     equ $FF00
def rLCDC   equ $FF40 ; LCD control
def rLY     equ $FF44 ; Current horizontal line
def rBGP    equ $FF47 ; BG palette
def rOBP0   equ $FF48 ; OBJ palette 0
def rOBP1   equ $FF49 ; OBJ palette 1