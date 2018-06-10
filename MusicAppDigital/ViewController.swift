//
//  ViewController.swift
//  MusicAppDigital
//
//  Created by Mohamed hassan on 6/6/18.
//  Copyright © 2018 youm7.iosapp. All rights reserved.
import UIKit
import AVFoundation
class ViewController: UIViewController,UIGestureRecognizerDelegate {
    @IBOutlet weak var nextBut: UIButton!
    @IBOutlet weak var songLabel: UILabel!
    @IBOutlet weak var previousButton: UIButton!
    @IBOutlet weak var stopButton: UIButton!
    @IBOutlet weak var playButton: UIButton!
    @IBOutlet weak var viewConstraints: NSLayoutConstraint!
    @IBOutlet weak var trayView: UIView!
    @IBOutlet weak var soungImage: UIImageView!
    var nextSong = 0
    var prevSong = 1
    var songs: [String] = []
    var FirstTimePlay = true
    var audioPlayer = AVAudioPlayer()
    var trayOriginalCenter: CGPoint!
    @IBOutlet weak var tableView: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()
        let gesture = UIPanGestureRecognizer(target: self, action: #selector(wasDragged(sender:)))
        trayView.addGestureRecognizer(gesture)
        trayView.isUserInteractionEnabled = true
        gesture.delegate = self
        gettingSongName()
        tableView.dataSource = self
        tableView.delegate = self
        soungImage.isHidden = true
        previousButton.isHidden =  true
        stopButton.isHidden = true
        nextBut.isHidden =  true
    }
    //handle panguesture
    @objc func wasDragged(sender: UIPanGestureRecognizer) {
        let translation = sender.translation(in: view)
        let velocity = sender.velocity(in: view)
        print("translation \( translation.y)")
        if velocity.y > 0 {
           UIView.animate(withDuration: 0.35, delay: 0.0, options: .curveEaseIn, animations: {
                self.viewConstraints.constant = self.view.frame.height - translation.y
            })
            
        } else {
            
            UIView.animate(withDuration: 0.35, delay: 0.0, options: .curveEaseIn, animations: {
                self.viewConstraints.constant = 77 + (translation.y * -1)
            })
            
        }
        if sender.state == UIGestureRecognizerState.began {
            trayOriginalCenter = trayView.center
        } else if sender.state == UIGestureRecognizerState.changed {
            trayView.center = CGPoint(x: trayOriginalCenter.x, y: trayOriginalCenter.y + translation.y)
        } else if sender.state == UIGestureRecognizerState.ended {
            if velocity.y > 0 {
                self.viewConstraints.constant = 77
                UIView.animate(withDuration: 0.35, delay: 0.0, options: .curveEaseIn, animations: {
                    self.soungImage.isHidden = true
                    self.previousButton.isHidden =  true
                    self.stopButton.isHidden = true
                    self.nextBut.isHidden =  true
                    self.view.layoutIfNeeded()
                })
            }
            else {
                self.viewConstraints.constant = self.view.frame.height
                UIView.animate(withDuration: 0.35, delay: 0.0, options: .curveEaseIn, animations: {
                    self.soungImage.isHidden = false
                    self.previousButton.isHidden =  false
                    self.stopButton.isHidden = false
                    self.nextBut.isHidden =  false
                    self.view.layoutIfNeeded()
                })
            }
        }
    }
    //next song
    @IBAction func nextBut(_ sender: Any) {
        if nextSong < songs.count {
         do {
        let audioPath = Bundle.main.path(forResource: songs[nextSong], ofType: ".mp3")
        try audioPlayer = AVAudioPlayer(contentsOf: NSURL(fileURLWithPath: audioPath!) as URL)
             songLabel.text = songs[nextSong]
        audioPlayer.play()
        }
         catch{
            print("Error")
        }
        let myPath = NSIndexPath(row: nextSong, section: 0)
        tableView.selectRow(at: myPath as IndexPath, animated: false, scrollPosition: UITableViewScrollPosition.none)
        prevSong = nextSong - 1
        nextSong += 1
        }
    }
    //previous song
    @IBAction func prevBu(_ sender: Any) {
         if prevSong > 0{
        do {
            let audioPath = Bundle.main.path(forResource: songs[prevSong], ofType: ".mp3")
            try audioPlayer = AVAudioPlayer(contentsOf: NSURL(fileURLWithPath: audioPath!) as URL)
            audioPlayer.play()
            songLabel.text = songs[prevSong]
        }
        catch{
            print("Error")
        }
        let myPath = NSIndexPath(row: prevSong, section: 0)
        tableView.selectRow(at: myPath as IndexPath, animated: false, scrollPosition: UITableViewScrollPosition.none)
        nextSong = prevSong + 1
        prevSong -= 1
        }
    }
    //stop
    @IBAction func stopButton(_ sender: Any) {
        if audioPlayer.isPlaying == true{
         audioPlayer.stop()
         playButton.setImage(UIImage(named: "play.png"), for: .normal)
        }
    }
    //play and pause
    @IBAction func ButonTap(_ sender: Any) {
        if FirstTimePlay {
            do {
                FirstTimePlay = false
                nextSong  = 1
                let myPath = NSIndexPath(row: 0, section: 0)
                tableView.selectRow(at: myPath as IndexPath, animated: false, scrollPosition: UITableViewScrollPosition.none)
                playButton.setImage(UIImage(named: "pause.png"), for: .normal)
                let audioPath = Bundle.main.path(forResource: songs[0], ofType: ".mp3")
                try audioPlayer = AVAudioPlayer(contentsOf: NSURL(fileURLWithPath: audioPath!) as URL)
                 songLabel.text = songs[0]
                audioPlayer.play()
            }
            catch {
                print("Error")
            }
        }
        else{
        if playButton.currentImage == UIImage(named: "pause.png") {
            playButton.setImage(UIImage(named: "play.png"), for: .normal)
            audioPlayer.pause()
          }
        else {
           playButton.setImage(UIImage(named: "pause.png"), for: .normal)
            audioPlayer.play()
        }
        
    }
    }
   

