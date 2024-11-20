import Foundation
import UIKit

/// Container for all RecyclerListView children. This will automatically remove all gaps and overlaps for GridLayouts with flexible spans.
/// Note: This cannot work for masonry layouts i.e, pinterest like layout
@objc public class AutoLayoutView: UIView {
#if RCT_NEW_ARCH_ENABLED
  @objc public var onBlankAreaEventHandler: ((CGFloat, CGFloat) -> Void)?
#endif
  
  @objc(onBlankAreaEvent)
  var onBlankAreaEvent: RCTDirectEventBlock?
  
  @objc public func setHorizontal(_ horizontal: Bool) {
    self.horizontal = horizontal
  }
  
  @objc public func setScrollOffset(_ scrollOffset: Int) {
    self.scrollOffset = CGFloat(scrollOffset)
  }
  
  @objc public func setWindowSize(_ windowSize: Int) {
    self.windowSize = CGFloat(windowSize)
  }
  
  @objc public func setRenderAheadOffset(_ renderAheadOffset: Int) {
    self.renderAheadOffset = CGFloat(renderAheadOffset)
  }
  
  @objc public func setEnableInstrumentation(_ enableInstrumentation: Bool) {
    self.enableInstrumentation = enableInstrumentation
  }
  
  @objc public func setDisableAutoLayout(_ disableAutoLayout: Bool) {
    self.disableAutoLayout = disableAutoLayout
  }
  
  @objc func setExperimentalMaintainVisibleContentPosition(_ experimentalMaintainVisibleContentPosition: Bool) {
    self.experimentalMaintainVisibleContentPosition = experimentalMaintainVisibleContentPosition
  }
  
  private var horizontal = false
  private var experimentalMaintainVisibleContentPosition = false
  private var scrollOffset: CGFloat = 0
  private var windowSize: CGFloat = 0
  private var renderAheadOffset: CGFloat = 0
  private var enableInstrumentation = false
  private var disableAutoLayout = false
  
  /// Tracks where the last pixel is drawn in the overall
  private var lastMaxBoundOverall: CGFloat = 0
  
  /// Tracks where the last pixel is drawn in the visible window
  private var lastMaxBound: CGFloat = 0
  
  /// Tracks where first pixel is drawn in the visible window
  private var lastMinBound: CGFloat = 0
  
  /// State that informs us whether this is the first render
  private var isInitialRender: Bool = true
  
  /// Id of the anchor element when using `experimentalMaintainVisibleContentPosition`
  private var anchorStableId: String = ""
  
  /// Offset of the anchor when using `experimentalMaintainVisibleContentPosition`
  private var anchorOffset: CGFloat = 0
  
  override public func layoutSubviews() {
    super.layoutSubviews()
    fixLayout()
    
    self.isInitialRender = false
    guard enableInstrumentation, let scrollView = getScrollView() else { return }
    
    let scrollContainerSize = horizontal ? scrollView.frame.width : scrollView.frame.height
    let currentScrollOffset = horizontal ? scrollView.contentOffset.x : scrollView.contentOffset.y
    let startOffset = horizontal ? frame.minX : frame.minY
    let endOffset = horizontal ? frame.maxX : frame.maxY
    let distanceFromWindowStart = max(startOffset - currentScrollOffset, 0)
    let distanceFromWindowEnd = max(currentScrollOffset + scrollContainerSize - endOffset, 0)
    
    let (blankOffsetStart, blankOffsetEnd) = computeBlankFromGivenOffset(
      currentScrollOffset - startOffset,
      filledBoundMin: lastMinBound,
      filledBoundMax: lastMaxBound,
      renderAheadOffset: renderAheadOffset,
      windowSize: windowSize,
      distanceFromWindowStart: distanceFromWindowStart,
      distanceFromWindowEnd: distanceFromWindowEnd
    )
    
#if RCT_NEW_ARCH_ENABLED
    onBlankAreaEventHandler?(blankOffsetStart, blankOffsetEnd)
#else
    onBlankAreaEvent?(
      [
        "offsetStart": blankOffsetStart,
        "offsetEnd": blankOffsetEnd,
      ]
    )
#endif
  }
  
  func getScrollView() -> UIScrollView? {
    return sequence(first: self, next: { $0.superview }).first(where: { $0 is UIScrollView }) as? UIScrollView
  }
  
  func getScrollViewOffset(for scrollView: UIScrollView?) -> CGFloat {
    /// When using `experimentalMaintainVisibleContentPosition` we can't use the offset provided by React
    /// Native. Because its async, it is sometimes sent in too late for the position maintenance
    /// calculation causing list jumps or sometimes wrong scroll positions altogether. Since this is still
    /// experimental, the old scrollOffset is here to not regress previous functionality if the feature
    /// doesn't work at scale.
    ///
    /// The goal is that we can remove this in the future and get the offset from only one place 🤞
    if let scrollView, experimentalMaintainVisibleContentPosition {
      return horizontal ?
      scrollView.contentOffset.x :
      scrollView.contentOffset.y
    }
    
    return scrollOffset
  }
  
