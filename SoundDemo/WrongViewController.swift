//
//  WrongViewController.swift
//  SoundDemo
//
//  Created by ngocdm on 3/24/17.
//  Copyright © 2017 ngocdm. All rights reserved.
//

import UIKit

class WrongViewController: UIViewController {

    var attributedString: NSAttributedString = NSAttributedString()
    var lbText: YYLabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.white

        let size = CGSize(width: self.view.frame.size.width, height: CGFloat(FLT_MAX))
        let layout = YYTextLayout(containerSize: size, text: attributedString)
        
        
        lbText = YYLabel(frame: CGRect(x: 0, y: self.view.frame.size.height / 2 - 15, width: self.view.frame.size.width, height: (layout?.textBoundingSize.height  ?? 30) + 5))
        lbText.numberOfLines = 0
        lbText.attributedText = attributedString
        
        self.view.addSubview(lbText)
        
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}
