//
//  TodayWorkSummaryView.swift
//  Moa
//
//  Created by 정도현 on 2/2/26.
//

import UIKit
import SnapKit

final class TodayWorkSummaryView: UIView {

    // MARK: - UI Components
    
    private lazy var containerView: UIView = {
        let view = UIView()
        view.backgroundColor = AppColor.Container.primary
        view.layer.cornerRadius = 16
        view.clipsToBounds = true
        return view
    }()
    
    private lazy var wageRowView = KeyValueRowView(
        title: "오늘 일급",
        value: "150,000원"
    )

    private lazy var timeRowView = KeyValueRowView(
        title: "근무 시간",
        value: "09:00 - 18:00",
        showsChevron: true
    )

    private lazy var dividerView: UIView = {
        let view = UIView()
        view.backgroundColor = AppColor.Divider.secondary
        return view
    }()

    // MARK: - Init

    init(wage: String, workTime: String) {
        
        super.init(frame: .zero)
        setupUI()
        configure(wage: wage, workTime: workTime)
    }

    required init?(coder: NSCoder) { fatalError() }

    // MARK: - Setup

    private func setupUI() {
        addSubview(containerView)

        containerView.addSubview(wageRowView)
        containerView.addSubview(dividerView)
        containerView.addSubview(timeRowView)

        containerView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }

        wageRowView.snp.makeConstraints {
            $0.top.equalToSuperview().inset(16)
            $0.leading.equalToSuperview().inset(16)
            $0.trailing.equalToSuperview().inset(12)
        }
        
        dividerView.snp.makeConstraints {
            $0.top.equalTo(wageRowView.snp.bottom).offset(14)
            $0.leading.equalToSuperview().inset(16)
            $0.trailing.equalToSuperview().inset(12)
            $0.height.equalTo(1)
        }

        timeRowView.snp.makeConstraints {
            $0.top.equalTo(dividerView.snp.bottom).offset(14)
            $0.leading.equalToSuperview().inset(16)
            $0.trailing.equalToSuperview().inset(12)
            $0.bottom.equalToSuperview().inset(16)
        }
    }

    // MARK: - Configure

    private func configure(wage: String, workTime: String) {
        wageRowView.updateValue(wage)
        timeRowView.updateValue(workTime)
    }
}
