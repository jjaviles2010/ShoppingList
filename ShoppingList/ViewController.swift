import UIKit
import Firebase

class ViewController: UIViewController {

    // MARK: - IBOutlets
    @IBOutlet weak var tfEmail: UITextField!
    @IBOutlet weak var tfPassword: UITextField!
    @IBOutlet weak var tfName: UITextField!
    
    // MARK: - Super Methods
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    // MARK: - IBActions
    @IBAction func signIn(_ sender: UIButton) {
        Auth.auth().signIn(withEmail: tfEmail.text!, password: tfPassword.text!) { [weak self] (result, error) in
            if error == nil {
                print("Usuario logado!")
                self?.updateUserAndProceed()
            } else {
                print(error!)
            }
        }
    }
    
    @IBAction func signUp(_ sender: UIButton) {
        Auth.auth().createUser(withEmail: tfEmail.text!, password: tfPassword.text!) { [weak self] (result, error) in
            
            if error == nil {
                print("Usuario criado!")
                self?.updateUserAndProceed()
            } else {
                print(error!)
            }
            
        }
    }
    
    // MARK: - Methods
    func updateUserAndProceed() {
        if tfName.text!.isEmpty {
            showMainScreen()
        } else {
            guard let user = Auth.auth().currentUser else {return}
            let changeRequest = user.createProfileChangeRequest()
            changeRequest.displayName = tfName.text!
            changeRequest.commitChanges { [weak self] (error) in
                //
                self?.showMainScreen()
            }
        }
    }
    
    func showMainScreen() {
        guard let vc = storyboard?.instantiateViewController(withIdentifier: TableViewController.name) else {return}
        //navigationController?.show(vc, sender: nil)
        navigationController?.viewControllers = [vc]
    }
    
}

