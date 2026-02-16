//
//  TimeWheelColumnView.swift
//  Moa
//
//  Created by 정도현 on 2/15/26.
//

import UIKit
import SnapKit


// MARK: - WheelColumnView
final class TimeWheelColumnView: UIView {
    
    // MARK: - Constants
    private let cellHeight: CGFloat = 44
    
    // MARK: - Properties
    private let values: [String]
    private let alignment: NSTextAlignment
    private var collectionView: UICollectionView!
    private var currentSelectedIndex: Int = 0
    private var isProgrammaticScroll: Bool = false
    
    var selectedIndex: Int {
        currentSelectedIndex
    }
    
    // MARK: - Callback
    var onValueChanged: (() -> Void)?
    
    // MARK: - Init
    init(values: [String], initialIndex: Int = 0, alignment: NSTextAlignment = .center) {
        self.values = values
        self.currentSelectedIndex = initialIndex
        self.alignment = alignment
        super.init(frame: .zero)
        
        setupCollectionView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Public Methods
    func scrollToIndex(_ index: Int, animated: Bool = false) {
        guard index >= 0 && index < values.count else { return }
        
        currentSelectedIndex = index
        
        let offset = CGFloat(index) * cellHeight
        collectionView.setContentOffset(CGPoint(x: 0, y: offset), animated: animated)
        collectionView.reloadData()
    }
    
    func scrollToIndexSilently(_ index: Int, animated: Bool = false) {
        guard index >= 0 && index < values.count else {
            print("⚠️ scrollToIndexSilently: index out of range (\(index))")
            return
        }
        
        print("   scrollToIndexSilently: \(index) (animated: \(animated))")
        
        isProgrammaticScroll = true
        currentSelectedIndex = index
        
        let indexPath = IndexPath(item: index, section: 0)
        
        // collectionView의 레이아웃이 완료된 후 스크롤
        if collectionView.numberOfItems(inSection: 0) > index {
            collectionView.scrollToItem(at: indexPath, at: .centeredVertically, animated: animated)
        } else {
            // fallback: contentOffset 수동 계산
            let offset = CGFloat(index) * cellHeight
            collectionView.setContentOffset(CGPoint(x: 0, y: offset), animated: animated)
        }
        
        // UI Update
        DispatchQueue.main.async { [weak self] in
            self?.collectionView.reloadData()
        }
        
        // 애니메이션 완료 후 처리
        let delay = animated ? 0.35 : 0.05
        DispatchQueue.main.asyncAfter(deadline: .now() + delay) { [weak self] in
            self?.isProgrammaticScroll = false
        }
    }
}

private extension TimeWheelColumnView {
    
    func setupCollectionView() {
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
        
        collectionView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        
        let inset = cellHeight * 2
        collectionView.contentInset = UIEdgeInsets(
            top: inset,
            left: 0,
            bottom: inset,
            right: 0
        )
        
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            self.scrollToIndexSilently(self.currentSelectedIndex, animated: false)
        }
    }
    
    func updateSelectionIfNeeded() {
        let centerY = collectionView.contentOffset.y + collectionView.bounds.height / 2
        let index = Int(centerY / cellHeight)
        
        guard index >= 0 && index < values.count else { return }
        guard index != currentSelectedIndex else { return }
        
        let previousIndex = currentSelectedIndex
        currentSelectedIndex = index
        
        let previousPath = IndexPath(item: previousIndex, section: 0)
        let currentPath = IndexPath(item: index, section: 0)
        
        if let previousCell = collectionView.cellForItem(at: previousPath) as? TimeWheelCell {
            previousCell.setSelectedStyle(false)
        }
        
        if let currentCell = collectionView.cellForItem(at: currentPath) as? TimeWheelCell {
            currentCell.setSelectedStyle(true)
        }
        
        if !isProgrammaticScroll {
            onValueChanged?()
        }
    }
}

extension TimeWheelColumnView: UICollectionViewDelegate {
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        updateSelectionIfNeeded()
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        updateSelectionIfNeeded()
    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView,
                                  willDecelerate decelerate: Bool) {
        if !decelerate {
            updateSelectionIfNeeded()
        }
    }
}

extension TimeWheelColumnView: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView,
                        numberOfItemsInSection section: Int) -> Int {
        values.count
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: TimeWheelCell.identifier,
            for: indexPath
        ) as! TimeWheelCell
        
        cell.configure(text: values[indexPath.item], alignment: alignment)
        cell.setSelectedStyle(indexPath.item == currentSelectedIndex)
        
        return cell
    }
}

extension TimeWheelColumnView: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        CGSize(
            width: collectionView.bounds.width,
            height: cellHeight
        )
    }
    
    func scrollViewWillEndDragging(_ scrollView: UIScrollView,
                                   withVelocity velocity: CGPoint,
                                   targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        
        let targetY = targetContentOffset.pointee.y
        let targetIndex = round(targetY / cellHeight)
        let snappedY = targetIndex * cellHeight
        
        targetContentOffset.pointee.y = snappedY
    }
}
