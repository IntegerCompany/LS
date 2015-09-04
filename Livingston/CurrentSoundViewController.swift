//
//  CurrentSoundViewController.swift
//  Livingston
//
//  Created by Max Vitruk on 04.09.15.
//  Copyright (c) 2015 integer. All rights reserved.
//

import UIKit
import AVFoundation

class CurrentSoundViewController: UIViewController {
    
    var audioPlayer : AVAudioPlayer!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let img = UIImage(named: "background")
        self.view.backgroundColor = UIColor(patternImage: img!)
        
        let path = NSBundle.mainBundle().pathForResource("water", ofType: "mp3") //MP3 file path
        let url = NSURL(fileURLWithPath: path!)
        
        AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryPlayback, error: nil)
        AVAudioSession.sharedInstance().setActive(true, error: nil)
        
        var error:NSError?
        audioPlayer = AVAudioPlayer(contentsOfURL: url, error: &error)
        audioPlayer.prepareToPlay()
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
        var cell = tableView.dequeueReusableCellWithIdentifier("SoundPurchaseCell", forIndexPath: indexPath) as! SoundPurchaseCell
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

