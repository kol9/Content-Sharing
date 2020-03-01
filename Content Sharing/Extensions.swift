//
//  Extensions.swift
//  Content Sharing
//
//  Created by Nikolay Yarlychenko on 27.02.2020.
//  Copyright © 2020 Nikolay Yarlychenko. All rights reserved.
//

import UIKit

extension UIColor {
    static var buttonIsHighlitedColor = UIColor(red: 96.0 / 255.0, green: 127.0 / 255.0, blue: 169.0 / 255.0, alpha: 1)
    
    static var buttonNotHighlitedColor = UIColor(red: 73.0 / 255.0, green: 134.0 / 255.0, blue: 204.0 / 255.0, alpha: 1)
    
}


var vSpinner : UIView?
 
extension UIViewController {
    func showSpinner(onView : UIView) {
        let spinnerView = UIView(frame: onView.bounds)
        spinnerView.layer.cornerRadius = onView.layer.cornerRadius
        spinnerView.backgroundColor = UIColor.buttonNotHighlitedColor
        let ai = UIActivityIndicatorView.init(style: .medium)
        ai.color = .white
        ai.startAnimating()
        ai.center = spinnerView.center
        
        DispatchQueue.main.async {
            print("Showing spinner")
            spinnerView.addSubview(ai)
            self.view.isUserInteractionEnabled = false
            onView.addSubview(spinnerView)
        }
        
        vSpinner = spinnerView
    }
    
    func removeSpinner() {
        DispatchQueue.main.async {
            
            print("Removed spinner")
            self.view.isUserInteractionEnabled = true
            vSpinner?.removeFromSuperview()
            vSpinner = nil
        }
    }
}
