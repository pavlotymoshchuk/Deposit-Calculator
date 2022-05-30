//
//  AppDelegate.swift
//  Deposit Calculator
//
//  Created by Павло Тимощук on 11.12.2020.
//

import UIKit
import CoreData
import AVFoundation
import AudioToolbox
import EventKit

struct Deposit: Codable {
    let dateStart: String
    let dateEnd: String
    let sumStart: Double
    let sumEnd: Double
    let profit: Double
    let percentage: Double
    var monthlyPayments: [MonthlyPayment]
    
    init(dateStart: Date, dateEnd: Date, sumStart: Double, percentage: Double) {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd.MM.yyyy"
        self.dateStart = formatter.string(from: dateStart)
        self.dateEnd = formatter.string(from: dateEnd)
        self.sumStart = round(100*sumStart)/100
        self.percentage = round(100*percentage)/100
        self.monthlyPayments = getMonthlyPayments(sumValue: sumStart, percentageValue: percentage, termStart: dateStart, termEnd: dateEnd)
        var profit: Double = 0
        for monthlyPayment in self.monthlyPayments {
            profit += monthlyPayment.paymentAmount
        }
        self.profit = round(100*profit)/100
        self.sumEnd = round(100*(sumStart+profit))/100
    }
    
    static func loadData(_ vc: UIViewController) {
        depositArray.removeAll()
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        let path = paths[0].appendingPathComponent("Deposits.txt")
        print(path)
        do {
            let data = try Data(contentsOf: path)
            let decoder = JSONDecoder()
            let jsonData = try decoder.decode([Deposit].self, from: data)
            depositArray += jsonData
        } catch {
            let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
            let path = paths[0].appendingPathComponent("Deposits.txt")
            let empty = ""
            do {
                try empty.write(to: path, atomically: false, encoding: .utf8)
            } catch {
                alert(alertTitle: "ERROR", alertMessage: error.localizedDescription, alertActionTitle: "OK", vc: vc)
            }
        }
    }
    
    static func saveData(_ vc: UIViewController, data: Deposit) {
        var array = [Deposit]()
        array.append(data)
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        let path = paths[0].appendingPathComponent("Deposits.txt")
        print(path)
        do {
            let encoder = JSONEncoder()
            encoder.outputFormatting = .prettyPrinted
            let jsonData = try encoder.encode(array)
            var fileWriter = try? FileHandle(forWritingTo: path)
            var jsonString = String(decoding: jsonData, as: UTF8.self)
            
            var readString = ""
            do {
                readString = try String(contentsOf: path)
            } catch {
                let empty = ""
                do {
                    try empty.write(to: path, atomically: false, encoding: .utf8)
                } catch {
                    alert(alertTitle: "ERROR", alertMessage: error.localizedDescription, alertActionTitle: "OK", vc: vc)
                }
                fileWriter = try? FileHandle(forWritingTo: path)
            }
            if !readString.isEmpty {
                readString.removeLast()
                readString.append(",")
                let empty = ""
                do {
                    try empty.write(to: path, atomically: false, encoding: .utf8)
                } catch {}
                
                fileWriter?.seekToEndOfFile()
                fileWriter?.write(readString.data(using: .utf8)!)
                
                jsonString.removeFirst()
            }
            fileWriter?.seekToEndOfFile()
            fileWriter?.write(jsonString.data(using: .utf8)!)
        } catch {
            alert(alertTitle: "ERROR", alertMessage: error.localizedDescription, alertActionTitle: "OK", vc: vc)
        }
    }
}

struct MonthlyPayment: Codable {
    let dateOfPayment: String
    let paymentAmount: Double
}

var depositArray = [Deposit]()
var depositIndex = 0

func getMonthlyPayments(sumValue: Double, percentageValue: Double, termStart: Date, termEnd: Date) -> [MonthlyPayment] {
    var monthlyPayments = [MonthlyPayment]()
    let calendar = Calendar.current
    var currentDate = termStart
    while currentDate < termEnd {
        var paymentAmount: Double
        let formatter = DateFormatter()
        formatter.dateFormat = "dd.MM.yyyy"
        var dateComponent = DateComponents()
        dateComponent.month = 1
        var futureDate = Calendar.current.date(byAdding: dateComponent, to: currentDate)!
        if futureDate > termEnd {
            futureDate = termEnd
        }
        let currentCountDaysInYear = calendar.range(of: .day, in: .year, for: currentDate)!.count
        let futureCountDaysInYear = calendar.range(of: .day, in: .year, for: futureDate)!.count
        if currentCountDaysInYear == futureCountDaysInYear {
            let countDays = Calendar.current.dateComponents([.day], from: currentDate, to: futureDate).day!
            paymentAmount = Double(countDays)*percentageValue*0.805/Double(currentCountDaysInYear)*sumValue/100
        } else {
            let year = Calendar.current.component(.year, from: currentDate)
            let firstOfNextYear = Calendar.current.date(from: DateComponents(year: year + 1, month: 1, day: 1))!
            let newYear = Calendar.current.date(byAdding: .day, value: -1, to: firstOfNextYear)!
            var countDays = Calendar.current.dateComponents([.day], from: currentDate, to: newYear).day!
            paymentAmount = Double(countDays)*percentageValue*0.805/Double(currentCountDaysInYear)*sumValue/100
            countDays = Calendar.current.dateComponents([.day], from: newYear, to: futureDate).day!
            paymentAmount += Double(countDays)*percentageValue*0.805/Double(futureCountDaysInYear)*sumValue/100
        }
        monthlyPayments.append(MonthlyPayment(dateOfPayment: formatter.string(from: Calendar.current.date(byAdding: .day, value: 1, to: futureDate)!), paymentAmount: round(100*paymentAmount)/100))
        currentDate = futureDate
    }
    return monthlyPayments
}

func addReminder(title: String, notes: String, date: Date, priority: Int) {
    let eventStore = EKEventStore()
    eventStore.requestAccess(to: EKEntityType.reminder, completion: {
        granted, error in
        if (granted) && (error == nil) {
            let reminder:EKReminder = EKReminder(eventStore: eventStore)
            reminder.title = title
            reminder.priority = priority
            reminder.notes = notes
            let dueDate = date.addingTimeInterval(60 * 60 * 20)
            reminder.dueDateComponents = Calendar.current.dateComponents([.year, .month, .day], from: dueDate)
            reminder.calendar = eventStore.defaultCalendarForNewReminders()
            do {
                try eventStore.save(reminder, commit: true)
            } catch {
                print("Cannot save")
                return
            }
            print("Reminder saved")
        }
    })
    
}

// MARK: - Make ALERT
func alert(alertTitle: String, alertMessage: String, alertActionTitle: String, vc: UIViewController) {
    AudioServicesPlaySystemSound(SystemSoundID(4095))
    let alert = UIAlertController(title: alertTitle, message: alertMessage, preferredStyle: .alert)
    let action = UIAlertAction(title: alertActionTitle, style: .cancel) { (action) in }
    alert.addAction(action)
    vc.present(alert, animated: true, completion: nil)
}

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        return true
    }

    // MARK: UISceneSession Lifecycle

    @available(iOS 13.0, *)
    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    @available(iOS 13.0, *)
    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
    }

    // MARK: - Core Data stack

    @available(iOS 13.0, *)
    lazy var persistentContainer: NSPersistentCloudKitContainer = {
        let container = NSPersistentCloudKitContainer(name: "Deposit_Calculator")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()

    // MARK: - Core Data Saving support

    @available(iOS 13.0, *)
    func saveContext () {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }

}

