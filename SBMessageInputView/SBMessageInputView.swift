//
//  SBMessageInputView.swift
//  SBMessageInputView
//
//  Created by Sacha BECOURT on 4/16/18.
//  Copyright © 2018 SB. All rights reserved.
//

import UIKit

protocol SBMessageInputViewDelegate: class {
    
    // TextViewDelegate methods
    func inputView(textView: UITextView, shouldChangeTextInRange: NSRange, replacementText: String) -> Bool
    func inputViewDidChange(textView: UITextView)
    func inputViewDidBeginEditing(textView: UITextView)
    func inputViewShouldBeginEditing(textView: UITextView) -> Bool
    
    // Button tap callback methods
    func inputViewDidTapButton(button: UIButton)
}

@IBDesignable
class SBMessageInputView: UIView {

    @IBInspectable var buttonImage: UIImage = SBMessageInputView.getDefaultImage() {
        didSet {
            button.setImage(buttonImage, for: .normal)
        }
    }
    
    @IBInspectable var viewBorderColor: UIColor = .gray {
        didSet {
            mainView.layer.borderColor = viewBorderColor.cgColor
        }
    }
    
    @IBInspectable var viewBorderWidth: CGFloat = 0.5 {
        didSet {
            mainView.layer.borderWidth = viewBorderWidth
        }
    }

    @IBInspectable var maxLines: CGFloat = 5.0
    
    @IBInspectable var textViewTopInset: CGFloat = 0.0 {
        didSet {
            textView.contentInset = UIEdgeInsets(top: textViewTopInset, left: textView.contentInset.left, bottom: textView.contentInset.bottom, right: textView.contentInset.right)
        }
    }
    
    @IBInspectable var textViewLeftInset: CGFloat = 8.0 {
        didSet {
            textView.contentInset = UIEdgeInsets(top: textView.contentInset.top, left: textViewLeftInset, bottom: textView.contentInset.bottom, right: textView.contentInset.right)
        }
    }

    var numberOfLines: CGFloat = 1.0 {
        didSet {
            if numberOfLines > oldValue && numberOfLines <= maxLines {
                increaseSize()
            } else if numberOfLines < oldValue && numberOfLines <= maxLines {
                reduceSize()
            } else {
                // do nothing
            }
        }
    }
    
    // Views
    var mainView = UIView()
    var textView = UITextView(frame: .zero)
    var button = UIButton()
    var heightConstraint: NSLayoutConstraint?
    
    // Heights
    var originalViewHeight: CGFloat = 0.0
    var containerViewHeight: CGFloat {
        let top: CGFloat = 4.0
        let bottom: CGFloat = 4.0
        return originalViewHeight - (top + bottom)
    }
    var buttonViewHeight: CGFloat = 26.0
    var lineHeight: CGFloat = 0.0
    
