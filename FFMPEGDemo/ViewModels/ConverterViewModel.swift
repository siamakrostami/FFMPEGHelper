//
//  ConverterViewModel.swift
//  FFMPEGDemo
//
//  Created by Siamak Rostami on 3/7/21.
//

import Foundation
import mobileffmpeg
import AVKit

//MARK:- Audio Bitrate Enums
enum bitrate : Int{
    case
        /// low = 64k
        low = 64,
        ///medium = 128k
        medium = 128,
        ///high = 256k
        high = 256,
        ///veryHigh = 320k
        veryHigh = 320
}

//MARK:- Convert Protocols
protocol ConvertProgressProtocols {
    func ConvertProgress(progress : Int32)
    func ConvertStatus(status : Int32)
    func ExecutionStatus(executionId: Int, level: Int32,message: String!)
}

//MARK:- Class Definition
class ConverterViewModel : NSObject{
    var delegate : ConvertProgressProtocols!
    let fileManager = FileManager.default
    var outputPath : URL?
    var tempOutputPath : URL?
    var totalTime : Double?
    var isConvert = true
}

extension ConverterViewModel{
    
    //MARK:- Convert Audio From Input URL
    func convertAudioFrom(url : URL , quality : bitrate){
        self.createAudioOutputPath(from: url)
        self.calculateTotalTime(url: url)
        guard let path = outputPath else{return}
        let command = "-i \(url) -acodec libmp3lame -ab \(quality.rawValue)k \(path)"
        MobileFFmpegConfig.setLogDelegate(self)
        MobileFFmpegConfig.setStatisticsDelegate(self)
        if let converter = MobileFFmpeg.executeAsync(command, withCallback: self, andDispatchQueue: .global(qos: .userInteractive)) as Int32?{
            debugPrint("converter status code :\(converter)")
        }
    }
    
    func convertHLStoMp4(url : URL){
        self.createTempOutputPathForHLS(from: url)
        self.calculateTotalTime(url: url)
        guard let path = self.tempOutputPath else{return}
        let command = "-i \(url) -codec:v libx264 -preset ultrafast \(path)"
        MobileFFmpegConfig.setLogDelegate(self)
        MobileFFmpegConfig.setStatisticsDelegate(self)
        if let converter = MobileFFmpeg.executeAsync(command, withCallback: self, andDispatchQueue: .global(qos: .userInteractive)) as Int32?{
            debugPrint("converter status code :\(converter)")
        }
    }
    
//    func addWatermarkToHLS(hls url : URL , watermark : URL){
//        self.createVideoOutputPath(from: url)
//        self.calculateTotalTime(url: url)
//        guard let path = outputPath else{return}
//       // -codec:v libx264 -preset ultrafast -filter_complex overlay
//       // -i \(url) -i \(watermark) -filter_complex \("overlay=(main_w-overlay_w)/2:(main_h-overlay_h)/2") -c:v libx264 -crf 23 \(path)
//        let command = "-i \(url) -codec:v libx264 -preset ultrafast \(path)"
//        MobileFFmpegConfig.setLogDelegate(self)
//        MobileFFmpegConfig.setStatisticsDelegate(self)
//        if let converter = MobileFFmpeg.executeAsync(command, withCallback: self, andDispatchQueue: .global(qos: .userInteractive)) as Int32?{
//            debugPrint("converter status code :\(converter)")
//        }
//    }
    
    func addWatermarkToVideo(video url : URL , watermark : URL){
        self.isConvert = false
        self.createVideoOutputPath(from: url)
        self.calculateTotalTime(url: url)
        guard let path = outputPath else{return}
        let command = "-i \(url) -i \(watermark) -filter_complex \("overlay=(main_w-overlay_w)/2:(main_h-overlay_h)/2") -threads 0 \(path)"
        MobileFFmpegConfig.setLogDelegate(self)
        MobileFFmpegConfig.setStatisticsDelegate(self)
        if let converter = MobileFFmpeg.executeAsync(command, withCallback: self, andDispatchQueue: .global(qos: .userInteractive)) as Int32?{
            debugPrint("converter status code :\(converter)")
        }
        
    }
    
