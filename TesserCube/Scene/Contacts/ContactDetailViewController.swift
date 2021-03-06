//
//  ContactDetailViewController.swift
//  TesserCube
//
//  Created by jk234ert on 2019/3/27.
//  Copyright © 2019 Sujitech. All rights reserved.
//

import UIKit
import SnapKit
//import SwifterSwift

class ContactDetailViewController: TCBaseViewController {
    
    var contactId: Int64
    private(set) var isPresenting = true
    private(set) var didPresented = false

    private var defaultNavigationBarShadowImage: UIImage?
    private var contact: Contact?

    init(contactId: Int64) {
        self.contactId = contactId
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private lazy var topBackgroundView: UIView = {
        let view = UIView(frame: .zero)
        if #available(iOS 13.0, *) {
            view.backgroundColor = .secondarySystemBackground
        } else {
            // Fallback on earlier versions
            view.backgroundColor = ._systemBackground
        }
        return view
    }()

    private lazy var userNameLabel: UILabel = {
        let label = UILabel(frame: .zero)
        label.font = FontFamily.SFProText.regular.font(size: 30)
        label.textAlignment = .center
        label.numberOfLines = 2
        return label
    }()

    private lazy var userIdentifierLabel: UILabel = {
        let label = UILabel(frame: .zero)
        label.font = FontFamily.SourceCodeProMedium.regular.font(size: 17)
        label.textColor = .systemGreen
        label.textAlignment = .center
        label.numberOfLines = 1
        return label
    }()

    private lazy var fingerprintlabel: UILabel = {
        let label = UILabel(frame: .zero)
        label.font = FontFamily.SourceCodePro.regular.font(size: 17)
        label.numberOfLines = 2
        return label
    }()
    
    private lazy var exportPubKeyButton: UIButton = {
        let button = UIButton(type: .system)
        button.titleLabel?.font = FontFamily.SFProText.regular.font(size: 17)
        button.setTitle(L10n.ContactDetailViewController.Button.exportPubKey, for: .normal)
        button.contentHorizontalAlignment = .leading
        return button
    }()

    private lazy var validitylabel: UILabel = {
        let label = UILabel(frame: .zero)
        label.font = FontFamily.SFProText.regular.font(size: 17)
        label.textColor = .systemGreen
        return label
    }()

    private lazy var typelabel: UILabel = {
        let label = UILabel(frame: .zero)
        label.font = FontFamily.SFProText.regular.font(size: 17)
        return label
    }()

    private lazy var createdAtlabel: UILabel = {
        let label = UILabel(frame: .zero)
        label.font = FontFamily.SFProText.regular.font(size: 17)
        label.adjustsFontSizeToFitWidth = true
        return label
    }()

    private lazy var emailTextView: UITextView = {
        let textView = UITextView(frame: .zero)
        textView.isScrollEnabled = false    // fix AutoLayout height
        textView.font = FontFamily.SFProText.regular.font(size: 17)
        textView.dataDetectorTypes = [.link]
        textView.isUserInteractionEnabled = true
        textView.isEditable = false
        textView.textContainerInset = .zero
        textView.backgroundColor = .clear
        return textView
    }()

    private lazy var sendMessageButton: TCActionButton = {
        let button = TCActionButton(frame: .zero)
        button.color = .systemBlue
        button.setTitleColor(.white, for: .normal)
        button.setTitle(L10n.ContactDetailViewController.Button.sendMessage, for: .normal)
        return button
    }()

    override func configUI() {
        super.configUI()

        if #available(iOS 13.0, *) {
            view.backgroundColor = .systemBackground
        } else {
            // Fallback on earlier versions
            view.backgroundColor = .white
        }
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: L10n.Common.Button.edit, style: .plain, target: self, action: #selector(ContactDetailViewController.editButtonDidClicked(_:)))
        
        view.addSubview(topBackgroundView)

        topBackgroundView.addSubview(userNameLabel)
        topBackgroundView.addSubview(userIdentifierLabel)
        
        userNameLabel.snp.makeConstraints { maker in
            maker.leading.trailing.equalTo(view.layoutMarginsGuide)
            maker.top.equalToSuperview().offset(79)
        }

        userIdentifierLabel.snp.makeConstraints { maker in
            maker.leading.trailing.equalTo(view.layoutMarginsGuide)
            maker.top.equalTo(userNameLabel.snp.bottom).offset(10)
        }

