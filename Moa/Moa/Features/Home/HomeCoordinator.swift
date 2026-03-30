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
        observeFcmTokenRefresh() // 이후 갱신 감지용은 유지
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
        existingSchedule: FixScheduleViewState? = nil
    ) -> FixScheduleViewController {
        let vm = FixScheduleViewModel(
            viewType: viewType,
            historyUseCase: container.historyUseCase,
            preselectedDate: preselectedDate,
            existingSchedule: existingSchedule
        )
        let vc = FixScheduleViewController(viewModel: vm)
        vc.coordinatorDelegate = self
        return vc
    }

    /// 일정 추가
    func showAddSchedule() {
        let vc = makeFixScheduleViewController(viewType: .add)
        nav?.pushViewController(vc, animated: true)
    }

    /// 일정 수정 — CalendarScheduleEntity + 날짜로 기존 데이터 선입력
    func showFixSchedule(workday: CalendarScheduleEntity, date: Date) {
        let existing = FixScheduleViewModel.makeState(from: workday, date: date)
        let vc = makeFixScheduleViewController(viewType: .fix, existingSchedule: existing)
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
        schedule: CalendarScheduleEntity
    ) {
        showFixSchedule(workday: schedule, date: schedule.date)
    }
    

    func historyViewControllerDidTapAdd(
        _ vc: HistoryViewController
    ) {
        showAddSchedule()
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

//  MARK: - Fcm token
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
