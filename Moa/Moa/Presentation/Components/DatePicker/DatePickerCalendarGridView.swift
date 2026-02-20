//
//  DatePickerCalendarGridView.swift
//  Moa
//
//  Created by 정도현 on 2/20/26.
//

import UIKit
import SnapKit

protocol DatePickerCalendarGridViewDelegate: AnyObject {
    func datePickerGridView(_ grid: DatePickerCalendarGridView, didTapDay day: CalendarDay)
}

/// 바텀시트 날짜 선택용 그리드
final class DatePickerCalendarGridView: UIView {

    private static let cellHeight: CGFloat = 66

    weak var delegate: DatePickerCalendarGridViewDelegate?
    private var days: [CalendarDay?] = []

    private lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.minimumLineSpacing      = 0
        layout.minimumInteritemSpacing = 0
        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.backgroundColor = .clear
        cv.isScrollEnabled = false
        cv.register(
            DatePickerCalendarDayCell.self,
            forCellWithReuseIdentifier: DatePickerCalendarDayCell.identifier
        )
        cv.dataSource = self
        cv.delegate   = self
        return cv
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(collectionView)
        collectionView.snp.makeConstraints { $0.edges.equalToSuperview() }
    }
    required init?(coder: NSCoder) { fatalError() }

    override func layoutSubviews() {
        super.layoutSubviews()
        guard let layout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout else { return }
        let width   = collectionView.bounds.width / 7
        let height  = DatePickerCalendarGridView.cellHeight
        let newSize = CGSize(width: width, height: height)
        guard width > 0, layout.itemSize != newSize else { return }
        layout.itemSize = newSize
    }

    func reload(with days: [CalendarDay?]) {
        self.days = days
        collectionView.reloadData()
    }

    /// 셀 수에 따른 동적 높이 (최대 6행)
    static func preferredHeight(rowCount: Int) -> CGFloat {
        CGFloat(rowCount) * cellHeight
    }
}

extension DatePickerCalendarGridView: UICollectionViewDataSource {
    func collectionView(_ cv: UICollectionView, numberOfItemsInSection s: Int) -> Int {
        days.count
    }
    func collectionView(_ cv: UICollectionView, cellForItemAt ip: IndexPath) -> UICollectionViewCell {
        let cell = cv.dequeueReusableCell(
            withReuseIdentifier: DatePickerCalendarDayCell.identifier, for: ip
        ) as! DatePickerCalendarDayCell
        cell.delegate = self
        cell.configure(with: days[ip.item])
        return cell
    }
}
extension DatePickerCalendarGridView: UICollectionViewDelegate {}

extension DatePickerCalendarGridView: DatePickerCalendarDayCellDelegate {
    func datePickerDayCell(_ cell: DatePickerCalendarDayCell, didTap day: CalendarDay) {
        delegate?.datePickerGridView(self, didTapDay: day)
    }
}
