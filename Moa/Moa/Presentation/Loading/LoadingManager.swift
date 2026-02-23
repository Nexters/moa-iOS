import UIKit

final class LoadingManager {

    static let shared = LoadingManager()

    private var loadingView: MoaLoadingView?
    private var referenceCount: Int = 0

    private var pendingWorkItem: DispatchWorkItem?
    private let delay: TimeInterval = 0.5

    private init() {}

    // MARK: - Show (0.5초 지연)

    func show() {
        DispatchQueue.main.async {
            self.referenceCount += 1

            // 이미 표시 중이면 추가 작업 없음
            if self.loadingView != nil { return }

            // 이미 예약되어 있으면 중복 예약 방지
            if self.pendingWorkItem != nil { return }

            let workItem = DispatchWorkItem { [weak self] in
                guard let self else { return }
                guard self.referenceCount > 0 else { return }
                guard let window = Self.keyWindow else { return }

                let view = MoaLoadingView(frame: window.bounds)
                window.addSubview(view)
                view.start()

                self.loadingView = view
                self.pendingWorkItem = nil
            }

            self.pendingWorkItem = workItem
            DispatchQueue.main.asyncAfter(deadline: .now() + self.delay, execute: workItem)
        }
    }

    // MARK: - Hide

    func hide() {
        DispatchQueue.main.async {

            guard self.referenceCount > 0 else { return }
            self.referenceCount -= 1

            // 아직 0.5초 안 지났다면 → 예약 취소
            if self.referenceCount == 0 {
                self.pendingWorkItem?.cancel()
                self.pendingWorkItem = nil
            }

            guard self.referenceCount == 0,
                  let view = self.loadingView
            else { return }

            view.stop {
                view.removeFromSuperview()
            }

            self.loadingView = nil
        }
    }

    // MARK: - Window

    private static var keyWindow: UIWindow? {
        UIApplication.shared
            .connectedScenes
            .compactMap { ($0 as? UIWindowScene)?.keyWindow }
            .first
    }
}
