//
//  MonTran.swift
//  BeActive
//
//  Created by Kasin Thappawan on 15/4/2568 BE.
//

import Foundation

func translatedDate(from date: Date, formatter: DateFormatter) -> String {
    let monthMap: [String: String] = [
        "January": t("January", in: "Month"),
        "February": t("February", in: "Month"),
        "March": t("March", in: "Month"),
        "April": t("April", in: "Month"),
        "May": t("May", in: "Month"),
        "June": t("June", in: "Month"),
        "July": t("July", in: "Month"),
        "August": t("August", in: "Month"),
        "September": t("September", in: "Month"),
        "October": t("October", in: "Month"),
        "November": t("November", in: "Month"),
        "December": t("December", in: "Month"),
        "Jan": t("Jan", in: "Month"),
        "Feb": t("Feb", in: "Month"),
        "Mar": t("Mar", in: "Month"),
        "Apr": t("Apr", in: "Month"),
        "Jun": t("Jun", in: "Month"),
        "Jul": t("Jul", in: "Month"),
        "Aug": t("Aug", in: "Month"),
        "Sep": t("Sep", in: "Month"),
        "Oct": t("Oct", in: "Month"),
        "Nov": t("Nov", in: "Month"),
        "Dec": t("Dec", in: "Month")
    ]

    let formatted = formatter.string(from: date)
    var result = formatted

    for (eng, translated) in monthMap {
        result = result.replacingOccurrences(of: eng, with: translated)
    }

    return result
}
