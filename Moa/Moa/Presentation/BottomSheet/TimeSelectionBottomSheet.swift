//
//  TimeSelectionBottomSheet.swift
//  Moa
//
//  Created by 정도현 on 2/15/26.
//

import UIKit
import SnapKit

// MARK: - TimeSelectionBottomSheetDelegate

protocol TimeSelectionBottomSheetDelegate: AnyObject {
    func timeSelectionBottomSheet(
        _ sheet: TimeSelectionBottomSheet,
        didConfirmStartTime startTime: TimeIndicatorEntity,
        endTime: TimeIndicatorEntity
    )
    /// extendEndTime 케이스의 "취소" 탭, changeWorkTime 케이스의 "오늘 휴가" 탭
    /// 기본 구현 제공 (필요한 케이스에서만 override)
    func timeSelectionBottomSheetDidTapOption(_ sheet: TimeSelectionBottomSheet)
}

extension TimeSelectionBottomSheetDelegate {
    func timeSelectionBottomSheetDidTapOption(_ sheet: TimeSelectionBottomSheet) {}
}

// MARK: - TimeSelectionBottomSheetCase

enum TimeSelectionBottomSheetCase {
    case setEstimateTime    // 예상 출퇴근 시간 설정 (출근 → 퇴근 순서)
    case setWorkingHours    // 근무 시간 설정
    case changeWorkTime     // 근무 시간 수정 (출퇴근 모두, "오늘 휴가" 옵션)
    case extendEndTime      // 퇴근 시간만 연장 ("취소" 옵션)
    
    var title: String {
        switch self {
        case .setEstimateTime: return "예상 출퇴근 시간을 알려주세요"
        case .setWorkingHours: return "근무 시간을 알려주세요"
        case .changeWorkTime:  return "실제 근무 시간을 알려주세요"
        case .extendEndTime:   return "얼마나 더 일하나요?"
        }
    }
    
    /// 출근 버튼 탭 불가 여부 (퇴근 시간만 수정)
    var isEndTimeOnly: Bool {
        return self == .extendEndTime
    }
    
    /// 옵션 버튼 타이틀. nil이면 확인 버튼 단독 표시
    var optionButtonTitle: String? {
        switch self {
        case .extendEndTime:  return "취소"
        case .changeWorkTime: return "오늘 휴가"
        default:              return nil
        }
    }
    
    /// extendEndTime: 퇴근 선택 모드에서 바로 시작
    var initialSelectionMode: TimeSelectionMode {
        return self == .extendEndTime ? .selectingEnd : .selectingStart
    }
}

// MARK: - TimeSelectionBottomSheet

final class TimeSelectionBottomSheet: UIViewController {
    
    // MARK: - Properties

    weak var delegate: TimeSelectionBottomSheetDelegate?
    
    private let type: TimeSelectionBottomSheetCase
    private let initialStartTime: TimeIndicatorEntity
    private let initialEndTime:   TimeIndicatorEntity
    
    // MARK: - UI Components

    private let titleLabel: StyledLabel = {
        let label = StyledLabel()
        label.setStyle(.init(
            typography: AppTypography.t1_700,
            color:      AppColor.IconAndText.highEmphasis
        ))
        label.numberOfLines = 1
        return label
    }()
    
    private lazy var timeSelectionView: TimeSelectionView = {
        let view = TimeSelectionView(
            startTime:     initialStartTime,
            endTime:       initialEndTime,
            selectionMode: type.initialSelectionMode,
            isEndTimeOnly: type.isEndTimeOnly,
            optionTitle:   type.optionButtonTitle
        )
        view.delegate = self
        return view
    }()
    
    // MARK: - Initialization

    init(
        type:      TimeSelectionBottomSheetCase,
        startTime: TimeIndicatorEntity,
        endTime:   TimeIndicatorEntity
    ) {
        self.type             = type
        self.initialStartTime = startTime
        self.initialEndTime   = endTime
        super.init(nibName: nil, bundle: nil)
        titleLabel.setText(type.title)
    }
    
    required init?(coder: NSCoder) { fatalError() }
    
    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
    }
    
    // MARK: - Setup

    private func setupViews() {
        view.backgroundColor = AppColor.Container.primary
        
        view.addSubview(titleLabel)
        titleLabel.snp.makeConstraints {
            $0.top.equalToSuperview()
            $0.leading.trailing.equalToSuperview().inset(AppSpacing.screenHorizontal)
        }
        
        view.addSubview(timeSelectionView)
        timeSelectionView.snp.makeConstraints {
            $0.top.equalTo(titleLabel.snp.bottom).offset(16)
            $0.leading.trailing.equalToSuperview()
            $0.bottom.equalToSuperview()
        }
    }
}

// MARK: - BottomSheetPresentable

extension TimeSelectionBottomSheet: BottomSheetPresentable {}

// MARK: - TimeSelectionViewDelegate

extension TimeSelectionBottomSheet: TimeSelectionViewDelegate {

    func timeSelectionView(
        _ view: TimeSelectionView,
        didConfirmStartTime startTime: TimeIndicatorEntity,
        endTime: TimeIndicatorEntity
    ) {
        delegate?.timeSelectionBottomSheet(self, didConfirmStartTime: startTime, endTime: endTime)
        
        if let bottomSheet = parent as? BottomSheetViewController {
            bottomSheet.animateDismiss()
        }
    }

    /// 옵션 버튼 탭
    /// - extendEndTime: "취소" → 그냥 닫기
    /// - changeWorkTime: "오늘 휴가" → delegate 전달
    func timeSelectionViewDidTapOption(_ view: TimeSelectionView) {
        switch type {
        case .extendEndTime:
            // 취소: delegate 없이 시트만 닫음
            if let bottomSheet = parent as? BottomSheetViewController {
                bottomSheet.animateDismiss()
            } else {
                dismiss(animated: true)
            }
            
        case .changeWorkTime:
            // 오늘 휴가: delegate 전달 후 시트 닫음
            delegate?.timeSelectionBottomSheetDidTapOption(self)
            if let bottomSheet = parent as? BottomSheetViewController {
                bottomSheet.animateDismiss()
            } else {
                dismiss(animated: true)
            }
            
        default:
            break
        }
    }
}
