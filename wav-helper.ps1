# Ask the user for the input and output folders
$inputFolder = Read-Host "Enter the folder where your WAV files are located"
$outputFolder = Read-Host "Enter the folder where you want to save the processed files"

# Ensure the output directory exists
if (!(Test-Path -Path $outputFolder)) {
    New-Item -ItemType Directory -Path $outputFolder | Out-Null
}

# Define expected local FFmpeg path
$localFFmpegPath = "C:\Users\atans\ffmpeg-7.1-essentials_build\bin\ffmpeg.exe"

# Check if FFmpeg exists in the local folder first
if (Test-Path -Path $localFFmpegPath) {
    $ffmpegPath = $localFFmpegPath
    Write-Host "Using local FFmpeg: $ffmpegPath" -ForegroundColor Green
} else {
    # Check if FFmpeg is available in the system PATH
    $ffmpegPath = Get-Command ffmpeg -ErrorAction SilentlyContinue | Select-Object -ExpandProperty Source

    if ($ffmpegPath) {
        Write-Host "Using system FFmpeg: $ffmpegPath" -ForegroundColor Green
    } else {
        Write-Host "FFmpeg is missing!" -ForegroundColor Red
        Write-Host "Make sure ffmpeg.exe is either:" -ForegroundColor Yellow
        Write-Host "- In the specified folder: C:\Users\atans\ffmpeg-7.1-essentials_build\bin\" -ForegroundColor Yellow
        Write-Host "- Or installed and added to the system PATH" -ForegroundColor Yellow
        exit
    }
}

# Get all .wav files from the input directory
$wavFiles = Get-ChildItem -Path $inputFolder -Filter "*.wav"

# Check if there are WAV files to process
if ($wavFiles.Count -eq 0) {
    Write-Host "No WAV files found in the input folder. Exiting..." -ForegroundColor Red
    exit
}

# Display conversion options
Write-Host "`nChoose an option:"
Write-Host "1. Convert to FLAC (Lossless)"
Write-Host "2. Convert to AIFF (CDJ-compatible)"
Write-Host "3. Convert to MP3 320kbps"
Write-Host "4. Remove metadata from WAV (CDJ fix)"
$choice = Read-Host "Enter the number of your choice"

# Process each WAV file based on user selection
foreach ($file in $wavFiles) {
    $inputFile = $file.FullName
    $outputFile = "$outputFolder\$($file.BaseName)"

    switch ($choice) {
        "1" {
            $outputFile += ".flac"
            Write-Host "Converting to FLAC: $inputFile -> $outputFile"
            Start-Process -NoNewWindow -Wait -FilePath "$ffmpegPath" -ArgumentList "-i `"$inputFile`" -c:a flac `"$outputFile`""
        }
        "2" {
            $outputFile += ".aiff"
            Write-Host "Converting to AIFF: $inputFile -> $outputFile"
            Start-Process -NoNewWindow -Wait -FilePath "$ffmpegPath" -ArgumentList "-i `"$inputFile`" -c:a pcm_s16le `"$outputFile`""
        }
        "3" {
            $outputFile += ".mp3"
            Write-Host "Converting to MP3 320kbps: $inputFile -> $outputFile"
            Start-Process -NoNewWindow -Wait -FilePath "$ffmpegPath" -ArgumentList "-i `"$inputFile`" -b:a 320k `"$outputFile`""
        }
        "4" {
            $outputFile += ".wav"
            Write-Host "Removing metadata from WAV: $inputFile -> $outputFile"
            Start-Process -NoNewWindow -Wait -FilePath "$ffmpegPath" -ArgumentList "-i `"$inputFile`" -map_metadata -1 -acodec copy `"$outputFile`""
        }
        Default {
            Write-Host "Invalid choice. Exiting script." -ForegroundColor Red
            exit
        }
    }
}

Write-Host "Processing complete! Files saved in: $outputFolder" -ForegroundColor Green
