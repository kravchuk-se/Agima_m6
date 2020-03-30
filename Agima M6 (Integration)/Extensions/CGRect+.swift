//
//  CGRect+.swift
//  Agima M6 (Integration)
//
//  Created by Kravchuk Sergey on 29.03.2020.
//  Copyright © 2020 Kravchuk Sergey. All rights reserved.
//

import UIKit

extension CGRect {
    var center: CGPoint {
        return CGPoint(x: midX, y: midY)
    }
}
