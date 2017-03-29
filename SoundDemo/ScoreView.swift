//
//  ScoreView.swift
//  SoundDemo
//
//  Created by ngocdm on 3/24/17.
//  Copyright © 2017 ngocdm. All rights reserved.
//

import UIKit

class ScoreView: UIView {
    public var btnNext: UIButton!
    public var btnMistake: UIButton!
    private var lbScore: UILabel!
    public var lbResult: UILabel!
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = UIColor.clear
        
        let alphaView = UIView(frame: self.bounds)
        alphaView.alpha = 0.4
        alphaView.backgroundColor = UIColor.black
        self.addSubview(alphaView)
        
        btnNext = UIButton(frame: CGRect(x: 0, y: frame.size.height - 50, width: frame.size.width, height: 50))
        btnNext.setTitle("つぎへ", for: .normal)
        btnNext.setTitleColor(UIColor.blue, for: .normal)
        btnNext.backgroundColor = UIColor.white
        btnNext.addTarget(self, action: #selector(tapView), for: .touchUpInside)
        self.addSubview(btnNext)
        
        btnMistake = UIButton(frame: CGRect(x: 0, y: frame.size.height - 110, width: frame.size.width, height: 50))
        btnMistake.setTitleColor(UIColor.blue, for: .normal)
        btnMistake.backgroundColor = UIColor.white
        btnMistake.setTitle("ミスした箇所を見る", for: .normal)
        self.addSubview(btnMistake)
        
        lbScore = UILabel(frame: CGRect(x: 0, y: frame.size.height / 2 - 20, width: frame.size.width, height: 50))
        lbScore.textAlignment = .center
        lbScore.font = UIFont.boldSystemFont(ofSize: 30)
        lbScore.textColor = UIColor.red
        lbScore.text = "SCORE"
        self.addSubview(lbScore)
        
        lbResult = UILabel(frame: CGRect(x: 0, y: frame.size.height / 2 + 50, width: frame.size.width, height: 50))
        lbResult.textAlignment = .center
        lbResult.font = UIFont.boldSystemFont(ofSize: 20)
        lbResult.textColor = UIColor.red
        lbResult.text = "0"
        self.addSubview(lbResult)
    }
    
    func tapView() {
        self.removeFromSuperview()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
