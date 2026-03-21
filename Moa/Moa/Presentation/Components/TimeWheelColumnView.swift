//
//  TimeWheelColumnView.swift
//  Moa
//
//  Created by 정도현 on 2/15/26.
//

import UIKit
import SnapKit

// MARK: - TimeWheelColumnView

final class TimeWheelColumnView: UIView {

    // MARK: - Constants

    private let cellHeight: CGFloat  = 44
    private let visibleRows: Int     = 5      // picker에 보이는 행 수
    private let repeatCount: Int     = 1_000

    /// index N 셀을 중앙에 놓기 위한 contentOffset 보정값
    private var midOffset: CGFloat {
        collectionView.contentInset.top
    }

    // MARK: - Properties

    private let values: [String]
    private let alignment: NSTextAlignment
    private var collectionView: UICollectionView!

    /// collectionView 전체 아이템 기준 절대 인덱스
    private var absoluteIndex: Int = 0

    /// 외부 노출용 실제 값 인덱스 (0 ..< values.count)
    var selectedIndex: Int { absoluteIndex % values.count }

    var onValueChanged: (() -> Void)?

    // MARK: - Init

    init(values: [String], initialIndex: Int = 0, alignment: NSTextAlignment = .center) {
        self.values    = values
        self.alignment = alignment
        self.absoluteIndex = (repeatCount / 2) * values.count + max(0, initialIndex)
        super.init(frame: .zero)
        setupCollectionView()
    }

    required init?(coder: NSCoder) { fatalError() }
    
    override func layoutSubviews() {
        super.layoutSubviews()

        let inset = (bounds.height - cellHeight) / 2
        collectionView.contentInset.top = inset
        collectionView.contentInset.bottom = inset
    }

    // MARK: - Public

    func scrollToIndexSilently(_ realIndex: Int, animated: Bool = false) {
        guard realIndex >= 0, realIndex < values.count else { return }

        let currentBlock = absoluteIndex / values.count
        var newAbsolute  = currentBlock * values.count + realIndex
        let diff         = newAbsolute - absoluteIndex
        if diff >  values.count / 2 { newAbsolute -= values.count }
        if diff < -(values.count / 2) { newAbsolute += values.count }

        absoluteIndex = newAbsolute
        collectionView.setContentOffset(
            CGPoint(x: 0, y: snapOffset(for: absoluteIndex)),
            animated: animated
        )
        collectionView.reloadData()
    }

    // MARK: - Private helpers

    /// index N의 셀이 picker 중앙에 오도록 하는 contentOffset.y
    private func snapOffset(for index: Int) -> CGFloat {
        CGFloat(index) * cellHeight - midOffset
    }

    /// 현재 contentOffset에서 중앙에 위치한 절대 인덱스
    private func centeredAbsoluteIndex() -> Int {
        let rawIndex = (collectionView.contentOffset.y + midOffset) / cellHeight
        let idx      = Int(rawIndex.rounded())
        return max(0, min(idx, values.count * repeatCount - 1))
    }

    private func snapToCurrent(animated: Bool = true) {
        collectionView.setContentOffset(
            CGPoint(x: 0, y: snapOffset(for: absoluteIndex)),
            animated: animated
        )
    }

    private func updateSelectionIfNeeded() {
        let newAbsolute = centeredAbsoluteIndex()
        guard newAbsolute != absoluteIndex else { return }

        let oldReal   = absoluteIndex % values.count
        let newReal   = newAbsolute   % values.count
        absoluteIndex = newAbsolute

        for cell in collectionView.visibleCells.compactMap({ $0 as? TimeWheelCell }) {
            guard let ip = collectionView.indexPath(for: cell) else { continue }
            cell.setSelectedStyle(ip.item % values.count == newReal)
        }

        if oldReal != newReal { onValueChanged?() }
    }

    // MARK: - Setup

    private func setupCollectionView() {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection    = .vertical
        layout.minimumLineSpacing = 0

        collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.showsVerticalScrollIndicator = false
        collectionView.decelerationRate = .fast
        collectionView.backgroundColor  = .clear
        collectionView.dataSource = self
        collectionView.delegate   = self
        collectionView.register(
            TimeWheelCell.self,
            forCellWithReuseIdentifier: TimeWheelCell.identifier
        )

        addSubview(collectionView)
        collectionView.snp.makeConstraints { $0.edges.equalToSuperview() }

        // bounds가 확정된 후 초기 위치 설정
        DispatchQueue.main.async { [weak self] in
            guard let self else { return }
            self.collectionView.setContentOffset(
                CGPoint(x: 0, y: self.snapOffset(for: self.absoluteIndex)),
                animated: false
            )
            self.collectionView.reloadData()
        }
    }
}

// MARK: - UICollectionViewDataSource

extension TimeWheelColumnView: UICollectionViewDataSource {

    func collectionView(_ collectionView: UICollectionView,
                        numberOfItemsInSection section: Int) -> Int {
        values.count * repeatCount
    }

    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: TimeWheelCell.identifier,
            for: indexPath
        ) as! TimeWheelCell
        let realIndex = indexPath.item % values.count
        cell.configure(text: values[realIndex], alignment: alignment)
        cell.setSelectedStyle(realIndex == selectedIndex)
        return cell
    }
}

// MARK: - UICollectionViewDelegate

extension TimeWheelColumnView: UICollectionViewDelegate {

    // 셀 터치 → 해당 값으로 snap
    func collectionView(_ collectionView: UICollectionView,
                        didSelectItemAt indexPath: IndexPath) {
        let tappedReal  = indexPath.item % values.count
        let currentBlock = absoluteIndex / values.count
        var newAbsolute  = currentBlock * values.count + tappedReal
        let diff         = newAbsolute - absoluteIndex
        if diff >  values.count / 2  { newAbsolute -= values.count }
        if diff < -(values.count / 2) { newAbsolute += values.count }

        absoluteIndex = newAbsolute
        snapToCurrent(animated: true)
        collectionView.reloadData()
        onValueChanged?()
    }

    // 손가락을 뗄 때 가장 가까운 셀로 snap
    func scrollViewWillEndDragging(_ scrollView: UIScrollView,
                                   withVelocity velocity: CGPoint,
                                   targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        let rawIdx = (targetContentOffset.pointee.y + midOffset) / cellHeight
        targetContentOffset.pointee.y = rawIdx.rounded() * cellHeight - midOffset
    }

    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        updateSelectionIfNeeded()
    }

    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        snapToCurrent()
        updateSelectionIfNeeded()
    }

    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate: Bool) {
        if !willDecelerate {
            snapToCurrent()
            updateSelectionIfNeeded()
        }
    }
}

// MARK: - UICollectionViewDelegateFlowLayout

extension TimeWheelColumnView: UICollectionViewDelegateFlowLayout {

    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        CGSize(width: collectionView.bounds.width, height: cellHeight)
    }
}
