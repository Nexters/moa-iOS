//
//  HomeViewModel.swift
//  Moa
//
//  Created by 정도현 on 2/17/26.
//


import Foundation
import Combine

// MARK: - ViewState

enum HomeViewState: Equatable {
    case idle
    case loading
    case loaded(HomeViewData)
    case error(HomeError)
    
    static func == (lhs: HomeViewState, rhs: HomeViewState) -> Bool {
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
    
    var autoWorkText: String {
        "\(workTime.start.displayString) 자동 출근 예정"
    }
}

struct WorkTime: Equatable {
    let start: TimeIndicatorEntity
    let end: TimeIndicatorEntity
    
    var displayRange: String {
        "\(start.displayString) - \(end.displayString)"
    }
    
    var durationInHours: Double {
        let startMinutes = start.hour * 60 + start.minute
        let endMinutes = end.hour * 60 + end.minute
        return Double(endMinutes - startMinutes) / 60.0
    }
}

struct MonthlyInfo: Equatable {
    let month: Int
    let currentAmount: Int
    let baseAmount: Int
    
    var progressRate: Double {
        guard baseAmount > 0 else { return 0 }
        return Double(currentAmount) / Double(baseAmount)
    }
}

struct LocationInfo: Equatable {
    let name: String
    let address: String?
}

// MARK: - Error

enum HomeError: LocalizedError {
    case networkError
    case dataParsingError
    case unauthorized
    case unknown(Error)
    
    var errorDescription: String? {
        switch self {
        case .networkError:
            return "네트워크 연결을 확인해주세요."
        case .dataParsingError:
            return "데이터를 처리하는 중 문제가 발생했습니다."
        case .unauthorized:
            return "로그인이 필요합니다."
        case .unknown(let error):
            return error.localizedDescription
        }
    }
}

// MARK: - ViewModel

final class HomeViewModel {
    
    // MARK: - Output
    
    @Published private(set) var state: HomeViewState = .idle
    
    // MARK: - Input Events
    
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

extension HomeViewModel {
    
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

private extension HomeViewModel {
    
    func loadInitialData() {
        guard state != .loading else { return }
        
        state = .loading
        
        
        // Mock 데이터
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
            self?.loadMockData()
        }
    }
    
    func updateWorkTime(start: TimeIndicatorEntity, end: TimeIndicatorEntity) {
        guard var data = currentData else {
            state = .error(.dataParsingError)
            return
        }
        
        // 유효성 검증
        guard validateWorkTime(start: start, end: end) else {
            state = .error(.unknown(NSError(
                domain: "WorkTimeValidation",
                code: -1,
                userInfo: [NSLocalizedDescriptionKey: "종료 시간이 시작 시간보다 빨라요."]
            )))
            return
        }
        
        let newWorkTime = WorkTime(start: start, end: end)
        
        // 일급 재계산
        let calculatedWage = calculateWage(for: newWorkTime)
        
        data = HomeViewData(
            wage: calculatedWage,
            workTime: newWorkTime,
            monthlyInfo: data.monthlyInfo,
            location: data.location
        )
        
        currentData = data
        state = .loaded(data)
    
    }
    
    func handleStartWork() {
    }
    
    func handleVacationRequest() {
        
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
        let hourlyWage = 15_000
        let hours = workTime.durationInHours
        return Int(Double(hourlyWage) * hours)
    }
    
    // MARK: - Mock Data (개발용)

    func loadMockData() {
        let initialWorkTime = WorkTime(
            start: .from(hour: 9, minute: 0),
            end: .from(hour: 18, minute: 0)
        )
        
        let monthlyInfo = MonthlyInfo(
            month: 2,
            currentAmount: 1_500_000,
            baseAmount: 1_200_000
        )
        
        let location = LocationInfo(
            name: "을지로",
            address: "서울특별시 중구 을지로"
        )
        
        let data = HomeViewData(
            wage: 150_000,
            workTime: initialWorkTime,
            monthlyInfo: monthlyInfo,
            location: location
        )
        
        currentData = data
        state = .loaded(data)
    }
}
