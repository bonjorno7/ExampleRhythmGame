# Example Rhythm Game
This is a project for Godot 4.3 which serves as a reference for
some of the core systems you might need when creating a rhythm game.

## Features
- Audio drift compensation, time smoothing, and pause support
- Audio and video latency calibration and compensation
- Tempo changes and layers with speed and zoom changes
- Efficient note processing and input handling

## Notes
A lot of the code has comments, though I tried to make it clear on its own.  
The audio pausing works when you pause the scene tree, not when you pause
the stream itself, because it relies on the paused/unpaused notifications.  
The audio and video offset values you get from calibration
both include input latency, which cancels out when subtracted.  
Looping audio isn't currently supported,
so don't take too long during calibration.  
View layers include both speed and zoom changes,
and only affect notes with the same layer index.  
Code in the utils folder isn't used by the game directly,
but was helpful during development.  

## Credits
- bonjorno7
  - Made the project
- TaroNuke
  - Helped with note processing
- isocosa
  - Made music, charts, and sound effects
- Lusumi
  - Made music, charts, and sound effects
