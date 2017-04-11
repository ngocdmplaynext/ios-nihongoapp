//
//  SplashViewController.swift
//  SoundDemo
//
//  Created by ngocdm on 3/29/17.
//  Copyright © 2017 ngocdm. All rights reserved.
//

import UIKit

class SplashViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if UserDefault.shared.getToken() != nil {
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            if let controller = storyboard.instantiateViewController(withIdentifier: "kSWRevealViewController") as? SWRevealViewController {
                self.present(controller, animated: true, completion: nil)
            }
        } else {
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            if let controller = storyboard.instantiateViewController(withIdentifier: "kLoginViewController") as? LoginViewController {
                let nav = UINavigationController(rootViewController: controller)
                self.present(nav, animated: true, completion: nil)
            }
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}
