//
//  CellsAndRows.swift
//  Livingston
//
//  Created by Max Vitruk on 04.09.15.
//  Copyright (c) 2015 integer. All rights reserved.
//

import UIKit

class SoundPurchaseCell : UITableViewCell {
    @IBOutlet weak var soundImage: UIImageView!
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var buttonPlay: UIButton!
    
}

class BLECell : UITableViewCell {
    
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var uuid: UILabel!
}

class TackleCell : UICollectionViewCell {
    @IBOutlet weak var image: UIImageView!
    @IBOutlet weak var refreshButton: UIButton!
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var type: UILabel!
    @IBOutlet weak var activeSoundType: UILabel!

}

class MenuCell : UITableViewCell {
    
    @IBOutlet weak var itemName: UILabel!
    
}

@IBDesignable
class RoundedCornersCell: UIView {
    
    @IBInspectable var cornerRadius: CGFloat = 0 {
        didSet {
            layer.cornerRadius = cornerRadius
            layer.masksToBounds = cornerRadius > 0
        }
    }
    
}
