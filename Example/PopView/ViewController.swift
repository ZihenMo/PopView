//
//  ViewController.swift
//  PopView
//
//  Created by mozihen on 08/04/2022.
//  Copyright (c) 2022 mozihen. All rights reserved.
//

import UIKit
import PopView
import SFSafeSymbols

class View: UIView {

    override init(frame: CGRect) {
        super.init(frame: frame)
        makeUI()
        let tap  = UITapGestureRecognizer(target: self, action: #selector(dismiss(_:)))
        tap.delaysTouchesBegan = true
        addGestureRecognizer(tap)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    let maskLayer = CAShapeLayer()
    
    func makeUI() {
        backgroundColor = .blue
    }
    
    func show(_ point: CGPoint) {
//        maskLayer.frame = bounds
        maskLayer.fillColor = UIColor.orange.cgColor
        maskLayer.backgroundColor = UIColor.red.cgColor
        let rect = CGRect(x: point.x - 50, y: point.y - 50, width: 100, height: 100)
        let path = UIBezierPath(roundedRect: rect, cornerRadius: 8)
        maskLayer.path = path.cgPath
        layer.mask = maskLayer
    }
    
    @objc func dismiss(_ sender: Any) {
        self.removeFromSuperview()
    }
}

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        let images: [UIImage] = [
            .init(systemSymbol: .textViewfinder).withTintColor(.lightGray, renderingMode: .alwaysOriginal),
            .init(systemSymbol: .handsSparkles).withTintColor(.lightGray, renderingMode: .alwaysOriginal),
            .init(systemSymbol: .brainHeadProfile).withTintColor(.lightGray, renderingMode: .alwaysOriginal)
        ]
        let titles = ["扫一扫", "摇一摇", "大猪头"]
        let actions = zip(titles, images)
            .map { title, image in
                PopView.Action(title: title, icon: image, handle: { print(title) } )
            }
        let popView = PopView(actions)
        popView.frame = view.bounds
        popView.show(at: touches.first?.location(in: view) ?? .zero)
        
        
//        let v = View(frame: view.bounds)
//        v.show(touches.first?.location(in: view) ?? .zero)
//        view.addSubview(v)
    }
    
    @objc func inject() {
        
    }
}

