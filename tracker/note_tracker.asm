; BitSynth Note Tracker Interface
; A simple tracker implementation for BitSynth
; To be integrated with the main synthesizer

%include "../src/main.asm"  ; Include main synthesizer code

; --------------------------------------------------
; Constants
KEY_ESC          equ 0x01      ; Escape key scancode
KEY_SPACE        equ 0x39      ; Space bar scancode
KEY_ENTER        equ 0x1C      ; Enter key scancode
MAX_PATTERN_LEN  equ 64        ; Maximum pattern length
MAX_PATTERNS     equ 16        ; Maximum patterns

; --------------------------------------------------
; Tracker data structures
section .data

current_pattern      db 0      ; Current pattern being edited
current_row          db 0      ; Current row in pattern
current_column       db 0      ; Current column (voice) being edited
current_octave       db 4      ; Default octave
play_mode            db 0      ; 0 = stopped, 1 = playing
edit_mode            db 1      ; 1 = edit mode

; Pattern data: [note][octave][volume][waveform]
pattern_data:        times MAX_PATTERNS * MAX_PATTERN_LEN * VOICE_COUNT * 4 db 0

; Note to frequency conversion table (C0 to B9)
note_freq_table:
    ; Note frequencies for C-0 through B-0
    dw 34, 36, 38, 41, 43, 46, 49, 52, 55, 58, 62, 65
    ; For C-1 through B-1, multiply by 2, etc.

; --------------------------------------------------
; Tracker main routine
tracker_main:
    call init_synth            ; Initialize synthesizer
    call init_tracker_ui       ; Initialize user interface
    call tracker_loop          ; Enter main tracker loop
    ret

; --------------------------------------------------
; Initialize tracker interface
init_tracker_ui:
    ; Set video mode to text mode 80x25
    mov ax, 0x0003
    int 0x10

    ; Print header
    mov ah, 0x09
    mov dx, header_text
    int 0x21

    ; Draw pattern editor
    call draw_pattern_grid
    ret

; --------------------------------------------------
; Main tracker loop
tracker_loop:
    ; Handle input
    mov ah, 0x01              ; Check for keypress
    int 0x16
    jz .no_key

    ; Process key input
    mov ah, 0x00              ; Get keystroke
    int 0x16
    
    cmp ah, KEY_ESC           ; Check for ESC
    je .exit_tracker
    
    cmp ah, KEY_SPACE         ; Check for Space (play/pause)
    je .toggle_playback
    
    call process_note_input   ; Process potential note input

.no_key:
    ; Update display if needed
    cmp byte [play_mode], 1
    jne .skip_playback
    call play_current_pattern
    
.skip_playback:
    ; Small delay
    mov cx, 0x1000
.delay_loop:
    loop .delay_loop
    jmp tracker_loop

.toggle_playback:
    xor byte [play_mode], 1   ; Toggle play mode
    jmp tracker_loop

.exit_tracker:
    ; Clean up and exit
    mov byte [play_mode], 0   ; Stop playback
    call clear_screen
    ret

; --------------------------------------------------
; Draw pattern editor grid
draw_pattern_grid:
    ; Draw grid headers
    mov ah, 0x09
    mov dx, grid_header
    int 0x21
    
    ; Draw rows (simplified)
    mov cx, 16                ; Draw 16 rows for now
    mov byte [current_row], 0
.draw_row:
    push cx
    call draw_pattern_row
    inc byte [current_row]
    pop cx
    loop .draw_row
    
    ret

; --------------------------------------------------
; Draw a single pattern row
draw_pattern_row:
    ; Position cursor
    mov ah, 0x02
    mov bh, 0
    mov dh, byte [current_row]
    add dh, 5                 ; Start at row 5
    mov dl, 2
    int 0x10
    
    ; Print row number
    mov ah, 0x09
    mov dx, row_template
    int 0x21
    
    ; Print pattern data (simplified)
    ; Real implementation would read from pattern_data and format properly
    
    ret

; --------------------------------------------------
; Process note input (simplified)
process_note_input:
    ; A = C, W = C#, S = D, etc. (simplified keyboard mapping)
    ; In a complete implementation, this would:
    ; 1. Map keyboard keys to notes
    ; 2. Update the pattern data at the current position
    ; 3. Play the note
    ; 4. Move to next position
    
    ret

; --------------------------------------------------
; Play current pattern (simplified)
play_current_pattern:
    ; In a complete implementation, this would:
    ; 1. Read notes from the current pattern
    ; 2. Convert to voice parameters
    ; 3. Update the voice table
    ; 4. Advance pattern position
    
    ret

; --------------------------------------------------
; Clear screen
clear_screen:
    mov ax, 0x0003            ; Text mode 80x25
    int 0x10
    ret

; --------------------------------------------------
; Data section
section .data

header_text     db "BitSynth Tracker v1.0", 0x0D, 0x0A
                db "=====================================", 0x0D, 0x0A
                db "ESC:Exit  SPACE:Play/Stop", 0x0D, 0x0A, "$"

grid_header     db "Row | Voice 1 | Voice 2 | Voice 3 | Voice 4", 0x0D, 0x0A
                db "----+----------+----------+----------+--------", 0x0D, 0x0A, "$"

row_template    db "00  | --- -- | --- -- | --- -- | --- -- |$"