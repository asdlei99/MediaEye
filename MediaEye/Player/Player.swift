//
//  PlayerManager.swift
//  MediaEye
//
//  Created by levinyang(杨亦伟) on 2019/12/11.
//  Copyright © 2019 levinyang(杨亦伟). All rights reserved.
//

import Cocoa

fileprivate var player: Player?


class Player {

    static let FrameNotification = "FrameNotificaiton"
    static let PacketNotification = "PacketNotification"
    var progress: Float {
        
        get {
            return FFP_progress()*100
        }
    }
    var videoStream: AVStream?
    var audioStream: AVStream?
    
    var packets = [AVPacket]()
    var frames = [AVFrame]()
    init() {
                
        player = self
        registerEventHandler()
    }
    func play(url: String) {
        
        FFP_play(url)
        videoStream = getVideoStream()
    }
   fileprivate func handleEvent(_ event: FFP_Event, data: UnsafeMutableRawPointer?) {
          
    switch event {
    case FFP_Event_PushPacket:
        
        if let packet = data?.load(as: AVPacket.self) {
            packets.append(packet)
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: Player.PacketNotification), object: self, userInfo: ["packet": packet])
        }
        
    case FFP_Event_PushFrame:
        
        if let frame = data?.load(as: AVFrame.self) {
            frames.append(frame)
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: Player.FrameNotification), object: self, userInfo: ["frame": frame])

        }
    default:
        print("")
        
    }
   }
}
private func registerEventHandler() {
    
    FFP_eventNotify {(event, data) in
               
        player?.handleEvent(event, data: data)
    }
}