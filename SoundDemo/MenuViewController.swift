//
//  MenuViewController.swift
//  SoundDemo
//
//  Created by ngocdm on 2/21/17.
//  Copyright © 2017 ngocdm. All rights reserved.
//

import UIKit

class MenuViewController: UIViewController {
    @IBOutlet weak var tableView: UITableView!
    var isTeacher: Bool = false
    
    let menuCellIdentifier = "menuCell"
    var items = [String]()
    

    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.register(UITableViewCell.self, forCellReuseIdentifier: menuCellIdentifier)
        isTeacher = (UserDefault.shared.getUserType() ?? student) == teacher
        if isTeacher {
            items = ["Logout", "Home", "My Topics"]
        } else {
            items = ["Logout", "Home", "Teacher"]
        }
        
        self.tableView.reloadData()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}

extension MenuViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: UITableViewCell = tableView.dequeueReusableCell(withIdentifier: menuCellIdentifier, for: indexPath)
        cell.textLabel?.text = items[indexPath.row]
        return cell
    }
}


extension MenuViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        switch indexPath.row {
        case 0:
            let alert = UIAlertController(title: "Logout", message: "ログアウトしてもよろしいですか", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "はい", style: .default, handler: { (action) in
                UserDefault.shared.resetToken()
                cleanDocumentsDirectory(hasPrefix: "card")
                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                if let controller = storyboard.instantiateViewController(withIdentifier: "kLoginViewController") as? LoginViewController {
                    let nav = UINavigationController(rootViewController: controller)
                    self.present(nav, animated: true, completion: nil)
                }
            }))
            
            alert.addAction(UIAlertAction(title: "いえ", style: .cancel, handler: nil))
            self.present(alert, animated: true, completion: nil)
        case 1:
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            if let controller = storyboard.instantiateViewController(withIdentifier: "kNavViewController") as? UINavigationController {
                self.revealViewController().pushFrontViewController(controller, animated: true)
            }
        case 2:
            if isTeacher {
                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                if let controller = storyboard.instantiateViewController(withIdentifier: "kMyDeckViewController") as? MyDeckViewController {
                    let nav = UINavigationController(rootViewController: controller)
                    self.revealViewController().pushFrontViewController(nav, animated: true)
                }
            } else {
                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                if let controller = storyboard.instantiateViewController(withIdentifier: "kTeacherViewController") as? TeacherViewController {
                    let nav = UINavigationController(rootViewController: controller)
                    self.revealViewController().pushFrontViewController(nav, animated: true)
                }
            }
        default:
            break
        }
    }
}
