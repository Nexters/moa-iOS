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
        let rootVC = makeWorkViewController()
        parentNav.setViewControllers([rootVC], animated: animated)
    }
}

// MARK: - Private

private extension HomeCoordinator {

    func makeWorkViewController() -> WorkViewController {
        let vm = WorkViewModel()
        let vc = WorkViewController(viewModel: vm)
        vc.coordinatorDelegate = self
        return vc
    }

    func makeHistoryViewController() -> HistoryViewController {
        let vc = HistoryViewController()
        return vc
    }

    func showHistory() {
        nav?.pushViewController(makeHistoryViewController(), animated: true)
    }

    func popToWork() {
        nav?.popViewController(animated: true)
    }
}

// MARK: - WorkViewControllerCoordinatorDelegate

extension HomeCoordinator: WorkViewControllerCoordinatorDelegate {

    func workViewControllerDidTapCalendar(_ viewController: WorkViewController) {
        showHistory()
    }
}
