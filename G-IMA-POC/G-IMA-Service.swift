//
//  G-IMA-Service.swift
//  G-IMA-POC
//
//  Created by Vijay Sanghavi on 22/07/20.
//  Copyright © 2020 Vijay Sanghavi. All rights reserved.
//

import UIKit
import AVKit
import GoogleInteractiveMediaAds

protocol GIMAServiceDelegate: AnyObject {
    func adWillPlay()
    func adPlayed()
}

final class GIMAService: NSObject {
    
    //MARK: - private lazy
    private lazy var background: UIView = {
        let background = UIView()
        background.backgroundColor = .black
        return background
    }()
    
    //MARK: - private
    private weak var viewController: UIViewController!
    private var playerViewController: AVPlayerViewController!
    private var contentPlayhead: IMAAVPlayerContentPlayhead?
    private var adsLoader: IMAAdsLoader!
    private var adsManager: IMAAdsManager!
    
    //MARK: - weak delegates
    weak var delegate: GIMAServiceDelegate?
    
    //MARK: - public
    public var adTagUrl: String = "https://pubads.g.doubleclick.net/gampad/ads?sz=640x480&iu=/124319096/external/single_ad_samples&ciu_szs=300x250&impl=s&gdfp_req=1&env=vp&output=vast&unviewed_position_start=1&cust_params=deployment%3Ddevsite%26sample_ct%3Dlinear&correlator="
    public var contentUrl : String = "https://devstreaming-cdn.apple.com/videos/streaming/examples/img_bipbop_adv_example_fmp4/master.m3u8"
    
    //MARK: - initializer
    init(vc instance: UIViewController) {
        viewController = instance
        self.delegate = viewController as? GIMAServiceDelegate
    }
    
    deinit {
        if let viewController = viewController {
            NotificationCenter.default.removeObserver(viewController)
        }
    }
}

//Core work
extension GIMAService {
    
    public func play( completion: @escaping ()->()) {
        setupBackground()
        setupContentPlayed()
        setUpAdsLoader()
        completion()
    }
    
    private func setUpAdsLoader() {
        adsLoader = IMAAdsLoader(settings: nil)
        adsLoader.delegate = self
    }
    
    public func requestAds() {
        // Create ad display container for ad rendering.
        let adDisplayContainer = IMAAdDisplayContainer(adContainer: viewController.view)
        // Create an ad request with our ad tag, display container, and optional user context.
        let request = IMAAdsRequest(
            adTagUrl: adTagUrl,
            adDisplayContainer: adDisplayContainer,
            contentPlayhead: contentPlayhead,
            userContext: nil)
        
        adsLoader.requestAds(with: request)
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
            
            contentPlayhead = IMAAVPlayerContentPlayhead(avPlayer: player)
            NotificationCenter.default.addObserver(
                self,
                selector: #selector(GIMAService.contentDidFinishPlaying(_:)),
                name: NSNotification.Name.AVPlayerItemDidPlayToEndTime,
                object: player.currentItem);
            
            showContentPlayer()
        }
    }
    
    private func showContentPlayer() {
        self.delegate?.adWillPlay()
        viewController.addChild(playerViewController)
        playerViewController.view.frame = viewController.view.bounds
        viewController.view.insertSubview(playerViewController.view, aboveSubview: background)
        playerViewController.didMove(toParent: viewController)
        
        playerViewController.player?.play()
    }
    
    @objc func contentDidFinishPlaying(_ notification: Notification) {
        adsLoader.contentComplete()
        hideContentPlayer()
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


extension GIMAService: IMAAdsLoaderDelegate {
    
    func adsLoader(_ loader: IMAAdsLoader!, adsLoadedWith adsLoadedData: IMAAdsLoadedData!) {
        adsManager = adsLoadedData.adsManager
        adsManager.initialize(with: nil)
        adsManager.delegate = self
    }
    
    func adsLoader(_ loader: IMAAdsLoader!, failedWith adErrorData: IMAAdLoadingErrorData!) {
        print("Error loading ads: " + adErrorData.adError.message)
        showContentPlayer()
        playerViewController.player?.play()
    }
    
}

extension GIMAService: IMAAdsManagerDelegate {
    func adsManagerDidRequestContentPause(_ adsManager: IMAAdsManager!) {
        // Pause the content for the SDK to play ads.
        playerViewController.player?.pause()
        hideContentPlayer()
    }
    
    func adsManagerDidRequestContentResume(_ adsManager: IMAAdsManager!) {
        // Resume the content since the SDK is done playing ads (at least for now).
        showContentPlayer()
        playerViewController.player?.play()
    }
    
    func adsManager(_ adsManager: IMAAdsManager!, didReceive error: IMAAdError!) {
        // Fall back to playing content
        print("AdsManager error: " + error.message)
        showContentPlayer()
        playerViewController.player?.play()
    }
    
    func adsManager(_ adsManager: IMAAdsManager!, didReceive event: IMAAdEvent!) {
        // Play each ad once it has been loaded
        if event.type == IMAAdEventType.LOADED {
            adsManager.start()
        }
    }
}
