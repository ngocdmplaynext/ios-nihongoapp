//
//  LoginViewController.swift
//  SoundDemo
//
//  Created by ngocdm on 3/29/17.
//  Copyright © 2017 ngocdm. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController {
    @IBOutlet weak var tflEmail: UITextField!
    @IBOutlet weak var tflPassword: UITextField!

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    @IBAction func login(_ sender: UIButton) {
        let email = tflEmail.text ?? ""
        let password = tflPassword.text ?? ""
        NetworkManager.shared.login(email: email, password: password) { (authToken, name, type, error) in
            if let error = error {
                var message: String = ""
                if error.code == 422 { // invalid email or password
                    message = "Invalid email or password"
                } else if error.code == 423 { //account is not active
                    message = "This account is being checked. Please wait"
                } else {
                    message = error.localizedDescription
                }
                let alert = UIAlertController(title: "Alert", message: message, preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                self.present(alert, animated: true, completion: nil)
            } else if let authToken = authToken, let name = name, let type = type {
                UserDefault.shared.setToken(authToken)
                UserDefault.shared.setUserName(name)
                UserDefault.shared.setUserType(type)
                
                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                if let controller = storyboard.instantiateViewController(withIdentifier: "kSWRevealViewController") as? SWRevealViewController {
                    self.present(controller, animated: true, completion: nil)
                }
            }
        }
    }
    
    @IBAction func register(_ sender: UIButton) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        if let controller = storyboard.instantiateViewController(withIdentifier: "kRegisterViewController") as? RegisterViewController {
            self.navigationController?.pushViewController(controller, animated: true)
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}
