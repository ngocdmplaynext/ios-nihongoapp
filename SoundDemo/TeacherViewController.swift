//
//  TeacherViewController.swift
//  SoundDemo
//
//  Created by ngocdm on 4/5/17.
//  Copyright © 2017 ngocdm. All rights reserved.
//

import UIKit

class TeacherViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    var users: [User] = [User]()
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Teachers"
        
        if revealViewController() != nil {
            let menuBtn = UIBarButtonItem(image: UIImage(named: "reveal-icon"), style: .plain, target: revealViewController(), action: #selector(SWRevealViewController.revealToggle(_:)))
            
            self.navigationItem.leftBarButtonItem = menuBtn
            
            view.addGestureRecognizer(self.revealViewController().panGestureRecognizer())
            view.addGestureRecognizer(self.revealViewController().tapGestureRecognizer())
        }
        
        NetworkManager.shared.teachers { [weak self](users, error) in
            if let users = users {
                self?.users = users
                self?.tableView.reloadData()
            }
        }

    }
    
    func bookmarkClicked(_ btn: UIButton) {
        if let cell = btn.superview?.superview as? UITableViewCell, let indexPath = tableView.indexPath(for: cell) {
            let user = users[indexPath.row]
            if user.bookmark {
                NetworkManager.shared.unbookmarks(user: user, completion: { [weak self](error) in
                    if let error = error {
                        var message: String = ""
                        if error.code == 1000 {
                            message = "Session invalid"
                        } else if error.code == 1001 {
                            message = "Can not find bookmarked user"
                        }
                        let alert = UIAlertController(title: "Alert", message: message, preferredStyle: .alert)
                        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                        self?.present(alert, animated: true, completion: nil)
                    } else {
                        btn.setTitle("Bookmark", for: .normal)
                        let newUser = User(userId: user.userId, name: user.name, bookmark: false)
                        self?.users[indexPath.row] = newUser
                    }
                })
            } else {
                NetworkManager.shared.bookmarks(user: user, completion: { [weak self](error) in
                    if let error = error {
                        var message: String = ""
                        if error.code == 1000 {
                            message = "Session invalid"
                        } else if error.code == 1001 {
                            message = "This user is bookmarked"
                        }
                        let alert = UIAlertController(title: "Alert", message: message, preferredStyle: .alert)
                        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                        self?.present(alert, animated: true, completion: nil)
                    } else {
                        btn.setTitle("Unbookmark", for: .normal)
                        let newUser = User(userId: user.userId, name: user.name, bookmark: true)
                        self?.users[indexPath.row] = newUser
                    }
                })
            }
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
    }

}

extension TeacherViewController: UITableViewDelegate {
    
}

extension TeacherViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return users.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: TeacherTableViewCell = tableView.dequeueReusableCell(withIdentifier: TeacherTableViewCell.cellIdentifier, for: indexPath) as! TeacherTableViewCell
        let user = users[indexPath.row]
        cell.lbName?.text = user.name
        user.bookmark ? cell.btnBookmark.setTitle("Unbookmark", for: .normal) : cell.btnBookmark.setTitle("Bookmark", for: .normal)
        cell.btnBookmark.addTarget(self, action: #selector(bookmarkClicked(_:)), for: .touchUpInside)
        return cell
    }
}
