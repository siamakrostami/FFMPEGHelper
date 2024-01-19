//
//  ViewController.swift
//  FFMPEGDemo
//
//  Created by Siamak Rostami on 1/25/21.
//

import AVKit
import ffmpegkit
import UIKit

// MARK: - ViewController

class ViewController: UIViewController {
    // MARK: Internal

    @IBOutlet var progressView: UIProgressView!
    @IBOutlet var progressPercentageLabel: UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()
        ConvertLocalFile()
        bindProgress()
        bindPercentage()
        bindCompletedProgress()
        // Do any additional setup after loading the view.
    }

    // MARK: Private

    private lazy var convertViewModel: ConverterViewModel = .init()
}

extension ViewController {
    // MARK: - Convert Local File From Main Bundle

    private func ConvertLocalFile() {
        guard let url = Bundle.main.url(forResource: "test", withExtension: "mp4") else {
            return
        }
        guard let image = URL(string: "https://prod.cloud.rockstargames.com/crews/sc/8985/20777580/publish/emblem/emblem_256.png") else {
            return
        }
        convertViewModel.addWatermarkToVideo(video: url, watermark: image)
    }

    private func bindProgress() {
        convertViewModel.$progress
            .subscribe(on: DispatchQueue.main)
            .sink { [weak self] progress in
                DispatchQueue.main.async {
                    self?.progressView.setProgress(Float(progress ?? 0), animated: true)
                }
            }.store(in: &convertViewModel.cancellables)
    }

    private func bindPercentage() {
        convertViewModel.$percentage
            .subscribe(on: DispatchQueue.main)
            .sink { [weak self] percentage in
                DispatchQueue.main.async {
                    self?.progressPercentageLabel.text = "\(percentage?.rounded() ?? 0) %"
                }
            }.store(in: &convertViewModel.cancellables)
    }

    private func bindCompletedProgress() {
        convertViewModel.$completedAtUrl
            .subscribe(on: DispatchQueue.main)
            .sink { [weak self] url in
                DispatchQueue.main.async {
                    guard let url = url else {
                        return
                    }
                    let player = AVPlayer(url: url)
                    let pc = AVPlayerViewController()
                    pc.player = player
                    self?.present(pc, animated: true) {
                        pc.player?.play()
                    }
                }

            }.store(in: &convertViewModel.cancellables)
    }
}
