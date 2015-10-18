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

class CatchLogCell : UITableViewCell{
    
    @IBOutlet weak var logName: UILabel!
    @IBOutlet weak var imageOfLog: UIImageView!
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
        addObserver(self, forKeyPath: "frame", options: [NSKeyValueObservingOptions.New, NSKeyValueObservingOptions.Initial], context: nil)
    }
    
    func ignoreFrameChanges() {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    override func observeValueForKeyPath(keyPath: String?, ofObject object: AnyObject?, change: [String : AnyObject]?, context: UnsafeMutablePointer<Void>) {
        if keyPath == "frame" {
            checkHeight()
        }
    }
    
}

protocol ProgramCellDelagate {
    func stopProgres()
    func setMyBatteryValue(sender : Int)
    func connectionStatus(sender : Bool)
    func on(sender : Bool)
}

class ProgramSoundCell : UITableViewCell {
    @IBOutlet weak var soundImage: UIImageView!
    @IBOutlet weak var soundName: UILabel!
  @IBOutlet weak var soundSelected: UIButton!
}

class ProgramCell : UITableViewCell , ProgramCellDelagate {
    @IBOutlet weak var progress: UIActivityIndicatorView!
    @IBOutlet weak var infoText: UILabel!
    @IBOutlet weak var batteryValue: UILabel!
    @IBOutlet weak var lureImage: UIImageView!
    @IBOutlet weak var lureName: UILabel!
    @IBOutlet weak var lureStyle: UILabel!
    @IBOutlet weak var lureType: UILabel!
    
    @IBOutlet weak var type: UILabel!
    @IBOutlet weak var depth: UILabel!
    @IBOutlet weak var action: UILabel!
    @IBOutlet weak var weight: UILabel!
    @IBOutlet weak var length: UILabel!
    @IBOutlet weak var percentage: UILabel!
    @IBOutlet weak var onOff: UILabel!    
    
    @IBOutlet weak var powerButton: UIButton!
    
    @IBAction func startProgress(sender: UIButton) {
        self.powerButton.hidden = true
        self.progress.hidden = false
        self.progress.startAnimating()
    }
    
    func stopProgres() {
        self.powerButton.hidden = false
        self.progress.hidden = true
        self.progress.stopAnimating()
    }
    func on(sender : Bool) {
        self.onOff.hidden = sender
    }
    
    func setMyBatteryValue(sender: Int) {
        self.batteryValue.text = "\(sender) %"
    }
    
    func setMyBatteryValueDouble(sender: Double) {
        self.batteryValue.text = "\(sender) %"
    }
    
    func connectionStatus(sender: Bool) {
        if sender {
            let timestamp = NSDateFormatter.localizedStringFromDate(NSDate(), dateStyle: .MediumStyle, timeStyle: .ShortStyle)
            self.infoText.text = "Connected : \(timestamp)"
            self.stopProgres()
        }else{
            self.infoText.text = "Can't connect with lure services"
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
