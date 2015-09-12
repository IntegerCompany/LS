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

class SoundListCell : UICollectionViewCell {
    
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var image: UIImageView!
}

class DealerList : UITableViewCell {
    @IBOutlet weak var shopName: UILabel!
    @IBOutlet weak var adress: UILabel!
    @IBOutlet weak var city: UILabel!
    @IBOutlet weak var state: UILabel!
    @IBOutlet weak var zip: UILabel!
    @IBOutlet weak var country: UILabel!
    @IBOutlet weak var Phone: UILabel!
    
    class var expandedHeight: CGFloat { get { return 223 } }
    class var defaultHeight: CGFloat  { get { return 44  } }
    
    func checkHeight() {
        let expHidden = (frame.size.height < DealerList.expandedHeight)
        adress.hidden = expHidden
        city.hidden = expHidden
        state.hidden = expHidden
        zip.hidden = expHidden
        country.hidden = expHidden
        Phone.hidden = expHidden
    }
    
    func watchFrameChanges() {
        addObserver(self, forKeyPath: "frame", options: NSKeyValueObservingOptions.New|NSKeyValueObservingOptions.Initial, context: nil)
    }
    
    func ignoreFrameChanges() {
        removeObserver(self, forKeyPath: "frame")
    }
    
    override func observeValueForKeyPath(keyPath: String, ofObject object: AnyObject, change: [NSObject : AnyObject], context: UnsafeMutablePointer<Void>) {
        if keyPath == "frame" {
            checkHeight()
        }
    }
    
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
