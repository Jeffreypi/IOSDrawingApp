//
//  LoadImageViewController.swift
//  DrawingAppIOSProject
//
//  Created by Jeffrey Pincombe on 2025-03-13.
//

import UIKit
import PencilKit

class LoadImageViewController: UIViewController, UITableViewDataSource, UITableViewDelegate{
    
    
    @IBOutlet var tableView: UITableView!
    var drawingToEdit: PKDrawing?
   
    let mainDelegate = UIApplication.shared.delegate as! AppDelegate
    
    override func viewDidLoad() {
        super.viewDidLoad()
        mainDelegate.getImagesFromDatabase()
    
        
        // Do any additional setup after loading the view.
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return mainDelegate.image.count
    }
    
//    func drawingToImage(_ drawing: PKDrawing, size: CGSize) -> UIImage{
//        
//        return drawing.image(from: CGRect(origin: .zero, size: size), scale: UIScreen.main.scale)
//    }
    func drawingToImage(_ drawing: PKDrawing) -> UIImage {
        let bounds = drawing.bounds
        let scale = UIScreen.main.scale
        return drawing.image(from: bounds, scale: scale)
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        print("prepare(for:sender:) called")
        
        if segue.identifier == "editDrawingSegue",
           let destinationVC = segue.destination as? CanvasViewController{
            destinationVC.existingDrawing = drawingToEdit
            print("passed drawing with bounds: \(drawingToEdit?.bounds ?? .zero)")
        }
    }

    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let tableCell = tableView.dequeueReusableCell(withIdentifier: "imagecell") as? ImageCell ?? ImageCell(style: .default, reuseIdentifier: "imagecell")
        let rowNum = indexPath.row
        let imageData = mainDelegate.image[rowNum]
        let dateFormatter = DateFormatter()
       
        
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        
        
        
        tableCell.IDLabel.text = "ID: \(imageData.ID ?? 0)"
        tableCell.titleLabel.text = imageData.Title
        tableCell.timeStampLabel.text = imageData.Timestamp
        if let drawingData = imageData.DrawingData{
            do{
                let drawing = try PKDrawing(data: drawingData)
                let preview = drawingToImage(drawing)
                print("Preview drawing ID \(imageData.ID ?? -1) bounds: \(drawing.bounds)")
                tableCell.myImageView.image = preview
            }catch{
                
                tableCell.myImageView.image = nil
            }
        }
        else{
            tableCell.myImageView.image = nil
        }
        
        
        //tableCell.myImageView.image = UIImage(named:mainDelegate.image[rowNum].DrawingData!)
        guard let imageID = imageData.ID else{
            print("no valid id for imagedata")
            return tableCell
        }
        
        tableCell.onEditTapped = { [weak self] in
            guard let self = self else {return}
            
            print("Attempting to load drawing by ID: \(imageID)")
            if let drawing = self.mainDelegate.getDrawingByID(imageID) {
                    print("Editing drawing with bounds: \(drawing.bounds)")
                    self.drawingToEdit = drawing
                    self.performSegue(withIdentifier: "editDrawingSegue", sender: self)
                } else {
                    print("Could not load drawing with ID: \(imageID)")
                }
            
        }
        return tableCell
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let deleteAction = UIContextualAction(style: .destructive, title: "Delete") { ac, view, success in
            
            let imageToDelete = self.mainDelegate.image[indexPath.row]
            if let id=imageToDelete.ID{
                self.mainDelegate.deleteDrawingFromDatabase(id: id)
            }
            
            self.mainDelegate.image.remove(at: indexPath.row)
            self.tableView.deleteRows(at: [indexPath], with: .automatic)
            success(true)
        }
        deleteAction.backgroundColor = .red
        
        return UISwipeActionsConfiguration(actions: [deleteAction])
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
