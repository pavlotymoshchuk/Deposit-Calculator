//
//  NewDepositVC.swift
//  Deposit Calculator
//
//  Created by Павло Тимощук on 11.12.2020.
//

import UIKit

class NewDepositVC: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var sumTextField: UITextField!
    @IBOutlet weak var percentageTextField: UITextField!
    @IBOutlet weak var termStartTextField: UITextField!
    @IBOutlet weak var termEndTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupControllers()
    }
        
    @IBAction func cancelButton(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func saveDepositButton(_ sender: UIButton) {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd.MM.yyyy"
        if let sumValue = getPositiveNumberFrom(textField: sumTextField),
           let percentageValue = getPositiveNumberFrom(textField: percentageTextField),
           let termStart = formatter.date(from: termStartTextField.text!),
           let termEnd = formatter.date(from: termEndTextField.text!) {
            if termStart < termEnd {
                let newDeposit = Deposit(dateStart: termStart, dateEnd: termEnd, sumStart: sumValue, percentage: percentageValue)
                Deposit.saveData(self, data: newDeposit)
                // MARK: - Refreshing the tableView from another ViewController
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: "newDataNotif"), object: nil)
                let alert = UIAlertController(title: "Do you want to add reminders?", message: "You will get a reminder the day before you receive the percents", preferredStyle: .alert)
                    let yesButton = UIAlertAction(title: "Add", style: .default, handler: {(_ action: UIAlertAction) -> Void in
                        for item in newDeposit.monthlyPayments {
                            let date = Calendar.current.date(byAdding: .day, value: -1, to: formatter.date(from: item.dateOfPayment)!)!
                            if date >= Date() {
                                addReminder(title: "Завтра, \(item.dateOfPayment), нарахування відсотків", notes: "На суму \(round(100*item.paymentAmount)/100) грн", date: date, priority: 3)
                            }
                        }
                        let dateOfPayment = newDeposit.monthlyPayments[newDeposit.monthlyPayments.count-1].dateOfPayment
                        let dateForReminder = Calendar.current.date(byAdding: .day, value: -1, to: formatter.date(from: dateOfPayment)!)!
                        if dateForReminder >= Date() {
                            addReminder(title: "Завтра, \(dateOfPayment), потрібно пітии у банк", notes: "", date: dateForReminder, priority: 1)
                        }
                        self.dismiss(animated: true, completion: nil)
                    })
                    let noButton = UIAlertAction(title: "Not add", style: .cancel, handler: {(_ action: UIAlertAction) -> Void in
                        self.dismiss(animated: true, completion: nil)
                    })
                    alert.addAction(yesButton)
                    alert.addAction(noButton)
                present(alert, animated: true)
                
            } else {
                alert(alertTitle: "Term date invalid", alertMessage: "The start time should be before the end", alertActionTitle: "Retry", vc: self)
            }
        } else {
            alert(alertTitle: "Some data invalid", alertMessage: "Try to write available data", alertActionTitle: "Retry", vc: self)
        }
    }
    
    
    
    func setupControllers() {
        sumTextField.delegate = self
        percentageTextField.delegate = self
        termStartTextField.addTarget(self, action: #selector(showDatePickerForStartDate), for: .editingDidBegin)
        termEndTextField.addTarget(self, action: #selector(showDatePickerForEndDate), for: .editingDidBegin)
        let todayDate = Date()
        let formatter = DateFormatter()
        formatter.dateFormat = "dd.MM.yyyy"
        termStartTextField.text = formatter.string(from: todayDate)
        termEndTextField.text = formatter.string(from: todayDate)
    }
    
    func getPositiveNumberFrom(textField: UITextField) -> Double? {
        var answer: Double?
        if let rawString = textField.text {
            if let a = Double(rawString) {
                if a >= 0 {
                    answer = a
                } else {
                    answer = nil
                }
            } else {
                answer = nil
            }
        } else {
            answer = nil
        }
        return answer
    }
    
    //MARK: - Date picker
    let datePicker = UIDatePicker()
    
    @objc func showDatePickerForStartDate() {
        datePicker.datePickerMode = .date
        let toolbar = UIToolbar();
        toolbar.sizeToFit()
        let cancelButton = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(cancelDatePicker))
        let spaceButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.flexibleSpace, target: nil, action: nil)
        let doneButton = UIBarButtonItem(title: "Done", style: .plain, target: self, action: #selector(doneDatePickerForStartDate))
        toolbar.setItems([doneButton,spaceButton,cancelButton], animated: false)
        termStartTextField.inputAccessoryView = toolbar
        termStartTextField.inputView = datePicker
    }
    
    @objc func showDatePickerForEndDate() {
        datePicker.datePickerMode = .date
        let toolbar = UIToolbar();
        toolbar.sizeToFit()
        let cancelButton = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(cancelDatePicker))
        let spaceButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.flexibleSpace, target: nil, action: nil)
        let doneButton = UIBarButtonItem(title: "Done", style: .plain, target: self, action: #selector(donedatePickerForEndDate))
        toolbar.setItems([doneButton,spaceButton,cancelButton], animated: true)
        termEndTextField.inputAccessoryView = toolbar
        termEndTextField.inputView = datePicker
    }
    
    @objc func doneDatePickerForStartDate() {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd.MM.yyyy"
        termStartTextField.text = formatter.string(from: datePicker.date)
        self.view.endEditing(true)
    }
    
    @objc func donedatePickerForEndDate() {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd.MM.yyyy"
        termEndTextField.text = formatter.string(from: datePicker.date)
        self.view.endEditing(true)
    }
    
    @objc func cancelDatePicker() {
        self.view.endEditing(true)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        textField.selectAll(nil)
    }
    
}