  /// Sorts views by index and then invokes clearGaps which does the correction.
  /// Performance: Sort is needed. Given relatively low number of views in RecyclerListView render tree this should be a non issue.
  private func fixLayout() {
    guard
      subviews.count > 1,
      // Fixing layout during animation can interfere with it.
      layer.animationKeys()?.isEmpty ?? true,
      !disableAutoLayout
    else { return }
    
    let cellContainers = subviews
      .compactMap { subview -> CellContainerComponentView? in
        if let cellContainer = subview as? CellContainerComponentView {
          return cellContainer
        } else {
          assertionFailure("CellRendererComponent outer view should always be CellContainer. Learn more here: https://shopify.github.io/flash-list/docs/usage#cellrenderercomponent.")
          return nil
        }
      }
      .sorted(by: { $0.index < $1.index })
    
    clearGaps(for: cellContainers)
    fixFooter()
  }
  
  /// Finds the item with the first stable id and adjusts the scroll view offset based on how much
  /// it moved when a new item is added.
  private func adjustTopContentPosition(
    cellContainers: [CellContainerComponentView],
    scrollView: UIScrollView?
  ) {
    guard let scrollView = scrollView, !self.isInitialRender else { return }
    
    for cellContainer in cellContainers {
      let minValue = horizontal ?
      cellContainer.frame.minX :
      cellContainer.frame.minY
      
      if cellContainer.stableId == anchorStableId {
        if minValue != anchorOffset {
          let diff = minValue - anchorOffset
          
          let currentOffset = horizontal
          ? scrollView.contentOffset.x
          : scrollView.contentOffset.y
          
          let scrollValue = diff + currentOffset
          
          scrollView.contentOffset = CGPoint(
            x: horizontal ? scrollValue : 0,
            y: horizontal ? 0 : scrollValue
          )
          
          // You only need to adjust the scroll view once. Break the
          // loop after this
          return
        }
      }
    }
  }
  
  /// Checks for overlaps or gaps between adjacent items and then applies a correction.
  /// Performance: RecyclerListView renders very small number of views and this is not going to trigger multiple layouts on the iOS side.
  private func clearGaps(for cellContainers: [CellContainerComponentView]) {
    let scrollView = getScrollView()
    let correctedScrollOffset = getScrollViewOffset(for: scrollView)
    var maxBound: CGFloat = 0
    var minBound: CGFloat = CGFloat(Int.max)
    var maxBoundNextCell: CGFloat = 0
    var nextAnchorStableId = ""
    var nextAnchorOffset: CGFloat = 0
    var anchorSet = false
    
    lastMaxBoundOverall = 0
    
    cellContainers.indices.dropLast().forEach { index in
      let currentCell = cellContainers[index]
      let cellTop = currentCell.frame.minY
      let cellBottom = currentCell.frame.maxY
      let cellLeft = currentCell.frame.minX
      let cellRight = currentCell.frame.maxX
      
      let nextCell = cellContainers[index + 1]
      let nextCellTop = nextCell.frame.minY
      let nextCellLeft = nextCell.frame.minX
      
      // Only apply correction if the next cell is consecutive.
      let isNextCellConsecutive = nextCell.index == currentCell.index + 1
      
      let isCellVisible = isWithinBounds(
        currentCell,
        scrollOffset: correctedScrollOffset,
        renderAheadOffset: renderAheadOffset,
        windowSize: windowSize,
        isHorizontal: horizontal
      )
      
      let isNextCellVisible = isWithinBounds(
        nextCell,
        scrollOffset: correctedScrollOffset,
        renderAheadOffset: renderAheadOffset,
        windowSize: windowSize,
        isHorizontal: horizontal
      )
      
      guard
        isCellVisible || isNextCellVisible
      else {
        updateLastMaxBoundOverall(currentCell: currentCell, nextCell: nextCell)
        return
      }
      
      if horizontal {
        maxBound = max(maxBound, cellRight)
        minBound = min(minBound, cellLeft)
        maxBoundNextCell = maxBound
        
        if isNextCellConsecutive {
          if cellTop < nextCellTop {
            if cellBottom != nextCellTop {
              nextCell.frame.origin.y = cellBottom
            }
            
            if cellLeft != nextCellLeft {
              nextCell.frame.origin.x = cellLeft
            }
          } else {
            nextCell.frame.origin.x = maxBound
          }
        }
        
        if isNextCellVisible {
          maxBoundNextCell = max(maxBound, nextCell.frame.maxX)
        }
      } else {
        maxBound = max(maxBound, cellBottom)
        minBound = min(minBound, cellTop)
        maxBoundNextCell = maxBound
        
        if isNextCellConsecutive {
          if cellLeft < nextCellLeft {
            if cellRight != nextCellLeft {
              nextCell.frame.origin.x = cellRight
            }
            
            if cellTop != nextCellTop {
              nextCell.frame.origin.y = cellTop
            }
          } else {
            nextCell.frame.origin.y = maxBound
          }
        }
        
        if isNextCellVisible {
          maxBoundNextCell = max(maxBound, nextCell.frame.maxY)
        }
      }
      
      let isAnchorFound = !anchorSet && (nextAnchorStableId == "" || nextCell.stableId == anchorStableId)
      
      if experimentalMaintainVisibleContentPosition && isAnchorFound {
        nextAnchorOffset = horizontal ? nextCell.frame.minX : nextCell.frame.minY
        nextAnchorStableId = nextCell.stableId
        anchorSet = true
      }
      
      updateLastMaxBoundOverall(currentCell: currentCell, nextCell: nextCell)
    }
    
    if experimentalMaintainVisibleContentPosition {
      adjustTopContentPosition(
        cellContainers: cellContainers,
        scrollView: scrollView
      )
    }
    
    lastMaxBound = maxBoundNextCell
    lastMinBound = minBound
    anchorStableId = nextAnchorStableId
    anchorOffset = nextAnchorOffset
  }
  
