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
    
    var name : String = "water"
    var image : String = "bluegill_black"
    
    var sounds = []
    var soundsMP3 = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let path = NSBundle.mainBundle().pathForResource("Sounds", ofType: "plist") {
            sounds = NSArray(contentsOfFile: path)!
        }
        if let pathmp3 = NSBundle.mainBundle().pathForResource("SoundsMP3", ofType: "plist") {
            soundsMP3 = NSArray(contentsOfFile: pathmp3)!
        }
        
        let img = UIImage(named: "background")
        self.view.backgroundColor = UIColor(patternImage: img!)
        
        let path = NSBundle.mainBundle().pathForResource(self.name, ofType: "mp3") //MP3 file path
        let url = NSURL(fileURLWithPath: path!)
        
        do {
            try AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryPlayback)
        } catch _ {
        }
        do {
            try AVAudioSession.sharedInstance().setActive(true)
        } catch _ {
        }
        
        do {
            audioPlayer = try AVAudioPlayer(contentsOfURL: url)
        } catch let error as NSError {
            print(error)
            audioPlayer = nil
        }
        audioPlayer.prepareToPlay()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        self.lureImage.setImage(UIImage(named: self.image), forState: .Normal)
        self.soundName.text = name
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        self.audioPlayer.stop()
    }
    
    @IBAction func replay(sender: UIButton) {
        let path = NSBundle.mainBundle().pathForResource(self.name, ofType: "mp3") //MP3 file path
        let url = NSURL(fileURLWithPath: path!)
        do {
            audioPlayer = try AVAudioPlayer(contentsOfURL: url)
        } catch let error as NSError {
            print(error)
            audioPlayer = nil
        }
        audioPlayer.prepareToPlay()
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
        return self.soundsMP3.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("SoundPurchaseCell", forIndexPath: indexPath) as! SoundPurchaseCell
        cell.name.text = self.soundsMP3[indexPath.row] as? String
        cell.soundImage.image = UIImage(named: "\(self.sounds[indexPath.row])")
        //cell.buttonPlay.addTarget(self, action: Selector("playButtonAction:"), forControlEvents: UIControlEvents.TouchUpInside)
        return cell
    }
}
//Delegate
extension CurrentSoundViewController : UITableViewDelegate {
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        print("Sounds count soundsMP3 : \(soundsMP3.count)")
        print("Sounds soundsMP3 : \(soundsMP3)")
        let path = NSBundle.mainBundle().pathForResource(soundsMP3[indexPath.row] as? String, ofType: "mp3") //MP3 file path
        let url = NSURL(fileURLWithPath: path!)
        do {
            audioPlayer = try AVAudioPlayer(contentsOfURL: url)
        } catch let error as NSError {
            print(error)
            audioPlayer = nil
        }
        audioPlayer.prepareToPlay()
        self.play()
    }
}

