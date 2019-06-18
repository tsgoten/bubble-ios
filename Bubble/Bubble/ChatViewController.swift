//
//  ChatViewController.swift
//  Bubble
//
//  Created by Tarang Srivastava on 6/17/19.
//  Copyright © 2019 Bubble. All rights reserved.
//

import UIKit
import JSQMessagesViewController
import CoreLocation

class ChatViewController: JSQMessagesViewController {
    
    var messages = [JSQMessage]()
    
    lazy var outgoingBubble: JSQMessagesBubbleImage = {
        return JSQMessagesBubbleImageFactory()!.outgoingMessagesBubbleImage(with: UIColor.jsq_messageBubbleGreen())
    }()
    
    lazy var incomingBubble: JSQMessagesBubbleImage = {
        return JSQMessagesBubbleImageFactory()!.incomingMessagesBubbleImage(with: UIColor.jsq_messageBubbleRed())
    }()
    
    var locationManager = CLLocationManager()
    var currentLocation: CLLocation!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.collectionView.backgroundColor = .black
        if(CLLocationManager.authorizationStatus() == .authorizedAlways || CLLocationManager.authorizationStatus() == .authorizedWhenInUse){
            currentLocation = locationManager.location
        }
        let defaults = UserDefaults.standard
        if  let id = defaults.string(forKey: "jsq_id"), let name = defaults.string(forKey: "jsq_name"){
            senderId = id
            senderDisplayName = name
        }
        else{
            senderId = String(arc4random_uniform(999999))
            senderDisplayName = ""
            
            defaults.set(senderId, forKey: "jsq_id")
            defaults.synchronize()
            
            showDisplayNameDialog()
        }
        
        title = "\(senderDisplayName!)'s Message Room"
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(showDisplayNameDialog))
        tapGesture.numberOfTapsRequired = 1
        
        navigationController?.navigationBar.addGestureRecognizer(tapGesture)
        inputToolbar.contentView.leftBarButtonItem = nil
        collectionView.collectionViewLayout.incomingAvatarViewSize = CGSize.zero
        collectionView.collectionViewLayout.outgoingAvatarViewSize = CGSize.zero
        
        // Query to get last 10 messages
        let query = Constants.refs.databaseChats.queryLimited(toLast: 40)
        
        // Closure for if there are new messages
        _ = query.observe(.childAdded, with: { [weak self] snapshot in
            if  let data = snapshot.value as? [String: String],
                let id = data["sender_id"],
                let name = data["name"],
                let text = data["text"],
                !text.isEmpty {
                if let message = JSQMessage(senderId: id, displayName: name, text: text){
                    self?.messages.append(message)
                    self?.finishReceivingMessage() //refresh UI
                }
            }
        })
    }
    @objc func showDisplayNameDialog()
    {
        let defaults = UserDefaults.standard
        
        let alert = UIAlertController(title: "Your Display Name", message: "Please choose a display name.", preferredStyle: .alert)
        
        alert.addTextField { textField in
            
            if let name = defaults.string(forKey: "jsq_name")
            {
                textField.text = name
            }
            else
            {
                textField.text = "user# \(Int(arc4random_uniform(UInt32(1000))))"
            }
        }
        
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { [weak self, weak alert] _ in
            
            if let textField = alert?.textFields?[0], !textField.text!.isEmpty {
                
                self?.senderDisplayName = textField.text
                
                self?.title = "\(self!.senderDisplayName!)'s Message Room"
                
                defaults.set(textField.text, forKey: "jsq_name")
                defaults.synchronize()
            }
        }))
        
        present(alert, animated: true, completion: nil)
    }
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, messageDataForItemAt indexPath: IndexPath!) -> JSQMessageData! {
        return messages[indexPath.item]
    }
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return messages.count
    }
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, messageBubbleImageDataForItemAt indexPath: IndexPath!) -> JSQMessageBubbleImageDataSource! {
        return messages[indexPath.item].senderId == senderId ? outgoingBubble : incomingBubble
    }
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, avatarImageDataForItemAt indexPath: IndexPath!) -> JSQMessageAvatarImageDataSource! {
        return nil
    }
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, attributedTextForMessageBubbleTopLabelAt indexPath: IndexPath!) -> NSAttributedString! {
        return messages[indexPath.item].senderId == senderId ? nil : NSAttributedString(string: messages[indexPath.item].senderDisplayName)
    }
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, layout collectionViewLayout: JSQMessagesCollectionViewFlowLayout!, heightForMessageBubbleTopLabelAt indexPath: IndexPath!) -> CGFloat {
        return messages[indexPath.item].senderId == senderId ? 0 : 15
    }
    @IBAction func backToMap(_ sender: UIBarButtonItem) {
        if((self.presentingViewController) != nil){
            self.dismiss(animated: true, completion: nil)
        }
    }
    override func didPressSend(_ button: UIButton!, withMessageText text: String!, senderId: String!, senderDisplayName: String!, date: Date!)
    {
        let ref = Constants.refs.databaseChats.childByAutoId()
        
        let message = ["sender_id": senderId, "name": senderDisplayName, "longitude": "\(self.currentLocation.coordinate.longitude)", "latitude": "\(self.currentLocation.coordinate.latitude)", "text": text]
        
        ref.setValue(message)
        
        finishSendingMessage()
    }
    
}
