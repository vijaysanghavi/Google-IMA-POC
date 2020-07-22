//
//  ViewController.swift
//  G-IMA-POC
//
//  Created by Vijay Sanghavi on 22/07/20.
//  Copyright © 2020 Vijay Sanghavi. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    private lazy var button: UIButton = {
        let button = UIButton()
        button.setTitle("Hit me!!", for: .normal)
        button.setTitleColor(.red, for: .normal)
        button.backgroundColor = .clear
        return button
    }()
    
    private lazy var gIMAService: GIMAService = {
        let service = GIMAService(vc: self)
        service.delegate = self
        return service
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.button.addTarget(self, action: #selector(ViewController.hitme), for: .touchUpInside)
        self.view.addSubview(button)
        self.button.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            self.button.centerXAnchor.constraint(equalTo: self.view.centerXAnchor),
            self.button.centerYAnchor.constraint(equalTo: self.view.centerYAnchor)
        ])
    }

    @objc func hitme() {
        self.gIMAService.play()
    }

}

//MARK: - Core work
extension ViewController {
    
}

//MARK: - Ad service delegate
extension ViewController: GIMAServiceDelegate {
    func adWillPlay() {
        print("adWillPlay")
    }
    
    func adPlayed() {
        print("adPlayed")
    }
}
