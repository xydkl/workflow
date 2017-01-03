//
//  AppDelegate.swift
//  workflow
//
//  Created by xuyan on 2016/12/26.
//  Copyright © 2016年 ffan. All rights reserved.
//

import Cocoa
import Automator

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate, NSTableViewDelegate {

    @IBOutlet weak var window: NSWindow!
    @IBOutlet weak var workflowView: AMWorkflowView!
    @IBOutlet weak var workflowTable: NSTableView!
    @IBOutlet weak var workflowController: AMWorkflowController!
    @IBOutlet weak var tableContent: NSArrayController!
    @IBOutlet weak var processBar: NSProgressIndicator!
    @IBOutlet weak var stopButton: NSButton!
    
    dynamic var workflows: [[String:Any]] = []
    dynamic var runningWorkflow: Bool = false
    
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        // Insert code here to initialize your application
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }
    
    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        return true
    }
    
    func displaySelectedWorkflow() -> Bool {
        let theRow = workflowTable.selectedRow
        if ( theRow != -1 && !runningWorkflow ) {
            let selectedEntry = (tableContent.arrangedObjects as! [[String:Any]])[theRow]
            let selectedWorkflow = selectedEntry["workflow"] as! AMWorkflow
            workflowController.workflow = selectedWorkflow
            window.title = selectedEntry["name"] as! String
            return true
        } else {
            return false
        }
    }
    
    override func awakeFromNib() {
        workflowView.isEditable = false
        runningWorkflow = false
        
        let workflowPaths:[String] = Bundle.main.paths(forResourcesOfType: "workflow", inDirectory: "workflows")
        var workflowList:[[String:Any]] = []
        for nthWorkflowPath in workflowPaths {
            let nthWorkflowURL = URL(fileURLWithPath: nthWorkflowPath, isDirectory: false)
            let nthWorkflow = try? AMWorkflow(contentsOf: nthWorkflowURL)
            if (nthWorkflow) != nil {
                let nthFileName = nthWorkflowURL.lastPathComponent
                let nthDisplayName = nthWorkflowURL.deletingPathExtension().lastPathComponent
                let nthWorkFlowDict = ["name":nthDisplayName, "path":nthFileName, "workflow":nthWorkflow!] as [String : Any]
                workflowList.append(nthWorkFlowDict)
            }
        }
        workflows = workflowList
        if (workflows.count > 0) {
            workflowTable.selectRowIndexes(IndexSet([0]), byExtendingSelection:false)
            
            displaySelectedWorkflow()
        }
    }
    
    func selectionShouldChange(in tableView: NSTableView) -> Bool {
        if runningWorkflow {
            
            let selectedWorkflow = (tableContent.arrangedObjects as! [[String:Any]])[workflowTable.selectedRow]["name"]
            
            
            /* display a modal sheet explaining why the selection cannot be changed. */
            let alertSheet = NSAlert()
            alertSheet.messageText = "The \(selectedWorkflow) is running."
            alertSheet.informativeText = "You cannot select another action until the \(selectedWorkflow) action has finished running."
            alertSheet.beginSheetModal(for: window, completionHandler: { (response) in
                switch response {
                default:
                    break
                }
            })
            
        }
        
        return !runningWorkflow
    }
    
    func tableViewSelectionDidChange(_ notification: Notification) {
        displaySelectedWorkflow()
    }
    
    override func workflowControllerWillRun(_ controller: AMWorkflowController) {
        runningWorkflow = true
    }
    
    override func workflowControllerDidRun(_ controller: AMWorkflowController) {
        runningWorkflow = false
    }
}

