//
//  SDLoopPicker.swift
//  SDPagingViewController
//
//  Created by SvD on 10.12.15.
//  Copyright © 2015 SvD. All rights reserved.
//

import UIKit

@objc
protocol SDLoopPickerDelegate {
    func loopPickerDidSelectedIndex(index: Int)
}


class SDLoopPicker: UIScrollView {

    @IBOutlet var pickerDelegate: SDLoopPickerDelegate? = nil

    var imageStore = [UIImageView]()
    var snapping = false
    var lastSnappingX = 0.0

    var selectedItem:Int = 0 {
        didSet {
            initInfiniteScrollViewWithSelectedItem(selectedItem)
        }
    }

    var imageAry = [UIImage]() {
        didSet {
            initInfiniteScrollView()
        }
    }
    var itemSize = CGSizeZero {
        didSet {
            initInfiniteScrollView()
        }
    }

    var alphaOfobjs: CGFloat = 0
    var heightOffset: CGFloat = 0
    var positionRatio: CGFloat = 1

    func initInfiniteScrollView() {
        initInfiniteScrollViewWithSelectedItem(0)
    }


    func initInfiniteScrollViewWithSelectedItem(index: Int) {
        if (itemSize.width == 0 && itemSize.height == 0) {
            if imageAry.count > 0 {
                itemSize = imageAry[0].size
            }
            else {
                itemSize = CGSizeMake(self.frame.size.height / 2, self.frame.size.height / 2)
            }
        }

//        NSAssert((_itemSize.height < self.frame.size.height), @"item's height must not bigger than scrollpicker's height");

        pagingEnabled = false
        showsHorizontalScrollIndicator = false
        showsVerticalScrollIndicator = false

        let imageCount = imageAry.count

        if imageCount > 0 {

            // Init 5 set of images, 3 for user selection, 2 for
            for i in 0..<(imageCount * 5)
            {
                // Place images into the bottom of view
                let temp = UIImageView(frame: CGRectMake(CGFloat(i) * itemSize.width, frame.size.height - itemSize.height, itemSize.width, itemSize.height))
                temp.image = imageAry[i % imageCount]
                imageStore.append(temp)
                addSubview(temp)
            }

            contentSize = CGSizeMake(CGFloat(imageCount * 5) * itemSize.width, frame.size.height)
            let viewMiddle = CGFloat(imageCount * 2) * itemSize.width - frame.size.width / CGFloat(2) + itemSize.width + (itemSize.width * CGFloat(index))
            contentOffset = CGPointMake(viewMiddle, 0)
            delegate = self

            let queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
            dispatch_async(queue) { [weak self] () -> Void in
                self?.reloadView(viewMiddle)

                dispatch_async(dispatch_get_main_queue()) { () -> Void in
                    self?.snapToAnEmotion()
                }
            }

        }
    }


    func reloadView(offset: CGFloat) {
        var biggestSize: CGFloat = 0
        var biggestView: UIView!

        for i in 0..<imageStore.count {

            let view = imageStore[i]

            if (view.center.x > (offset - itemSize.width) && view.center.x < (offset + frame.size.width + itemSize.width)) {
                var tOffset = (view.center.x - offset) - frame.size.width / CGFloat(4)

                if (tOffset < 0 || tOffset > self.frame.size.width) {
                    tOffset = 0
                }
                var addHeight: CGFloat = calculateFrameHeightByOffset(tOffset)

                if addHeight < 0 {
                    addHeight = 0
                }

                view.frame = CGRectMake(view.frame.origin.x, frame.size.height - itemSize.height - heightOffset - (addHeight / positionRatio),
                                        itemSize.width + addHeight,
                                        itemSize.height + addHeight)

                if (((view.frame.origin.x + view.frame.size.width) - view.frame.origin.x) > biggestSize) {
                    biggestSize = ((view.frame.origin.x + view.frame.size.width) - view.frame.origin.x)
                    biggestView = view
                }

            } else {
                view.frame = CGRectMake(view.frame.origin.x, frame.size.height, itemSize.width, itemSize.height)
                for imageView in view.subviews {
                    imageView.frame = CGRectMake(0, 0, view.frame.size.width, view.frame.size.height)
                }
            }
        }

        for i in 0 ..< imageStore.count {
            let cBlock = imageStore[i]
            cBlock.alpha = alphaOfobjs

            if i > 0 {
                let pBlock = imageStore[i - 1]
                cBlock.frame = CGRectMake(pBlock.frame.origin.x + pBlock.frame.size.width, cBlock.frame.origin.y, cBlock.frame.size.width, cBlock.frame.size.height)
            }
        }

        biggestView.alpha = 1
    }



    override func layoutSubviews() {
        super.layoutSubviews()
        if self.contentOffset.x > 0 {
            let sectionSize = CGFloat(imageAry.count) * itemSize.width

            let cgFloat2: CGFloat = 2
            let cgFloat3: CGFloat = 3

            if contentOffset.x <= (sectionSize - sectionSize / cgFloat2) {
                self.contentOffset = CGPointMake(sectionSize * cgFloat2 - sectionSize / cgFloat2, 0)
            }
            else if self.contentOffset.x >= (sectionSize * cgFloat3 + sectionSize / cgFloat2) {
                self.contentOffset = CGPointMake(sectionSize * cgFloat2 + sectionSize / cgFloat2, 0)
            }
            
            reloadView(contentOffset.x)
        }
    }




    func calculateFrameHeightByOffset(offset: CGFloat) -> CGFloat {

        let value1 = CGFloat(fabsf(Float(offset * 2 - self.frame.size.width / 2)))
        return (-1 * value1 + self.frame.size.width / 2) / 4
    }

    func snapToAnEmotion() {
        var biggestSize: CGFloat = 0
        var biggestView: UIView!

        snapping = true
        let offset = self.contentOffset.x

        for i in 0 ..< imageStore.count {
            let view = imageStore[i]
            if (view.center.x > offset && view.center.x < (offset + frame.size.width)) {
                if (((view.center.x + view.frame.size.width) - view.center.x) > biggestSize) {
                    biggestSize = ((view.frame.origin.x + view.frame.size.width) - view.frame.origin.x)
                    biggestView = view
                }
            }
        }

        let biggestViewX = biggestView.frame.origin.x + biggestView.frame.size.width / 2 - frame.size.width / 2
        let dX = contentOffset.x - biggestViewX
        let newX = contentOffset.x - dX / 1.4

        // Disable scrolling when snapping to new location
        let queue = dispatch_get_main_queue()
        dispatch_async(queue) { [weak self] () -> Void in

            if let weakSelf = self {
                weakSelf.scrollEnabled = false
                weakSelf.scrollRectToVisible(CGRectMake(newX, 0, weakSelf.frame.size.width, 1), animated: true)
            }

            dispatch_async(dispatch_get_main_queue()) { () -> Void in
                self?.pickerDelegate?.loopPickerDidSelectedIndex((self?.selectedItem)!)
                self?.scrollEnabled = true
                self?.snapping = false
            }
        }
    }

}


extension SDLoopPicker: UIScrollViewDelegate {

    func scrollViewDidEndDragging(scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if (!decelerate && !snapping) {
            snapToAnEmotion()
        }
    }

    func scrollViewDidEndDecelerating(scrollView: UIScrollView) {
        if !snapping {
            snapToAnEmotion()
        }
    }

}
