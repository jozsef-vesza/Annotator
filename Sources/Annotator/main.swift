import AnnotatorCore

let annotator = Annotator()

do {
    try annotator.run()
} catch {
    print("An error occured: \(error)")
}
