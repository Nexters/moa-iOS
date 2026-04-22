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

    /// HistoryViewController에서 받은 joinedAt을 캐싱
    /// WorkViewController의 "일정 조정" 플로우에서도 동일하게 활용
    private var cachedJoinedAt: Date?

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
        joinedAt: Date? = nil,
        isDateSelectable: Bool = true
    ) -> FixScheduleViewController {
        let vm = FixScheduleViewModel(
            viewType: viewType,
            historyUseCase: container.historyUseCase,
            preselectedDate: preselectedDate,
            existingSchedule: existingSchedule,
            joinedAt: joinedAt,
            isDateSelectable: isDateSelectable
        )
        let vc = FixScheduleViewController(viewModel: vm)
        vc.coordinatorDelegate = self
        return vc
    }

    /// 일정 추가
    func showAddSchedule(selectedDate: Date?, joinedAt: Date?) {
        let vc = makeFixScheduleViewController(
            viewType: .add,
            preselectedDate: selectedDate,
            joinedAt: joinedAt
        )
        nav?.pushViewController(vc, animated: true)
    }

    /// 일정 수정 (HistoryViewController → 캘린더 날짜 탭)
    func showFixSchedule(workday: CalendarScheduleEntity, joinedAt: Date?) {
        let existing = FixScheduleViewModel.makeState(from: workday)
        let vc = makeFixScheduleViewController(
            viewType: .fix,
            existingSchedule: existing,
            joinedAt: joinedAt
        )
        nav?.pushViewController(vc, animated: true)
    }

    /// 근무 중 "일정 조정" / idle "근무 시간 수정"
    /// → 오늘 날짜 고정(isDateSelectable: false)으로 FixScheduleViewController push
    func showChangeSchedule(workday: CalendarScheduleEntity, joinedAt: Date?) {
        let existing = FixScheduleViewModel.makeState(from: workday)
        let vc = makeFixScheduleViewController(
            viewType: .fix,
            existingSchedule: existing,
            joinedAt: joinedAt,
            isDateSelectable: false  // 오늘 날짜 고정, 날짜 선택 UI 비활성
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

    func workViewControllerDidTapChangeSchedule(
        _ viewController: WorkViewController,
        workday: CalendarScheduleEntity,
        joinedAt: Date?
    ) {
        showChangeSchedule(workday: workday, joinedAt: joinedAt ?? cachedJoinedAt)
    }
}

// MARK: - HistoryViewControllerCoordinatorDelegate

extension HomeCoordinator: HistoryViewControllerCoordinatorDelegate {

    func historyViewControllerDidTapEdit(
        _ vc: HistoryViewController,
        schedule: CalendarScheduleEntity?,
        selectedDate: Date?,
        joinedAt: Date?
    ) {
        if let joinedAt { cachedJoinedAt = joinedAt }
        
        if let schedule {
            showFixSchedule(workday: schedule, joinedAt: joinedAt)
        } else {
            showAddSchedule(
                selectedDate: selectedDate,
                joinedAt: joinedAt
            )
        }
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
