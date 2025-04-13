//
//  CanvasViewController.swift
//  DrawingAppIOSProject
//
//  Created by Jeffrey Pincombe on 2025-03-13.
//

import UIKit
import PencilKit

class CanvasViewController: UIViewController, PKCanvasViewDelegate {

    @IBAction func unwindToCanvasVC(sender : UIStoryboardSegue){
        
    }
    let mainDelegate = UIApplication.shared.delegate as! AppDelegate
    @IBOutlet var canvasView : PKCanvasView!
    @IBOutlet var saveButton : UIBarButtonItem!
    var toolPicker = PKToolPicker()
  
    override func viewDidLoad() {
        super.viewDidLoad()
        mainDelegate.checkTableExists()
        setupCanvasView()
        setupToolPicker()

        // Do any additional setup after loading the view.
    }
    
    @IBAction func saveImage(sender : UIBarButtonItem){
        let alert = UIAlertController(title: "Save Drawing", message: "Enter a title for your drawing", preferredStyle: .alert)
        
        alert.addTextField{
            textField in textField.placeholder = "Drawing title"
        }
        let saveAction = UIAlertAction(title: "Save", style: .default) { [weak self] _ in
                guard let self = self else { return }
                let title = alert.textFields?.first?.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? "Untitled"
                let drawing = self.canvasView.drawing
                self.mainDelegate.saveDrawingToDatabase(drawing: drawing, title: title)
            
            let confirm = UIAlertController(title: "Saved", message: "Drawing '\(title)' saved!", preferredStyle: .alert)
                    confirm.addAction(UIAlertAction(title: "OK", style: .default))
                    self.present(confirm, animated: true)
                }
        
        alert.addAction(saveAction)
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        
        present(alert, animated: true)
        
//        let drawing = canvasView.drawing
//        mainDelegate.saveDrawingToDatabase(drawing: drawing)
    }
    
    private func setupCanvasView(){
        
        canvasView.drawingPolicy = .anyInput
        canvasView.backgroundColor = .white
        
    }
    
    private func setupToolPicker(){
        
        toolPicker.setVisible(true, forFirstResponder: canvasView)
        toolPicker.addObserver(canvasView)
        canvasView.becomeFirstResponder()
    
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
