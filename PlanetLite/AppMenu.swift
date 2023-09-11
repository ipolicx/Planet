//
//  AppMenu.swift
//  PlanetLite
//

import Cocoa
import UniformTypeIdentifiers

@objc protocol EditMenuActions {
    func redo(_ sender: AnyObject)
    func undo(_ sender: AnyObject)
}

@objc protocol FileMenuActions {
    func importPlanet(_ sender: AnyObject)
    func rebuildPlanet(_ sender: AnyObject)
    func learnMore(_ sender: AnyObject)
    func openDiscordInviteLink(_ sender: AnyObject)
}

@objc protocol WriterMenuActions {
    func send(_ sender: AnyObject)
    func insertEmoji(_ sender: AnyObject)
    func attachPhoto(_ sender: AnyObject)
    func attachVideo(_ sender: AnyObject)
    func attachAudio(_ sender: AnyObject)
}

extension PlanetLiteAppDelegate: FileMenuActions, WriterMenuActions {
    func learnMore(_ sender: AnyObject) {
        if let url = URL(string: "https://croptop.eth.limo") {
            NSWorkspace.shared.open(url)
        }
    }

    func openDiscordInviteLink(_ sender: AnyObject) {
        if let url = URL(string: "https://discord.com/invite/ZSFkRjFkrA") {
            NSWorkspace.shared.open(url)
        }
    }

    func populateMainMenu() {
        let mainMenu = NSMenu(title: "MainMenu")

        // The titles of the menu items are for identification purposes only and shouldn't be localized.
        // The strings in the menu bar come from the submenu titles,
        // except for the application menu, whose title is ignored at runtime.
        var menuItem = mainMenu.addItem(withTitle: "Application", action: nil, keyEquivalent: "")
        var submenu = NSMenu(title: "Application")
        populateApplicationMenu(submenu)
        mainMenu.setSubmenu(submenu, for: menuItem)

        menuItem = mainMenu.addItem(withTitle: "File", action: nil, keyEquivalent: "")
        submenu = NSMenu(title: NSLocalizedString("File", comment: "File menu"))
        populateFileMenu(submenu)
        mainMenu.setSubmenu(submenu, for: menuItem)

        // Keep basic text editing features
        menuItem = mainMenu.addItem(withTitle: "Edit", action: nil, keyEquivalent: "")
        submenu = NSMenu(title: NSLocalizedString("Edit", comment: "Edit menu"))
        populateEditMenu(submenu)
        mainMenu.setSubmenu(submenu, for:menuItem)
        
        // Writer commands for editing post
        menuItem = mainMenu.addItem(withTitle: "Writer", action: nil, keyEquivalent: "")
        submenu = NSMenu(title: NSLocalizedString("Writer", comment: "Writer menu"))
        populateWriterMenu(submenu)
        mainMenu.setSubmenu(submenu, for: menuItem)

        menuItem = mainMenu.addItem(withTitle: "Window", action:nil, keyEquivalent: "")
        submenu = NSMenu(title:NSLocalizedString("Window", comment: "Window menu"))
        populateWindowMenu(submenu)
        mainMenu.setSubmenu(submenu, for: menuItem)
        NSApp.windowsMenu = submenu

        menuItem = mainMenu.addItem(withTitle: "Help", action: nil, keyEquivalent: "")
        submenu = NSMenu(title: NSLocalizedString("Help", comment: "View menu"))
        populateHelpMenu(submenu)
        mainMenu.setSubmenu(submenu, for: menuItem)

        NSApp.mainMenu = mainMenu
    }

    // MARK: - Menu: Application -

