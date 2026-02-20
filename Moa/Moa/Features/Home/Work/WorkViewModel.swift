//
//  WorkViewModel.swift
//  Moa
//
//  Created by 정도현 on 2/17/26.
//

import Foundation
import Combine

// MARK: - WorkStatus

enum WorkStatus: Equatable {
    case beforeWork
    case working(startedAt: Date)

    var isWorking: Bool {
        if case .working = self { return true }
        return false
    }
}

// MARK: - ViewState

enum WorkViewState: Equatable {
    case idle
    case loading
    case loaded(HomeViewData)
    case error(HomeError)

    static func == (lhs: WorkViewState, rhs: WorkViewState) -> Bool {
        switch (lhs, rhs) {
        case (.idle, .idle), (.loading, .loading):
            return true
        case let (.loaded(lData), .loaded(rData)):
            return lData == rData
        case let (.error(lError), .error(rError)):
            return lError.localizedDescription == rError.localizedDescription
        default:
            return false
        }
    }
}

// MARK: - ViewData

struct HomeViewData: Equatable {
    let wage: Int
    let workTime: WorkTime
    let monthlyInfo: MonthlyInfo
    let location: LocationInfo
    let workStatus: WorkStatus

    var autoWorkText: String {
        "\(workTime.start.displayString) 자동 출근 예정"
    }

    static func == (lhs: HomeViewData, rhs: HomeViewData) -> Bool {
        lhs.wage == rhs.wage &&
        lhs.workTime == rhs.workTime &&
        lhs.monthlyInfo == rhs.monthlyInfo &&
        lhs.location == rhs.location &&
        lhs.workStatus == rhs.workStatus
    }
}

// MARK: - WorkTime

struct WorkTime: Equatable {
    let start: TimeIndicatorEntity
    let end: TimeIndicatorEntity

    var displayRange: String {
        "\(start.displayString) - \(end.displayString)"
    }

    var durationInHours: Double {
        let startMinutes = start.hour * 60 + start.minute
        let endMinutes = end.hour * 60 + end.minute
        return Double(max(endMinutes - startMinutes, 0)) / 60.0
    }
}

// MARK: - MonthlyInfo

struct MonthlyInfo: Equatable {
    let month: Int
    let currentAmount: Int
    let baseAmount: Int

    var progressRate: Double {
        guard baseAmount > 0 else { return 0 }
        return Double(currentAmount) / Double(baseAmount)
    }
}

// MARK: - LocationInfo

struct LocationInfo: Equatable {
    let name: String
    let address: String?
}

// MARK: - HomeError

enum HomeError: LocalizedError {
    case networkError
    case dataParsingError
    case unauthorized
    case workTimeInvalid
    case unknown(Error)

    var errorDescription: String? {
        switch self {
        case .networkError:
            return "네트워크 연결을 확인해주세요."
        case .dataParsingError:
            return "데이터를 처리하는 중 문제가 발생했습니다."
        case .unauthorized:
            return "로그인이 필요합니다."
        case .workTimeInvalid:
            return "종료 시간이 시작 시간보다 빨라요."
        case .unknown(let error):
            return error.localizedDescription
        }
    }
}

// MARK: - ViewModel

final class WorkViewModel {

    // MARK: - Output

    @Published private(set) var state: WorkViewState = .idle

    // MARK: - Input

    enum Input {
        case viewDidLoad
        case updateWorkTime(start: TimeIndicatorEntity, end: TimeIndicatorEntity)
        case startWork
        case requestVacation
    }

    // MARK: - Private Properties

    private var cancellables = Set<AnyCancellable>()
    private var currentData: HomeViewData?

    // MARK: - Init

    init() { }

    deinit {
        cancellables.removeAll()
    }
}

// MARK: - Public Methods

extension WorkViewModel {

    func send(_ input: Input) {
        switch input {
        case .viewDidLoad:
            loadInitialData()

        case let .updateWorkTime(start, end):
            updateWorkTime(start: start, end: end)

        case .startWork:
            handleStartWork()

        case .requestVacation:
            handleVacationRequest()
        }
    }
}

// MARK: - Private Methods

private extension WorkViewModel {

    func loadInitialData() {
        guard state != .loading else { return }
        state = .loading

        // 실제 구현: API 호출
        // workRepository.fetchTodayWork()
        //     .receive(on: DispatchQueue.main)
        //     .sink { ... }
        //     .store(in: &cancellables)

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
            self?.loadMockData()
        }
    }

    func updateWorkTime(start: TimeIndicatorEntity, end: TimeIndicatorEntity) {
        guard var data = currentData else {
            state = .error(.dataParsingError)
            return
        }

        guard validateWorkTime(start: start, end: end) else {
            state = .error(.workTimeInvalid)
            return
        }

        let newWorkTime = WorkTime(start: start, end: end)
        let calculatedWage = calculateWage(for: newWorkTime)

        data = HomeViewData(
            wage: calculatedWage,
            workTime: newWorkTime,
            monthlyInfo: data.monthlyInfo,
            location: data.location,
            workStatus: data.workStatus
        )

        currentData = data
        state = .loaded(data)

        // 실제 구현: API 호출하여 서버에 저장
        // workRepository.updateWorkTime(start: start, end: end)
    }

    func handleStartWork() {
        guard var data = currentData else {
            state = .error(.dataParsingError)
            return
        }

        // 이미 근무 중이면 무시
        guard !data.workStatus.isWorking else { return }

        // 실제 구현: API 호출 후 성공 시 상태 변경
        // workRepository.startWork()
        //     .sink { ... }
        //     .store(in: &cancellables)

        data = HomeViewData(
            wage: data.wage,
            workTime: data.workTime,
            monthlyInfo: data.monthlyInfo,
            location: data.location,
            workStatus: .working(startedAt: Date())
        )

        currentData = data
        state = .loaded(data)
    }

    func handleVacationRequest() {
        // 실제 구현: API 호출
        // workRepository.requestVacation()
    }

    func handleError(_ error: Error) {
        let homeError: HomeError
        if let urlError = error as? URLError {
            homeError = urlError.code == .notConnectedToInternet ? .networkError : .unknown(error)
        } else {
            homeError = .unknown(error)
        }
        state = .error(homeError)
    }

    func validateWorkTime(start: TimeIndicatorEntity, end: TimeIndicatorEntity) -> Bool {
        let startMinutes = start.hour * 60 + start.minute
        let endMinutes = end.hour * 60 + end.minute
        return endMinutes > startMinutes
    }

    func calculateWage(for workTime: WorkTime) -> Int {
        let hourlyWage = 15_000 // 실제로는 사용자 데이터에서 가져와야 함
        return Int(Double(hourlyWage) * workTime.durationInHours)
    }

    // MARK: - Mock Data (개발용)

    func loadMockData() {
        let initialWorkTime = WorkTime(
            start: .from(hour: 9, minute: 0),
            end: .from(hour: 18, minute: 0)
        )
        let data = HomeViewData(
            wage: 150_000,
            workTime: initialWorkTime,
            monthlyInfo: MonthlyInfo(
                month: 2,
                currentAmount: 1_500_000,
                baseAmount: 1_200_000
            ),
            location: LocationInfo(
                name: "을지로",
                address: "서울특별시 중구 을지로"
            ),
            workStatus: .beforeWork
        )
        currentData = data
        state = .loaded(data)
    }
}

// MARK: - Testable (Unit Test용)

#if DEBUG
extension WorkViewModel {
    func setState(_ state: WorkViewState) {
        self.state = state
    }

    func getCurrentData() -> HomeViewData? {
        return currentData
    }
}
#endif
