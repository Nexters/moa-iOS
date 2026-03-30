//
//  CalendarGridView.swift
//  Moa
//

import UIKit
import SnapKit

protocol CalendarGridViewDelegate: AnyObject {
    func gridView(_ grid: CalendarGridView, didTapSchedule schedule: CalendarScheduleEntity)
}

final class CalendarGridView: UIView {

    private static let cellHeight: CGFloat = 66

    weak var delegate: CalendarGridViewDelegate?
    private var days: [CalendarScheduleEntity?] = []

    private let calendarType: CalendarNavigationType

    private lazy var collectionView: UICollectionView = {
        let layout                        = UICollectionViewFlowLayout()
        layout.minimumLineSpacing         = 0
        layout.minimumInteritemSpacing    = 0
        let cv                            = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.backgroundColor                = .clear
        cv.isScrollEnabled                = false
        cv.register(CalendarDayCell.self, forCellWithReuseIdentifier: CalendarDayCell.identifier)
        cv.dataSource = self
        cv.delegate   = self
        return cv
    }()

    init(calendarType: CalendarNavigationType = .history) {
        self.calendarType = calendarType
        super.init(frame: .zero)
        addSubview(collectionView)
        collectionView.snp.makeConstraints { $0.edges.equalToSuperview() }
    }

    required init?(coder: NSCoder) { fatalError() }

    override func layoutSubviews() {
        super.layoutSubviews()
        guard let layout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout else { return }
        let width   = collectionView.bounds.width / 7
        let newSize = CGSize(width: width, height: CalendarGridView.cellHeight)
        guard width > 0, layout.itemSize != newSize else { return }
        layout.itemSize = newSize
    }

    func reload(with days: [CalendarScheduleEntity?]) {
        self.days = days
        collectionView.reloadData()
    }
}

extension CalendarGridView: UICollectionViewDataSource {

    func collectionView(_ cv: UICollectionView, numberOfItemsInSection s: Int) -> Int {
        days.count
    }

    func collectionView(_ cv: UICollectionView, cellForItemAt ip: IndexPath) -> UICollectionViewCell {
        let cell = cv.dequeueReusableCell(
            withReuseIdentifier: CalendarDayCell.identifier, for: ip
        ) as! CalendarDayCell
        cell.delegate = self
        cell.configure(with: days[ip.item], calendarType: calendarType)
        return cell
    }
}

extension CalendarGridView: UICollectionViewDelegate {}

extension CalendarGridView: CalendarDayCellDelegate {
    func dayCell(_ cell: CalendarDayCell, didTap schedule: CalendarScheduleEntity) {
        delegate?.gridView(self, didTapSchedule: schedule)
    }
}
