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
}

// MARK: - TimeSelectionBottomSheetCase
enum TimeSelectionBottomSheetCase {
    case setEstimateTime
    case setWorkingHours
    
    var title: String {
        switch self {
        case .setEstimateTime:
            return "예상 출퇴근 시간을 알려주세요"
        case .setWorkingHours:
            return "근무 시간을 알려주세요"
        }
    }
}

// MARK: - TimeSelectionBottomSheet
final class TimeSelectionBottomSheet: UIViewController {
    
    // MARK: - Properties
    weak var delegate: TimeSelectionBottomSheetDelegate?
    
    private let initialStartTime: TimeIndicatorEntity
    private let initialEndTime: TimeIndicatorEntity
    
    // MARK: - UI Components
    private lazy var contentView: UIView = {
        let view = UIView()
        view.backgroundColor = .clear
        return view
    }()
    
    private let titleLabel: StyledLabel = {
        let label = StyledLabel()
        label.setStyle(
            .init(
                typography: AppTypography.t1_700,
                color: AppColor.IconAndText.highEmphasis
            )
        )
        label.numberOfLines = 1
        return label
    }()
    
    private lazy var timeSelectionView: TimeSelectionView = {
        let view = TimeSelectionView(
            startTime: initialStartTime,
            endTime: initialEndTime
        )
        view.delegate = self
        return view
    }()
    
    // MARK: - Initialization
    init(
        type: TimeSelectionBottomSheetCase,
        startTime: TimeIndicatorEntity,
        endTime: TimeIndicatorEntity
    ) {
        self.titleLabel.setText(type.title)
        self.initialStartTime = startTime
        self.initialEndTime = endTime
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
    }
    
    // MARK: - Setup
    private func setupViews() {
        
        view.backgroundColor = AppColor.Container.primary
        
        view.addSubview(contentView)
        contentView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        contentView.addSubview(titleLabel)
        titleLabel.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.leading.trailing.equalToSuperview().inset(AppSpacing.screenHorizontal)
        }
        
        contentView.addSubview(timeSelectionView)
        timeSelectionView.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(16)
            make.leading.trailing.equalToSuperview()
            make.bottom.equalToSuperview().inset(24)
        }
    }
}

// MARK: - BottomSheetPresentable
extension TimeSelectionBottomSheet: BottomSheetPresentable {
    
}

// MARK: - TimeSelectionViewDelegate
extension TimeSelectionBottomSheet: TimeSelectionViewDelegate {
    func timeSelectionView(
        _ view: TimeSelectionView,
        didConfirmStartTime startTime: TimeIndicatorEntity,
        endTime: TimeIndicatorEntity
    ) {
        // Delegate
        delegate?.timeSelectionBottomSheet(
            self,
            didConfirmStartTime: startTime,
            endTime: endTime
        )
        
        if let bottomSheet = parent as? BottomSheetViewController {
            bottomSheet.animateDismiss()
        }
    }
}