  private func updateLastMaxBoundOverall(currentCell: CellContainerComponentView, nextCell: CellContainerComponentView) {
    lastMaxBoundOverall = max(lastMaxBoundOverall, horizontal ? currentCell.frame.maxX : currentCell.frame.maxY, horizontal ? nextCell.frame.maxX : nextCell.frame.maxY)
  }
  
  func computeBlankFromGivenOffset(
    _ actualScrollOffset: CGFloat,
    filledBoundMin: CGFloat,
    filledBoundMax: CGFloat,
    renderAheadOffset: CGFloat,
    windowSize: CGFloat,
    distanceFromWindowStart: CGFloat,
    distanceFromWindowEnd: CGFloat
  ) -> (
    offsetStart: CGFloat,
    offsetEnd: CGFloat
  ) {
    let blankOffsetStart = filledBoundMin - actualScrollOffset - distanceFromWindowStart
    let blankOffsetEnd = actualScrollOffset + windowSize - renderAheadOffset - filledBoundMax - distanceFromWindowEnd
    
    return (blankOffsetStart, blankOffsetEnd)
  }
  
  /// It's important to avoid correcting views outside the render window. An item that isn't being recycled might still remain in the view tree. If views outside get considered then gaps between unused items will cause algorithm to fail.
  func isWithinBounds(
    _ cellContainer: CellContainerComponentView,
    scrollOffset: CGFloat,
    renderAheadOffset: CGFloat,
    windowSize: CGFloat,
    isHorizontal: Bool
  ) -> Bool {
    let boundsStart = scrollOffset - renderAheadOffset
    let boundsEnd = scrollOffset + windowSize
    let cellFrame = cellContainer.frame
    
    if isHorizontal {
      return (cellFrame.minX >= boundsStart || cellFrame.maxX >= boundsStart) && (cellFrame.minX <= boundsEnd || cellFrame.maxX <= boundsEnd)
    } else {
      return (cellFrame.minY >= boundsStart || cellFrame.maxY >= boundsStart) && (cellFrame.minY <= boundsEnd || cellFrame.maxY <= boundsEnd)
    }
  }
  
  /// Fixes footer position along with rest of the items
  private func fixFooter() {
    guard !disableAutoLayout, let parentScrollView = getScrollView() else {
      return
    }
    
    let isAutoLayoutEndVisible = horizontal ? frame.maxX <= parentScrollView.frame.width : frame.maxY <= parentScrollView.frame.height
    
    guard isAutoLayoutEndVisible, let footer = footer() else {
      return
    }
    
    let diff = footerDiff()
    guard diff != 0 else { return }
    
    if horizontal {
      footer.frame.origin.x += diff
      frame.size.width += diff
      superview?.frame.size.width += diff
    } else {
      footer.frame.origin.y += diff
      frame.size.height += diff
      superview?.frame.size.height += diff
    }
  }
  
  private func footerDiff() -> CGFloat {
    if subviews.count == 0 {
      lastMaxBoundOverall = 0
    } else if subviews.count == 1 {
      let firstChild = subviews[0]
      
      lastMaxBoundOverall = horizontal ? firstChild.frame.maxX : firstChild.frame.maxY
    }
    
    let autoLayoutEnd = horizontal ? frame.width : frame.height
    
    return lastMaxBoundOverall - autoLayoutEnd
  }
  
  private func footer() -> UIView? {
    // On the new arch, AutoLayoutView is wrapped with AutoLayoutViewComponentView, so we need to go up one more level
#if RCT_NEW_ARCH_ENABLED
    let parentSubviews = superview?.superview?.subviews
#else
    let parentSubviews = superview?.subviews
#endif
    
    return parentSubviews?.first(where:{($0 as? CellContainerComponentView)?.index == -1})
  }
}
