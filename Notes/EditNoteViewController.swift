//
//  EditNoteViewController.swift
//  Notes
//
//  Created by Anna Shuryaeva on 12.02.2023.
//

import UIKit

class EditNoteViewController: UIViewController {
    
    let dataManager = CoreDataManager.shared
    var note: NoteItem?
    
    private lazy var titleTextField: UITextField = {
        let titleTextField = UITextField()
        titleTextField.placeholder = " Note title "
        titleTextField.layer.cornerRadius = 10
        titleTextField.layer.borderWidth = 1.0
        titleTextField.backgroundColor = .yellow
        titleTextField.layer.borderColor = UIColor.lightGray.cgColor
        return titleTextField
    }()
    
    private lazy var textView: UITextView = {
        let textView = UITextView()
        textView.backgroundColor = .brown
        textView.layer.cornerRadius = 10
        textView.layer.borderWidth = 1.0
        textView.textContainerInset = UIEdgeInsets(top: 10, left: 20, bottom: 0, right: 10)
        textView.layer.borderColor = UIColor.lightGray.cgColor
        textView.dataDetectorTypes = [.link, .phoneNumber]
        textView.isSelectable = true
        textView.isEditable = true
        return textView
    }()
    
//    private func setupNavBar() {
//        let backButton = UIBarButtonItem(
//            image: UIImage(systemName: "arrow.backward"),
//            style: .plain,
//            target: self,
//            action: #selector(finalNoteCheck)
//        )
//        backButton.tintColor = UIColor(named: "textColor")
//        
//        let doneButton = UIBarButtonItem(
//            title: "Done",
//            style: .plain,
//            target: self,
//            action: #selector(doneButtonPressed)
//        )
//        doneButton.tintColor = UIColor(named: "textColor")
//        doneButton.title = isDone ? "Edit" : "Done"
//        
//        let trashButton = UIBarButtonItem(
//            barButtonSystemItem: .trash ,
//            target: self,
//            action: #selector(showTrashButtonAlert)
//        )
//        trashButton.tintColor = .systemRed
//        navigationItem.leftBarButtonItem = backButton
//        navigationItem.rightBarButtonItems = [trashButton, doneButton]
//    }
    
    @objc private func tapSave() {
        print("Tap")
 
        dismiss(animated: true)


    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
//        setupNavigationBarItem()
        setupTextField()
        setupTextView()

    }
    
//    private func setupNavigationBarItem() {
//        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(dismissKeyboard))
//    }
    
}
extension EditNoteViewController: UITextViewDelegate, UITextFieldDelegate {
    
    
}

extension EditNoteViewController {
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
    
}
extension EditNoteViewController {
    
    private func setupTextView() {
        view.addSubview(textView)
        textView.delegate = self
        
        textView.snp.makeConstraints {
            $0.left.right.equalTo(view.safeAreaLayoutGuide).inset(10)
            $0.top.equalTo(titleTextField.snp.bottom).offset(20)
            $0.bottom.equalTo(view.safeAreaLayoutGuide).inset(300)
        }
    }
    
//    private func setupSaveButton() {
//        view.addSubview(saveButton)
//        
//        saveButton.snp.makeConstraints {
//            $0.top.equalTo(view).inset(55)
//            $0.right.equalToSuperview().inset(16)
//        }
//    }
    
    private func setupTextField() {
        view.addSubview(titleTextField)
        titleTextField.delegate = self
        
        titleTextField.snp.makeConstraints {
            $0.top.left.right.equalTo(view.safeAreaLayoutGuide).inset(10)
            $0.height.equalTo(50)
        }
    }

}
