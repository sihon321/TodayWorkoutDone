//
//  LoopingVideoPlayerView.swift
//  TodayworkoutDone
//
//  Created by ocean on 7/7/25.
//

import SwiftUI
import AVKit

struct LoopingVideoPlayerView: View {
    // 1. @StateObject를 사용해 LoopingPlayerManager 인스턴스를 생성하고 유지합니다.
    @StateObject private var playerManager: LoopingPlayerManager
    
    // 뷰를 초기화할 때 재생할 비디오 파일 이름을 받습니다.
    init?(videoFileName: String = "sampleVideo", fileExtension: String = "mp4") {
        guard let manager = LoopingPlayerManager(
            videoFileName: videoFileName,
            fileExtension: fileExtension
        ) else {
            return nil
        }
        _playerManager = StateObject(wrappedValue: manager)
    }

    var body: some View {
        // 2. VideoPlayer 뷰에 관리 객체의 player를 전달합니다.
        VideoPlayer(player: playerManager.player)
            .aspectRatio(16/9, contentMode: .fit)
            .frame(maxWidth: .infinity, maxHeight: 300)
            .onAppear {
                // 뷰가 나타나면 소리를 끄고 재생을 시작합니다.
                // 백그라운드 비디오 등에 유용합니다.
                playerManager.player.isMuted = true
                playerManager.player.play()
            }
            .onDisappear {
                // 뷰가 사라지면 재생을 멈춥니다.
                playerManager.player.pause()
            }
            .ignoresSafeArea() // 화면 전체를 채우도록 설정
    }
}