    // Delegate
    var delegate: SBMessageInputViewDelegate?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupView()
    }
    
    class func getDefaultImage()-> UIImage {
        if let defaultImage = UIImage(named: "send") {
            return defaultImage
        } else {
            return UIImage()
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        if originalViewHeight == 0 {
            originalViewHeight = frame.height
        }
        
        mainView.layer.cornerRadius = containerViewHeight / 2.0
        setTextView()
        textView.setContentOffset(CGPoint(x: -textViewLeftInset - 20, y: -textViewTopInset), animated: false)
    }
    
    fileprivate func setupView() {
        setContainerView()
    }
    
    func increaseSize() {
        
        let newConstant = containerViewHeight + ((numberOfLines - 1) * lineHeight) + 8.0
        if let c = heightConstraint {
            c.constant = newConstant
        } else {
            for constraint in constraints {
                if constraint.firstAttribute == .height {
                    constraint.constant = newConstant
                    break
                }
            }
        }
    }
    
    func reduceSize() {
        
        let newConstant = numberOfLines == 1 ? containerViewHeight + 8.0 : containerViewHeight + ((numberOfLines - 1) * lineHeight) + 8.0
        if let c = heightConstraint {
            c.constant = newConstant
        } else {
            for constraint in constraints {
                if constraint.firstAttribute == .height {
                    constraint.constant = newConstant
                    break
                }
            }
        }
    }
    
    fileprivate func setContainerView() {
        mainView = UIView(frame: .zero)
        addSubview(mainView)
        
        mainView.translatesAutoresizingMaskIntoConstraints = false
        let leadingConstraint = NSLayoutConstraint(item: mainView, attribute: .leading, relatedBy: .equal, toItem: self, attribute: .leading, multiplier: 1, constant: 16)
        let trailingConstraint = NSLayoutConstraint(item: self, attribute: .trailing, relatedBy: .equal, toItem: mainView, attribute: .trailing, multiplier: 1, constant: 16)
        let topConstraint = NSLayoutConstraint(item: mainView, attribute: .top, relatedBy: .equal, toItem: self, attribute: .top, multiplier: 1, constant: 4)
        let bottomConstraint = NSLayoutConstraint(item: self, attribute: .bottom, relatedBy: .equal, toItem: mainView, attribute: .bottom, multiplier: 1, constant: 4)
        
        addConstraints([topConstraint, bottomConstraint, leadingConstraint, trailingConstraint])
    }
    
    fileprivate func setTextView() {
        
        if textView.delegate == nil {
            textView = UITextView(frame: .zero)
            textView.delegate = self
            
            button = UIButton(type: .custom)
            button.setImage(buttonImage, for: .normal)
            button.addTarget(self, action: #selector(didTapButton(sender:)), for: .touchUpInside)
            
            textView.clipsToBounds = true
            textView.layer.cornerRadius = containerViewHeight / 2.0
            textView.contentInset = UIEdgeInsets(top: textViewTopInset, left: 0.0, bottom: 0.0, right: 0.0)
            textView.font = UIFont.systemFont(ofSize: 18.0)
            
            mainView.addSubview(textView)
            mainView.addSubview(button)
            
            textView.translatesAutoresizingMaskIntoConstraints = false
            textView.leadingAnchor.constraint(equalTo: mainView.leadingAnchor, constant: textViewLeftInset).isActive = true
            textView.topAnchor.constraint(equalTo: mainView.topAnchor, constant: 0.0).isActive = true
            textView.bottomAnchor.constraint(equalTo: mainView.bottomAnchor, constant: 0.0).isActive = true
            
            button.translatesAutoresizingMaskIntoConstraints = false
            button.heightAnchor.constraint(equalToConstant: buttonViewHeight).isActive = true
            button.widthAnchor.constraint(equalToConstant: buttonViewHeight).isActive = true
            button.leadingAnchor.constraint(equalTo: textView.trailingAnchor, constant: 5.0).isActive = true
            button.trailingAnchor.constraint(equalTo: mainView.trailingAnchor, constant: -5.0).isActive = true
            button.bottomAnchor.constraint(equalTo: mainView.bottomAnchor, constant: -5.5).isActive = true
        }
    }
    
    @objc fileprivate func didTapButton(sender: UIButton) {
        if let delegate = delegate {
            delegate.inputViewDidTapButton(button: sender)
        }
    }
}

extension SBMessageInputView: UITextViewDelegate {
    
    func textViewShouldBeginEditing(_ textView: UITextView) -> Bool {
        if let delegate = delegate {
            return delegate.inputViewShouldBeginEditing(textView: textView)
        }
        return true
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        if let delegate = delegate {
            delegate.inputViewDidBeginEditing(textView: textView)
        }
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        
        if let delegate = delegate {
            return delegate.inputView(textView: textView, shouldChangeTextInRange: range, replacementText: text)
        }
        return true
    }
    
    func textViewDidChange(_ textView: UITextView) {
        guard let font = textView.font else { return }
        let fontLineHeight = font.lineHeight
        
        let lines = round((textView.contentSize.height - textView.textContainerInset.top - textView.textContainerInset.bottom) / fontLineHeight)
        lineHeight = fontLineHeight
        numberOfLines = lines
        
        if let delegate = delegate {
            delegate.inputViewDidChange(textView: textView)
        }
    }
}
