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
        if revealViewController() != nil {
            menuBtn.target = revealViewController()
            menuBtn.action = "revealToggle:"
            view.addGestureRecognizer(self.revealViewController().panGestureRecognizer())
            view.addGestureRecognizer(self.revealViewController().tapGestureRecognizer())
        }
        
        initData()
    }

    func initData() {
        var decks = [Deck]()
        let card = Card(name: "あ久しぶり", bestScore: 0)
        let card1 = Card(name: "おはよう", bestScore: 0)
        
        decks.append(Deck(name: "あ久しぶり", card: card))
        decks.append(Deck(name: "おはよう", card: card1))
        
        themes.append(Theme(name: "挨拶", decks: decks))
    }
    
        
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

extension ViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        if let controller = storyboard.instantiateViewController(withIdentifier: "kDeckViewController") as? DeckViewController {
            controller.decks = themes[indexPath.row].decks
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
