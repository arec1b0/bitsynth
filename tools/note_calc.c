#include <stdio.h>
#include <stdlib.h>
#include <math.h>

// Note frequency calculator for BitSynth
// Generates PIT frequency values for musical notes

// Constants
#define PIT_FREQ 1193180       // PIT crystal frequency
#define SAMPLE_RATE 18200      // Sample rate used in BitSynth

// Note names
const char* NOTE_NAMES[] = {
    "C-", "C#", "D-", "D#", "E-", "F-", "F#", "G-", "G#", "A-", "A#", "B-"
};

// Calculate frequency for a given note/octave (A4 = 440Hz)
double note_to_freq(int note, int octave) {
    // A4 = 440Hz (note 9, octave 4)
    double a4 = 440.0;
    // Calculate semitones from A4
    int semitones = (octave - 4) * 12 + (note - 9);
    // Calculate frequency (12-TET tuning)
    return a4 * pow(2.0, semitones / 12.0);
}

// Calculate PIT value for BitSynth
unsigned short freq_to_pit_value(double freq) {
    // Formula: phase_increment = (freq * 2^16) / sample_rate
    // Simplifies to: phase_increment = (freq * 65536) / sample_rate
    return (unsigned short)((freq * 65536.0) / SAMPLE_RATE);
}

int main(int argc, char* argv[]) {
    printf("BitSynth Note Frequency Calculator\n");
    printf("=================================\n\n");
    printf("Note  Frequency (Hz)   PIT Value (hex)\n");
    printf("----  -------------   --------------\n");
    
    // Generate table for octaves 1-8
    for (int octave = 1; octave <= 8; octave++) {
        for (int note = 0; note < 12; note++) {
            double freq = note_to_freq(note, octave);
            unsigned short pit_value = freq_to_pit_value(freq);
            
            printf("%s%d   %8.2f Hz      0x%04X (%d)\n", 
                   NOTE_NAMES[note], octave, freq, pit_value, pit_value);
        }
        printf("\n");
    }
    
    // Output to assembly-ready format
    printf("\n; Assembly-ready frequency table\n");
    printf("note_freqs:\n");
    
    for (int octave = 1; octave <= 8; octave++) {
        printf("    ; Octave %d\n    dw ", octave);
        for (int note = 0; note < 12; note++) {
            double freq = note_to_freq(note, octave);
            unsigned short pit_value = freq_to_pit_value(freq);
            printf("0x%04X", pit_value);
            if (note < 11) printf(", ");
        }
        printf("\n");
    }
    
    return 0;
}