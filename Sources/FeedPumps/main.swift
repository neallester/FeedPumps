import Cocoa

let tagsArray = tags.split (separator: "\n", omittingEmptySubsequences: false)
let namesArray = names.split (separator: "\n", omittingEmptySubsequences: false)

let combined = zip (tagsArray, namesArray).filter { (tag, name) in
    return !tag.isEmpty && !name.isEmpty
}
var pumps = Set<String>()
var tagsByName: [String:[String:String]] = [:]
for (tag, fullName) in combined {
    let firstComma = fullName.firstIndex(of: ",") ?? fullName.endIndex
    let pump = String (fullName[..<firstComma])
    if (pump.count > 6) {
        print ("Missing comma in name: \"\(pump)\" (tag \(tag))")
    }
    if (firstComma < fullName.endIndex) {
        let afterComma = fullName.index (firstComma, offsetBy: 1)
        let name = String (fullName[afterComma...].trimmingCharacters(in: .whitespaces))
        pumps.insert(String (pump))
        var tags = tagsByName[name]
        if let existingTags = tags {
            if let _ = existingTags[pump] {
                print ("Duplicate name \"\(name)\" for pump \(pump)")
            } else {
                tags![pump] = String (tag)
            }
        } else {
            var newTags: [String:String] = [:]
            newTags[pump] = String (tag)
            tags = newTags
        }
        tagsByName[name] = tags
    }
}
let pumpList = pumps.sorted()
let nameList = tagsByName.keys.sorted()
var output = ""
for pump in pumpList {
    output = output + "," + pump
}
output = output + "\n"
for name in nameList {
    output = output + "\"\(name)\""
    for pump in pumpList {
        output = output + ","
        if let tags = tagsByName[name], let tag = tags[pump] {
            output = output + tag
        }
    }
    output = output + "\n"
}
//let fileURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first.appendingPathComponent("bfp-crosstab.csv")
let documentsUrl = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]

// add a filename
let fileUrl = documentsUrl.appendingPathComponent("bfp-crosstab.csv")

try output.write (to: fileUrl, atomically: true, encoding: .utf8)

