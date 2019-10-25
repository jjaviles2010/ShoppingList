import UIKit
import Firebase

class TableViewController: UITableViewController {
    
    // MARK: - Properties
    let collection = "shoppingList"
    var shoppingList: [ShoppingItem] = []
    var firestore: Firestore = {
       let settings = FirestoreSettings()
        settings.areTimestampsInSnapshotsEnabled = true
        settings.isPersistenceEnabled = true
        
        let firestore = Firestore.firestore()
        firestore.settings = settings
        return firestore
    }()
    var firestoreListener: ListenerRegistration!
    
    
    // MARK: - Super Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        title = Auth.auth().currentUser?.displayName ?? "Lista de compras"
        loadItems()
    }
    
    //MARK: - Methods
    func loadItems() {
        firestoreListener = firestore
            .collection(collection)
            .order(by: "name", descending: true)
            //.limit(to: 15)
            .addSnapshotListener(includeMetadataChanges: true, listener: { (snapshot, error) in
                
                if error != nil {
                    print(error!)
                } else {
                    guard let snapshot = snapshot else {return}
                    print("Documentos alterados:", snapshot.documentChanges.count)
                    
                    if snapshot.metadata.isFromCache ||
                        snapshot.documentChanges.count > 0 {
                        self.showItems(snapshot: snapshot)
                        //reload na tabela
                    }
                }
                
            })
    }
    
    func showItems(snapshot: QuerySnapshot) {
        shoppingList.removeAll()
        
        for document in snapshot.documents {
            let data = document.data()
            let name = data["name"] as! String
            let quantity = data["quantity"] as! Int
            let shoppingItem = ShoppingItem(name: name, quantity: quantity, id: document.documentID)
            shoppingList.append(shoppingItem)
        }
        tableView.reloadData()
    }
    
    // MARK: - IBActions
    @IBAction func addItem(_ sender: Any) {
    }
    
    // MARK: - Table view data source
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return shoppingList.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        
        let shoppingItem = shoppingList[indexPath.row]
        cell.textLabel?.text = shoppingItem.name
        cell.detailTextLabel?.text = "\(shoppingItem.quantity)"
        
        return cell
    }
}
