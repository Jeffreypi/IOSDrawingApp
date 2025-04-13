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
   
    let mainDelegate = UIApplication.shared.delegate as! AppDelegate
    
    override func viewDidLoad() {
        super.viewDidLoad()
        mainDelegate.getImagesFromDatabase()
    
        
        // Do any additional setup after loading the view.
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return mainDelegate.image.count
    }
    
    func drawingToImage(_ drawing: PKDrawing, size: CGSize) -> UIImage{
        return drawing.image(from: CGRect(origin: .zero, size: size), scale: UIScreen.main.scale)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let tableCell = tableView.dequeueReusableCell(withIdentifier: "imagecell") as? ImageCell ?? ImageCell(style: .default, reuseIdentifier: "imagecell")
        let rowNum = indexPath.row
        let imageData = mainDelegate.image[rowNum]
        let dateFormatter = DateFormatter()
        
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        
        
        tableCell.IDLabel.text = "ID: \(imageData.ID ?? 0)"
        tableCell.timeStampLabel.text = imageData.Timestamp
        if let drawingData = imageData.DrawingData{
            do{
                let drawing = try PKDrawing(data: drawingData)
                let preview = drawingToImage(drawing, size: CGSize(width: 300, height: 300))
                tableCell.myImageView.image = preview
            }catch{
                tableCell.myImageView.image = nil
            }
        }
        else{
            tableCell.myImageView.image = nil
        }
        return tableCell
        //tableCell.myImageView.image = UIImage(named:mainDelegate.image[rowNum].DrawingData!)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 300
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
