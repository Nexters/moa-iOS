//
//  WorkdayDetailListView.swift
//  Moa
//
//  캘린더 하단 날짜 상세 패널
//  - 날짜 타이틀
//  - WorkScheduleTicket 목록
//  - payday는 CalendarScheduleEntity.events에서 직접 판단

import UIKit
import SnapKit

// MARK: - Delegate

protocol WorkdayDetailViewDelegate: AnyObject {
    /// 근무/휴가 티켓 탭 → 일정 수정 화면으로 이동
    func workdayDetailView(_ view: WorkdayDetailView, didTapEdit schedule: CalendarScheduleEntity)
    /// 월급 티켓 탭 → 월급날 수정 바텀시트
    func workdayDetailViewDidTapPaydayTicket(_ view: WorkdayDetailView)
}

// MARK: - WorkdayDetailView

final class WorkdayDetailView: UIView {

    // MARK: - Delegate

    weak var delegate: WorkdayDetailViewDelegate?

    // MARK: - Private State

    private var currentSchedule: CalendarScheduleEntity?

    // MARK: - UI

    private let dateLabel: StyledLabel = {
        let label = StyledLabel()
        label.setStyle(.init(
            typography: AppTypography.b1_500,
            color: UIColor(resource: .Color.Grayscale.gray40)
        ))
        return label
    }()

    private let ticketStack: UIStackView = {
        let sv     = UIStackView()
        sv.axis    = .vertical
        sv.spacing = 12
        return sv
    }()

    private let containerStack: UIStackView = {
        let sv     = UIStackView()
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
        containerStack.snp.makeConstraints { $0.edges.equalToSuperview() }
    }

    // MARK: - Configure
    //
    // payday 여부는 schedule.events에서 직접 판단
    // → UserDefaults.payday 의존 제거
    // salary: 이번달 기본 월급 (ViewModel에서 CalendarEntity.earnings.standardSalary로 전달)

    func configure(schedule: CalendarScheduleEntity, salary: Int) {
        currentSchedule = schedule

        dateLabel.setText(dateString(from: schedule.date))

        ticketStack.arrangedSubviews.forEach { $0.removeFromSuperview() }

        let tickets = makeTickets(from: schedule, salary: salary)

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

    private func makeTickets(from schedule: CalendarScheduleEntity, salary: Int) -> [WorkScheduleTicket] {
        var tickets: [WorkScheduleTicket] = []
        let today    = Date()
        let calendar = Calendar.korea

        let startStr = schedule.clockInTime?.displayString  ?? "--:--"
        let endStr   = schedule.clockOutTime?.displayString ?? "--:--"

        switch schedule.contentType {
        case .work:
            let ticket: WorkScheduleTicket = schedule.status == .scheduled
                ? .scheduled(startTime: startStr, endTime: endStr) { [weak self] in self?.handleTicketTap() }
                : .worked(startTime: startStr, endTime: endStr) { [weak self] in self?.handleTicketTap() }
            tickets.append(ticket)

        case .vacation:
            tickets.append(
                .vacation(startTime: startStr, endTime: endStr) { [weak self] in self?.handleTicketTap() }
            )

        case .none:
            break
        }

        // payday 티켓: events 배열에 .payday 포함 여부로 판단
        // 기존 UserDefaults.payday 의존 방식에서 서버 데이터 기반으로 변경
        if schedule.events.contains(.payday) {
            let nf                  = NumberFormatter()
            nf.numberStyle          = .decimal
            nf.groupingSeparator    = ","
            let formattedSalary     = nf.string(from: NSNumber(value: salary)) ?? "\(salary)"
            let paydayDay           = calendar.component(.day, from: schedule.date)
            tickets.append(
                .payday(schedule: "\(paydayDay)", salary: formattedSalary) { [weak self] in
                    self?.handlePaydayTicketTap()
                }
            )
        }

        return tickets
    }

    private func handleTicketTap() {
        guard let schedule = currentSchedule else { return }
        delegate?.workdayDetailView(self, didTapEdit: schedule)
    }

    private func handlePaydayTicketTap() {
        delegate?.workdayDetailViewDidTapPaydayTicket(self)
    }

    // MARK: - Helpers

    private func dateString(from date: Date) -> String {
        let formatter        = DateFormatter()
        formatter.dateFormat = "yyyy.M.d"
        formatter.locale     = Locale(identifier: "ko_KR")
        formatter.timeZone   = TimeZone(identifier: "Asia/Seoul")
        return formatter.string(from: date)
    }
}
