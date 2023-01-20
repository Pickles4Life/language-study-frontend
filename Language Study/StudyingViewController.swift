//
//  StudyingViewController.swift
//  Language Study
//
//  Created by Christian Kaminski on 12/22/22.
//

import UIKit

class StudyingViewController: UIViewController {
    @IBOutlet var questionLabel: UILabel!
    @IBOutlet var answerField: UITextField!
    @IBOutlet var timeLabel: UILabel!
    @IBOutlet var currentCorrectAnswersLabel: UILabel!
    
    var questionHandler: Int!
    var initialQuestion: String!
    var initialTime: String!
    var initialCorrect: String!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        currentCorrectAnswersLabel.text = "0/\(CORRECT_NEEDED)"
        
        questionLabel.text = initialQuestion
        timeLabel.text = initialTime
        currentCorrectAnswersLabel.text = initialCorrect
        
        let _ = WebSocket.instance.registerHandler(event: .answer, handler: { data in
            let color: UIColor = data == "true" ? .green : .red;
            DispatchQueue.main.async {
                self.view.backgroundColor = color
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                self.view.backgroundColor = .systemBackground
            }
        })
        
        let _ = WebSocket.instance.registerHandler(event: .time, handler: { data in
            DispatchQueue.main.async {
                self.timeLabel.text = data
            }
        })
        
        let _ = WebSocket.instance.registerHandler(event: .correct, handler: { data in
            DispatchQueue.main.async {
                self.currentCorrectAnswersLabel.text = "\(data)/\(CORRECT_NEEDED)"
            }
        })
        
        let _ = WebSocket.instance.registerHandler(event: .stop, handler: { data in
            DispatchQueue.main.async {
                self.performSegue(withIdentifier: "ReturnHome", sender: nil)
            }
        })
        
        let _ = WebSocket.instance.registerHandler(event: .done, handler: { data in
            DispatchQueue.main.async {
                self.performSegue(withIdentifier: "ReturnHome", sender: nil)
            }
        })

        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        questionHandler = WebSocket.instance.registerHandler(event: .question, handler: { data in
            DispatchQueue.main.async {
                self.questionLabel.text = data
            }
        })
    }
    
    @IBAction func submitClicked() {
        WebSocket.instance.sendMessage(event: .answer, data: answerField.text ?? "")
        answerField.text = ""
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        WebSocket.instance.unregisterHandler(event: .question, id: questionHandler)
        questionHandler = nil
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
