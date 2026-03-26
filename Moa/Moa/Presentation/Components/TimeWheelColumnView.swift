//
//  TimeWheelColumnView.swift
//  Moa
//
//  Created by 정도현 on 2/15/26.
//

import UIKit
import SnapKit

final class TimeWheelColumnView: UIView {

    // MARK: - Constants

    private let cellHeight: CGFloat = 44
    private let visibleRows: Int = 5
    private let repeatCount: Int = 1_000

    /// 중앙 기준 index
    private var centerIndex: Int {
        (repeatCount / 2) * values.count
    }

    /// 중앙 정렬 offset 보정
    private var midOffset: CGFloat {
        collectionView.contentInset.top
    }

    // MARK: - Properties

    private let values: [String]
    private let alignment: NSTextAlignment
    private var collectionView: UICollectionView!

    /// 전체 index
    private var absoluteIndex: Int = 0
    private var hasInitialized = false
    
    /// 외부 노출 index
    var selectedIndex: Int {
        let mod = absoluteIndex % values.count
        return mod >= 0 ? mod : mod + values.count
    }

    var onValueChanged: (() -> Void)?

    // MARK: - Init

    init(values: [String], initialIndex: Int = 0, alignment: NSTextAlignment = .center) {
        self.values = values
        self.alignment = alignment
        self.absoluteIndex = (repeatCount / 2) * values.count + initialIndex
        super.init(frame: .zero)
        setupCollectionView()
    }

    required init?(coder: NSCoder) { fatalError() }

    override func layoutSubviews() {
        super.layoutSubviews()

        let inset = (bounds.height - cellHeight) / 2
        collectionView.contentInset.top = inset
        collectionView.contentInset.bottom = inset

        guard !hasInitialized else { return }
        hasInitialized = true

        let offset = snapOffset(for: absoluteIndex)
        collectionView.setContentOffset(CGPoint(x: 0, y: offset), animated: false)

        collectionView.reloadData()
    }

    // MARK: - Public

    func scrollToIndexSilently(_ realIndex: Int, animated: Bool = false) {
        guard realIndex >= 0, realIndex < values.count else { return }

        let newAbsolute = centerIndex + realIndex
        absoluteIndex = newAbsolute

        collectionView.setContentOffset(
            CGPoint(x: 0, y: snapOffset(for: newAbsolute)),
            animated: animated
        )

        collectionView.reloadData()
    }

    // MARK: - Core Logic

    private func snapOffset(for index: Int) -> CGFloat {
        CGFloat(index) * cellHeight - midOffset
    }

    /// clamp 제거 → 진짜 무한 index
    private func centeredAbsoluteIndex() -> Int {
        let rawIndex = (collectionView.contentOffset.y + midOffset) / cellHeight
        return Int(rawIndex.rounded())
    }

    private func snapToCurrent(animated: Bool = true) {
        collectionView.setContentOffset(
            CGPoint(x: 0, y: snapOffset(for: absoluteIndex)),
            animated: animated
        )
    }

    private func updateSelectionIfNeeded() {
        guard hasInitialized else { return }

        let newAbsolute = centeredAbsoluteIndex()
        guard newAbsolute != absoluteIndex else { return }

        let oldReal = selectedIndex
        absoluteIndex = newAbsolute
        let newReal = selectedIndex

        for cell in collectionView.visibleCells.compactMap({ $0 as? TimeWheelCell }) {
            guard let ip = collectionView.indexPath(for: cell) else { continue }
            let realIndex = ip.item % values.count
            cell.setSelectedStyle(realIndex == newReal)
        }

        if oldReal != newReal {
            onValueChanged?()
        }
    }

    private func recenterIfNeeded() {
        let threshold = values.count * repeatCount / 4

        if absoluteIndex < threshold || absoluteIndex > values.count * repeatCount - threshold {
            let newIndex = centerIndex + selectedIndex
            absoluteIndex = newIndex

            collectionView.setContentOffset(
                CGPoint(x: 0, y: snapOffset(for: newIndex)),
                animated: false
            )
        }
    }

    // MARK: - Setup

    private func setupCollectionView() {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.minimumLineSpacing = 0

        collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.showsVerticalScrollIndicator = false
        collectionView.decelerationRate = .fast
        collectionView.backgroundColor = .clear
        collectionView.dataSource = self
        collectionView.delegate = self

        collectionView.register(
            TimeWheelCell.self,
            forCellWithReuseIdentifier: TimeWheelCell.identifier
        )

        addSubview(collectionView)
        collectionView.snp.makeConstraints { $0.edges.equalToSuperview() }
    }
}

// MARK: - DataSource

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

// MARK: - Delegate

extension TimeWheelColumnView: UICollectionViewDelegate {

    func collectionView(_ collectionView: UICollectionView,
                        didSelectItemAt indexPath: IndexPath) {

        let realIndex = indexPath.item % values.count
        let newAbsolute = centerIndex + realIndex

        absoluteIndex = newAbsolute
        snapToCurrent(animated: true)
        collectionView.reloadData()
        onValueChanged?()
    }

    func scrollViewWillEndDragging(_ scrollView: UIScrollView,
                                   withVelocity velocity: CGPoint,
                                   targetContentOffset: UnsafeMutablePointer<CGPoint>) {

        let rawIdx = (targetContentOffset.pointee.y + midOffset) / cellHeight
        targetContentOffset.pointee.y = rawIdx.rounded() * cellHeight - midOffset
    }

    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        updateSelectionIfNeeded()
        recenterIfNeeded()
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

// MARK: - FlowLayout

extension TimeWheelColumnView: UICollectionViewDelegateFlowLayout {

    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        CGSize(width: collectionView.bounds.width, height: cellHeight)
    }
}
