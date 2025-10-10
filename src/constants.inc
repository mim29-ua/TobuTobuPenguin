; ---------------------------------------------------
; VALUES

def READ_DPAD   equ %00100000
def READ_BUTT   equ %00010000
def DEF_PALETTE equ %11100100

; ---------------------------------------------------
; MEMORY ADDRESSES

def TILES   equ $8000
def TMAP0   equ $9800
def TMAP1   equ $9C00

; ---------------------------------------------------
; HARDWARE REGISTERS

def rJOYP   equ $FF00
def rLCDC   equ $FF40 ; LCD control
def rLY     equ $FF44 ; Current horizontal line
def rBGP    equ $FF47 ; BG palette
def rOBP0   equ $FF48 ; OBJ palette 0
def rOBP1   equ $FF49 ; OBJ palette 1