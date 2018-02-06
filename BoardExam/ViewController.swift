//
//  ViewController.swift
//  BoardExam
//
//  Created by NohJaisung on 2018. 2. 6..
//  Copyright © 2018년 NohJaisung. All rights reserved.
//

import UIKit
import AVFoundation
import Speech

class ViewController: UIViewController {
    
    var qPlayer: AVQueuePlayer?
    var questionDic: [String : Int] = [:]
    var questionArray:[String] = []
    
    @IBOutlet weak var startButton: UIButton!
    
    @IBOutlet weak var recognizingLabel: UILabel!
    @IBOutlet weak var answerButton1: UIButton!
    @IBOutlet weak var speechTextView: UILabel!
    @IBOutlet weak var numberIs: UILabel!
    
    @IBOutlet weak var answerIs: UILabel!
    private var speechRecognizer: SFSpeechRecognizer!
    private var recognitionRequest: SFSpeechAudioBufferRecognitionRequest!
    private var recognitionTask: SFSpeechRecognitionTask!
    private let audioEngine = AVAudioEngine()
    private let defaultLocale = Locale(identifier: "en-US")
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.startButton.isEnabled = false
        prepareRecognizer(locale: defaultLocale)
        
    }
    private func prepareRecognizer(locale: Locale) {
        speechRecognizer = SFSpeechRecognizer(locale: locale)!
        speechRecognizer.delegate = self
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
                    self.startButton.isEnabled = true
                    
                case .denied:
                    self.startButton.isEnabled = false
                    self.startButton.setTitle("User denied access to speech recognition", for: .disabled)
                    
                case .restricted:
                    self.startButton.isEnabled = false
                    self.startButton.setTitle("Speech recognition restricted on this device", for: .disabled)
                    
                case .notDetermined:
                    self.startButton.isEnabled = false
                    self.startButton.setTitle("Speech recognition not yet authorized", for: .disabled)
                }
            }
        }
        
        
        let timer = Timer.scheduledTimer(timeInterval:10, target: self, selector: #selector(clickOnRecordButton), userInfo: nil, repeats: true)
        
    }
    
  
    
    @objc func clickOnRecordButton() {
        
        //  let myArray = [1,2,3,4,5]
        
        
        
        if audioEngine.isRunning {
            audioEngine.stop()
            recognitionRequest?.endAudio()
          //  self.recordButton.isEnabled = false
           // self.recordButton.setTitle("Stopping", for: .disabled)
        } else {
            try! getAnswer(correctAnswer: 1)
            
          //  self.recordButton.setTitle("Stop recording", for: [])
        }
        
        
    }
 
    
}

extension ViewController: SFSpeechRecognizerDelegate {
    
    public func speechRecognizer(_ speechRecognizer: SFSpeechRecognizer, availabilityDidChange available: Bool) {
        if available {
          //  self.recordButton.isEnabled = true
         //   self.recordButton.setTitle("Start Recording", for: [])
        } else {
          //  self.recordButton.isEnabled = false
          //  self.recordButton.setTitle("Recognition is not available", for: .disabled)
        }
    }
    
    
    
    private func getAnswer(correctAnswer:Int) throws  {
        let inputNode = audioEngine.inputNode
        if audioEngine.isRunning {
            audioEngine.stop()
            recognitionRequest?.endAudio()
            inputNode.removeTap(onBus: 0)
          //  self.recordButton.isEnabled = false
           // self.recordButton.setTitle("Stopping", for: .disabled)
        } else {
            
            
            
            // Cancel the previous task if it's running.
            
            
            
            
            if let recognitionTask = recognitionTask {
                recognitionTask.cancel()
                self.recognitionTask = nil
            }
            
            let audioSession = AVAudioSession.sharedInstance()
            try audioSession.setCategory(AVAudioSessionCategoryRecord)
            try audioSession.setMode(AVAudioSessionModeMeasurement)
            try audioSession.setActive(true, with: .notifyOthersOnDeactivation)
            
            recognitionRequest = SFSpeechAudioBufferRecognitionRequest()
            
            // let inputNode = audioEngine.inputNode
            guard let recognitionRequest = recognitionRequest else { fatalError("Unable to create a SFSpeechAudioBufferRecognitionRequest object") }
            
            // Configure request so that results are returned before audio recording is finished
            recognitionRequest.shouldReportPartialResults = true
            
            // A recognition task represents a speech recognition session.
            // We keep a reference to the task so that it can be cancelled.
            
            recognitionTask = speechRecognizer.recognitionTask(with: recognitionRequest) { result, error in
                var isFinal = false
                inputNode.removeTap(onBus: 0)
                if let result = result {
                    self.speechTextView.text = result.bestTranscription.formattedString
                    let bestSting  = result.bestTranscription.formattedString
                    var lastString: String = ""
                    for segment in result.bestTranscription.segments {
                        let indexTo = bestSting.index(bestSting.startIndex, offsetBy: segment.substringRange.location)
                        lastString = String(bestSting[indexTo...])
                        self.numberIs.text = lastString
                        
                    }
                    
                    self.checkAnswer(rightAnswer:correctAnswer, resultSting: lastString)
                    
                    self.audioEngine.stop()
                    recognitionRequest.endAudio()
                    
                  //  self.recordButton.isEnabled = false
                  //  self.recordButton.setTitle("Stopping", for: .disabled)
                    isFinal = result.isFinal
                }
                
                if error != nil || isFinal {
                    self.audioEngine.stop()
                    inputNode.removeTap(onBus: 0)
                    
                    self.recognitionRequest = nil
                    self.recognitionTask = nil
                    
                 //   self.recordButton.isEnabled = true
                 //   self.recordButton.setTitle("Start Recording", for: [])
                }
            }
            
            let recordingFormat = inputNode.outputFormat(forBus: 0)
            inputNode.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { (buffer: AVAudioPCMBuffer, when: AVAudioTime) in
                self.recognitionRequest?.append(buffer)
            }
            audioEngine.prepare()
            try audioEngine.start()
            self.speechTextView.text = "(listening...)"
        }
        
    }
    
    
    
    
    
    
    private func checkAnswer(rightAnswer:Int,resultSting:String){
        var i = 0
        var answer = ""
        
        switch resultSting.uppercased() {
            
        case "ONE" :
            i = 1
        case "TWO", "TO":
            i = 2
        case "THREE", "SIRI":
            i = 3
        case "FOUR", "FOR", "POUR":
            i = 4
        case "FIVE", "HIVE" :
            i = 5
        default:
            i = 0
        }
        
        if i != 0 && i == rightAnswer {
            answer = "correct"
        } else if i != 0 && i != rightAnswer  {
            answer = "wrong"
        } else if i == 0 {
            answer = "not comprhended"
        }
        answerIs.text = answer
    }
    
    
    
    
    
    
}

