//
//  SentenceViewController.swift
//  SoundDemo
//
//  Created by ngocdm on 3/21/17.
//  Copyright © 2017 ngocdm. All rights reserved.
//

import AVFoundation
import UIKit
import Speech
import PlayListPlayer
import SVProgressHUD

class SentenceViewController: UIViewController, SFSpeechRecognizerDelegate, AVAudioRecorderDelegate {
    var deckId: Int = 0
    var cards: [Card] = [Card]()
    var currentIndexPath = IndexPath()
    var resultAttributedString = NSMutableAttributedString()
    
    var enableSpeech: Bool = false
    
    var sampleSound: AVAudioPlayer?
    
    var recordingSession: AVAudioSession!
    var audioRecorder: AVAudioRecorder!
    private var speechRecognizer: SFSpeechRecognizer!
    private var recognitionRequest: SFSpeechAudioBufferRecognitionRequest!
    private var recognitionTask: SFSpeechRecognitionTask!
    private let defaultLocale = Locale(identifier: "ja-JA")

    @IBOutlet weak var btnPlayAll: UIButton!
    @IBOutlet weak var tableView: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
//        if !DBManager.shared.hasCardData(byDeckId: deckId) {
//            NetworkManager.shared.getInitCardData(byDeckId: deckId, completion: { (cards, error) in
//                if let cards = cards {
//                    self.cards = cards
//                    self.tableView.reloadData()
//                } else {
//                    print("can't load init card data")
//                }
//            })
//        } else {
//            self.cards = DBManager.shared.loadCardsData(byDeckId: deckId)
//            self.tableView.reloadData()
//        }
        
        
        NetworkManager.shared.getInitCardData(byDeckId: deckId, completion: { (cards, error) in
            if let cards = cards {
                self.cards = cards
                self.tableView.reloadData()
                
                var isFileExist: Bool = true
                
                for card in cards {
                    isFileExist = isFileExist && fileExist(atPath: filePath(withName: "card\(card.cardId).m4a").path)
                }
                
                if !isFileExist {
                    SVProgressHUD.show()
                    NetworkManager.shared.downloadListCardAudioUrl(cards: cards, completion: { (error) in
                        if error != nil {
                            print ("download error")
                        } else {
                            print ("download success")
                        }
                        SVProgressHUD.dismiss()
                    })
                }
            } else {
                print("can't load init card data")
            }
        })
        
        recordingSession = AVAudioSession.sharedInstance()
        
        recordingSession.requestRecordPermission() { [unowned self] allowed in
            DispatchQueue.main.async {
                if allowed {
                    self.enableSpeech = true
                } else {
                    self.enableSpeech = false
                }
                self.tableView.reloadData()
            }
        }
        
        prepareRecognizer(locale: defaultLocale)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        SFSpeechRecognizer.requestAuthorization { authStatus in
            /*
             The callback may not be called on the main thread. Add an
             operation to the main queue to update the record button's state.
             */
            OperationQueue.main.addOperation {
                switch authStatus {
                case .authorized:
                    self.enableSpeech = true
                    
                case .denied:
                    self.enableSpeech = false
                    
                case .restricted:
                    self.enableSpeech = false
                    
                case .notDetermined:
                    self.enableSpeech = false
                }
                self.tableView.reloadData()
            }
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if PlayListPlayer.sharedInstance.isPlaying() {
            PlayListPlayer.sharedInstance.pause()
            btnPlayAll.setTitle("Play", for: .normal)
        }
    }
    
    private func prepareRecognizer(locale: Locale) {
        speechRecognizer = SFSpeechRecognizer(locale: locale)!
        speechRecognizer.delegate = self
    }
    
    func record(_ btn: UIButton) {
        let cell = btn.superview?.superview as? UITableViewCell
        if let cell = cell {
            if let indexPath = self.tableView.indexPath(for: cell) {
                self.currentIndexPath = indexPath
            }
        }
        startRecording()
    }
    
    func stopRecord() {
        finishRecording(success: true)
    }
    