    func convertVideoFrom(url : URL){
        self.createVideoOutputPath(from: url)
        self.calculateTotalTime(url: url)
        guard let path = outputPath else{return}
        let command = "-i \(url) -c:v libx264 -crf 23 \(path)"
        MobileFFmpegConfig.setLogDelegate(self)
        MobileFFmpegConfig.setStatisticsDelegate(self)
        if let converter = MobileFFmpeg.executeAsync(command, withCallback: self, andDispatchQueue: .global(qos: .userInteractive)) as Int32?{
            debugPrint("converter status code :\(converter)")
        }
        
    }
    func cancelConvertProgress(){
        MobileFFmpeg.cancel()
    }
    
    //MARK:- Create Output Path For Converted Audio
    func createAudioOutputPath(from url : URL){
        let fileMgr = FileManager.default
        let dirPaths = fileMgr.urls(for: .documentDirectory, in: .userDomainMask)
        let filePath = dirPaths[0].appendingPathComponent("\(url.lastPathComponent.replacingOccurrences(of: " ", with: "")).mp3")
        self.checkFileExistance(in: filePath)
        self.outputPath = filePath
    }
    
    func createVideoOutputPath(from url : URL){
        let fileMgr = FileManager.default
        let dirPaths = fileMgr.urls(for: .documentDirectory, in: .userDomainMask)
        let filePath = dirPaths[0].appendingPathComponent("\(url.lastPathComponent.replacingOccurrences(of: " ", with: "")).mp4")
        self.checkFileExistance(in: filePath)
        self.outputPath = filePath
    }
    
    func createTempOutputPathForHLS(from url : URL){
        let fileMgr = FileManager.default
        let dirPaths = fileMgr.urls(for: .documentDirectory, in: .userDomainMask)
        let filePath = dirPaths[0].appendingPathComponent("\(url.lastPathComponent.replacingOccurrences(of: ".m3u8", with: "")).mp4")
        self.checkFileExistance(in: filePath)
        self.tempOutputPath = filePath
    }

    
    //MARK:- Check File Existance
    func checkFileExistance(in url : URL){
        if FileManager.default.fileExists(atPath: url.path){
            do{
                try fileManager.removeItem(at: url)
            }catch{
                debugPrint("Error")
            }
        }else{
            debugPrint("file doesn't exist")
        }
    }
    //MARK:- Calculate Input Audio File's Duration
    fileprivate func calculateTotalTime(url : URL?){
        guard let newUrl = url else{return}
        let assets = AVURLAsset(url: newUrl)
        let option = ["duration"]
        assets.loadValuesAsynchronously(forKeys: option) {
            var error : NSError? = nil
            let status = assets.statusOfValue(forKey: "duration", error: &error)
            switch status{
            case .loaded:
                debugPrint(assets.duration)
                self.totalTime = assets.duration.seconds
                break
            default:
                debugPrint(assets.duration)
                break
            }
        }

    }
    
}

//MARK:- FFMPEG ExecuteDelegate
extension ConverterViewModel : ExecuteDelegate{
    func executeCallback(_ executionId: Int, _ returnCode: Int32) {
        delegate.ConvertStatus(status: returnCode)
    }
}
//MARK:- FFMPEG LogDelegate
extension ConverterViewModel : LogDelegate {
    func logCallback(_ executionId: Int, _ level: Int32, _ message: String!) {
        delegate.ExecutionStatus(executionId: executionId, level: level, message: message)
    }
}
//MARK:- FFMPEGCONFIG StatisticsDelegate
extension ConverterViewModel : StatisticsDelegate{
    func statisticsCallback(_ statistics: Statistics!) {
        delegate.ConvertProgress(progress: statistics.getTime())
    }
    
    
}
