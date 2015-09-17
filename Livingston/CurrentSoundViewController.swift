//
//  CurrentSoundViewController.swift
//  Livingston
//
//  Created by Max Vitruk on 04.09.15.
//  Copyright (c) 2015 integer. All rights reserved.
//

import UIKit
import AVFoundation

class CurrentSoundViewController: BaseViewController {
    
    @IBOutlet weak var lureImage: UIButton!
    @IBOutlet weak var soundName: UILabel!
    var audioPlayer : AVAudioPlayer!
    
    var name : String = ""
    var image : String = "bluegill_black"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let img = UIImage(named: "background")
        self.view.backgroundColor = UIColor(patternImage: img!)
        
        let path = NSBundle.mainBundle().pathForResource("water", ofType: "mp3") //MP3 file path
        let url = NSURL(fileURLWithPath: path!)
        
        do {
            try AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryPlayback)
        } catch _ {
        }
        do {
            try AVAudioSession.sharedInstance().setActive(true)
        } catch _ {
        }
        
        var error:NSError?
        do {
            audioPlayer = try AVAudioPlayer(contentsOfURL: url)
        } catch let error1 as NSError {
            error = error1
            audioPlayer = nil
        }
        audioPlayer.prepareToPlay()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        self.lureImage.setImage(UIImage(named: self.image), forState: .Normal)
        self.soundName.text = name
    }
    @IBAction func replay(sender: UIButton) {
        self.play()
    }
    @IBAction func back(sender: UIButton) {
        self.navigationController?.popViewControllerAnimated(true)
    }
    
    func playButtonAction(sender : UIButton){
        self.play()
    }
    //Play func !
    func play(){
        audioPlayer.stop()
        audioPlayer.play()
    }
}

//Data source
extension CurrentSoundViewController : UITableViewDataSource {
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 6
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("SoundPurchaseCell", forIndexPath: indexPath) as! SoundPurchaseCell
        cell.name.text = "Item # \(indexPath.row + 1)"
        cell.buttonPlay.addTarget(self, action: Selector("playButtonAction:"), forControlEvents: UIControlEvents.TouchUpInside)
        return cell
    }
}
//Delegate
extension CurrentSoundViewController : UITableViewDelegate {
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        self.play()
    }
}

