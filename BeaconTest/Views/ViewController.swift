

import UIKit
import CoreLocation
import UserNotifications
let storedItemsKey = "storedItems"
let uuidStr = UUID(uuidString: "5A4BCFCE-174E-4BAC-A814-092E77F6B7E5")!
class ViewController: UIViewController {

    //@IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var btnAdd: UIButton!
    @IBOutlet weak var imgLeft: UIImageView!
    @IBOutlet weak var imgTop: UIImageView!
    @IBOutlet weak var imgRight: UIImageView!
    var items = [Item]()
    let locationManager = CLLocationManager()
    
    
    override func viewDidLoad() {
        
        locationManager.requestAlwaysAuthorization()
        locationManager.delegate = self
        //loadItems()
        
        self.items.append(Item(name: "Lecture", uuid: UUID(uuidString: "00000000-0000-0000-0000-000000000000")!, major: 0, minor: 0, description: "Room for lectures"))
        self.items.append(Item(name: "Coffee", uuid: UUID(uuidString: "00000000-0000-0000-0000-000000000000")!, major: 1, minor: 1, description: "Room for coffee"))
        self.items.append(Item(name: "Practice", uuid: UUID(uuidString: "00000000-0000-0000-0000-000000000000")!, major: 2, minor: 2, description: "Room for practice"))
        for item in items{
            self.startMonitoringRegion(item)
        }
        if let appDelegate = UIApplication.shared.delegate as? AppDelegate{
            appDelegate.viewController = self
        }
        self.imgLeft.image = UIImage(named: "Left.png")
        self.imgTop.image = UIImage(named: "Top.png")
        self.imgRight.image = UIImage(named: "Right.png")
//        self.tableView.isHidden = true
        self.btnAdd.isHidden = true
    }
    
    func loadItems() {
        guard let storedItems = UserDefaults.standard.array(forKey: storedItemsKey) as? [Data] else {return}
        
        for itemData in storedItems{
            guard let item = NSKeyedUnarchiver.unarchiveObject(with: itemData) as? Item else {continue}
            items.append(item)
            self.startMonitoringRegion(item)
        }
    }
    
    func saveItems() {
        var itemsData = [Data]()
        for item in items {
            let itemData = NSKeyedArchiver.archivedData(withRootObject: item)
            itemsData.append(itemData)
        }
        
        UserDefaults.standard.set(itemsData, forKey: storedItemsKey)
        UserDefaults.standard.synchronize()
    }
    func startMonitoringRegion(_ item: Item){
        let beaconRegion = item.asBeaconRegion()
        locationManager.startMonitoring(for: beaconRegion)
        locationManager.startRangingBeacons(in: beaconRegion )
    }
    
    func stopMonitoringRegion(_ item: Item){
        let beaconRegion = item.asBeaconRegion()
        locationManager.stopMonitoring(for: beaconRegion)
        locationManager.stopRangingBeacons(in: beaconRegion )
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "segueAdd", let viewController = segue.destination as? AddViewController{
            viewController.delegate = self
        }
    }
    func notification(rect: CGRect, item: Item) -> UIView{
        let notification = UIView(frame: rect)
//        notification.backgroundColor  = UIColor(named: "white")
        notification.backgroundColor = UIColor(red: CGFloat(integerLiteral: 255), green: CGFloat(integerLiteral: 255), blue: CGFloat(integerLiteral: 255), alpha: CGFloat(integerLiteral: 1))
        let label = UILabel(frame: notification.bounds)
//        label.backgroundColor = UIColor(red: CGFloat(integerLiteral: 255), green: CGFloat(integerLiteral: 255), blue: CGFloat(integerLiteral: 255), alpha: CGFloat(integerLiteral: 1))
        
        label.textColor = UIColor(red: CGFloat(integerLiteral: 0), green: CGFloat(integerLiteral: 0), blue: CGFloat(integerLiteral: 0), alpha: CGFloat(integerLiteral: 1))
        label.textAlignment = .center
        label.baselineAdjustment = .alignCenters
        label.text = item.desc
        print(label.text!)
        notification.addSubview(label)
        self.view.addSubview(notification)
        return notification
    }
}

//MARK: CCLocationManagerDelegate
extension ViewController: CLLocationManagerDelegate{
    func locationManager(_ manager: CLLocationManager, monitoringDidFailFor region: CLRegion?, withError error: Error) {
        print("Failed monitoring region: \(error.localizedDescription)")
        let regions = locationManager.monitoredRegions.count
        print(regions)
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Location manager failed: \(error.localizedDescription)")
    }
    
