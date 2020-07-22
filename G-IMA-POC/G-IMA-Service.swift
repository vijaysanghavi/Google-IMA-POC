//
//  G-IMA-Service.swift
//  G-IMA-POC
//
//  Created by Vijay Sanghavi on 22/07/20.
//  Copyright © 2020 Vijay Sanghavi. All rights reserved.
//

import AVFoundation
import UIKit
import AVKit

protocol GIMAServiceDelegate {
    func adWillPlay()
    func adPlayed()
}

final class GIMAService {
    
    private lazy var background: UIView = {
        let background = UIView()
        background.backgroundColor = .black
        return background
    }()
    
    private var viewController: UIViewController!
    private var playerViewController: AVPlayerViewController!
    var delegate: GIMAServiceDelegate?
    public var contentUrl : String = "https://devstreaming-cdn.apple.com/videos/streaming/examples/img_bipbop_adv_example_fmp4/master.m3u8"
    
    init(vc instance: UIViewController) {
        viewController = instance
        self.delegate = viewController as? GIMAServiceDelegate
    }
}

//Core work
extension GIMAService {
    
    public func play() {
        setupBackground()
        setupContentPlayed()
    }
    
    
    func setupBackground() {
        viewController.view.backgroundColor = .black
        viewController.view.addSubview(background)
        background.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            self.background.topAnchor.constraint(equalTo: self.viewController.view.topAnchor),
            self.background.bottomAnchor.constraint(equalTo: self.viewController.view.bottomAnchor),
            self.background.leadingAnchor.constraint(equalTo: self.viewController.view.leadingAnchor),
            self.background.trailingAnchor.constraint(equalTo: self.viewController.view.trailingAnchor)
        ])
    }
    
    private func setupContentPlayed() {
        // Load AVPlayer with path to your content.
        if let contentURL = URL(string: self.contentUrl) {
            let player = AVPlayer(url: contentURL)
            playerViewController = AVPlayerViewController()
            playerViewController.player = player
        }
        
        showContentPlayer()
    }
    
    private func showContentPlayer() {
        self.delegate?.adWillPlay()
        viewController.addChild(playerViewController)
        playerViewController.view.frame = viewController.view.bounds
        viewController.view.insertSubview(playerViewController.view, aboveSubview: background)
        playerViewController.didMove(toParent: viewController)
        
        playerViewController.player?.play()
    }
    
    private func hideContentPlayer() {
        playerViewController.player?.pause()
        self.delegate?.adPlayed()
        background.removeFromSuperview()
        playerViewController.willMove(toParent:nil)
        playerViewController.view.removeFromSuperview()
        playerViewController.removeFromParent()
    }
    
}