    func populateApplicationMenu(_ menu: NSMenu) {

        var title = NSLocalizedString("About", comment: "About menu item") + " " + applicationName
        var menuItem = menu.addItem(
            withTitle: title,
            action: #selector(NSApplication.orderFrontStandardAboutPanel(_:)),
            keyEquivalent: ""
        )
        menuItem.target = NSApp

        title = NSLocalizedString("Check for Updates", comment: "")
        menuItem = menu.addItem(
            withTitle: title,
            action: #selector(self.checkForUpdate(_:)),
            keyEquivalent: ""
        )
        menuItem.target = self

        menu.addItem(NSMenuItem.separator())

        title = NSLocalizedString("Services", comment: "Services menu item")
        menuItem = menu.addItem(withTitle: title, action: nil, keyEquivalent: "")
        let servicesMenu = NSMenu(title: "Services")
        menu.setSubmenu(servicesMenu, for: menuItem)
        NSApp.servicesMenu = servicesMenu

        menu.addItem(NSMenuItem.separator())

        title = NSLocalizedString("Hide", comment: "Hide menu item") + " " + applicationName
        menuItem = menu.addItem(
            withTitle: title,
            action: #selector(NSApplication.hide(_:)),
            keyEquivalent: "h"
        )
        menuItem.target = NSApp

        title = NSLocalizedString("Hide Others", comment: "Hide Others menu item")
        menuItem = menu.addItem(
            withTitle: title,
            action: #selector(NSApplication.hideOtherApplications(_:)),
            keyEquivalent: "h"
        )
        menuItem.keyEquivalentModifierMask = [.command, .option]
        menuItem.target = NSApp

        title = NSLocalizedString("Show All", comment: "Show All menu item")
        menuItem = menu.addItem(
            withTitle: title,
            action: #selector(NSApplication.unhideAllApplications(_:)),
            keyEquivalent: ""
        )
        menuItem.target = NSApp

        menu.addItem(NSMenuItem.separator())

        title = NSLocalizedString("Quit", comment: "Quit menu item") + " " + applicationName
        menuItem = menu.addItem(
            withTitle: title,
            action: #selector(NSApplication.terminate(_:)),
            keyEquivalent: "q"
        )
        menuItem.target = NSApp
    }

    func populateFileMenu(_ menu: NSMenu) {
        let importItem = NSMenuItem(
            title: NSLocalizedString("Import Site", comment: "Import Site menu item"),
            action: #selector(FileMenuActions.importPlanet(_:)),
            keyEquivalent: "i"
        )
        importItem.keyEquivalentModifierMask = [.command, .shift]
        menu.addItem(importItem)
        let rebuildItem = NSMenuItem(
            title: NSLocalizedString("Rebuild Site", comment: "Rebuild Site menu item"),
            action: #selector(FileMenuActions.rebuildPlanet(_:)),
            keyEquivalent: "r")
        rebuildItem.keyEquivalentModifierMask = [.command]
        menu.addItem(rebuildItem)
    }

