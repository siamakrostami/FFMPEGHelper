//
//  ConverterViewModel.swift
//  FFMPEGDemo
//
//  Created by Siamak Rostami on 3/7/21.
//

import AVKit
import Combine
import ffmpegkit
import Foundation

// MARK: - bitrate

// MARK: - Audio Bitrate Enums

enum bitrate: Int {
    case
        /// low = 64k
        low = 64
    case /// medium = 128k
        medium = 128
    case /// high = 256k
        high = 256
    case /// veryHigh = 320k
        veryHigh = 320
}

// MARK: - ConverterViewModel

// MARK: - Class Definition

class ConverterViewModel: NSObject {
    // MARK: Internal

    @Published var completedAtUrl: URL?
    @Published var progressTime: Int32?
    @Published var percentage: Double?
    @Published var progress: Double?
    var cancellables = Set<AnyCancellable>()

    // MARK: Private

    private var outputPath: URL?
    private var tempOutputPath: URL?
    private var totalTime: Double?
}

extension ConverterViewModel {
    // MARK: - Convert Audio From Input URL

    func convertAudioFrom(url: URL, quality: bitrate) {
        self.createAudioOutputPath(from: url)
        self.calculateTotalTime(url: url)
        guard let path = tempOutputPath else {
            return
        }
        let command = "-i \(url) -acodec libmp3lame -ab \(quality.rawValue)k \(path)"
        let _ = FFmpegKit.executeAsync(command, withCompleteCallback: { [weak self] _ in
            self?.outputPath = self?.tempOutputPath
            self?.completedAtUrl = self?.outputPath
        }, withLogCallback: { _ in
        }, withStatisticsCallback: { [weak self] stat in
            self?.calculateProgress(currentTime: stat?.getTime())
        }, onDispatchQueue: .global(qos: .userInitiated))
    }
    
    func convertHLStoMp4(url: URL) {
        self.createTempOutputPathForHLS(from: url)
        self.calculateTotalTime(url: url)
        guard let path = tempOutputPath else {
            return
        }
        let command = "-i \(url) -codec:v libx264 -preset ultrafast \(path)"
        let _ = FFmpegKit.executeAsync(command, withCompleteCallback: { [weak self] _ in
            self?.outputPath = self?.tempOutputPath
            self?.completedAtUrl = self?.outputPath
        }, withLogCallback: { _ in
        }, withStatisticsCallback: { [weak self] stat in
            self?.calculateProgress(currentTime: stat?.getTime())
        }, onDispatchQueue: .global(qos: .userInitiated))
    }
    
    func addWatermarkToHLS(hls url: URL, watermark: URL) {
        self.createVideoOutputPath(from: url)
        self.calculateTotalTime(url: url)
        guard let path = tempOutputPath else {
            return
        }
        let command = "-i \(url) -i \(watermark) -filter_complex \("overlay=(main_w-overlay_w)/2:(main_h-overlay_h)/2") -c:v libx264 -crf 23 \(path)"
        let _ = FFmpegKit.executeAsync(command, withCompleteCallback: { [weak self] _ in
            self?.outputPath = self?.tempOutputPath
            self?.completedAtUrl = self?.outputPath
        }, withLogCallback: { _ in
        }, withStatisticsCallback: { [weak self] stat in
            self?.calculateProgress(currentTime: stat?.getTime())
        }, onDispatchQueue: .global(qos: .userInitiated))
    }
    
    func addWatermarkToVideo(video url: URL, watermark: URL) {
        self.createVideoOutputPath(from: url)
        self.calculateTotalTime(url: url)
        guard let path = tempOutputPath else {
            return
        }
        let command = "-i \(url) -i \(watermark) -filter_complex \("overlay=(main_w-overlay_w)/2:(main_h-overlay_h)/2") -threads 0 \(path)"
        let _ = FFmpegKit.executeAsync(command, withCompleteCallback: { [weak self] _ in
            self?.outputPath = self?.tempOutputPath
            self?.completedAtUrl = self?.outputPath
        }, withLogCallback: { _ in
        }, withStatisticsCallback: { [weak self] stat in
            self?.calculateProgress(currentTime: stat?.getTime())
        }, onDispatchQueue: .global(qos: .userInitiated))
    }
    
    func convertVideoFrom(url: URL) {
        self.createVideoOutputPath(from: url)
        self.calculateTotalTime(url: url)
        guard let path = tempOutputPath else {
            return
        }
        let command = "-i \(url) -c:v libx264 -crf 23 \(path)"
        let _ = FFmpegKit.executeAsync(command, withCompleteCallback: { [weak self] _ in
            self?.outputPath = self?.tempOutputPath
            self?.completedAtUrl = self?.outputPath
        }, withLogCallback: { _ in
        }, withStatisticsCallback: { [weak self] stat in
            self?.calculateProgress(currentTime: stat?.getTime())
        }, onDispatchQueue: .global(qos: .userInitiated))
    }

    func cancelConvertProgress() {
        FFmpegKit.cancel()
    }
    
    // MARK: - Create Output Path For Converted Audio

    private func createAudioOutputPath(from url: URL) {
        let dirPaths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        let filePath = dirPaths[0].appendingPathComponent("\(url.lastPathComponent.replacingOccurrences(of: " ", with: "")).mp3")
        self.checkFileExistance(in: filePath)
        self.tempOutputPath = filePath
    }
    
    private func createVideoOutputPath(from url: URL) {
        let dirPaths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        let filePath = dirPaths[0].appendingPathComponent("\(url.lastPathComponent.replacingOccurrences(of: " ", with: "")).mp4")
        self.checkFileExistance(in: filePath)
        self.tempOutputPath = filePath
    }
    
    private func createTempOutputPathForHLS(from url: URL) {
        let dirPaths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        let filePath = dirPaths[0].appendingPathComponent("\(url.lastPathComponent.replacingOccurrences(of: ".m3u8", with: "")).mp4")
        self.checkFileExistance(in: filePath)
        self.tempOutputPath = filePath
    }
    
    // MARK: - Check File Existance

    private func checkFileExistance(in url: URL) {
        if FileManager.default.fileExists(atPath: url.path) {
            do {
                try FileManager.default.removeItem(at: url)
            } catch {
                debugPrint("Error")
            }
        } else {
            debugPrint("file doesn't exist")
        }
    }

    // MARK: - Calculate Input Audio File's Duration

    private func calculateTotalTime(url: URL?) {
        guard let newUrl = url else {
            return
        }
        let assets = AVURLAsset(url: newUrl)
        let option = ["duration"]
        assets.loadValuesAsynchronously(forKeys: option) {
            var error: NSError?
            let status = assets.statusOfValue(forKey: "duration", error: &error)
            switch status {
            case .loaded:
                debugPrint(assets.duration)
                self.totalTime = assets.duration.seconds
            default:
                debugPrint(assets.duration)
            }
        }
    }
    
    private func calculateProgress(currentTime: Double?) {
        guard let totalTime = self.totalTime else {
            return
        }
        let progress = (Double(currentTime ?? 0) / totalTime) / 1000
        let percent = (Double(currentTime ?? 0) / totalTime) / 10
        self.percentage = percent
        self.progress = progress
    }
}
