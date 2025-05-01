; File: bitsynth/src/main.asm
; Purpose: Entry point for BitSynth – 16-bit real-mode 4-voice PCM synthesizer
; Build with: nasm -f bin main.asm -o bitsynth.com

org 0x100                   ; DOS .COM programs start at offset 0x100

; --------------------------------------------------
; Constants
SAMPLE_RATE      equ 18200      ; ~18.2 kHz, PIT timer rate
VOICE_COUNT      equ 4
WAVEFORM_LENGTH  equ 256        ; Wave table length
PIT_FREQ        equ 1193180    ; PIT crystal frequency
SAMPLE_DIV      equ PIT_FREQ / SAMPLE_RATE  ; PIT divisor for sample rate

; --------------------------------------------------
; Entry point
start:
    xor ax, ax
    mov ds, ax
    mov es, ax

    call init_synth      ; Initialize waveform tables
    call play_loop       ; Enter playback loop (stub)

    ; Restore original IRQ0 handler before exit
    cli
    mov bx, 8*4
    mov ax, [old_int8_off]
    mov [bx], ax
    mov ax, [old_int8_seg]
    mov [bx+2], ax
    sti

    mov ax, 0x4C00       ; Return to DOS
    int 0x21

; --------------------------------------------------
; New IRQ0 handler entry point
new_isr:
    pusha                       ; Save all general-purpose registers
    call mix_and_output        ; Mix and output audio
    mov al, 0x20               ; Send EOI to PIC
    out 0x20, al
    popa                       ; Restore registers
    iret                       ; Return from interrupt

; --------------------------------------------------
; Mix and output routine
mix_and_output:
    push ds
    push es
    mov ax, cs          ; Ensure DS points to our segment
    mov ds, ax
    
    ; Clear accumulator
    xor bx, bx          ; BX will hold our mixed sample
    
    ; For each voice
    mov si, voice_table
    mov cx, VOICE_COUNT
.voice_loop:
    ; Get voice parameters
    mov dl, [si+2]      ; Volume
    test dl, dl         ; Skip if volume = 0
    jz .next_voice
    
    ; Get current phase
    mov ax, [si+3]      ; Load phase (low, high)
    
    ; Get waveform type (new parameter at offset 5)
    mov dh, [si+5]      ; 0=sine, 1=square, 2=saw, 3=triangle
    
    ; Select appropriate waveform table
    push si
    mov si, wave_sine   ; Default to sine wave
    cmp dh, 0
    je .got_wave_table
    mov si, wave_square
    cmp dh, 1
    je .got_wave_table
    mov si, wave_saw
    cmp dh, 2
    je .got_wave_table
    mov si, wave_triangle
.got_wave_table:
    
    ; Get waveform sample based on high byte of phase
    mov di, ax
    shr di, 8           ; Use high byte as index
    add di, si          ; Add waveform table base
    mov al, [di]        
    pop si
    
    ; Scale by volume
    mul dl              ; AX = AL * DL (sample * volume)
    shr ax, 8           ; Scale back to 8-bit
    
    ; Add to mix
    add bx, ax
    
    ; Update phase based on frequency
    mov ax, [si]        ; Load frequency
    add [si+3], ax      ; Add to phase
    
.next_voice:
    add si, 6           ; Point to next voice entry (new size)
    loop .voice_loop
    
    ; Scale final mix
    mov ax, bx
    mov bl, VOICE_COUNT
    div bl              ; Scale by number of voices
    
    ; Output to PC speaker
    mov bl, al          ; Save sample
    
    ; Convert sample to speaker frequency
    add al, 128         ; Center around 128
    shr al, 2           ; Scale to reasonable frequency range
    
    ; Program timer 2 (speaker timer)
    mov al, 0xb6        ; Command byte: channel 2, write LSB/MSB
    out 0x43, al
    mov al, bl          ; Sample value determines frequency
    out 0x42, al        ; LSB
    xor al, al
    out 0x42, al        ; MSB
    
    ; Toggle speaker
    in al, 0x61
    or al, 3           ; Enable speaker
    out 0x61, al
    
    pop es
    pop ds
    ret

; --------------------------------------------------
; Synthesizer Initialization
init_synth:
    ; -- Initialize waveform tables --
    call init_waves

    ; -- Hook IRQ0 and program PIT for audio sample rate --
    cli                         ; Disable interrupts
    ; Save old IRQ0 handler
    mov bx, 8*4                ; Vector 8 location = 8*4 = 0x20
    mov ax, [bx]
    mov [old_int8_off], ax
    mov ax, [bx+2]
    mov [old_int8_seg], ax
    ; Install new handler
    mov dx, new_isr
    mov [bx], dx
    mov ax, cs
    mov [bx+2], ax
    ; Program PIT channel 0
    mov al, 0x36              ; Channel 0, LSB/MSB, mode 3
    out 0x43, al
    mov bx, SAMPLE_DIV       ; Set frequency divider
    mov al, bl
    out 0x40, al            ; LSB
    mov al, bh
    out 0x40, al            ; MSB
    sti                     ; Re-enable interrupts
    ret

; --------------------------------------------------
; Initialize wave tables
init_waves:
    ; Initialize sine wave
    mov cx, WAVEFORM_LENGTH
    mov di, wave_sine
    mov si, sine_table
