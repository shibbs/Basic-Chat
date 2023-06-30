//
//  Data_Interface.swift
//  Tynt Demo
//
//  Created by Arjun Dalwadi on 6/25/23.
//

import UIKit

class Data_Interface: UIViewController {
    
    // MARK: - Outlets/Variables
    @IBOutlet weak var tempLabel: UILabel!
    @IBOutlet weak var humidityLabel: UILabel!
    @IBOutlet weak var intLightLabel: UILabel!
    @IBOutlet weak var extLightLabel: UILabel!
    @IBOutlet weak var homeButton: UIButton!
    @IBOutlet weak var opticTransLabel: UILabel!
    @IBOutlet weak var alertslabel: UILabel!
    @IBOutlet weak var coulombCountLabel: UILabel!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        homeButton.setTitle("", for: .normal)
    }
    
    // MARK: - IB Action Funcs
    
    @IBAction func autoTintStatus(_ sender: Any) {
    }
    
    
    // MARK: - Navigation

     @IBAction func backToHome(_ sender: Any) {
         performSegue(withIdentifier: "unwindToHome", sender: nil)
     }
     
    
//    // In a storyboard-based application, you will often want to do a little preparation before navigation
//    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
//        // Get the new view controller using segue.destination.
//        // Pass the selected object to the new view controller.
//    }
    
}
