//
//  VideoThumbnailView.swift
//  TodayworkoutDone
//
//  Created by ocean on 7/7/25.
//

import SwiftUI
import AVKit
import AVFoundation

struct VideoThumbnailView: View {
    let videoURL: URL?
    @State private var thumbnailImage: Image? = nil
    @State private var isLoadingThumbnail: Bool = false
    @State private var errorMessage: String? = nil
    
    init(videoFileName: String? = "sampleVideo",
         fileExtension: String = "mp4") {
        videoURL = Bundle.main.url(
            forResource: videoFileName,
            withExtension: fileExtension
        )
    }

    var body: some View {
        VStack {
            if isLoadingThumbnail {
                ProgressView()
                    .frame(width: 50, height: 50)
            } else if errorMessage != nil {
                if let image = UIImage(named: "default") {
                    Image(uiImage: image)
                        .resizable()
                        .frame(width: 50, height: 50)
                        .cornerRadius(10)
                }
            } else if let thumbnailImage = thumbnailImage {
                thumbnailImage
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 50, height: 50)
                    .cornerRadius(10)
            }
        }
        .onAppear {
            generateThumbnail()
        }
    }

    private func generateThumbnail() {
        isLoadingThumbnail = true
        errorMessage = nil
        thumbnailImage = nil

        // AVAsset을 생성하여 비디오를 나타냅니다.
        guard let videoURL = videoURL else {
            isLoadingThumbnail = false
            errorMessage = "비디오 URL이 없습니다."
            return
        }
        let asset = AVAsset(url: videoURL)
        let imageGenerator = AVAssetImageGenerator(asset: asset)

        // 비디오의 특정 시점(초)을 지정합니다.
        // 예를 들어, 비디오 시작 후 1초 지점의 이미지를 가져옵니다.
        let time = CMTime(seconds: 2.5, preferredTimescale: 600) // 1초, 600은 시간 스케일 (높을수록 정확)

        // 비동기적으로 썸네일 이미지를 생성합니다.
        imageGenerator.generateCGImageAsynchronously(for: time) { cgImage, actualTime, error in
            DispatchQueue.main.async {
                self.isLoadingThumbnail = false

                if let error = error {
                    self.errorMessage = "썸네일 생성 실패: \(error.localizedDescription)"
                    print("Error generating thumbnail: \(error.localizedDescription)")
                    return
                }

                guard let cgImage = cgImage else {
                    self.errorMessage = "썸네일 이미지를 가져올 수 없습니다."
                    return
                }

                // CGImage를 UIImage로 변환
                let uiImage = UIImage(cgImage: cgImage)
                // UIImage를 SwiftUI의 Image로 변환
                self.thumbnailImage = Image(uiImage: uiImage)
            }
        }
    }
}
