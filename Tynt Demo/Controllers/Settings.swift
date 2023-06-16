//
//  Settings.swift
//  Tynt Demo
//
//  Created by Arjun on 6/15/23.
//

import UIKit

class Settings: UIViewController {
    
    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var pairButton: UIButton!
    @IBOutlet weak var sensorDataButton: UIButton!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        backButton.setTitle("", for: .normal)
        
        
        // Do any additional setup after loading the view.
    }
    
    
    
    // MARK: - Navigation
    
    @IBAction func returnToSettings(segue: UIStoryboardSegue) { //exists for unwind
    }
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    // override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    // Get the new view controller using segue.destination.
    // Pass the selected object to the new view controller.
    // }
    
}