    func locationManager(_ manager: CLLocationManager, didExitRegion region: CLRegion) {
        self.imgLeft.image = UIImage(named: "Left.png")
        self.imgTop.image = UIImage(named: "Top.png")
        self.imgRight.image = UIImage(named: "Right.png")
    }
    
    
    func locationManager(_ manager: CLLocationManager, didRangeBeacons beacons: [CLBeacon], in region: CLBeaconRegion) {
        var indexPath = [IndexPath]()
        for beacon in beacons{
            for row in 0..<items.count {
//                print("UUID \(beacon.proximityUUID.uuidString), major \(beacon.major), minor \(beacon.minor), accuracy \(beacon.rssi)")
//                print("iUUID \(items[row].uuid.uuidString), imajor \(items[row].majorValue), iminor \(items[row].minorValue)")
                if items[row].uuid == beacon.proximityUUID &&
                    items[row].majorValue == Int(truncating: beacon.major) &&
                    items[row].minorValue == Int(truncating: beacon.minor){
                    items[row].beacon = beacon
                    indexPath += [IndexPath(row: row, section: 0)]
                    var notification = UIView()
                    if beacon.accuracy < 3.0{
                        if items[row].name == "Lecture"{
                            self.imgLeft.image = UIImage(named: "Left_selected.png")
                            self.imgTop.image = UIImage(named: "Top.png")
                            self.imgRight.image = UIImage(named: "Right.png")
                            let frame = CGRect(x: 0, y: 40, width: 150, height: 50)
                            notification = self.notification(rect: frame, item: items[row])
                            Timer.scheduledTimer(withTimeInterval: 1.0, repeats: false){_ in
                                notification.removeFromSuperview()
                            }
                            
                        }
                        if items[row].name == "Coffee"{
                            print(beacon.accuracy)
                            self.imgTop.image = UIImage(named: "Top_selected.png")
                            self.imgRight.image = UIImage(named: "Right.png")
                            self.imgLeft.image = UIImage(named: "Left.png")
                            let frame = CGRect(x: 220, y: 40, width: 150, height: 50)
                            notification = self.notification(rect: frame, item: items[row])
                            Timer.scheduledTimer(withTimeInterval: 1.0, repeats: false){_ in
                                notification.removeFromSuperview()
                            }
                        }
                        if items[row].name == "Practice"{
                            print(beacon.accuracy)
                            self.imgRight.image = UIImage(named: "Right_selected.png")
                            self.imgLeft.image = UIImage(named: "Left.png")
                            self.imgTop.image = UIImage(named: "Top.png")
                            let frame = CGRect(x: 220, y: 220, width: 150, height: 50)
                            notification = self.notification(rect: frame, item: items[row])
                            Timer.scheduledTimer(withTimeInterval: 1.0, repeats: false){_ in
                                notification.removeFromSuperview()
                            }
                        }
                    } 
                }
            }
        }
        
//        if let visibleRows = tableView.indexPathsForVisibleRows {
//            let rowsToUpdate = visibleRows.filter{ indexPath.contains($0) }
//            for row in rowsToUpdate{
//                let cell = tableView.cellForRow(at: row) as! ItemCell
//                cell.refreshLocation()
//            }
//        }
    }
}

//MARK: AddBeacon
extension ViewController: AddBeacon{
    func addBeacon(item: Item) {
        items.append(item)
        startMonitoringRegion(item)
//        tableView.beginUpdates()
        let newIndexPath = IndexPath(row: items.count - 1, section: 0)
//        tableView.insertRows(at: [newIndexPath], with: .automatic)
//        tableView.endUpdates()
        saveItems()
    }

}

//MARK: UITableViewDataSource
extension ViewController: UITableViewDataSource{
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Item", for: indexPath) as! ItemCell
        cell.item = items[indexPath.row]
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            stopMonitoringRegion(items[indexPath.row])
            tableView.beginUpdates()
            items.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .automatic)
            tableView.endUpdates()
            
            saveItems()
        }
    }
}

// MARK: UITableViewDelegate
extension ViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let item = items[indexPath.row]
        
        let detailMessage = "UUID: \(item.uuid.uuidString)\nMajor: \(item.majorValue)\nMinor: \(item.minorValue)\nDescription: \(item.desc ?? "")"
        let detailAlert = UIAlertController(title: "Details", message: detailMessage, preferredStyle: .alert)
        detailAlert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        self.present(detailAlert, animated: true, completion: nil)
    }
}




















