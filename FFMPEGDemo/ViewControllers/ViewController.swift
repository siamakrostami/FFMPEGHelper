//
//  ViewController.swift
//  FFMPEGDemo
//
//  Created by Siamak Rostami on 1/25/21.
//

import UIKit
import mobileffmpeg
import AVKit

class ViewController: UIViewController {
    
    @IBOutlet weak var progressView: UIProgressView!
    @IBOutlet weak var progressPercentageLabel: UILabel!
    var convertViewModel : ConverterViewModel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initData()
        // Do any additional setup after loading the view.
    }
}

extension ViewController{
    //MARK:- Initialize ViewModel
    fileprivate func initData(){
        self.convertViewModel = ConverterViewModel()
        self.convertViewModel.delegate = self
        self.ConvertLocalFile()
    }
    
    //MARK:- Convert Local File From Main Bundle
    func ConvertLocalFile(){
       // let url = Bundle.main.url(forResource: "test", withExtension: "mp3")
       // guard let inputUrl = url else{return}
        //https://bitdash-a.akamaihd.net/content/MI201109210084_1/m3u8s/f08e80da-bf1d-4e3d-8899-f0f6155f6efa.m3u8
   // https://1307889028.vod2.myqcloud.com/4985057avodger1307889028/995c8f26387702294028133240/kERQdXwS1z8A.mp4
    //https://api.mp4.to/static/downloads/99e4537e67a540769/bd44dc72-b38b-49ea-9d04-80d0dd84a8aa.m3u8
        guard let url = URL(string: "https://1307889028.vod2.myqcloud.com/8649c42fvodhk1307889028/2b97f390387702294030708591/lLwiHBAJlRMA.mp4") else {return}
        guard let image = URL(string: "https://prod.cloud.rockstargames.com/crews/sc/8985/20777580/publish/emblem/emblem_256.png") else {return}
        self.convertViewModel.addWatermarkToVideo(video: url, watermark: image)
        //self.convertViewModel.addWatermarkToVideo(video: url, watermark: image)
       // self.convertViewModel.convertVideoFrom(url: inputUrl)
    }
    
    
    //MARK:- Open AVPlayerController for playing converted audio
    fileprivate func openAudioPlayer(){
        guard let fileUrl = self.convertViewModel.outputPath else{return}
        debugPrint(fileUrl)
        DispatchQueue.main.async {
            let player = AVPlayer(url: fileUrl)
            let pc = AVPlayerViewController()
            pc.player = player
            self.present(pc, animated: true) {
                pc.player?.play()
            }
        }
    }
    
    //MARK:- Calculate ProgressBar Progress and Progress Percentage
    fileprivate func calculateProgressPercentage(current : Int32){
        guard let totalTime = self.convertViewModel.totalTime else{return}
        let progress = (Double(current) / totalTime) / 1000
        let percent = (Double(current) / totalTime) / 10
        self.setProgressData(progress: progress, percent: percent)
        debugPrint("percentage : \(progress)")
    }
    
    //MARK:- Update UI
    fileprivate func setProgressData(progress : Double , percent : Double){
        DispatchQueue.main.async {
            self.progressView.setProgress(Float(progress), animated: true)
            self.progressPercentageLabel.text = "\(percent.rounded()) %"
        }
        
    }
}

//MARK:- FFMPEG Progress Protocols
extension ViewController : ConvertProgressProtocols{
    /// Converting Progress
    func ConvertProgress(progress: Int32) {
        calculateProgressPercentage(current: progress)
    }
    /// Converting Status
    func ConvertStatus(status: Int32) {
        debugPrint("status : \(status)")
        if status == RETURN_CODE_SUCCESS{
            if convertViewModel.isConvert{
                guard let image = URL(string: "https://prod.cloud.rockstargames.com/crews/sc/8985/20777580/publish/emblem/emblem_256.png") else {return}
                guard let path = self.convertViewModel.tempOutputPath else {return}
                self.convertViewModel.addWatermarkToVideo(video: path, watermark: image)
            }else{
                self.openAudioPlayer()
            }

        }
    }
    /// Converting Log
    func ExecutionStatus(executionId: Int, level: Int32, message: String!) {
        debugPrint("message : \(String(describing: message))")
    }
    
}


