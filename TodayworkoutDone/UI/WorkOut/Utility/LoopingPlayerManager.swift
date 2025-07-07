//
//  LoopingPlayerManager.swift
//  TodayworkoutDone
//
//  Created by ocean on 7/7/25.
//

import Foundation
import AVFoundation

// 플레이어 로직을 관리하는 ObservableObject 클래스
class LoopingPlayerManager: ObservableObject {
    let player: AVQueuePlayer
    private var playerLooper: AVPlayerLooper?
    
    init(videoFileName: String, fileExtension: String) {
        // 1. 비디오 파일 URL 가져오기
        guard let fileUrl = Bundle.main.url(
            forResource: videoFileName,
            withExtension: fileExtension
        ) else {
            // URL을 찾지 못하면 빈 플레이어를 생성합니다.
            // 실제 앱에서는 오류 처리를 더 견고하게 해야 합니다.
            self.player = AVQueuePlayer()
            return
        }
        
        // 2. AVPlayerItem, AVQueuePlayer, AVPlayerLooper 생성
        let playerItem = AVPlayerItem(url: fileUrl)
        self.player = AVQueuePlayer(playerItem: playerItem)
        self.playerLooper = AVPlayerLooper(player: self.player, templateItem: playerItem)
    }
}
