//
//  ViewController.swift
//  SoundDataTrasfer
//
//  Created by Admin on 05/01/21.
//

import UIKit
import QuietModemKit
import BubbleTransition
import CryptoKit

class ViewController: UIViewController {
    
    // MARK: - Outlets
    @IBOutlet weak var sendButton: UIButton!
    @IBOutlet weak var receiveButton: UIButton!
    
    // MARK: - Properties
    /// Fetch configuration key for QMK
    let QMK_Key = Bundle.main.infoDictionary?["QMK_Key"] as! String
    
    /// Get the 256-bit symmetric key
    let stringKEY256 = Bundle.main.infoDictionary?["KEY256"] as! String
    var key256 :SymmetricKey {
        let keyData = Data(base64Encoded: stringKEY256)
        let retrievedKey = SymmetricKey(data: keyData!)
        return retrievedKey
    }
    
    ///Set QMFTransmitter  & QMFrameReceiver to use later
    var QMFTransmitter: QMFrameTransmitter{
        let QMTConfig: QMTransmitterConfig = QMTransmitterConfig(key: QMK_Key);
        let QMFTransmitter: QMFrameTransmitter = QMFrameTransmitter(config:QMTConfig);
        return QMFTransmitter;
    }
    var QMFReceiver: QMFrameReceiver?;
    
    /// Create payment info object for testing
    let paymentObject = PaymentModel(Merchant_ID: "0A4F4V5", Amount: 2599)
    
    /// To identify  which button is pressed Send/Receive
    var buttonPressed: UIButton!
    
    
    /// For Bubble Animation
    let transition = BubbleTransition()
    let interactiveTransition = BubbleInteractiveTransition()
    
    // MARK: - ViewController Lifecycle Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
    }
    
}



// MARK: - Message transsaction handlers
extension ViewController{
    
    @IBAction func sendUltrasonicSoundMessage(_ sender: Any) {
        
        do {
            /// Create JSON data from property
            let encoder = JSONEncoder()
            encoder.outputFormatting = .prettyPrinted
            let jsonData = try encoder.encode(paymentObject)
            ////  Create a sealed box with the encrypted data
            let sealedBoxData = try! ChaChaPoly.seal(jsonData, using: key256).combined
            /// Send data via transmitter
            self.QMFTransmitter.send(sealedBoxData);
            
        } catch {
            print(error.localizedDescription)
        }
        
        
    }
    
    @IBAction func receiveUltrasonicSoundMesage(_ sender: Any) {
        /// Check access for Microphone.
        AVAudioSession.sharedInstance().requestRecordPermission({(granted: Bool)-> Void in
            if granted {
                if self.QMFReceiver == nil {
                    let QMRConfig: QMReceiverConfig = QMReceiverConfig(key:self.QMK_Key);
                    self.QMFReceiver = QMFrameReceiver(config: QMRConfig);
                    self.QMFReceiver?.setReceiveCallback(self.parseFrameData);
                }
            } else {
                /// Fallback
                print("Permission not granted to use microphone")
            }
        })
        
    }
    
    /// Displays payment information in an alert.
    /// - Parameter paymentInfo: Carrys the payment infomation of type 'PaymentModel'
    fileprivate func displayPaymentInfo(_ paymentInfo: PaymentModel) {
        let alert = UIAlertController(title: "Payment Details Received", message: "Merchant ID: \(paymentInfo.Merchant_ID) Amount: \(paymentInfo.Amount)", preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "Done", style: .default, handler: nil))
        UIApplication.topViewController()?.present(alert, animated: true, completion: nil)
        
    }
    
    /// Parses JSON data to the 'PaymentModel' type
    /// - Parameter jsonData: data recieved through the call back
    func parseFrameData(encryptedData: Data?) {
        
        do {
            /// To decrypt
            let sealedBox = try! ChaChaPoly.SealedBox(combined: encryptedData!)
            let decryptedData = try! ChaChaPoly.open(sealedBox, using: key256)
            /// Decode data
            let decoder = JSONDecoder()
            let paymentInfo = try decoder.decode(PaymentModel.self, from: decryptedData)
            displayPaymentInfo(paymentInfo)
        } catch {
            print(error)
        }
    }
    
}

// MARK:  - UIViewControllerTransitioningDelegate
extension ViewController: UIViewControllerTransitioningDelegate
{
    
    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        transition.transitionMode = .present
        transition.startingPoint = buttonPressed.center
        transition.bubbleColor = buttonPressed.backgroundColor!
        return transition
    }
    
    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        transition.transitionMode = .dismiss
        transition.startingPoint = buttonPressed.center
        transition.bubbleColor = buttonPressed.backgroundColor!
        return transition
    }
    
    func interactionControllerForDismissal(using animator: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
        return interactiveTransition
    }
    
}
// MARK: - Prepare segue
extension ViewController
{
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let controller = segue.destination as? ModalViewController {
            
            if segue.identifier == "Send"{
                buttonPressed = sendButton
                controller.messageString = "Message Sent!"
            }else{
                buttonPressed = receiveButton
                controller.messageString = "Listening..."
            }
            controller.transitioningDelegate = self
            controller.modalPresentationStyle = .custom
            controller.modalPresentationCapturesStatusBarAppearance = true
            controller.interactiveTransition = interactiveTransition
            interactiveTransition.attach(to: controller)
        }
    }
}

