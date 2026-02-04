//
//  DateLocationInfoView.swift
//  Moa
//
//  Created by 정도현 on 2/4/26.
//

import UIKit
import SnapKit

final class DateLocationInfoView: UIView {

    // MARK: - Properties
    private let dateIconTextView: IconTextView
    private let locationIconTextView: IconTextView

    private lazy var containerView: UIView = {
        let view = UIView()
        view.backgroundColor = AppColor.Container.primary
        view.clipsToBounds = true
        return view
    }()

    private lazy var stackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [
            dateIconTextView,
            locationIconTextView
        ])
        stackView.axis = .horizontal
        stackView.spacing = 10
        stackView.alignment = .center
        return stackView
    }()

    // MARK: - Init
    init(date: String, location: String) {
        self.dateIconTextView = IconTextView(type: .date, text: date)
        self.locationIconTextView = IconTextView(type: .location, text: location)
        super.init(frame: .zero)
        setupUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Setup
    private func setupUI() {
        addSubview(containerView)
        containerView.addSubview(stackView)

        containerView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }

        stackView.snp.makeConstraints {
            $0.verticalEdges.equalToSuperview().inset(8)
            $0.horizontalEdges.equalToSuperview().inset(16)
        }
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        containerView.layer.cornerRadius = containerView.bounds.height / 2
    }

    // MARK: - Public API
    func update(date: String) {
        dateIconTextView.configure(type: .date, text: date)
    }

    func update(location: String) {
        locationIconTextView.configure(type: .location, text: location)
    }
}