.sine_loop:
    mov al, [si]
    mov [di], al
    inc si
    inc di
    loop .sine_loop

    ; Initialize square wave
    mov cx, WAVEFORM_LENGTH
    mov di, wave_square
    xor bx, bx
.square_loop:
    mov al, 0           ; Default to 0
    cmp bx, WAVEFORM_LENGTH/2
    jae .square_low
    mov al, 127        ; First half = max amplitude
.square_low:
    mov [di], al
    inc di
    inc bx
    loop .square_loop

    ; Initialize sawtooth wave
    mov cx, WAVEFORM_LENGTH
    mov di, wave_saw
    xor bx, bx
.saw_loop:
    mov al, bl         ; Linear ramp from 0 to 255
    mov [di], al
    inc di
    inc bx
    loop .saw_loop

    ; Initialize triangle wave
    mov cx, WAVEFORM_LENGTH
    mov di, wave_triangle
    xor bx, bx
.tri_loop:
    mov al, bl
    cmp bx, WAVEFORM_LENGTH/2
    jae .tri_down
    shl al, 1          ; First half: multiply by 2
    jmp .tri_store
.tri_down:
    neg al             ; Second half: invert and scale
    add al, 255
.tri_store:
    mov [di], al
    inc di
    inc bx
    loop .tri_loop
    ret

; --------------------------------------------------
; Playback Loop
play_loop:
    ; Setup test notes (can be modified for actual input handling)
    mov si, voice_table
    
    ; Voice 1: C4 note (~262 Hz)
    mov word [si], 1207    ; frequency
    mov byte [si+2], 64    ; volume (0-255)
    mov byte [si+5], 0     ; waveform type (0=sine)
    
    ; Voice 2: E4 note (~330 Hz)
    mov word [si+6], 1520  ; frequency
    mov byte [si+8], 48    ; volume
    mov byte [si+11], 1    ; waveform type (1=square)
    
    ; Voice 3: G4 note (~392 Hz)
    mov word [si+12], 1804 ; frequency
    mov byte [si+14], 48   ; volume
    mov byte [si+17], 2    ; waveform type (2=saw)
    
    ; Voice 4: C5 note (~523 Hz)
    mov word [si+18], 2414 ; frequency
    mov byte [si+20], 32   ; volume
    mov byte [si+23], 3    ; waveform type (3=triangle)
    
    ; Wait for key press to exit
.wait_loop:
    mov ah, 1           ; Check for keypress
    int 0x16
    jz .wait_loop      ; Loop if no key
    
    mov ah, 0          ; Clear keystroke
    int 0x16
    
    ; Zero all voices before exit
    mov cx, VOICE_COUNT * 6
    mov di, voice_table
    xor al, al
    rep stosb          ; Fill with zeros
    
    ret

; --------------------------------------------------
; Data Section
section .data

; BIOS IRQ0 vector storage
old_int8_off    dw 0
old_int8_seg    dw 0

; Waveform Tables (256 bytes each)
wave_sine:      times WAVEFORM_LENGTH db 0
wave_square:    times WAVEFORM_LENGTH db 0
wave_saw:       times WAVEFORM_LENGTH db 0
wave_triangle:  times WAVEFORM_LENGTH db 0

; Voice Table: 6 bytes per voice [freq_lo, freq_hi, volume, phase_lo, phase_hi, waveform_type]
voice_table:    times VOICE_COUNT * 6 db 0

; Precomputed sine table (256 bytes, full sine wave)
sine_table:
    db 128, 131, 134, 137, 140, 143, 146, 149, 152, 155, 158, 161, 164, 167, 170, 173
    db 176, 179, 182, 184, 187, 190, 192, 195, 198, 200, 203, 205, 207, 210, 212, 214
    db 216, 218, 220, 222, 224, 226, 228, 229, 231, 232, 234, 235, 236, 237, 238, 239
    db 240, 241, 242, 242, 243, 243, 244, 244, 244, 244, 244, 244, 244, 243, 243, 242
    db 242, 241, 240, 239, 238, 237, 236, 235, 234, 232, 231, 229, 228, 226, 224, 222
    db 220, 218, 216, 214, 212, 210, 207, 205, 203, 200, 198, 195, 192, 190, 187, 184
    db 182, 179, 176, 173, 170, 167, 164, 161, 158, 155, 152, 149, 146, 143, 140, 137
    db 134, 131, 128, 124, 121, 118, 115, 112, 109, 106, 103, 100, 97, 94, 91, 88
    db 85, 82, 79, 76, 73, 71, 68, 65, 63, 60, 57, 55, 52, 50, 48, 45
    db 43, 41, 39, 37, 35, 33, 31, 29, 27, 26, 24, 23, 21, 20, 19, 18
    db 17, 16, 15, 14, 13, 13, 12, 12, 11, 11, 11, 11, 11, 11, 11, 12
    db 12, 13, 13, 14, 15, 16, 17, 18, 19, 20, 21, 23, 24, 26, 27, 29
    db 31, 33, 35, 37, 39, 41, 43, 45, 48, 50, 52, 55, 57, 60, 63, 65
    db 68, 71, 73, 76, 79, 82, 85, 88, 91, 94, 97, 100, 103, 106, 109, 112
    db 115, 118, 121, 124, 127, 130, 133, 136, 139, 142, 145, 148, 151, 154, 157, 160
    db 163, 166, 169, 172, 175, 178, 181, 183, 186, 189, 191, 194, 197, 199, 202, 204
