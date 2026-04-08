//
//  HomeCoordinator.swift
//  Moa
//
//  Created by 정도현 on 2/20/26.
//

import UIKit

final class HomeCoordinator {

    // MARK: - Properties

    private let container: AppContainer
    private weak var nav: UINavigationController?

    // MARK: - Init

    init(container: AppContainer) {
        self.container = container
    }

    // MARK: - Start

    func start(from parentNav: UINavigationController, animated: Bool) {
        self.nav = parentNav
        parentNav.setViewControllers([makeWorkViewController()], animated: animated)
        observeFcmTokenRefresh()
    }
}

// MARK: - Private Factory / Navigation

private extension HomeCoordinator {

    // MARK: Work

    func makeWorkViewController() -> WorkViewController {
        let vm = WorkViewModel(homeUseCase: container.homeUseCase)
        let vc = WorkViewController(viewModel: vm)
        vc.coordinatorDelegate = self
        return vc
    }

    // MARK: History

    func makeHistoryViewController() -> HistoryViewController {
        let vm = HistoryViewModel(historyUseCase: container.historyUseCase)
        let vc = HistoryViewController(viewModel: vm)
        vc.coordinatorDelegate = self
        return vc
    }

    func showHistory() {
        nav?.pushViewController(makeHistoryViewController(), animated: true)
    }

    // MARK: Setting

    func makeSettingViewController() -> SettingHomeViewController {
        let coordinator = SettingCoordinator(container: container, nav: nav)
        return SettingHomeViewController(
            coordinator: coordinator,
            viewModel: .init(settingUsecase: container.settingUsecase)
        )
    }

    func showSetting() {
        nav?.pushViewController(makeSettingViewController(), animated: true)
    }

    // MARK: FixSchedule

    func makeFixScheduleViewController(
        viewType: ScheduleTypeOptionViewType,
        preselectedDate: Date? = nil,
        existingSchedule: FixScheduleViewState? = nil,
        joinedAt: Date? = nil
    ) -> FixScheduleViewController {
        let vm = FixScheduleViewModel(
            viewType: viewType,
            historyUseCase: container.historyUseCase,
            preselectedDate: preselectedDate,
            existingSchedule: existingSchedule,
            joinedAt: joinedAt
        )
        let vc = FixScheduleViewController(viewModel: vm)
        vc.coordinatorDelegate = self
        return vc
    }

    /// 일정 추가 — joinedAt을 함께 전달해 날짜 선택 캘린더에 이전 달 이동 제한 적용
    func showAddSchedule(joinedAt: Date?) {
        let vc = makeFixScheduleViewController(viewType: .add, joinedAt: joinedAt)
        nav?.pushViewController(vc, animated: true)
    }

    /// 일정 수정 — joinedAt을 함께 전달해 날짜 선택 캘린더에 이전 달 이동 제한 적용
    func showFixSchedule(workday: CalendarScheduleEntity, joinedAt: Date?) {
        let existing = FixScheduleViewModel.makeState(from: workday)
        let vc = makeFixScheduleViewController(
            viewType: .fix,
            existingSchedule: existing,
            joinedAt: joinedAt
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

    func workViewControllerDidTapSetting(_ viewController: WorkViewController) {
        showSetting()
    }

    func workViewControllerDidTapWorkComplete(_ viewController: WorkViewController) {
        // WorkViewController 내부에서 처리 — Coordinator 추가 작업 없음
    }
}

// MARK: - HistoryViewControllerCoordinatorDelegate

extension HomeCoordinator: HistoryViewControllerCoordinatorDelegate {

    func historyViewControllerDidTapEdit(
        _ vc: HistoryViewController,
        schedule: CalendarScheduleEntity,
        joinedAt: Date?
    ) {
        showFixSchedule(workday: schedule, joinedAt: joinedAt)
    }

    func historyViewControllerDidTapAdd(_ vc: HistoryViewController, joinedAt: Date?) {
        showAddSchedule(joinedAt: joinedAt)
    }
}

// MARK: - FixScheduleViewControllerDelegate

extension HomeCoordinator: FixScheduleViewControllerDelegate {

    func fixScheduleViewControllerDidCancel(_ vc: FixScheduleViewController) {
        pop()
    }

    func fixScheduleViewControllerDidConfirm(
        _ vc: FixScheduleViewController,
        state: FixScheduleViewState
    ) {
        pop()
    }
}

// MARK: - FCM Token

private extension HomeCoordinator {

    func observeFcmTokenRefresh() {
        NotificationCenter.default.addObserver(
            forName: .fcmTokenRefreshed,
            object: nil,
            queue: .main
        ) { [weak self] notification in
            guard let self,
                  let fcmToken = notification.userInfo?["fcmToken"] as? String
            else { return }

            Task {
                await self.container.authUseCase.updateFcmToken(to: fcmToken)
            }
        }
    }
}
