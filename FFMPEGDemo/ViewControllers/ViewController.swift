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
    
    //MARK:- Open FilePicker For Select Audio Item
    //    fileprivate func openFilePicker(){
    //        let documentPicker = UIDocumentPickerViewController(forOpeningContentTypes: [UTType.audio])
    //        documentPicker.delegate = self
    //        if #available(iOS 11.0, *) {
    //            documentPicker.allowsMultipleSelection = false
    //        }
    //        self.present(documentPicker, animated: true, completion: nil)
    //    }
    //MARK:- Start Converting Audio From Selected File
    //    fileprivate func ConvertAudioFromPicker(url : URL){
    //        self.convertViewModel.convertAudioFrom(url, with: .medium)
    //    }
    
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
        let url = Bundle.main.url(forResource: "Your_Media_File_Name", withExtension: "Your_Media_File_Extension")
        guard let inputUrl = url else{return}
        self.convertViewModel.convertAudioFrom(url: inputUrl, quality: .low)
    }
    
    
    //MARK:- Open AVPlayerController for playing converted audio
    fileprivate func openAudioPlayer(){
        guard let fileUrl = self.convertViewModel.outputPath else{return}
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
            openAudioPlayer()
        }
    }
    /// Converting Log
    func ExecutionStatus(executionId: Int, level: Int32, message: String!) {
        debugPrint("message : \(String(describing: message))")
    }
    
}

//MARK:- UIDocumentPickerDelegate for selected item from files

//extension ViewController : UIDocumentPickerDelegate{
//    func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
//        guard  let url = urls.first else { return }
//        defer {
//            DispatchQueue.main.async {
//                url.stopAccessingSecurityScopedResource()
//            }
//        }
//        let documentDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
//        let filePath = documentDirectory.appendingPathComponent("\(urls.first!.lastPathComponent.replacingOccurrences(of: " ", with: "")).\(urls.first!.pathExtension)")
//        do {
//            try FileManager.default.copyItem(at: urls.first!.standardizedFileURL, to: filePath)
//        } catch {
//            print(error)
//        }
//        self.ConvertAudioFromPicker(url: filePath)
//    }
//}

