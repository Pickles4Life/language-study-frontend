//
//  ViewController.swift
//  Language Study
//
//  Created by Christian Kaminski on 12/14/22.
//

import UIKit

let CORRECT_NEEDED: Int = 15

class ViewController: UIViewController {
    @IBOutlet var timeLabel: UILabel!
    @IBOutlet var currentCorrectAnswersLabel: UILabel!
    @IBOutlet var startStudyingButton: UIButton!
    
    var currentQuestion = ""
    var questionHandler: Int?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge]) {
            granted, error in
            if granted {
                DispatchQueue.main.sync {
                    UIApplication.shared.registerForRemoteNotifications()
                }
            } else {
                if let error = error {
                    print(error)
                }
            }
        }
        currentCorrectAnswersLabel.text = "0/\(CORRECT_NEEDED)"
        
        let ws = WebSocket.instance
        
        let _ = ws.registerHandler(event: .start, handler: { _ in
            DispatchQueue.main.async {
                self.startStudyingButton.isEnabled = true
                self.startStudyingButton.setTitle("Start Studying!", for: .normal)
                self.currentCorrectAnswersLabel.text = "0/\(CORRECT_NEEDED)"
            }
        })
        
        let _ = ws.registerHandler(event: .stop, handler: { _ in
            DispatchQueue.main.async {
                self.timeLabel.text = "Not Started"
                self.startStudyingButton.isEnabled = false
                self.startStudyingButton.setTitle("Not Yet!", for: .disabled)
                self.currentCorrectAnswersLabel.text = "0/\(CORRECT_NEEDED)"
            }
        })
        
        let _ = ws.registerHandler(event: .done, handler: { _ in
            DispatchQueue.main.async {
                self.timeLabel.text = "Finished"
                self.startStudyingButton.isEnabled = false
                self.startStudyingButton.setTitle("Finished!", for: .disabled)
                self.currentCorrectAnswersLabel.text = "\(CORRECT_NEEDED)/\(CORRECT_NEEDED)"
            }
        })
        
        
        let _ = ws.registerHandler(event: .time, handler: { data in
            DispatchQueue.main.async {
                self.timeLabel.text = data
            }
        })
        
        let _ = ws.registerHandler(event: .correct, handler: { data in
            DispatchQueue.main.async {
                self.currentCorrectAnswersLabel.text = "\(data)/\(CORRECT_NEEDED)"
            }
        })
        
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if !WebSocket.instance.isOpen {
            WebSocket.instance.connect()
        }
        
        if questionHandler == nil {
            questionHandler = WebSocket.instance.registerHandler(event: .question, handler: { data in
                DispatchQueue.main.async {
                    self.currentQuestion = data
                }
            })
        }
    }
        
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "StartStudy" {
            WebSocket.instance.unregisterHandler(event: .question, id: questionHandler!)
            questionHandler = nil
            let study = segue.destination as! StudyingViewController
            study.initialQuestion = currentQuestion
            study.initialTime = timeLabel.text!
            study.initialCorrect = currentCorrectAnswersLabel.text!
        }
    }
    
    @IBAction func back(_ segue: UIStoryboardSegue) {
        if questionHandler == nil {
            questionHandler = WebSocket.instance.registerHandler(event: .question, handler: { data in
                DispatchQueue.main.async {
                    self.currentQuestion = data
                }
            })
        }
    }


}

