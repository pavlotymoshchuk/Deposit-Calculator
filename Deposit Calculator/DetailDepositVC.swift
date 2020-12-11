//
//  DetailDepositVC.swift
//  Deposit Calculator
//
//  Created by Павло Тимощук on 11.12.2020.
//

import UIKit

class DetailDepositVC: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var sumStartLabel: UILabel!
    @IBOutlet weak var sumEndLabel: UILabel!
    @IBOutlet weak var dateStartLabel: UILabel!
    @IBOutlet weak var dateEndLabel: UILabel!
    @IBOutlet weak var profitLabel: UILabel!
    @IBOutlet weak var percentageLabel: UILabel!
    @IBOutlet weak var detailDepositTableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let currrentDeposit = depositArray[depositIndex]
        sumStartLabel.text = String(currrentDeposit.sumStart)
        sumEndLabel.text = String(currrentDeposit.sumEnd)
        dateStartLabel.text = currrentDeposit.dateStart
        dateEndLabel.text = currrentDeposit.dateEnd
        profitLabel.text = String(currrentDeposit.profit)
        percentageLabel.text = String(currrentDeposit.percentage)
    }

    @IBAction func backButton(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return depositArray[depositIndex].monthlyPayments.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return UITableViewCell()
    }
    
}
