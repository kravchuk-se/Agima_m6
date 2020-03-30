//
//  DownloadButton.swift
//  Agima M6 (Integration)
//
//  Created by Kravchuk Sergey on 29.03.2020.
//  Copyright © 2020 Kravchuk Sergey. All rights reserved.
//

import UIKit

@IBDesignable
class DownloadButton: UIButton {
    
    enum LoadingState {
        case stoped
        case paused
        case inProgress
        case done
    }
    
    private var barLayer: CAShapeLayer!
    private var iconView: UIImageView!
    
    var loadingState: LoadingState = .stoped {
        didSet {
            changeProgress()
            setupIconLayer()
        }
    }
    @IBInspectable var progress: CGFloat = 0.0 {
        didSet {
            changeProgress()
        }
    }
    
    private var roundSizeLength: CGFloat {
        return min(bounds.width, bounds.height)
    }
    private var iconSideLenght: CGFloat {
        return roundSizeLength * 0.5
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        initialSetup()
    }
    
    private func initialSetup() {
        barLayer = CAShapeLayer()
        layer.addSublayer(barLayer)
        
        iconView = UIImageView()
        addSubview(iconView)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        barLayer.frame = bounds
        
        let mid = bounds.center
        let rect = CGRect(origin: mid.offset(dx: -iconSideLenght / 2, dy: -iconSideLenght / 2),
                          size: CGSize(width: iconSideLenght, height: iconSideLenght))
        
        iconView.frame = rect
        
        setupProgressLayer()
        setupIconLayer()
        
        changeProgress()
    }
    
    private func changeProgress() {
        switch loadingState {
        case .inProgress, .paused:
            barLayer.opacity = 1
            barLayer.strokeEnd = progress
        default:
            barLayer.opacity = 0
            barLayer.strokeEnd = 0
        }
    }
    
    private func setupProgressLayer() {
        
        let path = UIBezierPath()
        
        let sideLength = roundSizeLength
        let mid = bounds.center

        let offset: CGFloat = -.pi / 2
        let startAngle: CGFloat = offset
        let endAngle: CGFloat = (2 * .pi) + offset
        
        path.addArc(withCenter: mid,
                    radius: sideLength/2,
                    startAngle: startAngle,
                    endAngle: endAngle,
                    clockwise: true)

        
        barLayer.path = path.cgPath
        barLayer.strokeColor = tintColor.cgColor
        barLayer.fillColor = nil
        barLayer.lineCap = .round
        barLayer.lineWidth = 5.0
        barLayer.strokeEnd = 0

    }
    
    private func setupIconLayer() {
        switch loadingState {
        case .inProgress:
            iconView.isHidden = false
            iconView.image = UIImage(systemName: "pause")
        case .paused, .stoped:
            iconView.isHidden = false
            iconView.image = UIImage(systemName: "arrow.down")
        default:
            iconView.isHidden = true
        }
    }
    
    private var alphaBefore: CGFloat?
    private var transformBefore: CGAffineTransform?
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        
        transformBefore = transform
        alphaBefore = alpha
        
        transform = transform.scaledBy(x: 0.95, y: 0.95)
        alpha = alpha - 0.2
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)
        
        transform = transformBefore ?? .identity
        alpha = alphaBefore ?? 1.0
    }
    
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        initialSetup()
    }
    
}
