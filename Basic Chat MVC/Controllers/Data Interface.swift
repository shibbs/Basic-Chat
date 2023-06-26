//
//  Data_Interface.swift
//  Tynt Demo
//
//  Created by Arjun Dalwadi on 6/25/23.
//

import UIKit

class Data_Interface: UIViewController {
    
    // MARK: - Variables
    @IBOutlet weak var homeButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        homeButton.setTitle("", for: .normal)
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
