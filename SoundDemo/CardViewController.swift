//
//  CardViewController.swift
//  SoundDemo
//
//  Created by ngocdm on 2/13/17.
//  Copyright © 2017 ngocdm. All rights reserved.
//
import AVFoundation
import UIKit
import Speech

class CardViewController: UIViewController, AVAudioRecorderDelegate, AVAudioPlayerDelegate, 
SFSpeechRecognizerDelegate  {
    var card: Card = Card()
    
    @IBOutlet weak var btnPlay: UIButton!
    @IBOutlet weak var lbRomaji: UILabel!
    @IBOutlet weak var lbResult: YYLabel!
    @IBOutlet weak var lbTitle: UILabel!
    @IBOutlet weak var btnRecord: UIButton!
    @IBOutlet weak var lbScore: UILabel!
    var recordingSession: AVAudioSession!
    var audioRecorder: AVAudioRecorder!
    var sampleSound: AVAudioPlayer?
    
    @IBOutlet weak var ytextView: UITextView!
    private var speechRecognizer: SFSpeechRecognizer!
    private var recognitionRequest: SFSpeechAudioBufferRecognitionRequest!
    private var recognitionTask: SFSpeechRecognitionTask!
    private let defaultLocale = Locale(identifier: "ja-JA")
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.lbResult.textAlignment = .center
        self.lbResult.textVerticalAlignment = .center
        
        recordingSession = AVAudioSession.sharedInstance()
        lbTitle.text = card.name
        lbRomaji.text = card.romaji
        
        btnRecord.isEnabled = false
        
        recordingSession.requestRecordPermission() { [unowned self] allowed in
            DispatchQueue.main.async {
                if allowed {
                    self.loadRecordingUI()
                } else {
                    // failed to record!
                    print("failed to record! 1")
                }
            }
        }
        // Do any additional setup after loading the view.
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
                    self.btnRecord.isEnabled = true
                    
                case .denied:
                    self.btnRecord.isEnabled = false
                    
                case .restricted:
                    self.btnRecord.isEnabled = false
                    
                case .notDetermined:
                    self.btnRecord.isEnabled = false
                }
            }
        }
    }
    
    private func prepareRecognizer(locale: Locale) {
        speechRecognizer = SFSpeechRecognizer(locale: locale)!
        speechRecognizer.delegate = self
    }
    
    func recognizeFile(url:URL) {
        
        if !speechRecognizer.isAvailable {
            // The recognizer is not available right now
            return
        }
        
        let request = SFSpeechURLRecognitionRequest(url: url)
        request.shouldReportPartialResults = false
        speechRecognizer.recognitionTask(with: request) { (result, error) in
            guard let result = result else {
                // Recognition failed, so check error for details and handle it
                return
            }
            
            var score: Float = 0
            var count: Int = 0
            var currentIndex: Int = 0
            var numberCharFinded: Int = 0
            
            let symbols = ["！","、","。","？"]
            let textStr = self.card.name
            
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
                score = score * (Float(numberCharFinded) / Float(textStr.characters.count))
            }

            
            
            self.lbScore.text = "\(score)"
            
            let resultAttributedString = NSMutableAttributedString(string: textStr)
            resultAttributedString.yy_font = UIFont.systemFont(ofSize: 17)
            resultAttributedString.yy_color = UIColor.black
            resultAttributedString.yy_lineSpacing = 5
            resultAttributedString.yy_alignment = .center
            resultAttributedString.yy_lineBreakMode = .byCharWrapping
            
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
                    resultAttributedString.yy_setColor(UIColor.red, range: ran)
                    resultAttributedString.yy_setTextBorder(border, range: ran)
                    resultAttributedString.yy_setTextHighlight(hightLight, range: ran)
                }
            })
            
            self.lbResult.attributedText = resultAttributedString
        }
    
    }
    
    func loadRecordingUI() {
        btnRecord.isHidden = false
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
            
            btnRecord.setTitle("Tap To Stop", for: .normal)
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
    
    func getDocumentsDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        let documentsDirectory = paths[0]
        return documentsDirectory
    }
    
    @IBAction func play(_ sender: UIButton) {
        
        let isPlaying = sampleSound?.isPlaying ?? false
        if isPlaying {
            sampleSound?.stop()
            sender.setTitle("Play", for: .normal)
        } else {
            sender.setTitle("Stop", for: .normal)
            let path = Bundle.main.path(forResource: card.name, ofType:"m4a")
            if let path = path {
                do {
                    let currentRoute = AVAudioSession.sharedInstance().currentRoute
                    for description in currentRoute.outputs {
                        if description.portType == AVAudioSessionPortHeadphones {
                            try recordingSession.overrideOutputAudioPort(AVAudioSessionPortOverride.none)
                            print("headphone plugged in")
                        } else {
                            print("headphone pulled out")
                            try recordingSession.overrideOutputAudioPort(AVAudioSessionPortOverride.speaker)
                        }
                    }
                    
                    let url = URL(fileURLWithPath: path)
                    let sound = try AVAudioPlayer(contentsOf: url)
                    sampleSound = sound
                    sampleSound?.delegate = self
                    sound.prepareToPlay()
                } catch {
                    print("get an error:\(error.localizedDescription)")
                }
                
                do {
                    try recordingSession.setCategory(AVAudioSessionCategoryPlayAndRecord)
                    try recordingSession.setActive(true)
                    sampleSound?.play()
                } catch {
                    print("get an error 2:\(error.localizedDescription)")
                }
            } else {
                let alert = UIAlertController(title: "Alert", message: "File not found", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                self.present(alert, animated: true, completion: nil)
            }
        }
    }

    @IBAction func testSampleSound(_ sender: UIButton) {
        let path = Bundle.main.path(forResource: card.name, ofType:"m4a")
        if let path = path {
            let url = URL(fileURLWithPath: path)
            
            recognizeFile(url: url)
        } else {
            let alert = UIAlertController(title: "Alert", message: "File not found", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    @IBAction func btnClicked(_ sender: UIButton) {
        if audioRecorder == nil {
            startRecording()
        } else {
            finishRecording(success: true)
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
        
        btnRecord.setTitle("Tap to Record", for: .normal)
    }
    
    func audioRecorderDidFinishRecording(_ recorder: AVAudioRecorder, successfully flag: Bool) {
        if !flag {
            finishRecording(success: false)
        }
    }
    
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        if  sampleSound != nil {
            sampleSound?.stop()
            sampleSound = nil
            btnPlay.setTitle("Play", for: .normal)
        }
    }

}


