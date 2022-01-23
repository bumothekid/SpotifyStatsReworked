//
//  Extentions.swift
//  SpotifyStatsReworked
//
//  Created by David Riegel on 18.01.22.
//

import Foundation
import UIKit

extension UIColor {
    public static let backgroundColor = UIColor(named: "backgroundColor")!
    public static let secondaryColor = UIColor(named: "secondaryColor")!
    public static let greenColor = UIColor(named: "greenColor")!
}

extension UINavigationBar {
    
    // Set font and background color
    func setupNavigationBar() {
        self.standardAppearance.titleTextAttributes = [.font: UIFont.systemFont(ofSize: 20, weight: .heavy)]
        self.standardAppearance.backgroundColor = .backgroundColor
        self.standardAppearance.shadowImage = UIImage()
        self.standardAppearance.shadowColor = .clear
        self.scrollEdgeAppearance = self.standardAppearance
    }
}

extension UITabBar {
    
    func setupTabBar() {
        self.standardAppearance.backgroundColor = .backgroundColor
        self.scrollEdgeAppearance = self.standardAppearance
    }
}

extension UIView {
    
    func anchor(top: NSLayoutYAxisAnchor? = nil, left: NSLayoutXAxisAnchor? = nil, bottom: NSLayoutYAxisAnchor? = nil, right: NSLayoutXAxisAnchor? = nil, paddingTop: CGFloat = 0, paddingLeft: CGFloat = 0, paddingBottom: CGFloat = 0, paddingRight: CGFloat = 0, width: CGFloat = 0, height: CGFloat = 0) {
        translatesAutoresizingMaskIntoConstraints = false
        
        if let top = top {
            self.topAnchor.constraint(equalTo: top, constant: paddingTop).isActive = true
        }
        
        if let left = left {
            self.leftAnchor.constraint(equalTo: left, constant: paddingLeft).isActive = true
        }
        
        if let bottom = bottom {
            self.bottomAnchor.constraint(equalTo: bottom, constant: paddingBottom).isActive = true
        }
        
        if let right = right {
            self.rightAnchor.constraint(equalTo: right, constant: paddingRight).isActive = true
        }
        
        if width != 0 {
            widthAnchor.constraint(equalToConstant: width).isActive = true
        }
        
        if height != 0 {
            heightAnchor.constraint(equalToConstant: height).isActive = true
        }
    }
}

class getJson {
    func getJson(data: Data) {
        if let json = try? JSONSerialization.jsonObject(with: data, options: .mutableContainers),
           let jsonData = try? JSONSerialization.data(withJSONObject: json, options: .prettyPrinted) {
            print(String(decoding: jsonData, as: UTF8.self))
        } else {
            print("json data malformed")
        }
    }
}

class FadingLabel: UILabel
{
    // Add a property observer for text changes
    // as we might not need to fade anymore
    override var text: String?
    {
        didSet
        {
            // Check if the text needs to be faded
            fadeTailIfRequired()
        }
    }
    
    // Add a property observer for numberOfLines changes
    // as only 1 line labels are supported for now
    override var numberOfLines: Int
    {
        didSet
        {
            // Reset the number of lines to 1
            if numberOfLines != 1
            {
                numberOfLines = 1
            }
        }
    }
    
    override func layoutSubviews()
    {
        super.layoutSubviews()
        
        // The label's frame might have changed so check
        // if the text needs to be faded or not
        fadeTailIfRequired()
    }
    
    
    /// The function that handles fading the tail end of the text if the text goes
    /// beyond the bounds of the label's width
    func fadeTailIfRequired()
    {
        // Reset the numberOfLines to 1
        numberOfLines = 1
        
        // Check if the label's text goes beyond it's width
        if bounds.width > CGFloat.zero && intrinsicContentSize.width > bounds.width
        {
            // Initialize and configure a gradient to start at the end of
            // the label
            let gradient = CAGradientLayer()
            gradient.frame = bounds
            gradient.colors = [UIColor.white.cgColor, UIColor.clear.cgColor]
            gradient.startPoint = CGPoint(x: 0.7, y: 0.5)
            gradient.endPoint = CGPoint(x: 0.85, y: 0.5)
            
            // Apply the gradient as a mask to the UILabel
            layer.mask = gradient
        }
    }
}