        topBackgroundView.snp.makeConstraints { maker in
            maker.leading.trailing.equalToSuperview()
            maker.top.equalToSuperview()
            maker.bottom.equalTo(userIdentifierLabel.snp.bottom).offset(15)
        }

        let scrollView = UIScrollView()
        view.addSubview(scrollView)
        scrollView.snp.makeConstraints { maker in
            maker.top.equalTo(topBackgroundView.snp.bottom)
            maker.leading.trailing.bottom.equalTo(view)
        }
        scrollView.alwaysBounceVertical = true

        // 1. Fingerprint
        let fingerprintTitleLabel = createTitleLabel(title: L10n.ContactDetailViewController.Label.fingerprint)
        scrollView.addSubview(fingerprintTitleLabel)

        fingerprintTitleLabel.snp.makeConstraints { maker in
            maker.leading.equalTo(view.readableContentGuide)
            maker.top.equalTo(scrollView.snp.top).offset(15)
        }

        scrollView.addSubview(fingerprintlabel)
        fingerprintlabel.snp.makeConstraints { maker in
            maker.leading.equalTo(view.readableContentGuide)
            maker.top.equalTo(fingerprintTitleLabel.snp.bottom).offset(2)
        }

        // 2. validity
        let validityTitleLabel = createTitleLabel(title: L10n.ContactDetailViewController.Label.validity)
        scrollView.addSubview(validityTitleLabel)

        validityTitleLabel.snp.makeConstraints { maker in
            maker.leading.equalTo(view.readableContentGuide)
            maker.top.equalTo(fingerprintlabel.snp.bottom).offset(17)
        }

        scrollView.addSubview(validitylabel)
        validitylabel.snp.makeConstraints { maker in
            maker.leading.equalTo(view.readableContentGuide)
            maker.top.equalTo(validityTitleLabel.snp.bottom).offset(2)
        }

        // 3. type
        let typeTitleLabel = createTitleLabel(title: L10n.ContactDetailViewController.Label.keytype)
        scrollView.addSubview(typeTitleLabel)

        typeTitleLabel.snp.makeConstraints { maker in
            maker.leading.equalTo(view.readableContentGuide)
            maker.top.equalTo(validitylabel.snp.bottom).offset(17)
        }

        scrollView.addSubview(typelabel)
        typelabel.snp.makeConstraints { maker in
            maker.leading.equalTo(view.readableContentGuide)
            maker.top.equalTo(typeTitleLabel.snp.bottom).offset(2)
        }

        // 4. created at
        let createdAtTitleLabel = createTitleLabel(title: L10n.ContactDetailViewController.Label.createdAt)
        scrollView.addSubview(createdAtTitleLabel)

        createdAtTitleLabel.snp.makeConstraints { maker in
            maker.leading.equalTo(view.readableContentGuide)
            maker.top.equalTo(typelabel.snp.bottom).offset(17)
        }

        scrollView.addSubview(createdAtlabel)
        createdAtlabel.snp.makeConstraints { maker in
            maker.leading.trailing.equalTo(view.readableContentGuide)
            maker.top.equalTo(createdAtTitleLabel.snp.bottom).offset(2)
        }

        // 5. email
        let emailTitlelabel = createTitleLabel(title: L10n.ContactDetailViewController.Label.email)
        scrollView.addSubview(emailTitlelabel)

        emailTitlelabel.snp.makeConstraints { maker in
            maker.leading.equalTo(view.readableContentGuide)
            maker.top.equalTo(createdAtlabel.snp.bottom).offset(17)
        }

        scrollView.addSubview(emailTextView)
        emailTextView.snp.makeConstraints { maker in
            maker.leading.equalTo(view.readableContentGuide).offset(-5)
            maker.trailing.equalTo(view.readableContentGuide)
            maker.top.equalTo(emailTitlelabel.snp.bottom)
        }

        // Export public key button
        let upperSeparatorLine = UIView()
        scrollView.addSubview(upperSeparatorLine)
        upperSeparatorLine.snp.makeConstraints { maker in
            maker.leading.trailing.equalTo(view.readableContentGuide)
            maker.top.equalTo(emailTextView.snp.bottom).offset(16)
            maker.height.equalTo(0.67)
        }
        upperSeparatorLine.backgroundColor = .separator

        scrollView.addSubview(exportPubKeyButton)
        exportPubKeyButton.snp.makeConstraints { maker in
            maker.leading.trailing.equalTo(view.readableContentGuide)
            maker.top.equalTo(upperSeparatorLine.snp.bottom).offset(8)
        }

