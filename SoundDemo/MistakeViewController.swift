//
//  MistakeViewController.swift
//  SoundDemo
//
//  Created by ngocdm on 2/24/17.
//  Copyright © 2017 ngocdm. All rights reserved.
//

import UIKit
import AVFoundation

class MistakeViewController: UIViewController {
    var mistakeString: String = ""
    
    let synth = AVSpeechSynthesizer()
    var myUtterance = AVSpeechUtterance(string: "")
    @IBOutlet weak var lbTitle: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        lbTitle.text = mistakeString
        
        let audioSession = AVAudioSession.sharedInstance()
        do {
            
            try! audioSession.setCategory(AVAudioSessionCategoryPlayAndRecord)
            try audioSession.setMode(AVAudioSessionModeSpokenAudio)
            try audioSession.setActive(true, with: .notifyOthersOnDeactivation)
            
            let currentRoute = AVAudioSession.sharedInstance().currentRoute
            for description in currentRoute.outputs {
                if description.portType == AVAudioSessionPortHeadphones {
                    try audioSession.overrideOutputAudioPort(AVAudioSessionPortOverride.none)
                    print("headphone plugged in")
                } else {
                    print("headphone pulled out")
                    try audioSession.overrideOutputAudioPort(AVAudioSessionPortOverride.speaker)
                }
            }
            
        } catch {
            print("audioSession properties weren't set because of an error.")
        }

        // Do any additional setup after loading the view.
    }

    @IBAction func play(_ sender: UIButton) {
        myUtterance = AVSpeechUtterance(string: mistakeString)
        myUtterance.voice = AVSpeechSynthesisVoice(language: "ja-JP")
        myUtterance.rate = 0.4
        synth.speak(myUtterance)
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