    func startRecording() {
        let audioFilename = getDocumentsDirectory().appendingPathComponent("recording.m4a")
        
        let settings = [
            AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
            AVSampleRateKey: 12000,
            AVNumberOfChannelsKey: 1,
            AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue
        ]
        
        do {
            audioRecorder = try AVAudioRecorder(url: audioFilename, settings: settings)
            audioRecorder.delegate = self
            audioRecorder.prepareToRecord()
            
        } catch {
            finishRecording(success: false)
        }
        
        do {
            try recordingSession.setCategory(AVAudioSessionCategoryPlayAndRecord)
            try recordingSession.setActive(true)
            audioRecorder.record()
        } catch let error as NSError {
            print ("\(error.localizedDescription)")
        }
        
    }
    
    func finishRecording(success: Bool) {
        audioRecorder.stop()
        audioRecorder = nil
        if success {
            let audioFilename = getDocumentsDirectory().appendingPathComponent("recording.m4a")
            recognizeFile(url: audioFilename)
        } else {
            let alert = UIAlertController(title: "Alert", message: "Fail to record", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    func recognizeFile(url:URL) {
        
        if !speechRecognizer.isAvailable {
            // The recognizer is not available right now
            let alert = UIAlertController(title: "Alert", message: "Please turn on siri", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            self.present(alert, animated: true, completion: nil)
            return
        }
        
        let request = SFSpeechURLRecognitionRequest(url: url)
        request.shouldReportPartialResults = false
        speechRecognizer.recognitionTask(with: request) { (result, error) in
            guard let result = result else {
                // Recognition failed, so check error for details and handle it
                print("\(error?.localizedDescription)")
                return
            }
            
            var score: Float = 0
            var count: Int = 0
            var currentIndex: Int = 0
            var numberCharFinded: Int = 0
            var hasMistake: Bool = false
            
            let symbols = ["！","、","。","？"]
            let currentCard = self.cards[self.currentIndexPath.row]
            let textStr = currentCard.name
            
            let attributedString = NSMutableAttributedString(string:textStr)
            attributedString.addAttribute(NSForegroundColorAttributeName, value: UIColor.red , range: NSRange(location: 0, length: textStr.characters.count))
            for symbol in symbols {
                let ranges = textStr.ranges(of: symbol)
                for range in ranges {
                    attributedString.addAttribute(NSForegroundColorAttributeName, value: UIColor.black, range: range)
                }
            }
            
            let stringRomaji = MeCabUtil.shared().stringJapanese(toRomaji: textStr, withWordSeperator: "", unuseChar: symbols)
            
            var arrStrRomaji = [[String]]()
            result.bestTranscription.segments.forEach {
                print("--- SEGMENT ---")
                print("substring            : \($0.substring)")
                print("timestamp            : \($0.timestamp)")
                print("duration             : \($0.duration)")
                print("confidence           : \($0.confidence)")
                print("alternativeSubstrings: \($0.alternativeSubstrings)")
                print("")
                score = score + ($0.confidence / 0.93) * 100
                let arrItem = [$0.substring] + $0.alternativeSubstrings
                var arrItemRomajiNoGrammer = arrItem.map({
                    return ($0 as NSString).transliteratingJapaneseToRomaji() ?? ""
                })
                
                let arrItemRomajiUseGrammer = arrItem.map({
                    return MeCabUtil.shared().stringJapanese(toRomaji: $0, withWordSeperator: "" , unuseChar: symbols) ?? ""
                })
                
                let filter = arrItemRomajiUseGrammer.filter({ (str) -> Bool in
                    return !arrItemRomajiNoGrammer.contains(str)
                })
                
                arrItemRomajiNoGrammer.append(contentsOf: filter)
                
                arrStrRomaji.append(arrItemRomajiNoGrammer)
                
                count = count + 1
            }
            
            var arrStrRomajiResult: [String] = [""]
            for arrStrItem in arrStrRomaji {
                arrStrRomajiResult = arrayCrossJoin(aArray: arrStrRomajiResult, bArray: arrStrItem, joiner: {
                    return "\($0)\($1)"
                })
            }
            
            if let stringRomaji = stringRomaji, arrStrRomajiResult.contains(stringRomaji) {
                score = score / Float(count)
                if score > 100 {
                    score = 100
                }
                
                attributedString.addAttribute(NSForegroundColorAttributeName, value: UIColor.black , range: NSRange(location: 0, length: textStr.characters.count))
                
            } else {
                //reset score and count for other calculate
                score = 0
                count = 0
                
                result.bestTranscription.segments.forEach {
                    print("--- SEGMENT ---")
                    print("substring            : \($0.substring)")
                    print("timestamp            : \($0.timestamp)")
                    print("duration             : \($0.duration)")
                    print("confidence           : \($0.confidence)")
                    print("alternativeSubstrings: \($0.alternativeSubstrings)")
                    print("")
                    
                    let str = textStr.subStr(from: currentIndex)
                    
                    if str != "" {
                        let subStr = $0.substring
                        if let index = str.index(of: subStr) {
                            numberCharFinded = numberCharFinded + subStr.characters.count
                            score = score + ($0.confidence / 0.93) * 100
                            attributedString.addAttribute(NSForegroundColorAttributeName, value: UIColor.black , range: NSRange(location: currentIndex + index, length: subStr.characters.count))
                            
                            currentIndex = currentIndex + index + subStr.characters.count
                        } else {
                            for alternativeSubStr in $0.alternativeSubstrings {
                                
                                if let index = str.index(of: alternativeSubStr) {
                                    numberCharFinded = numberCharFinded + alternativeSubStr.characters.count
                                    score = score + ($0.confidence / 0.93) * 100
                                    attributedString.addAttribute(NSForegroundColorAttributeName, value: UIColor.black , range: NSRange(location: currentIndex + index, length: alternativeSubStr.characters.count))
                                    
                                    currentIndex = currentIndex + index + alternativeSubStr.characters.count
                                    break
                                }
                            }
                        }
                    }
                    count = count + 1
                }
                
                score = score / Float(count)
                if score > 100 {
                    score = 100
                }
                hasMistake = !(numberCharFinded == textStr.characters.count)
                score = score * (Float(numberCharFinded) / Float(textStr.characters.count))
            }
            
           // self.lbScore.text = "\(score)"
            
            self.resultAttributedString = NSMutableAttributedString(string: textStr)
            self.resultAttributedString.yy_font = UIFont.systemFont(ofSize: 17)
            self.resultAttributedString.yy_color = UIColor.black
            self.resultAttributedString.yy_lineSpacing = 5
            self.resultAttributedString.yy_alignment = .center
            self.resultAttributedString.yy_lineBreakMode = .byCharWrapping
            
            let border = YYTextBorder(fill: UIColor.clear, cornerRadius: 3)
            border.strokeWidth = 1
            border.insets = UIEdgeInsetsMake(-1, 0, -1, 0)
            border.strokeColor = UIColor.red
            
            let hightlightBorder: YYTextBorder = border.copy() as! YYTextBorder
            hightlightBorder.strokeColor = UIColor.yellow
            
            let hightLight = YYTextHighlight()
            hightLight.setColor(UIColor.yellow)
            hightLight.setBackgroundBorder(hightlightBorder)
            hightLight.tapAction = {(_,text,ran,_) in
                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                if let controller = storyboard.instantiateViewController(withIdentifier: "kMistakeViewController") as? MistakeViewController {
                    controller.mistakeString = text.yy_plainText(for: ran) ?? ""
                    self.navigationController?.pushViewController(controller, animated: true)
                }
            }
            
            attributedString.enumerateAttribute(NSForegroundColorAttributeName, in: NSRange(location: 0, length: textStr.characters.count), options: [], using: { (object, ran, _) in
                if let deviceColor = object as? UIColor, deviceColor == UIColor.red {
                    self.resultAttributedString.yy_setColor(UIColor.red, range: ran)
                    self.resultAttributedString.yy_setTextBorder(border, range: ran)
                    self.resultAttributedString.yy_setTextHighlight(hightLight, range: ran)
                }
            })
            
            let bestScore = currentCard.bestScore > Int(score) ? currentCard.bestScore : Int(score)
            let newCard = Card(name: currentCard.name, cardId: currentCard.cardId, deckId: currentCard.deckId, bestScore: bestScore)
            self.cards[self.currentIndexPath.row] = newCard
            self.tableView.reloadRows(at: [self.currentIndexPath], with: .automatic)
            
            NetworkManager.shared.practices(card: newCard, completion: { (error) in
                if let error = error {
                    print ("\(error.localizedDescription)")
                } else {
                    let scoreView = ScoreView(frame: CGRect(x: 0, y: 0, width: self.view.bounds.width, height: self.view.bounds.height))
                    scoreView.btnMistake.addTarget(self, action: #selector(self.wrongPlaceSentence(_:)), for: .touchUpInside)
                    scoreView.btnMistake.isHidden = !hasMistake
                    scoreView.lbResult.text = "\(Int(score))"
                    self.view.addSubview(scoreView)
                }
            })
          //  self.lbResult.attributedText = resultAttributedString
        }
        
    }
    
    @IBAction func playAllAudio(_ sender: UIButton) {
        if PlayListPlayer.sharedInstance.isPlaying() {
            PlayListPlayer.sharedInstance.pause()
            sender.setTitle("Play", for: .normal)
        } else {
            sender.setTitle("Stop", for: .normal)
            var playlist: [URL] = [URL]()
            for card in cards {
                playlist.append(filePath(withName: "card\(card.cardId).m4a"))
            }
            do {
                try AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryPlayback)
                
                try AVAudioSession.sharedInstance().setActive(true)
                
                PlayListPlayer.sharedInstance.set(playList: playlist)
                PlayListPlayer.sharedInstance.playMode = .NoRepeat
                PlayListPlayer.sharedInstance.play()
                PlayListPlayer.sharedInstance.didFinishPlayingPlayList = {
                    PlayListPlayer.sharedInstance.pause()
                    sender.setTitle("Play", for: .normal)
                }
            } catch {
                print("get an error:\(error.localizedDescription)")
            }
        }
    }
    
    func wrongPlaceSentence(_ btn: UIButton) {
        btn.superview?.removeFromSuperview()
        let controller = WrongViewController()
        controller.attributedString = resultAttributedString
        self.navigationController?.pushViewController(controller, animated: true)
    }
    
    func audioRecorderDidFinishRecording(_ recorder: AVAudioRecorder, successfully flag: Bool) {
        if !flag {
            finishRecording(success: false)
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}

extension SentenceViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return cards.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let card = cards[indexPath.row]
        return heightForView(text: card.name, font: UIFont.systemFont(ofSize: 17), width: tableView.frame.size.width - 91) + heightForView(text: card.romaji, font: UIFont.systemFont(ofSize: 17), width: tableView.frame.size.width - 91) + 62
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: SentenceTableViewCell = tableView.dequeueReusableCell(withIdentifier: SentenceTableViewCell.cellIdentifier, for: indexPath) as! SentenceTableViewCell
        cell.btnRecord.isEnabled = self.enableSpeech
        let card = cards[indexPath.row]
        cell.lbTitle.text = card.name
        cell.lbRomaji.text = card.romaji
        cell.lbScore.text = "\(card.bestScore)"
        
        cell.btnRecord.addTarget(self, action: #selector(record(_:)), for: .touchDown)
        cell.btnRecord.addTarget(self, action: #selector(stopRecord), for: .touchUpInside)
        return cell
    }
}

extension SentenceViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let card = cards[indexPath.row]
        sampleSound?.stop()
        sampleSound = nil
        
        let pathUrl = filePath(withName: "card\(card.cardId).m4a")
        do {
            try AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryPlayback)
            
            try AVAudioSession.sharedInstance().setActive(true)
            
            let sound = try AVAudioPlayer(contentsOf: pathUrl)
            self.sampleSound = sound
            sound.play()
        } catch {
            print("get an error:\(error.localizedDescription)")
        }
    }
}