        let lowerSeparatorLine = UIView()
        scrollView.addSubview(lowerSeparatorLine)
        lowerSeparatorLine.snp.makeConstraints { maker in
            maker.leading.trailing.equalTo(view.readableContentGuide)
            maker.top.equalTo(exportPubKeyButton.snp.bottom).offset(8)
            maker.height.equalTo(upperSeparatorLine)
            maker.bottom.equalToSuperview()     // snap to scroll view bottom
        }
        lowerSeparatorLine.backgroundColor = .separator

        // 6. Send message button
        view.addSubview(sendMessageButton)
        sendMessageButton.snp.makeConstraints { maker in
            maker.leading.trailing.equalTo(view.readableContentGuide)
            maker.bottom.equalTo(view.safeAreaLayoutGuide).offset(-20)
        }

        scrollView.contentInset.bottom = 100

        exportPubKeyButton.addTarget(self, action: #selector(ContactDetailViewController.exportPubKeyToPasteboard(_:)), for: .touchUpInside)
        sendMessageButton.addTarget(self, action: #selector(ContactDetailViewController.sendMessageButtonDidClicked(_:)), for: .touchUpInside)
    }

}

extension ContactDetailViewController {

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        // fix navigation bar hairline bug
        if isPresenting {
            assert(navigationController != nil)
            defaultNavigationBarShadowImage = navigationController?.navigationBar.shadowImage?.copy() as? UIImage
            navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
            navigationController?.navigationBar.shadowImage = UIImage()

            isPresenting = false
            didPresented = true
        }

        updateData()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        if didPresented {
            assert(navigationController != nil)
            navigationController?.navigationBar.setBackgroundImage(UINavigationBar().backgroundImage(for: .default), for: .default)
            // FIXME: hairline under large title style bar not restore successful
            navigationController?.navigationBar.shadowImage = defaultNavigationBarShadowImage

            didPresented = false
        }

    }

    @objc
    private func editButtonDidClicked(_ sender: UIButton) {
        guard let toEditContactId = contact?.id else { return }
        Coordinator.main.present(scene: .contactEdit(contactId: toEditContactId), from: self)
    }

    @objc
    private func sendMessageButtonDidClicked(_ sender: UIButton) {
        guard let currentContact = contact,
        let keys = contact?.getKeys(), !keys.isEmpty else { return }

        let keybridges = keys.map { key in
            KeyBridge(contact: currentContact, key: key)
        }

        Coordinator.main.present(scene: .composeMessageTo(keyBridges: keybridges), from: self, transition: .modal, completion: nil)
    }
    
    @objc
    private func exportPubKeyToPasteboard(_ sender: UIButton) {
        guard let firstKey = contact?.getKeys().first else {
            return
        }

        ShareUtil.share(key: firstKey, from: self, over: sender)
    }

    private func createTitleLabel(title: String) -> UILabel {
        let label = UILabel(frame: .zero)
        label.text = title
        label.font = FontFamily.SFProText.regular.font(size: 14)
        label.numberOfLines = 1
        return label
    }

    private func updateData() {
        contact = Contact.find(id: contactId)
        let keys = contact?.getKeys()
        let emails = contact?.getEmails()

        userNameLabel.text = contact?.name
        userIdentifierLabel.text = keys?.first?.shortIdentifier
        fingerprintlabel.text = keys?.first?.displayFingerprint ?? L10n.ContactDetailViewController.Label.invalidFingerprint

        let isValid = keys?.first?.isValid ?? false
        validitylabel.text = isValid ? L10n.ContactDetailViewController.Label.valid : L10n.ContactDetailViewController.Label.invalid
        validitylabel.textColor = isValid ? .systemGreen : .systemRed

        let keyTypeString = keys?.first?.primaryKeyAlgorihm?.displayName ?? L10n.Common.Label.nameUnknown
        let keySizeString = keys?.first?.primaryKeyStrength?.string ?? L10n.Common.Label.nameUnknown
        let keyInfoString = "\(keyTypeString)-\(keySizeString)"
        typelabel.text = keyInfoString

        createdAtlabel.text = keys?.first?.creationDate.flatMap {
            let formatter = DateFormatter()
            formatter.dateStyle = .long
            formatter.timeStyle = .long
            // alternative format style
            // formatter.dateFormat = "yyyy-MM-dd hh:mm '('z')'"
            return formatter.string(from: $0)
        } ?? L10n.Common.Label.nameUnknown

        let emailsString = emails?.compactMap { $0.address }.joined(separator: "\n")
        emailTextView.text = emailsString
    }
}
