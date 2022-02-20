//
//  Quiz.swift
//  Zaptastic My Attempt 2
//
//  Created by Ben  Thoburn on 15/02/2022.
//

import UIKit

class Quiz: UIViewController {
    @IBOutlet weak var backButton: UIButton!
    
    var levelValue: Int?
    
    override func viewDidLoad() {
        super.viewDidLoad()

    }
    @IBAction func goBackToGame(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
        let refreshGame = Notification.Name(rawValue: refreshGame1)
        NotificationCenter.default.post(name: refreshGame, object: nil)
    }
    
}
