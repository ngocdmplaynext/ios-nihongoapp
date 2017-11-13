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
    var editingIndexPath: IndexPath?
    
    @IBOutlet weak var btnEdit: UIButton!
    @IBOutlet weak var lbDeck: UITextField!
    @IBOutlet weak var btnRecord: UIButton!
    @IBOutlet weak var tableView: UITableView!
    weak var tflNewSentence: UITextField!
    
    var recordingSession: AVAudioSession!
    var audioRecorder: AVAudioRecorder!
    
    private var speechRecognizer: SFSpeechRecognizer!
    private var recognitionRequest: SFSpeechAudioBufferRecognitionRequest!
    private var recognitionTask: SFSpeechRecognitionTask!
    private let defaultLocale = Locale(identifier: "ja-JA")
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "トピック作成"
        
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
        
        cleanDocumentsDirectory(hasPrefix: "recording")
        
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
            NetworkManager.shared.createDeck(themeId: themeId, topic: topic, sentences: sentences, completion: { (error) in
                
                if let error = error {
                    var message: String = error.description;
                    if error.code == 1000 {
                        message = "Session Invalid"
                    } else if error.code == 1001 {
                        message = "Teacher only can create topic"
                    }
                    let alert = UIAlertController(title: "Alert", message: message, preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                    self.present(alert, animated: true, completion: nil)
                } else {
                    let alert = UIAlertController(title: "Alert", message: "Successful Created!", preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { (action) in
                            self.dismiss(animated: true, completion: nil)
                    }))
                    self.present(alert, animated: true, completion: nil)
                }
            })
        } else {
            let alert = UIAlertController(title: "Alert", message: "Please input topic and sentences", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    func startRecording() {
        fileCount = Int(NSDate().timeIntervalSince1970)
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
                let errorMsg = error?.localizedDescription ?? ""
                let alert = UIAlertController(title: "Alert", message: errorMsg, preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                self.present(alert, animated: true, completion: nil)
                return
            }
            
            let str = result.bestTranscription.formattedString
            
            let alert = UIAlertController(title: "Result", message: str, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { (action) in
                print("\(url)")
                let sentence = RecordSentence(sentence: str, audioUrl: url)
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
    
    func editSentence(_ btn: UIButton) {
        let cell = btn.superview?.superview as! UITableViewCell
        self.editingIndexPath = self.tableView.indexPath(for: cell)
        let alert = UIAlertController(title: "Edit Sentence", message: "", preferredStyle: .alert)
        alert.addTextField(configurationHandler: addTextField)
        alert.addAction(UIAlertAction(title: "Cancel", style: .default, handler: nil))
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: wordEntered))
        self.present(alert, animated: true, completion: nil)
    }
    
    func wordEntered(alert: UIAlertAction!){
        if let indexPath = self.editingIndexPath, let cell = self.tableView.cellForRow(at: indexPath) as?  CreateDeckTableViewCell, let text = self.tflNewSentence.text {
            cell.lbTitle.text = text
            let sentence = sentences[indexPath.row]
            let newsentence = RecordSentence(sentence: text, audioUrl: sentence.audioUrl)
            sentences[indexPath.row] = newsentence
        }
    }
    
    func addTextField(textField: UITextField!){
        if let indexPath = self.editingIndexPath {
            textField.text = sentences[indexPath.row].sentence
        }
        self.tflNewSentence = textField
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
        cell.btnEdit.addTarget(self, action: #selector(editSentence(_:)), for: .touchUpInside)
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


