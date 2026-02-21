//
//  HomeCoordinator.swift
//  Moa
//
//  Created by 정도현 on 2/20/26.
//

import UIKit

final class HomeCoordinator {

    // MARK: - Properties

    private weak var nav: UINavigationController?

    // MARK: - Init

    init() {}

    // MARK: - Start

    func start(from parentNav: UINavigationController, animated: Bool) {
        self.nav = parentNav
        parentNav.setViewControllers([makeWorkViewController()], animated: animated)
    }
}

// MARK: - Private Factory / Navigation

private extension HomeCoordinator {

    // MARK: Work

    func makeWorkViewController() -> WorkViewController {
        let vm = WorkViewModel()
        let vc = WorkViewController(viewModel: vm)
        vc.coordinatorDelegate = self
        return vc
    }

    // MARK: History

    func makeHistoryViewController() -> HistoryViewController {
        let vc = HistoryViewController()
        vc.coordinatorDelegate = self
        return vc
    }

    func showHistory() {
        nav?.pushViewController(makeHistoryViewController(), animated: true)
    }

    // MARK: FixSchedule

    /// - Parameters:
    ///   - viewType: .add (추가) / .fix (수정)
    ///   - preselectedDate: 캘린더에서 미리 선택된 날짜 — 추가 플로우에서 자동 세팅
    func makeFixScheduleViewController(
        viewType: ScheduleTypeOptionViewType,
        preselectedDate: Date? = nil,
        existingSchedule: FixScheduleViewState? = nil
    ) -> FixScheduleViewController {
        let vm = FixScheduleViewModel(
            viewType: viewType,
            preselectedDate: preselectedDate,
            existingSchedule: existingSchedule
        )
        let vc = FixScheduleViewController(viewModel: vm)
        vc.coordinatorDelegate = self
        return vc
    }

    func showAddSchedule() {
        let vc = makeFixScheduleViewController(
            viewType: .add
        )
        nav?.pushViewController(vc, animated: true)
    }

    func showFixSchedule(existing: FixScheduleViewState) {
        let vc = makeFixScheduleViewController(
            viewType: .fix,
            existingSchedule: existing
        )
        nav?.pushViewController(vc, animated: true)
    }

    func pop() {
        nav?.popViewController(animated: true)
    }
}

// MARK: - WorkViewControllerCoordinatorDelegate

extension HomeCoordinator: WorkViewControllerCoordinatorDelegate {

    func workViewControllerDidTapCalendar(_ viewController: WorkViewController) {
        showHistory()
    }
}

// MARK: - HistoryViewControllerCoordinatorDelegate

extension HomeCoordinator: HistoryViewControllerCoordinatorDelegate {

    /// CalendarView + 버튼 → FixScheduleVC(.add) push
    func historyViewControllerDidTapAdd(
        _ vc: HistoryViewController
    ) {
        showAddSchedule()
    }
}

// MARK: - FixScheduleViewControllerDelegate

extension HomeCoordinator: FixScheduleViewControllerDelegate {

    /// 취소 → 뒤로
    func fixScheduleViewControllerDidCancel(_ vc: FixScheduleViewController) {
        pop()
    }

    /// 확인 (ViewModel이 API 전송 완료) → 뒤로
    /// 성공 후 HistoryVC 데이터 갱신이 필요하면 NotificationCenter or Combine publisher 활용
    func fixScheduleViewControllerDidConfirm(
        _ vc: FixScheduleViewController,
        state: FixScheduleViewState
    ) {
        pop()
    }
}
