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

class CardViewController: UIViewController, AVAudioRecorderDelegate,
SFSpeechRecognizerDelegate  {
    var card: Card = Card()
    
    @IBOutlet weak var lbRomaji: UILabel!
    @IBOutlet weak var lbResult: UILabel!
    @IBOutlet weak var lbTitle: UILabel!
    @IBOutlet weak var btnRecord: UIButton!
    @IBOutlet weak var lbScore: UILabel!
    var recordingSession: AVAudioSession!
    var audioRecorder: AVAudioRecorder!
    
    @IBOutlet weak var ytextView: UITextView!
    private var speechRecognizer: SFSpeechRecognizer!
    private var recognitionRequest: SFSpeechAudioBufferRecognitionRequest!
    private var recognitionTask: SFSpeechRecognitionTask!
    private let defaultLocale = Locale(identifier: "ja-JA")
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        recordingSession = AVAudioSession.sharedInstance()
        lbTitle.text = card.name
        lbRomaji.text = card.romaji
        
        btnRecord.isEnabled = false
        
        do {
            try recordingSession.setCategory(AVAudioSessionCategoryPlayAndRecord)
            try recordingSession.setActive(true)
            recordingSession.requestRecordPermission() { [unowned self] allowed in
                DispatchQueue.main.async {
                    if allowed {
                        self.loadRecordingUI()
                    } else {
                        // failed to record!
                    }
                }
            }
        } catch {
            // failed to record!
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
//            var wrongRanges: [NSRange] = [NSRange]()
//            var correctRanges: [NSRange] = [NSRange]()
            let textStr = self.card.name
            let attributedString = NSMutableAttributedString(string:textStr)
            attributedString.addAttribute(NSForegroundColorAttributeName, value: UIColor.red , range: NSRange(location: 0, length: textStr.characters.count))
            //find all symbol string
            for symbol in symbols {
                let ranges = textStr.ranges(of: symbol)
                for range in ranges {
                    attributedString.addAttribute(NSForegroundColorAttributeName, value: UIColor.black, range: range)
                }
            }
            
//            var i = 0
//            for transcription in result.transcriptions {
//                transcription.segments.forEach {
//                    print("--- SEGMENT\(i) ---")
//                    print("substring            : \($0.substring)")
//                    print("timestamp            : \($0.timestamp)")
//                    print("duration             : \($0.duration)")
//                    print("confidence           : \($0.confidence)")
//                    print("alternativeSubstrings: \($0.alternativeSubstrings)")
//                    print("")
//                }
//                i = i + 1
//            }
            
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
            
            self.lbScore.text = "\(score)"
            self.lbResult.attributedText = attributedString
            
            attributedString.enumerateAttribute(NSForegroundColorAttributeName, in: NSRange(location: 0, length: textStr.characters.count), options: [], using: { (object, ran, _) in
                if let deviceColor = object as? UIColor, deviceColor == UIColor.red {
                    
                }
            })
            
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
            audioRecorder.record()
            
            btnRecord.setTitle("Tap To Stop", for: .normal)
        } catch {
            finishRecording(success: false)
        }
    }
    
    func getDocumentsDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        let documentsDirectory = paths[0]
        return documentsDirectory
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
        
        let audioFilename = getDocumentsDirectory().appendingPathComponent("recording.m4a")
        recognizeFile(url: audioFilename)
        
        btnRecord.setTitle("Tap to Record", for: .normal)
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
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}