    func populateEditMenu(_ menu: NSMenu) {
        var title = NSLocalizedString("Undo", comment: "Undo menu item")
        menu.addItem(
            withTitle: title,
            action: #selector(EditMenuActions.undo(_:)),
            keyEquivalent: "z"
        )

        title = NSLocalizedString("Redo", comment: "Redo menu item")
        menu.addItem(
            withTitle: title,
            action: #selector(EditMenuActions.redo(_:)),
            keyEquivalent: "Z"
        )

        menu.addItem(NSMenuItem.separator())

        title = NSLocalizedString("Cut", comment: "Cut menu item")
        menu.addItem(withTitle: title, action: #selector(NSText.cut(_:)), keyEquivalent: "x")

        title = NSLocalizedString("Copy", comment: "Copy menu item")
        menu.addItem(withTitle: title, action: #selector(NSText.copy(_:)), keyEquivalent: "c")

        title = NSLocalizedString("Paste", comment: "Paste menu item")
        menu.addItem(withTitle: title, action: #selector(NSText.paste(_:)), keyEquivalent: "v")

        title = NSLocalizedString(
            "Paste and Match Style",
            comment: "Paste and Match Style menu item"
        )
        var menuItem = menu.addItem(
            withTitle: title,
            action: #selector(NSTextView.pasteAsPlainText(_:)),
            keyEquivalent: "V"
        )
        menuItem.keyEquivalentModifierMask = [.command, .option]

        title = NSLocalizedString("Delete", comment: "Delete menu item")
        menu.addItem(withTitle: title, action: #selector(NSText.delete(_:)), keyEquivalent: "\u{8}")  // backspace

        title = NSLocalizedString("Select All", comment: "Select All menu item")
        menu.addItem(withTitle: title, action: #selector(NSText.selectAll(_:)), keyEquivalent: "a")

        menu.addItem(NSMenuItem.separator())

        title = NSLocalizedString("Find", comment: "Find menu item")
        menuItem = menu.addItem(withTitle: title, action: nil, keyEquivalent: "")
        let findMenu = NSMenu(title: "Find")
        populateFindMenu(findMenu)
        menu.setSubmenu(findMenu, for: menuItem)

        title = NSLocalizedString("Spelling", comment: "Spelling menu item")
        menuItem = menu.addItem(withTitle: title, action: nil, keyEquivalent: "")
        let spellingMenu = NSMenu(title: "Spelling")
        populateSpellingMenu(spellingMenu)
        menu.setSubmenu(spellingMenu, for: menuItem)
    }
    
    func populateWriterMenu(_ menu: NSMenu) {
        let sendTitle = NSLocalizedString("Send", comment: "Send menu item")
        let sendMenuItem = NSMenuItem(title: sendTitle, action: #selector(WriterMenuActions.send(_:)), keyEquivalent: "d")
        sendMenuItem.keyEquivalentModifierMask = [.command, .shift]
        menu.addItem(sendMenuItem)
        
        let emojiTitle = NSLocalizedString("Insert Emoji", comment: "Insert Emoji menu item")
        menu.addItem(NSMenuItem(title: emojiTitle, action: #selector(WriterMenuActions.insertEmoji(_:)), keyEquivalent: ""))
        
        let photoTitle = NSLocalizedString("Attach Photo", comment: "Attach Photo menu item")
        menu.addItem(withTitle: photoTitle, action: #selector(WriterMenuActions.attachPhoto(_:)), keyEquivalent: "")
        
        let videoTitle = NSLocalizedString("Attach Video", comment: "Attach Video menu item")
        menu.addItem(withTitle: videoTitle, action: #selector(WriterMenuActions.attachVideo(_:)), keyEquivalent: "")
        
        let audioTitle = NSLocalizedString("Attach Audio", comment: "Attach Audio menu item")
        menu.addItem(withTitle: audioTitle, action: #selector(WriterMenuActions.attachAudio(_:)), keyEquivalent: "")
    }

    func populateFindMenu(_ menu: NSMenu) {
        var title = NSLocalizedString("Find…", comment: "Find… menu item")
        var menuItem = menu.addItem(
            withTitle: title,
            action: #selector(NSResponder.performTextFinderAction(_:)),
            keyEquivalent: "f"
        )

        menuItem.tag = NSTextFinder.Action.showFindInterface.rawValue

        title = NSLocalizedString("Find Next", comment: "Find Next menu item")
        menuItem = menu.addItem(
            withTitle: title,
            action: #selector(NSResponder.performTextFinderAction(_:)),
            keyEquivalent: "g"
        )
        menuItem.tag = NSTextFinder.Action.nextMatch.rawValue

        title = NSLocalizedString("Find Previous", comment: "Find Previous menu item")
        menuItem = menu.addItem(
            withTitle: title,
            action: #selector(NSResponder.performTextFinderAction(_:)),
            keyEquivalent: "G"
        )
        menuItem.tag = NSTextFinder.Action.previousMatch.rawValue

        title = NSLocalizedString(
            "Use Selection for Find",
            comment: "Use Selection for Find menu item"
        )
        menuItem = menu.addItem(
            withTitle: title,
            action: #selector(NSResponder.performTextFinderAction(_:)),
            keyEquivalent: "e"
        )
        menuItem.tag = NSTextFinder.Action.setSearchString.rawValue

        title = NSLocalizedString("Jump to Selection", comment: "Jump to Selection menu item")
        menu.addItem(
            withTitle: title,
            action: #selector(NSResponder.centerSelectionInVisibleArea(_:)),
            keyEquivalent: "j"
        )
    }

    func populateSpellingMenu(_ menu: NSMenu) {
        var title = NSLocalizedString("Spelling…", comment: "Spelling… menu item")
        menu.addItem(
            withTitle: title,
            action: #selector(NSText.showGuessPanel(_:)),
            keyEquivalent: ":"
        )

        title = NSLocalizedString("Check Spelling", comment: "Check Spelling menu item")
        menu.addItem(
            withTitle: title,
            action: #selector(NSText.checkSpelling(_:)),
            keyEquivalent: ";"
        )

        title = NSLocalizedString(
            "Check Spelling as You Type",
            comment: "Check Spelling as You Type menu item"
        )
        menu.addItem(
            withTitle: title,
            action: #selector(NSTextView.toggleContinuousSpellChecking(_:)),
            keyEquivalent: ""
        )
    }

    func populateViewMenu(_ menu: NSMenu) {
        var title = NSLocalizedString("Show Toolbar", comment: "Show Toolbar menu item")
        var menuItem = menu.addItem(
            withTitle: title,
            action: #selector(NSWindow.toggleToolbarShown(_:)),
            keyEquivalent: "t"
        )
        menuItem.keyEquivalentModifierMask = [.command, .option]

        title = NSLocalizedString("Customize Toolbar…", comment: "Customize Toolbar… menu item")
        menu.addItem(
            withTitle: title,
            action: #selector(NSWindow.runToolbarCustomizationPalette(_:)),
            keyEquivalent: ""
        )

        menu.addItem(NSMenuItem.separator())

        title = NSLocalizedString("Enter Full Screen", comment: "Enter Full Screen menu item")
        menuItem = menu.addItem(
            withTitle: title,
            action: #selector(NSWindow.toggleFullScreen(_:)),
            keyEquivalent: "f"
        )
        menuItem.keyEquivalentModifierMask = [.command, .control]
    }

    func populateWindowMenu(_ menu: NSMenu) {
        var title = NSLocalizedString("Close", comment:"Close menu item")
        menu.addItem(
            withTitle: title,
            action: #selector(NSWindow.performClose(_:)),
            keyEquivalent: "w"
        )

        title = NSLocalizedString("Minimize", comment: "Minimize menu item")
        menu.addItem(
            withTitle: title,
            action: #selector(NSWindow.performMiniaturize(_:)),
            keyEquivalent: "m"
        )

        title = NSLocalizedString("Zoom", comment: "Zoom menu item")
        menu.addItem(
            withTitle: title,
            action: #selector(NSWindow.performZoom(_:)),
            keyEquivalent: ""
        )

        menu.addItem(NSMenuItem.separator())

        title = NSLocalizedString("Bring All to Front", comment: "Bring All to Front menu item")
        let menuItem = menu.addItem(
            withTitle: title,
            action: #selector(NSApplication.arrangeInFront(_:)),
            keyEquivalent: ""
        )
        menuItem.target = NSApp
    }

    func populateHelpMenu(_ menu: NSMenu) {
        let learnMoreTitle = NSLocalizedString(
            "Learn more about Croptop",
            comment: "Learn more about Croptop menu item"
        )
        menu.addItem(
            withTitle: learnMoreTitle,
            action: #selector(FileMenuActions.learnMore(_:)),
            keyEquivalent: "?"
        )

        let discordInviteLinkTitle = NSLocalizedString("Discord", comment: "Discord menu item")
        menu.addItem(
            withTitle: discordInviteLinkTitle,
            action: #selector(FileMenuActions.openDiscordInviteLink(_:)),
            keyEquivalent: ""
        )
    }

    // MARK: - Menu Actions -

    func importPlanet(_ sender: AnyObject) {
        KeyboardShortcutHelper.shared.importPlanetAction()
    }
    
    func rebuildPlanet(_ sender: AnyObject) {
        if let planet = KeyboardShortcutHelper.shared.activeMyPlanet {
            Task {
                do {
                    try await planet.rebuild()
                } catch {
                    debugPrint("failed to rebuild planet: \(planet), error: \(error)")
                }
            }
        }
    }
    
    func send(_ sender: AnyObject) {
        if let activeWriterWindow = KeyboardShortcutHelper.shared.activeWriterWindow {
            activeWriterWindow.send(nil)
        }
    }
    
    func insertEmoji(_ sender: AnyObject) {
        if let activeWriterWindow = KeyboardShortcutHelper.shared.activeWriterWindow {
            activeWriterWindow.insertEmoji(nil)
        }
    }
    
    func attachPhoto(_ sender: AnyObject) {
        if let activeWriterWindow = KeyboardShortcutHelper.shared.activeWriterWindow {
            activeWriterWindow.attachPhoto(nil)
        }
    }
    
    func attachVideo(_ sender: AnyObject) {
        if let activeWriterWindow = KeyboardShortcutHelper.shared.activeWriterWindow {
            activeWriterWindow.attachVideo(nil)
        }
    }
    
    func attachAudio(_ sender: AnyObject) {
        if let activeWriterWindow = KeyboardShortcutHelper.shared.activeWriterWindow {
            activeWriterWindow.attachAudio(nil)
        }
    }
}
