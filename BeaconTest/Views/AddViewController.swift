

import UIKit

class AddViewController: UIViewController {

    
    @IBOutlet weak var txfName: UITextField!
    @IBOutlet weak var txfUUID: UITextField!
    @IBOutlet weak var txfMajor: UITextField!
    @IBOutlet weak var txfMinor: UITextField!
    @IBOutlet weak var txfDescription: UITextField!
    @IBOutlet weak var btnAdd: UIButton!
    let uuidRegex = try! NSRegularExpression(pattern: "^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$", options: .caseInsensitive)
    var delegate : AddBeacon?
    var session : URLSession?
    var dataTask : URLSessionDataTask?
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        btnAdd.isEnabled = false
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        // Dismiss keyboard
        self.view.endEditing(true)
    }
    
    @IBAction func textFieldEditingChanged(_ sender: UITextField) {
        let nameValid = txfName.text!.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines).count > 0

        var uuidValid = false
        let uuidString = txfUUID.text!.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
        if uuidString.count > 0 {
            uuidValid = (uuidRegex.numberOfMatches(in: uuidString, options: [], range: NSMakeRange(0, uuidString.count)) > 0)
        }

        txfUUID.textColor = (uuidValid) ? .black : .red

        btnAdd.isEnabled = (uuidValid && nameValid)
    }
    
    @IBAction func btnAdd_Pressed(_ sender: UIButton) {
        let uuidString = txfUUID.text!.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
        guard let uuid = UUID(uuidString: uuidString) else { return }
        let major = Int(txfMajor.text!) ?? 0
        let minor = Int(txfMinor.text!) ?? 0
        let name = txfName.text!.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
        let desc = txfDescription.text!
        let newItem = Item(name: name, uuid: uuid, major: major, minor: minor, description: desc)
        
        delegate?.addBeacon(item: newItem)
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func btnCancel_Pressed(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
    func parseData(data: Data){
        
    }
    
    func getBeaconFromURL(){
        self.session = URLSession(configuration: .ephemeral)
        dataTask?.cancel()
        
        if let urlComponents = URLComponents(string: "http://56e98ac4.ngrok.io/beacon"){
            guard let url = urlComponents.url else { return }
            
            dataTask = session?.dataTask(with: url){ data, response, error in
                defer {self.dataTask = nil}
                if let error = error{
                    print("Data Task error: " + error.localizedDescription)
                } else if let data = data, let response = response as? HTTPURLResponse, response.statusCode == 200{
                    self.parseData(data: data)
                }
            }
        }
        
        dataTask?.resume()
        
        
    }
}

extension AddViewController: UITextFieldDelegate{
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        // Enter key hides keyboard
        textField.resignFirstResponder()
        return true
    }
}
