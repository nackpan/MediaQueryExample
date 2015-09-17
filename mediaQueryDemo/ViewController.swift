//
//  ViewController.swift
//  mediaQueryDemo
//
//  Created by KUWAJIMA MITSURU on 2015/09/16.
//  Copyright (c) 2015年 nackpan. All rights reserved.
//

import UIKit
import MediaPlayer


class ViewController: UIViewController, UITextFieldDelegate, UITableViewDelegate, UITableViewDataSource {
    
    struct Song {
        let title:String
        let album:String
        init(title: String, album: String) {
            self.title = title
            self.album = album
        }
    }
    
    @IBOutlet weak var artistField: UITextField!
    
    @IBOutlet weak var tableView: UITableView!
    
    let kCellIdentifier = "TableCell"
    
    var player = MPMusicPlayerController()
    
    var songs = [Song]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        player = MPMusicPlayerController.applicationMusicPlayer()
        //player = MPMusicPlayerController.systemMusicPlayer()
        
        // artist fieldのdelegate先をselfとする(「改行」を検知する)
        artistField.delegate = self
        
        
        // tableViewのdelagete先をselfとする
        tableView.delegate = self
        tableView.dataSource = self
        
        // テーブルセルを登録
        tableView.registerClass(UITableViewCell.self, forCellReuseIdentifier: kCellIdentifier)
        

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // アーティスト名で絞りこみ
    func filteredArtistQuery(artist: String)-> MPMediaQuery! {
        // 「曲」を取得
        let query = MPMediaQuery.songsQuery()
        
        
        // アーティスト名で絞り込む
        let predicate = MPMediaPropertyPredicate(value: artist, forProperty: MPMediaItemPropertyArtist, comparisonType: MPMediaPredicateComparison.Contains)
        query.addFilterPredicate(predicate)

        player.setQueueWithQuery(query)
        
        return query
        
    }
    
    // 曲情報を更新（テーブル表示用に使う）
    func updateSongsWithQuery(query:MPMediaQuery!) {
        if query == nil {
            return
        }
        
        songs.removeAll(keepCapacity: false)
        
        
        if let collections = query.collections {
            for collection in collections {
                for item in collection.items {
                    let title: String = item.title != nil ? item.title! : ""
                    let album: String = item.albumTitle != nil ? item.albumTitle! : ""
                    let song = Song(title: title, album: album)
                    songs.append(song)
                }
            }
        }
    }
    


    @IBAction func doneBtnTapped(sender: AnyObject) {
        // キーボードをひっこめる
        if artistField.isFirstResponder() {
            artistField.resignFirstResponder()
        }
        
        // textを取得
        let artistText: String = artistField.text != nil ? artistField.text! : ""
        if artistText == "" {
            return
        }
        
        // 非同期でアーティスト名で絞り込む
        dispatch_async(dispatch_get_global_queue(Int(QOS_CLASS_USER_INITIATED.rawValue), 0)) {
            // アーティスト名で絞り込み
            let query = self.filteredArtistQuery(artistText)
            // プレイヤーに絞り込んだqueryを与える
            self.player.setQueueWithQuery(query)
        
            // songsを更新
            self.updateSongsWithQuery(query)
        
            // メインスレッドでテーブルを描画
            dispatch_async(dispatch_get_main_queue()) {
                // テーブルを描画
                self.tableView.reloadData()
                
                // 再生
                self.player.play()

            }
        }
        
    }
    
    
    /// artist fieldで「改行」が押された
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        // 実行ボタンが押されたのと同様の処理
        doneBtnTapped(textField)

        
        return true
    }
    
    
    @IBAction func pushPlay(sender: AnyObject) {
        player.play()
    }
    
    @IBAction func pushPause(sender: AnyObject) {
        player.pause()
    }
    
    @IBAction func pushStop(sender: AnyObject) {
        player.stop()
    }
    
    // MARK: Table View
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        // indexPathが示すセルを取得
        let cell = tableView.dequeueReusableCellWithIdentifier(kCellIdentifier, forIndexPath: indexPath) 
        
        // セルを更新
        let song = songs[indexPath.row]
        cell.textLabel?.text = song.title + "(" + song.album + ")"

        return cell
        
    }

    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return songs.count
    }
    
    
//    //albums query
//    func filteredAlbumsQuery() {
//        let query = MPMediaQuery.albumsQuery()
//
//
//        query.addFilterPredicate(MPMediaPropertyPredicate(value: false, forProperty: MPMediaItemPropertyIsCloudItem))
//
//        // 取得したアルバム情報を表示
//        let collections = query.collections
//        for collection in collections as! [MPMediaItemCollection] {
//            if let representativeTitle = collection.representativeItem.albumTitle {
//                println("アルバム名: \(representativeTitle)  曲数: \(collection.items.count)")
//            }
//        }
//    }


}





