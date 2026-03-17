//
//  CalendarGridView.swift
//  Moa
//
//  Created by 정도현 on 2/19/26.
//

import UIKit
import SnapKit

protocol CalendarGridViewDelegate: AnyObject {
    func gridView(_ grid: CalendarGridView, didTapDay day: CalendarDayEntity)
}

final class CalendarGridView: UIView {
    
    private static let cellHeight: CGFloat = 66
    
    weak var delegate: CalendarGridViewDelegate?
    private var days: [CalendarDayEntity?] = []
    
    private lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.minimumLineSpacing      = 0
        layout.minimumInteritemSpacing = 0
        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.backgroundColor  = .clear
        cv.isScrollEnabled  = false
        cv.register(CalendarDayCell.self, forCellWithReuseIdentifier: CalendarDayCell.identifier)
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
        let width        = collectionView.bounds.width / 7
        let height       = CalendarGridView.cellHeight
        let newSize = CGSize(width: width, height: height)
        guard width > 0, layout.itemSize != newSize else { return }
        layout.itemSize = newSize
    }
    
    func reload(with days: [CalendarDayEntity?]) {
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
        cell.configure(with: days[ip.item])   // nil 또는 CalendarDay 전달
        return cell
    }
}
extension CalendarGridView: UICollectionViewDelegate {}
extension CalendarGridView: CalendarDayCellDelegate {
    func dayCell(_ cell: CalendarDayCell, didTap day: CalendarDayEntity) {
        delegate?.gridView(self, didTapDay: day)
    }
}
