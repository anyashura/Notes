//
//  NotesListCollectionViewCell.swift
//  Notes
//
//  Created by Anna Shuryaeva on 12.02.2023.
//

import UIKit
import SnapKit

class NotesListCollectionViewCell: UICollectionViewCell {
    // MARK: - Properties

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .left
        label.font = UIFont(name: "Arial-BoldItalicMT", size: 17)
        label.numberOfLines = 1
        label.textColor = .black
        return label
    }()
    
    private let descriptionLabel: UILabel = {
        let descriptionLabel = UILabel()
        descriptionLabel.textColor = .gray
        descriptionLabel.backgroundColor = .clear
        descriptionLabel.font = UIFont.systemFont(ofSize: 17)
        descriptionLabel.numberOfLines = 1
        return descriptionLabel
    }()
    
    private let dateLabel: UILabel = {
        let dateLabel = UILabel()
        dateLabel.backgroundColor = .clear
        dateLabel.textColor = .gray
        dateLabel.font = UIFont.systemFont(ofSize: 15)
        dateLabel.numberOfLines = 1
        return dateLabel
    }()
    
    // MARK: - Init
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.contentView.backgroundColor = .blue.withAlphaComponent(0.1)
        self.contentView.layer.cornerRadius = 10.0
        self.contentView.layer.borderWidth = 2
        self.contentView.layer.borderColor = UIColor.darkGray.cgColor
        self.contentView.layer.masksToBounds = true
        addSubviews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Layout

    override func layoutSubviews() {
        super.layoutSubviews()
        addConstraints()
    }
    
    // MARK: - Functions

    func setup(note: NoteItem) {
        titleLabel.text = note.title
        descriptionLabel.text = note.details
        
        let date = DateFormatter()
        date.dateFormat = "dd/MM/yy h:mm a"
        let dateSaved = date.string(from: note.date ?? Date())
        dateLabel.text = dateSaved
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
}

extension NotesListCollectionViewCell {
    
    private func addSubviews() {
        contentView.addSubview(titleLabel)
        contentView.addSubview(dateLabel)
        contentView.addSubview(descriptionLabel)
    }
    
    func addConstraints() {
        titleLabel.snp.makeConstraints {
            $0.left.equalTo(contentView).inset(5)
            $0.top.right.equalTo(contentView)
            $0.bottom.equalTo(contentView.snp.centerY)
        }
        
        dateLabel.snp.makeConstraints {
            $0.top.equalTo(contentView.snp.centerY)
            $0.bottom.equalTo(contentView)
            $0.left.equalTo(contentView).inset(5)
            $0.right.equalTo(contentView.snp.centerX).multipliedBy(0.75)
        }
        
        descriptionLabel.snp.makeConstraints {
            $0.top.equalTo(contentView.snp.centerY)
            $0.left.equalTo(dateLabel.snp.right)
            $0.right.bottom.equalTo(contentView)
        }
    }
}
