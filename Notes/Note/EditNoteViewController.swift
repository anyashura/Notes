//
//  EditNoteViewController.swift
//  Notes
//
//  Created by Anna Shuryaeva on 12.02.2023.
//

import UIKit

final class EditNoteViewController: UIViewController {
    
    // MARK: - Enum
    private enum Constants {
        static let placeholderText = "Note title"
        static let title = "New note"
        static let backChevron = "chevron.backward"
        static let pickPhoto = "photo.on.rectangle"
        static let fontName = "Arial"
    }
    
    // MARK: - Properties
    var note: NoteItem?
    weak var delegate: NotesListDelegate?
    let pickImageButton = UIButton(type: .custom)
    lazy var titleTextField = UITextField()
    lazy var textView = UITextView()
    private let dataManager = CoreDataManager.shared
    private lazy var idKey = note?.identifier?.uuidString ?? "default"
    private var tapDone = false

    // MARK: - LifeCycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureView()
        setConstraints()
        registerKeyboardNotifications()
        addGestureForExit()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        titleTextField.becomeFirstResponder()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    // MARK: - Methods
    
    //Configure UI
    private func configureView() {
        view.backgroundColor = .white
        navigationController?.navigationBar.prefersLargeTitles = true
        title = Constants.title
        configureTitleField()
        configureTextView()
        configureBackButton()
        configureDoneAndDeleteButtons()
        configurePickButton()
    }
    
    private func configureTitleField() {
        titleTextField.text = note?.title
        titleTextField.placeholder = Constants.placeholderText
        titleTextField.backgroundColor = .gray.withAlphaComponent(0.1)
        titleTextField.layer.cornerRadius = 10
        titleTextField.layer.borderWidth = 1.0
        titleTextField.font = UIFont(name: Constants.fontName, size: 17.0)
        titleTextField.setLeftPaddingPoints(15)
        titleTextField.autocorrectionType = .no
        titleTextField.layer.borderColor = UIColor.lightGray.cgColor
    }
    
