# wav-helper
Powershell script that uses FFmpeg to remove metadata from wav files. Fixes compatibility issues when playing .wav files on certain CDJs. .wav files downloaded from bandcamp can contain metadata headers which can cause format errors when playing on a CDj. The script can also convert wav files to FLAC, AIFF, MP3-320.
Requires FFmpeg library. Add the libraries path to system variables. You must also edit the script and define $localFFmpegPath on line 11. 

The plan is to create a exe package that includes the libaries so that its easier to use. 
