//
//  WorkdayDetailListView.swift
//  Moa
//
//  캘린더 하단에 인라인으로 표시되는 날짜 상세 패널
//  - 날짜 타이틀 ("2026.1.14")
//  - WorkScheduleTicket 카드 세로 목록 (ScrollView 없이 stackView)
//  - 티켓 탭 → delegate.didTapEdit
//

import UIKit
import SnapKit

// MARK: - Delegate

protocol WorkdayDetailViewDelegate: AnyObject {
    /// 티켓 탭 → 일정 수정 화면으로 이동
    func workdayDetailView(_ view: WorkdayDetailView, didTapEdit workday: WorkdayEntity, date: Date)
}

// MARK: - WorkdayDetailView

final class WorkdayDetailView: UIView {

    // MARK: - Delegate

    weak var delegate: WorkdayDetailViewDelegate?

    // MARK: - Private State

    private var currentWorkday: WorkdayEntity?
    private var currentDate: Date?

    // MARK: - UI

    private let dateLabel: StyledLabel = {
        let l = StyledLabel()
        l.setStyle(.init(
            typography: AppTypography.b1_500,
            color: UIColor(resource: .Color.Grayscale.gray40)
        ))
        return l
    }()

    private let ticketStack: UIStackView = {
        let sv = UIStackView()
        sv.axis    = .vertical
        sv.spacing = 12
        return sv
    }()

    private let containerStack: UIStackView = {
        let sv = UIStackView()
        sv.axis    = .vertical
        sv.spacing = 20
        return sv
    }()

    // MARK: - Init

    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    required init?(coder: NSCoder) { fatalError() }

    // MARK: - Setup

    private func setup() {
        containerStack.addArrangedSubview(dateLabel)
        containerStack.addArrangedSubview(ticketStack)

        addSubview(containerStack)
        containerStack.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
    }

    // MARK: - Configure

    func configure(date: Date, workday: WorkdayEntity) {
        currentWorkday = workday
        currentDate    = date

        dateLabel.setText(dateString(from: date))

        ticketStack.arrangedSubviews.forEach { $0.removeFromSuperview() }

        let tickets = makeTickets(from: workday, date: date)

        if tickets.isEmpty {
            let emptyLabel = StyledLabel()
            emptyLabel.setText(
                "등록된 일정이 없어요",
                style: .init(
                    typography: AppTypography.b1_500,
                    color: AppColor.IconAndText.lowEmphasis
                )
            )
            emptyLabel.textAlignment = .center
            ticketStack.addArrangedSubview(emptyLabel)
        } else {
            tickets.forEach { ticketStack.addArrangedSubview($0) }
        }
    }

    // MARK: - Ticket Factory

    private func makeTickets(from workday: WorkdayEntity, date: Date) -> [WorkScheduleTicket] {
        let type     = workday.type
        let startStr = workday.clockInTime?.displayString  ?? "--:--"
        let endStr   = workday.clockOutTime?.displayString ?? "--:--"
        let today    = Date()

        switch type {
        case .work:
            let isPastOrToday = Calendar.korea.compare(
                date, to: today, toGranularity: .day
            ) != .orderedDescending

            let ticket: WorkScheduleTicket = isPastOrToday
                ? .worked(startTime: startStr, endTime: endStr)  { [weak self] in self?.handleTicketTap() }
                : .scheduled(startTime: startStr, endTime: endStr) { [weak self] in self?.handleTicketTap() }
            return [ticket]

        case .vacation:
            return [.vacation(startTime: startStr, endTime: endStr) { [weak self] in self?.handleTicketTap() }]

        case .none:
            return []
        }
    }

    private func handleTicketTap() {
        guard let workday = currentWorkday, let date = currentDate else { return }
        delegate?.workdayDetailView(self, didTapEdit: workday, date: date)
    }

    // MARK: - Helpers

    private func dateString(from date: Date) -> String {
        let f        = DateFormatter()
        f.dateFormat = "yyyy.M.d"
        f.locale     = Locale(identifier: "ko_KR")
        f.timeZone   = TimeZone(identifier: "Asia/Seoul")
        return f.string(from: date)
    }
}