    //getting songs name
    func gettingSongName(){
        let folderUrl = URL(fileURLWithPath: Bundle.main.resourcePath!)
        do{
            let songPath = try FileManager.default.contentsOfDirectory(at: folderUrl, includingPropertiesForKeys: nil, options: .skipsHiddenFiles)
            for song in songPath{
                var mySong = song.absoluteString
                if mySong.contains(".mp3")
                {
                    let findString = mySong.components(separatedBy: "/")
                    mySong = findString[findString.count - 1]
                    mySong = mySong.replacingOccurrences(of: ".mp3", with: "")
                    songs.append(mySong)
                }
            }
            tableView.reloadData()
        }
        catch{
            print("Error")
        }
    }

}
extension ViewController : UITableViewDataSource,UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return songs.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.textLabel?.text = songs[indexPath.row]
        cell.textLabel?.textColor = UIColor.blue
        cell.textLabel?.font = UIFont(name: "myriad-set-pro_bold", size: 18)
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        do {
            FirstTimePlay = false
            if indexPath.row != songs.count - 1{
                nextSong = indexPath.row + 1
            }
            if indexPath.row != 0{
                  prevSong = indexPath.row - 1
            }
            let audioPath = Bundle.main.path(forResource: songs[indexPath.row], ofType: ".mp3")
            try audioPlayer = AVAudioPlayer(contentsOf: NSURL(fileURLWithPath: audioPath!) as URL)
            audioPlayer.play()
            playButton.setImage(UIImage(named: "pause.png"), for: .normal)
            audioPlayer.currentTime = 0
            songLabel.text = songs[indexPath.row]
        }
        catch {
             print("Error")
        }
    }
}
