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
    var totalTime : Double?
}

extension ConverterViewModel{
    
    //MARK:- Convert Audio From Input URL
    func convertAudioFrom(_ url : URL , with bitrate : bitrate){
        self.createOutputPath(from: url)
        self.calculateTotalTime(url: url)
        guard let path = outputPath else{return}
        let command = "-i \(url) -acodec libmp3lame -ab \(bitrate.rawValue)k \(path)"
        MobileFFmpegConfig.setLogDelegate(self)
        MobileFFmpegConfig.setStatisticsDelegate(self)
        if let converter = MobileFFmpeg.executeAsync(command, withCallback: self, andDispatchQueue: .global(qos: .background)) as Int32?{
            debugPrint("converter status code :\(converter)")
        }
    }
    
    //MARK:- Create Output Path For Converted Audio
    func createOutputPath(from url : URL){
        let fileMgr = FileManager.default
        let dirPaths = fileMgr.urls(for: .documentDirectory, in: .userDomainMask)
        let filePath = dirPaths[0].appendingPathComponent("\(url.lastPathComponent.replacingOccurrences(of: " ", with: "")).mp3")
        self.checkFileExistance(in: filePath)
        self.outputPath = filePath
    }
    
    //MARK:- Check File Existance
    func checkFileExistance(in url : URL){
        if fileManager.fileExists(atPath: url.path){
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
        let assets = AVAsset(url: newUrl)
        self.totalTime = assets.duration.seconds
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
