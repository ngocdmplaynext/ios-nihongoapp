//
//  CreateDeckViewController.swift
//  SoundDemo
//
//  Created by ngocdm on 3/21/17.
//  Copyright © 2017 ngocdm. All rights reserved.
//

import UIKit
import AVFoundation
import Speech

class CreateDeckViewController: UIViewController, SFSpeechRecognizerDelegate, AVAudioRecorderDelegate {

    var themeId: Int = 0
    var sentences: [RecordSentence] = [RecordSentence]()
    var fileCount: Int = 0
    
    @IBOutlet weak var btnEdit: UIButton!
    @IBOutlet weak var lbDeck: UITextField!
    @IBOutlet weak var btnRecord: UIButton!
    @IBOutlet weak var tableView: UITableView!
    
    var recordingSession: AVAudioSession!
    var audioRecorder: AVAudioRecorder!
    
    private var speechRecognizer: SFSpeechRecognizer!
    private var recognitionRequest: SFSpeechAudioBufferRecognitionRequest!
    private var recognitionTask: SFSpeechRecognitionTask!
    private let defaultLocale = Locale(identifier: "ja-JA")
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        recordingSession = AVAudioSession.sharedInstance()
        
        recordingSession.requestRecordPermission() { [unowned self] allowed in
            DispatchQueue.main.async {
                if allowed {
                    self.enableRecord()
                } else {
                    // failed to record!
                    print("failed to record! 1")
                }
            }
        }
        
        let tapgest = UITapGestureRecognizer(target: self, action: #selector(tapgestClicked))
        tapgest.cancelsTouchesInView = false
        view.addGestureRecognizer(tapgest)
        
        prepareRecognizer(locale: defaultLocale)
        
        // Do any additional setup after loading the view.
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
    
    func enableRecord() {
        btnRecord.isHidden = false
    }
    
    private func prepareRecognizer(locale: Locale) {
        speechRecognizer = SFSpeechRecognizer(locale: locale)!
        speechRecognizer.delegate = self
    }
    
    @IBAction func registerDeck(_ sender: UIButton) {
        if let topic = lbDeck.text, sentences.count != 0 {
            NetworkManager.shared.createDeck(themeId: themeId, topic: topic, sentences: sentences, completion: {
                self.dismiss(animated: true, completion: nil)
            })
        } else {
            let alert = UIAlertController(title: "Alert", message: "Please input topic and sentences", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    func startRecording() {
        fileCount = fileCount + 1
        let audioFilename = getDocumentsDirectory().appendingPathComponent("recording\(fileCount).m4a")
        
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
            
            btnRecord.setTitle("Stop", for: .normal)
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
            let audioFilename = getDocumentsDirectory().appendingPathComponent("recording\(fileCount).m4a")
            recognizeFile(url: audioFilename)
        } else {
            let alert = UIAlertController(title: "Alert", message: "Fail to record", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
        
        btnRecord.setTitle("Record", for: .normal)
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
            
            let str = result.bestTranscription.formattedString
            
            let alert = UIAlertController(title: "Result", message: str, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { (action) in
                let audioUrl = getDocumentsDirectory().appendingPathComponent("recording\(self.fileCount).m4a")
                let sentence = RecordSentence(sentence: str, audioUrl: audioUrl)
                self.sentences.append(sentence)
                self.tableView.reloadData()
            }))
            
            alert.addAction(UIAlertAction(title: "Try Again", style: .cancel, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    func tapgestClicked() {
        self.lbDeck.resignFirstResponder()
    }
    
    @IBAction func btnRecordClicked(_ sender: UIButton) {
        if audioRecorder == nil {
            startRecording()
        } else {
            finishRecording(success: true)
        }
    }
    
    func audioRecorderDidFinishRecording(_ recorder: AVAudioRecorder, successfully flag: Bool) {
        if !flag {
            finishRecording(success: false)
        }
    }
    
    @IBAction func edit(_ sender: UIButton) {
        self.tableView.isEditing ? sender.setTitle("Edit", for: .normal) : sender.setTitle("Done", for: .normal)
        self.tableView.setEditing(!self.tableView.isEditing, animated: true)
    }
    
    @IBAction func dissmiss(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}

extension CreateDeckViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sentences.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return heightForView(text: sentences[indexPath.row].sentence, font: UIFont.systemFont(ofSize: 17), width: tableView.frame.size.width - 16) + 35
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: CreateDeckTableViewCell = tableView.dequeueReusableCell(withIdentifier: CreateDeckTableViewCell.cellIdentifier, for: indexPath) as! CreateDeckTableViewCell
        cell.selectionStyle = .none
        cell.lbTitle?.text = sentences[indexPath.row].sentence
        return cell
    }
    
    func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        let itemToMove = sentences[sourceIndexPath.row]
        sentences.remove(at: sourceIndexPath.row)
        sentences.insert(itemToMove, at: destinationIndexPath.row)
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            sentences.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .automatic)
        }
    }
}

extension CreateDeckViewController: UITableViewDelegate {
    
}


