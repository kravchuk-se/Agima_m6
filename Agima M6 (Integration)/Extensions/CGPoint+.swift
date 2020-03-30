//
//  CGPoint+.swift
//  Agima M6 (Integration)
//
//  Created by Kravchuk Sergey on 29.03.2020.
//  Copyright © 2020 Kravchuk Sergey. All rights reserved.
//

import UIKit

extension CGPoint {
    func offset(dx: CGFloat, dy: CGFloat) -> CGPoint {
        return CGPoint(x: self.x + dx, y: self.y + dy)
    }
}
