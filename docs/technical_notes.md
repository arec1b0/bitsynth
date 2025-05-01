# BitSynth Technical Documentation

## Architecture

BitSynth is a DOS-based digital synthesizer that uses the programmable interval timer (PIT) to produce audio through the PC speaker. The architecture consists of several key components:

### 1. Waveform Generation
The synthesizer maintains four wave tables, each 256 bytes in length:
- Sine wave: Smooth, harmonic-rich waveform
- Square wave: Rich in odd harmonics, creates a hollow sound
- Sawtooth wave: Contains all harmonics, creates a buzzy sound
- Triangle wave: Contains odd harmonics with steep falloff, creates a mellow sound

### 2. Voice Management
Each voice has the following parameters:
- Frequency: Controls the pitch of the note
- Volume: Controls the amplitude (0-255)
- Phase: Internal state tracking for oscillator
- Waveform selection (currently fixed to sine wave)

### 3. Mixing Engine
The mixer combines samples from all active voices:
- Samples from each voice are scaled by their respective volumes
- Samples are summed and then divided by the number of voices
- The result is output through the PC speaker

### 4. Timer System
- IRQ0 (Timer Interrupt) is hooked for regular sample playback
- Channel 0 of the PIT is programmed for the sample rate
- Channel 2 of the PIT is used for PC speaker output

## Memory Layout

- `0x0100`: Entry point (DOS .COM standard)
- Data section: Includes waveform tables and voice parameters
- Code section: Includes initialization, mixing, and playback routines

## Performance Considerations
- The synthesizer runs at ~18.2 kHz, which is adequate for basic waveforms
- CPU usage is relatively high due to software mixing
- Limited to PC speaker output which has restrictions in audio fidelity