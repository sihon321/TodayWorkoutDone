import SwiftUI
import Lottie
import UIKit

struct LottieView: UIViewRepresentable {
    var filename: String
    var loopMode: LottieLoopMode = .playOnce
    var contentMode: UIView.ContentMode = .scaleAspectFit
    var animationSpeed: CGFloat = 1.0

    // Coordinator를 사용하여 현재 로드된 애니메이션의 파일 이름을 저장합니다.
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    class Coordinator: NSObject {
        var parent: LottieView
        var currentFilename: String? // 현재 로드된 애니메이션의 파일 이름

        init(_ parent: LottieView) {
            self.parent = parent
        }
    }

    func makeUIView(context: Context) -> UIView {
        let view = UIView(frame: .zero)
        let animationView = LottieAnimationView(name: filename)
        animationView.contentMode = contentMode
        animationView.loopMode = loopMode
        animationView.animationSpeed = animationSpeed
        animationView.play()

        // Coordinator에 현재 파일 이름 저장
        context.coordinator.currentFilename = filename

        animationView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(animationView)

        NSLayoutConstraint.activate([
            animationView.heightAnchor.constraint(equalTo: view.heightAnchor),
            animationView.widthAnchor.constraint(equalTo: view.widthAnchor)
        ])

        return view
    }

    func updateUIView(_ uiView: UIView, context: Context) {
        if let animationView = uiView.subviews.first as? LottieAnimationView {
            // filename이 변경되었을 때만 애니메이션을 다시 로드합니다.
            if context.coordinator.currentFilename != filename {
                animationView.animation = LottieAnimation.named(filename)
                context.coordinator.currentFilename = filename // 변경된 파일 이름 저장
            }

            // 그 외 속성들은 항상 업데이트합니다.
            animationView.loopMode = loopMode
            animationView.contentMode = contentMode
            animationView.animationSpeed = animationSpeed
            
            // 애니메이션이 정지되어 있다면 다시 재생
            if !animationView.isAnimationPlaying {
                animationView.play()
            }
        }
    }
}
