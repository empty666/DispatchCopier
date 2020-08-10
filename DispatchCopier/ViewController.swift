//
//  ViewController.swift
//  DispatchCopier
//
//  Created by BK Lee on 2020/08/10.
//  Copyright © 2020 BK Lee. All rights reserved.
//

import Cocoa

class ViewController: NSViewController {

    @IBOutlet weak var targetPathTextField: NSTextField?
    @IBOutlet weak var destPathTextField: NSTextField?
    
    let dispatchCopyWorker: DispatchCopyWorker = DispatchCopyWorker.Shared;
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override var representedObject: Any? {
        didSet {
        // Update the view, if already loaded.
        }
    }
    
    @IBAction func startFileCopyAction(_ sender: Any) {
        
        guard
            let targetPath: String = self.targetPathTextField?.stringValue,
            let destPath: String = self.destPathTextField?.stringValue
        else {
            let alert: NSAlert = NSAlert()
            alert.messageText = "Required Target & Dest Path"
            alert.alertStyle = .critical
            alert.runModal()
            
            return ;
        }
        
        self.dispatchCopyWorker.startCopy(targetPath: targetPath, destPath: destPath);
    }
    
    @IBAction func stopFileCopyAction(_ sender: Any) {
        self.dispatchCopyWorker.stopCopy();
    }

}

