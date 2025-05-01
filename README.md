# BitSynth

A 16-bit real-mode 4-voice PCM synthesizer for DOS systems.

![License](https://img.shields.io/github/license/arec1bo/bitsynth)
![Stars](https://img.shields.io/github/stars/arec1bo/bitsynth?style=social)

## Overview
BitSynth is a compact DOS-compatible synthesizer that produces multi-voice digital audio through the PC speaker using programmable interval timer (PIT) manipulation.

## Features
- 4 independent sound channels
- Multiple waveform types: sine, square, sawtooth, and triangle
- Sample rate: ~18.2 kHz
- 8-bit amplitude resolution
- Compact DOS .COM format executable
- Assembly optimized for size and performance

## Demo
[View demo video](https://arec1bo.github.io/bitsynth/demo.html)

## Building
1. Ensure NASM is installed: `sudo apt-get install nasm`
2. Run the build script: `cd build && ./build.sh`
3. The output will be generated as `output/bitsynth.com`

## Usage
Run `bitsynth.com` in a DOS environment or emulator (like DOSBox). A C-major chord will play through the PC speaker. Press any key to exit.

### Running in DOSBox
```
mount c /path/to/bitsynth
c:
bitsynth.com
```

## Project Structure
- `src/` - Assembly source code
- `build/` - Build scripts 
- `output/` - Compiled binaries
- `docs/` - Documentation
- `tools/` - Utility scripts
- `tracker/` - Simple music tracker interface

## Development Status
This is a functional prototype demonstrating PCM synthesis on legacy hardware.

## Contributing
Contributions are welcome! Please feel free to submit a Pull Request.
See [CONTRIBUTING.md](CONTRIBUTING.md) for development guidelines.

## License
This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Acknowledgments
- Thanks to the vintage computing community for keeping DOS programming alive
- Special thanks to all contributors