//
//  CustomButton.swift
//  AVFoundationSwift
//
//  Created by Rubaiyat Jahan Mumu on 7/15/19.
//  Copyright © 2019 Rubaiyat Jahan Mumu. All rights reserved.
//

import Foundation
import UIKit

class CustomButton: UIButton {
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        let widthContraints =  NSLayoutConstraint(item: self, attribute: NSLayoutConstraint.Attribute.width, relatedBy: NSLayoutConstraint.Relation.equal, toItem: nil, attribute: NSLayoutConstraint.Attribute.notAnAttribute, multiplier: 1, constant: 100)
        let heightContraints = NSLayoutConstraint(item: self, attribute: NSLayoutConstraint.Attribute.height, relatedBy: NSLayoutConstraint.Relation.equal, toItem: nil, attribute: NSLayoutConstraint.Attribute.notAnAttribute, multiplier: 1, constant: 100)
        NSLayoutConstraint.activate([heightContraints,widthContraints])
        //let rect = CGRect(origin: self.frame.origin, size: CGSize(width: 100, height: 100))
        //self.frame = rect
        self.layer.cornerRadius = 50
        self.backgroundColor = UIColor.white
        self.layer.borderWidth = 4
        self.layer.borderColor = UIColor.red.cgColor
        self.setTitle("", for: .normal)
    }
}
