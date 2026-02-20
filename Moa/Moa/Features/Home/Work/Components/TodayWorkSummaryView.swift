//
//  TodayWorkSummaryView.swift
//  Moa
//
//  Created by 정도현 on 2/2/26.
//

import UIKit
import SnapKit

final class TodayWorkSummaryView: UIView {

    // MARK: - UI
    
    private let containerView: UIView = {
        let view = UIView()
        view.backgroundColor = AppColor.Container.primary
        view.layer.cornerRadius = 16
        view.clipsToBounds = true
        return view
    }()
    
    private lazy var wageRowView = KeyValueRowView(
        type: .wageRow(wage: 0)
    )
    
    private lazy var timeRowView = KeyValueRowView(
        type: .timeRow(startTime: "", endTime: ""),
        showsChevron: true
    )
    
    private let dividerView: UIView = {
        let view = UIView()
        view.backgroundColor = AppColor.Divider.secondary
        return view
    }()
    
    // MARK: - Action
    
    var onTapTimeRow: (() -> Void)? {
        get { timeRowView.onTap }
        set { timeRowView.onTap = newValue }
    }
    
    // MARK: - Init
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) { fatalError() }
    
    // MARK: - Public
    
    func configure(
        wage: Int,
        startTime: String,
        endTime: String
    ) {
        wageRowView.updateValue("\(AppNumberFormatter.decimalString(from: wage))원")
        timeRowView.updateValue("\(startTime) - \(endTime)")
    }
    
    // MARK: - Setup
    
    private func setupUI() {
        addSubview(containerView)
        
        containerView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        
        containerView.addSubview(wageRowView)
        containerView.addSubview(dividerView)
        containerView.addSubview(timeRowView)
        
        wageRowView.snp.makeConstraints {
            $0.top.equalToSuperview().inset(16)
            $0.horizontalEdges.equalToSuperview().inset(16)
        }
        
        dividerView.snp.makeConstraints {
            $0.top.equalTo(wageRowView.snp.bottom).offset(14)
            $0.horizontalEdges.equalToSuperview().inset(16)
            $0.height.equalTo(1)
        }
        
        timeRowView.snp.makeConstraints {
            $0.top.equalTo(dividerView.snp.bottom).offset(14)
            $0.horizontalEdges.equalToSuperview().inset(16)
            $0.bottom.equalToSuperview().inset(16)
        }
    }
}
