# FFMPEGDemo Readme

## Overview
This repository contains code for an iOS app that utilizes FFmpegKit to perform audio and video conversion operations. The app includes a `ConverterViewModel` class responsible for handling the conversion logic and a `ViewController` class to demonstrate the functionality.

## `ConverterViewModel`

### Overview
The `ConverterViewModel` class manages the conversion process using FFmpegKit. It includes methods for converting audio from an input URL and adding a watermark to a video. The progress, percentage, and completion URL are published properties, allowing the UI to react to changes during the conversion process.

### `bitrate` Enumeration
The `bitrate` enumeration defines different bitrates for audio conversion.

### Public Properties
- `completedAtUrl`: Published property for the completion URL.
- `progressTime`: Published property for the progress time.
- `percentage`: Published property for the conversion percentage.
- `progress`: Published property for the overall progress.
- `cancellables`: Set of Combine cancellables.

### Public Methods
- `convertAudioFrom(url:quality:)`: Converts audio from the input URL with the specified bitrate.
- `addWatermarkToVideo(video:watermark:)`: Adds a watermark to the video from the input URLs.
- `cancelConvertProgress()`: Cancels the ongoing conversion process.

### Private Methods
- `createAudioOutputPath(from:)`: Creates an output path for converted audio.
- `createVideoOutputPath(from:)`: Creates an output path for converted video.
- `checkFileExistance(in:)`: Checks and removes existing files.
- `calculateTotalTime(url:)`: Calculates the total duration of the input audio file.
- `calculateProgress(currentTime:)`: Calculates the conversion progress based on the current time.

## `ViewController`

### Overview
The `ViewController` class serves as the main view controller for the app. It includes UI elements such as a progress view and a label to display the conversion percentage. The class initializes a `ConverterViewModel` instance, triggers a conversion from a local file on `viewDidLoad`, and binds UI elements to the conversion progress.

### Public Properties
- `progressView`: UIProgressView to visualize the conversion progress.
- `progressPercentageLabel`: UILabel to display the conversion percentage.

### Private Properties
- `convertViewModel`: Instance of `ConverterViewModel` for handling conversion logic.

### Private Methods
- `ConvertLocalFile()`: Initiates the conversion of a local video file with a watermark.
- `bindProgress()`: Binds the UI progress view to the conversion progress.
- `bindPercentage()`: Binds the UI label to the conversion percentage.
- `bindCompletedProgress()`: Binds the UI to display the completed video.

## Usage
To use this code, follow these steps:
1. Integrate the code into your iOS project.
2. Ensure FFmpegKit is included in your project.
3. Initialize a `ConverterViewModel` instance.
4. Trigger audio or video conversion using the appropriate methods.
5. Bind UI elements to the published properties for real-time updates.

Feel free to customize the code based on your specific requirements.

## Dependencies
- [FFmpegKit](https://github.com/tanersener/ffmpeg-kit): FFmpeg library for iOS.

## License
This code is licensed under the [MIT License](LICENSE).
