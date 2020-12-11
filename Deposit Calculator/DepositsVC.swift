//
//  ViewController.swift
//  Deposit Calculator
//
//  Created by Павло Тимощук on 11.12.2020.
//

import UIKit

class DepositsVC: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var depositsTableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        Deposit.loadData(self)
        depositsTableView.rowHeight = 100
        refresh.addTarget(self, action: #selector(handleRefresh), for: .valueChanged)
        depositsTableView.addSubview(refresh)
        NotificationCenter.default.addObserver(self, selector: #selector(self.handleRefresh), name: NSNotification.Name(rawValue: "newDataNotif"), object: nil)
    }
    
    //MARK: - Refresh
    var refresh = UIRefreshControl()
    
    @objc func handleRefresh()
    {
        Deposit.loadData(self)
        self.depositsTableView.reloadData()
        refresh.endRefreshing()
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return depositArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: "DepositTableViewCell", for: indexPath) as? DepositTableViewCell {
            cell.indexLabel?.text = String(indexPath.row+1)
            cell.dateStartLabel?.text = depositArray[indexPath.row].dateStart
            cell.dateEndLabel?.text = depositArray[indexPath.row].dateEnd
            cell.sumStartLabel?.text = String(depositArray[indexPath.row].sumStart)
            cell.sumEndLabel?.text = String(depositArray[indexPath.row].sumEnd)
            cell.percentageLabel?.text = String(depositArray[indexPath.row].percentage) + "%"
            return cell
        }
        return UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        depositIndex = indexPath.row
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "DetailDepositVC")
        self.present(vc, animated: true, completion: nil)
        depositsTableView.deselectRow(at: indexPath, animated: true)
    }
    
}

