//
//  StaticVC.swift
//  SDPagingViewController
//
//  Created by SvD on 10.12.15.
//  Copyright © 2015 SvD. All rights reserved.
//

import UIKit

class StaticVC: UIViewController, SDLoopPickerDelegate {

    @IBOutlet weak var loopPicker: SDLoopPicker!

    func loopPickerDidSelectedIndex(index: Int) {
        print("Selected item: \(index)")
    }


    override func viewDidLoad() {
        super.viewDidLoad()
//        loopPicker.pickerDelegate = self

        let imgSet = [UIImage(named: "s2_1")!, UIImage(named: "s2_2")!, UIImage(named: "s2_3")!, UIImage(named: "s2_4")!]

//        loopPicker.imageAry = imgSet



        let isp2 = SDLoopPicker(frame: CGRectMake(0, 60, 300, 200))

        var centerPoint = isp2.center
        centerPoint.x = view.center.x
        isp2.center = centerPoint
        isp2.imageAry = imgSet
        isp2.heightOffset = 40.0
        isp2.positionRatio = 1.0
        isp2.alphaOfobjs = 0.9
//        isp2. setSelectedItem:0];
        view.addSubview(isp2)



    }

}
