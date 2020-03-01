//
//  PopUpViewController.swift
//  Content Sharing
//
//  Created by Nikolay Yarlychenko on 29.02.2020.
//  Copyright © 2020 Nikolay Yarlychenko. All rights reserved.
//

import UIKit
import UIKit
import VK_ios_sdk


class PopUpViewController: UIViewController {
    
    let VK_APP_ID = "7337296"
    let scope = ["wall", "photos"]
    var sdkInstance: VKSdk!
    var image: UIImage?
    @IBOutlet weak var closeButton: UIButton!
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var sendButton: UIButton!
    @IBOutlet weak var textView: UITextView!
    
    @IBOutlet weak var blackView: UIView!
    
    @IBOutlet weak var backView: UIView!
    
    
    func openPopUpController(with: UIImage) {
        image = with
        imageView.image = with
        textView.text = "Добавить комментарий"
    }
    
    func swipeDown() {
        UIView.animate(withDuration: 0.2, animations: {
            self.blackView.isHidden = true
            self.backView.transform = CGAffineTransform(translationX: 0, y: self.backView.frame.height)
        }, completion: {_ in
            self.image = nil
            self.imageView.image = nil
            self.backView.isHidden = true
            self.blackView.isHidden = true
            self.backView.transform = .identity
        })
    }
    
    
    @objc func closePopUp() {
        let alert = UIAlertController(title: "Закрыть редактирование", message: "Удалить изменения?", preferredStyle: .alert)
        let action1 = UIAlertAction(title: "Удалить", style: .destructive, handler: {
            _ in
            self.dismissKeyboard()
            self.swipeDown()
        })
        let action2 = UIAlertAction(title: "Отмена", style: .cancel, handler: .none)
        
        alert.addAction(action1)
        alert.addAction(action2)
        present(alert, animated: true, completion: nil)
    }
    @IBAction func pickPhotoButtonPressed(_ sender: UIButton) {
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.sourceType = .photoLibrary
        self.present(picker, animated: true, completion: .none)
    }
    
    
    func publishPost() {
        let text = textView.text
        let image = self.image
        
        self.showSpinner(onView: self.sendButton)
        
        if let req: VKRequest = VKApi.uploadWallPhotoRequest(image, parameters: VKImageParameters.jpegImage(withQuality: 0.7), userId: Int((VKSdk.accessToken()?.userId)!)!, groupId: 0) {
            self.view.isUserInteractionEnabled = false
            req.execute(resultBlock: {
                response in
                
                if let photo = (response?.parsedModel as! VKPhotoArray)[0] {
                    let post = VKApi.wall()?.post(
                        ["message" : "\(text ?? "")",
                            "mute_notifications" : "1",
                            "attachments": "photo\(String(describing: photo.owner_id.intValue))_\(String(describing: photo.id.intValue))"
                    ])
                    
                    post?.execute(resultBlock: {
                        result in
                        self.removeSpinner()
                        self.swipeDown()
                    }, errorBlock: {
                        error in
                        self.removeSpinner()
                        self.swipeDown()
                        print(error)
                    })
                }
                
                
            }, errorBlock: {
                error in
                self.removeSpinner()
                self.swipeDown()
                print(error)
            })
        }
        
        self.view.isUserInteractionEnabled = true
    }
    
    
    
    
    
    @objc func createPost() {
        
        
        dismissKeyboard()
        
        VKSdk.wakeUpSession(scope, complete: {(state: VKAuthorizationState, error: Error?) in
            if state == .authorized {
                print("Authorized and ready to go ")
                self.publishPost()
            } else if error == nil{
                VKSdk.authorize(self.scope)
            } else {
                print("Error")
                return
            }
        })
        
        
        
        
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        sdkInstance = VKSdk.initialize(withAppId: VK_APP_ID)
        sdkInstance.register(self)
        sdkInstance.uiDelegate = self
        blackView.isHidden = true
        backView.isHidden = true
        textView.delegate = self
        
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tap)
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
        
        
        sendButton.addTarget(self, action: #selector(createPost), for: .touchUpInside)
        closeButton.addTarget(self, action: #selector(closePopUp), for: .touchUpInside)
    }
    
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        textView.textContainerInset = UIEdgeInsets(top: 7.5, left: 12, bottom: 8.5, right: 12)
        
    }
    
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
    
    @objc func keyboardWillShow(_ notification:Notification) {
        
        
        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            
            backView.transform = CGAffineTransform(translationX: 0, y: -keyboardSize.height + 10)
        }
    }
    @objc func keyboardWillHide(_ notification:Notification) {
        if ((notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue) != nil {
            backView.transform = .identity
        }
    }
    
}



extension PopUpViewController: VKSdkDelegate, VKSdkUIDelegate {
    func vkSdkAccessAuthorizationFinished(with result: VKAuthorizationResult!) {
        print("token: \(result.token!)")
        publishPost()
        
    }
    
    func vkSdkUserAuthorizationFailed() {
        print("vkSdkUserAuthorizationFailed")
    }
    
    func vkSdkShouldPresent(_ controller: UIViewController!) {
        if (self.presentedViewController != nil) {
            self.dismiss(animated: true, completion: {
                print("hide current modal controller if presents")
                self.present(controller, animated: true, completion: {
                    print("SFSafariViewController opened to login through a browser")
                })
            })
        } else {
            self.present(controller, animated: true, completion: {
                print("SFSafariViewController opened to login through a browser")
            })
        }
    }
    
    func vkSdkNeedCaptchaEnter(_ captchaError: VKError!) {
        print("vkSdkNeedCaptchaEnter")
    }
    
}


extension PopUpViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        let img = (info[.originalImage] as? UIImage)!
        
        blackView.isHidden = false
        backView.isHidden = false
        self.openPopUpController(with: img)
        picker.dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        self.blackView.isHidden = true
        self.backView.isHidden = true
        picker.dismiss(animated: true, completion: nil)
    }
}


extension PopUpViewController: UITextViewDelegate {
    func textViewDidChange(_ textView: UITextView) {
        let fixedWidth = textView.frame.size.width
        let newSize = textView.sizeThatFits(CGSize(width: fixedWidth, height: CGFloat.greatestFiniteMagnitude))
        UIView.animate(withDuration: 0.11, animations: {
            textView.frame.size = CGSize(width: fixedWidth, height: newSize.height)
        })
        
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.textColor == .placeholderText {
            textView.text = nil
            textView.textColor = .black
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text.isEmpty {
            textView.text = "Добавить комментарий"
            textView.textColor = .placeholderText
        }
    }
}