    private func configureTextView() {
        textView.text = note?.details
        let attributedText = self.getAttributedTextFromUserDefault(key: idKey)
        textView.attributedText = attributedText
        textView.layer.cornerRadius = 10
        textView.layer.borderWidth = 1.0
        textView.backgroundColor = .gray.withAlphaComponent(0.1)
        textView.font = UIFont(name: Constants.fontName, size: 17.0)
        textView.textContainerInset = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 20)
        textView.layer.borderColor = UIColor.lightGray.cgColor
        textView.autocorrectionType = .no
        textView.isScrollEnabled = true
        textView.isSelectable = true
        textView.isEditable = true
    }
    
    private func configureBackButton() {
        let backButton = UIBarButtonItem(image: UIImage(systemName: Constants.backChevron), style: .plain, target: self, action: #selector(updateOrDeleteNote))
        navigationItem.leftBarButtonItem = backButton
    }
    
    private func configureDoneAndDeleteButtons() {
        let doneButton = UIBarButtonItem(title: "Done", style: .plain, target: self, action: #selector(tapDoneButton)
        )
        doneButton.title = tapDone ? "Edit" : "Done"
        
        let deleteButton = UIBarButtonItem(barButtonSystemItem: .trash, target: self, action: #selector(showAlertWhenDelete))
        navigationItem.rightBarButtonItems = [doneButton, deleteButton]
    }
    
    private func configurePickButton() {
        if let image = UIImage(systemName: Constants.pickPhoto) {
            pickImageButton.setImage(image, for: .normal)
        }
        pickImageButton.backgroundColor = .gray.withAlphaComponent(0.1)
        pickImageButton.layer.cornerRadius = 5
        pickImageButton.layer.borderColor = UIColor.lightGray.cgColor
        pickImageButton.layer.borderWidth = 1
        pickImageButton.addTarget(self, action: #selector(addPicture), for: .touchUpInside)
    }
    
    // Core Data
    private func updateTextForNote() {
        if titleTextField.text == "" {
            note?.title = "No name"
        } else {
            note?.title = titleTextField.text
        }
        if textView.text == "" {
            note?.details = "No description"
        } else {
            note?.details = textView.text
        }
        note?.date = Date()
        self.saveAttributedTextToUserDefault(attributedText: textView.attributedText, key: idKey)
        dataManager.saveContext()
        delegate?.updateNotes()
    }
    
    @objc private func updateOrDeleteNote() {
        note?.title = titleTextField.text
        note?.details = textView.text
        
        if note?.title == "" && note?.details == "" {
            deleteNote()
        } else {
            note?.title = titleTextField.text
            note?.details = textView.text
            updateTextForNote()
        }
        navigationController?.popViewController(animated: true)
    }
    
    @objc private func deleteNote() {
        if note != nil, note?.identifier != nil {
            delegate?.deleteNote(identifier: (note?.identifier)! )
            dataManager.deleteNote(note: note!)
        }
    }
    
    @objc private func tapDoneButton() {
        tapDone.toggle()
        DispatchQueue.main.async {
            self.configureDoneAndDeleteButtons()
        }
        textView.isEditable.toggle()
        if tapDone {
            titleTextField.resignFirstResponder()
            textView.resignFirstResponder()
        }
    }
    
    // Pick picture
    @objc func addPicture(_ sender: UIButton) {
        ImagePickerManager().pickImage(self){ image in
            let resizedImage = image.resizeImage(targetSize: .init(width: self.textView.bounds.width - 30, height: self.textView.bounds.height - 20))
            self.addToTextView(image: resizedImage)
        }
    }

    private func addToTextView(image: UIImage) {
        let attachment = NSTextAttachment()
        attachment.image = image
        let attString = NSAttributedString(attachment: attachment)
        saveAttributedTextToUserDefault(attributedText: attString, key: idKey)

        textView.textStorage.insert(attString, at: textView.selectedRange.location)
    }
    
    func saveAttributedTextToUserDefault(attributedText: NSAttributedString, key: String) {
        do {
            let data = try attributedText.data(from: NSRange(location: 0, length: attributedText.length), documentAttributes: [.documentType: NSAttributedString.DocumentType.rtfd])
            UserDefaults.standard.setValue(data, forKeyPath: key)
        } catch {
            print(error)
        }
    }
    
    func getAttributedTextFromUserDefault(key: String) -> NSAttributedString {
        if let dataValue = UserDefaults.standard.value(forKey: key) as? Data {
            do {
                let attributeText = try NSAttributedString(data: dataValue, documentAttributes: nil)
                return attributeText
            } catch {
                print("error: ", error)
            }
        }

        return NSAttributedString()
    }
            
    //MARK: - Alert for deleting
    
    @objc private func showAlertWhenDelete() {
        let alert = UIAlertController(title: "Delete this note?", message: nil, preferredStyle: .alert)
        let yesAction = UIAlertAction(title: "Yes", style: .default) { _ in
            self.deleteNote()
            self.navigationController?.popViewController(animated: true)
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .destructive)
        alert.addAction(cancelAction)
        alert.addAction(yesAction)
        present(alert, animated: true)
    }
    
    //MARK: - Notifications
    
    private func registerKeyboardNotifications() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(updateTextView),
            name: UIResponder.keyboardWillShowNotification,
            object: nil
        )

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(updateTextView),
            name: UIResponder.keyboardWillHideNotification,
            object: nil
        )
    }
    
    @objc private func updateTextView(_ notification: Notification) {
        let info = notification.userInfo
        let keyboardSize = (info![UIResponder.keyboardFrameEndUserInfoKey] as! NSValue).cgRectValue
        let keyboardFrame = self.view.convert(keyboardSize, to: view.window)
        if notification.name == UIResponder.keyboardWillHideNotification {
            textView.contentInset = UIEdgeInsets.zero
        } else {
            textView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: keyboardFrame.height, right: 0)
            textView.scrollIndicatorInsets = textView.contentInset
        }
        textView.scrollRangeToVisible(textView.selectedRange)
    }
}
 // MARK: - Extension

extension EditNoteViewController {
    //MARK: - Gestures
    func addGestureForExit() {
        let swipeRight = UISwipeGestureRecognizer(target: self, action: #selector(updateOrDeleteNote))
        swipeRight.direction = .right
        view.addGestureRecognizer(swipeRight)
    }
}
