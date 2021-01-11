//
//  ModalViewController.swift
//  SoundDataTrasfer
//
//  Created by Admin on 05/01/21.
//

import UIKit
import BubbleTransition
class ModalViewController: UIViewController {
    // MARK: - Outlets & Properties
    @IBOutlet weak var closeButton: UIButton!
    @IBOutlet weak var messageLabel: UILabel!
    weak var interactiveTransition: BubbleInteractiveTransition?
    var messageString = ""
    // MARK: - ViewController Lifecycle Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        /// Set messageLabel text
        messageLabel.text = messageString
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        /// Set status bar stye to light
        UIApplication.shared.setStatusBarStyle(.lightContent, animated: true)
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        /// Set status bar stye to default
        UIApplication.shared.setStatusBarStyle(.default, animated: true)
    }
    
    
}


// MARK: - IBActions
extension ModalViewController{
    
    @IBAction func closeAction(_ sender: AnyObject) {
        self.dismiss(animated: true, completion: nil)
        interactiveTransition?.finish()
    }
}
