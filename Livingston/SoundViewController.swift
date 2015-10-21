//
//  SoundViewController.swift
//  Livingston
//
//  Created by Max Vitruk on 03.09.15.
//  Copyright (c) 2015 integer. All rights reserved.
//

import UIKit

class SoundViewController: BaseViewController {

    @IBOutlet weak var collectionView: UICollectionView!
    
    let segueId = "goToCurrentSoundVIew"
    
    var sounds = []
    var soundsMP3 = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let img = UIImage(named: "background")
        self.collectionView.backgroundColor = UIColor(patternImage: img!)
        
        if let path = NSBundle.mainBundle().pathForResource("Sounds", ofType: "plist") {
            sounds = NSArray(contentsOfFile: path)!
        }
        if let path = NSBundle.mainBundle().pathForResource("SoundsMP3", ofType: "plist") {
            soundsMP3 = NSArray(contentsOfFile: path)!
        }
    }

    @IBAction func record(sender: UIButton) {
        let vc = self.storyboard?.instantiateViewControllerWithIdentifier("RecordACatchViewController") as! RecordACatchViewController
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @IBAction func tackle(sender: UIButton) {
        let vc = self.storyboard?.instantiateViewControllerWithIdentifier("TackleBoxViewController") as! TackleBoxViewController
        self.navigationController?.pushViewController(vc, animated: true)
    }

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        let index = sender as! Int
        
        let vc = segue.destinationViewController as! CurrentSoundViewController
        vc.name = (soundsMP3[index] as! String)
        vc.image = sounds[index] as! String
    }

}

extension SoundViewController : UICollectionViewDataSource {
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        print("Sound lib count : \(self.soundsMP3.count)")
        return self.soundsMP3.count
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("soundGridViewCell", forIndexPath: indexPath) as! SoundListCell
        
        cell.image.image = UIImage(named: self.sounds[indexPath.item] as! String)
        cell.name.text = (soundsMP3[indexPath.item] as! String)
        
        return cell
    }
}

extension SoundViewController : UICollectionViewDelegate {
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        self.performSegueWithIdentifier(self.segueId, sender: indexPath.item)
    }
}
