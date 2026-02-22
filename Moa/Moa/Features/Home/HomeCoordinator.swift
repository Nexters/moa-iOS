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

    func makeSettingViewController() -> SettingHomeViewController {
        let coordinator = SettingCoordinator(
            container: container,
            nav: nav
        )
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
            preselectedDate: preselectedDate,
            existingSchedule: existingSchedule
        )
        let vc = FixScheduleViewController(viewModel: vm)
        vc.coordinatorDelegate = self
        return vc
    }

    func showAddSchedule() {
        let vc = makeFixScheduleViewController(viewType: .add)
        nav?.pushViewController(vc, animated: true)
    }

    func showFixSchedule(existing: FixScheduleViewState) {
        let vc = makeFixScheduleViewController(viewType: .fix, existingSchedule: existing)
        nav?.pushViewController(vc, animated: true)
    }

    func pop() {
        nav?.popViewController(animated: true)
    }
}

// MARK: - WorkViewControllerCoordinatorDelegate

extension HomeCoordinator: WorkViewControllerCoordinatorDelegate {

    /// 네비게이션 바 캘린더 아이콘 탭 → 캘린더(History) 화면
    func workViewControllerDidTapCalendar(_ viewController: WorkViewController) {
        showHistory()
    }

    func workViewControllerDidTapSetting(_ viewController: WorkViewController) {
        showSetting()
    }

    /// 근무완료 1에서 "완료" 탭 → 최종 완료 페이지
    ///
    /// 최종 완료 페이지는 기존 WorkMainContentView를 status: .finished로 렌더링:
    ///   - MonthlySalaryView: imgFullMoney 이미지, 금액 녹색, + 접두사 없음
    ///   - WorkMainSummaryView: dailyPay 표기, 휴가 시 "휴가", chevron X, 수정 불가
    ///   - 하단 버튼 영역: idle 전용이므로 숨겨짐
    ///
    /// WorkViewController.hasConfirmedWork = true 로 이미 설정되어 있으므로
    /// render(.loaded(status: .finished, data:)) 시 renderFinalComplete() 분기로 진입.
    /// → 별도 VC push 없이 WorkViewController 내에서 workMainView를 전환.
    func workViewControllerDidTapWorkComplete(_ viewController: WorkViewController) {
        // WorkViewController 내부에서 hasConfirmedWork = true 설정 후 delegate 호출.
        // render()가 viewModel state를 구독 중이므로 최신 state로 re-render 트리거.
        // (ViewModel state는 .finished 유지 — 별도 액션 불필요)
        // WorkViewController가 직접 renderFinalComplete()를 처리하므로 Coordinator 추가 작업 없음.
    }
}

// MARK: - HistoryViewControllerCoordinatorDelegate

extension HomeCoordinator: HistoryViewControllerCoordinatorDelegate {

    func historyViewControllerDidTapAdd(_ vc: HistoryViewController) {
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
