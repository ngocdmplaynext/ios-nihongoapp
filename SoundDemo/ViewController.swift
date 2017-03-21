//
//  ViewController.swift
//  SoundDemo
//
//  Created by ngocdm on 2/7/17.
//  Copyright © 2017 ngocdm. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var menuBtn: UIBarButtonItem!
    @IBOutlet weak var tableView: UITableView!
    var themes = [Theme]()
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        self.title = "カテゴリー"
        
        if revealViewController() != nil {
            menuBtn.target = revealViewController()
            menuBtn.action = #selector(SWRevealViewController.revealToggle(_:))
            view.addGestureRecognizer(self.revealViewController().panGestureRecognizer())
            view.addGestureRecognizer(self.revealViewController().tapGestureRecognizer())
        }
        
        if !DBManager.shared.hasThemeData() {
            NetworkManager.shared.getInitThemeData(completion: { (themes, error) in
                if let themes = themes {
                    self.themes = themes
                    self.tableView.reloadData()
                } else {
                    print("can't load init theme data")
                }
            })
        } else {
            self.themes = DBManager.shared.loadThemesData()
            self.tableView.reloadData()
        }
    }
        
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

extension ViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let theme = themes[indexPath.row]
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        if let controller = storyboard.instantiateViewController(withIdentifier: "kDeckViewController") as? DeckViewController {
            controller.themeId = theme.themeId
            self.navigationController?.pushViewController(controller, animated: true)
        }
    }
}

extension ViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return themes.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return heightForView(text: themes[indexPath.row].name, font: UIFont.systemFont(ofSize: 17), width: tableView.frame.size.width - 16) + 20
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: TextTableViewCell = tableView.dequeueReusableCell(withIdentifier: TextTableViewCell.cellIdentifier, for: indexPath) as! TextTableViewCell
        cell.label?.text = themes[indexPath.row].name
        return cell
    }
}
