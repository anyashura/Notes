//
//  ExtensionsForEditNoteVC.swift
//  Notes
//
//  Created by Anna Shuryaeva on 18.02.2023.
//

import Foundation
import UIKit

extension EditNoteViewController: UITextViewDelegate, UITextFieldDelegate {
}

extension EditNoteViewController {
    // MARK: - Constraints
    
    func setConstraints() {
        setConstraintsForTextField()
        setConstraintsForTextView()
        setConstraintsForPickButton()
        setConstraintsForDecreaseFontSizeButton()
        setConstraintsForIncreaseFontSizeButton()
    }
    
    func setConstraintsForTextView() {
        view.addSubview(textView)
        textView.delegate = self
        
        textView.snp.makeConstraints {
            $0.left.right.equalTo(view.safeAreaLayoutGuide).inset(10)
            $0.top.equalTo(titleTextField.snp.bottom).offset(20)
            $0.bottom.equalTo(view.safeAreaLayoutGuide).inset(100)
        }
    }
    
    func setConstraintsForTextField() {
        view.addSubview(titleTextField)
        titleTextField.delegate = self
        
        titleTextField.snp.makeConstraints {
            $0.top.left.right.equalTo(view.safeAreaLayoutGuide).inset(10)
            $0.height.equalTo(50)
        }
    }
    
    func setConstraintsForPickButton() {
        view.addSubview(pickImageButton)
        pickImageButton.snp.makeConstraints {
            $0.top.equalTo(textView.snp.bottom).offset(10)
            $0.right.equalTo(textView.snp.right)
            $0.height.width.equalTo(40)
        }
    }
    
    func setConstraintsForDecreaseFontSizeButton() {
        view.addSubview(decreaseFontSizeButton)
        decreaseFontSizeButton.snp.makeConstraints {
            $0.top.equalTo(textView.snp.bottom).offset(20)
            $0.left.equalTo(textView.snp.left)
            $0.height.width.equalTo(20)
        }
    }
    
    func setConstraintsForIncreaseFontSizeButton() {
        view.addSubview(increaseFontSizeButton)
        increaseFontSizeButton.snp.makeConstraints {
            $0.top.equalTo(textView.snp.bottom).offset(20)
            $0.left.equalTo(decreaseFontSizeButton.snp.right).offset(1)
            $0.height.width.equalTo(20)
        }
    }
}

extension UITextField {
    // MARK: - Padding for TextView
    func setLeftPaddingPoints(_ amount: CGFloat) {
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: amount, height: self.frame.size.height))
        self.leftView = paddingView
        self.leftViewMode = .always
    }
}

extension UIImage {
    
    func resizeImage(targetSize: CGSize) -> UIImage {
      let size = self.size
      let widthRatio  = targetSize.width  / size.width
      let heightRatio = targetSize.height / size.height
      let newSize = widthRatio > heightRatio ?  CGSize(width: size.width * heightRatio, height: size.height * heightRatio) : CGSize(width: size.width * widthRatio, height: size.height * widthRatio)
      let rect = CGRect(x: 0, y: 0, width: newSize.width, height: newSize.height)
      UIGraphicsBeginImageContextWithOptions(newSize, false, 1.0)
      self.draw(in: rect)
      let newImage = UIGraphicsGetImageFromCurrentImageContext()
      UIGraphicsEndImageContext()
      return newImage!
    }
}
