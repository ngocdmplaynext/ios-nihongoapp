//
//  RegisterViewController.swift
//  SoundDemo
//
//  Created by ngocdm on 3/29/17.
//  Copyright © 2017 ngocdm. All rights reserved.
//

import UIKit

class RegisterViewController: UIViewController {
    @IBOutlet weak var tflName: UITextField!
    @IBOutlet weak var tflEmail: UITextField!
    @IBOutlet weak var tflPassword: UITextField!
    @IBOutlet weak var tflPasswordConfirm: UITextField!

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    @IBAction func register(_ sender: UIButton) {
        let email = tflEmail.text ?? ""
        let password = tflPassword.text ?? ""
        let passwordConfirm = tflPasswordConfirm.text ?? ""
        let name = tflName.text ?? ""
        view.endEditing(true)
        
        NetworkManager.shared.register(name: name, email: email, password: password, passwordConfirm: passwordConfirm){ (error) in
            if let error = error {
                var message: String = ""
                if error.code == 422 { // invalid email or password
                    message = "Invalid input field"
                } else {
                    message = error.localizedDescription
                }
                let alert = UIAlertController(title: "Alert", message: message, preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                self.present(alert, animated: true, completion: nil)
            } else {
                self.tflEmail.text = ""
                self.tflPassword.text = ""
                self.tflPasswordConfirm.text = ""
                self.tflName.text = ""
                let message: String = "Successful!\nThis account is being checked. Please wait"
                let alert = UIAlertController(title: "Alert", message: message, preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { [weak self](action) in
                    let _ = self?.navigationController?.popViewController(animated: true)
                }))
                self.present(alert, animated: true, completion: nil)
            }
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}
