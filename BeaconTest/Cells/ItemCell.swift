

import UIKit

class ItemCell: UITableViewCell {

    @IBOutlet weak var imgIcon: UIImageView!
    @IBOutlet weak var lblName: UILabel!
    @IBOutlet weak var lblLocation: UILabel!
    
    var item: Item? = nil {
        didSet{
            if let item = item {
                imgIcon = nil
                lblName.text = item.name
                lblLocation.text = item.locationString()
            } else {
                imgIcon = nil
                lblName.text = ""
                lblLocation.text = ""
            }
        }
    }
    
    func refreshLocation(){
        lblLocation.text = item?.locationString()
    }

}
