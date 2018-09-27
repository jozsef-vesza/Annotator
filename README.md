# Annotator

Annotator is a command line tool for annotating class extensions defined for protocol conformance. Adding these comments can ease navigation in source files (especially large ones), but can be quite cumbersome, so I decided to make a tool for it.

Without annotation:

![](Docs/before-annotation.png)

With annotation:

![](Docs/after-annotation.png)

Annotator leverages Apple's [SwiftSyntax](https://github.com/apple/swift-syntax) package for parsing/changing the source code.

> Note: SwiftSyntax is still in development, and the API is not guaranteed to
> be stable. It's subject to change without warning. Always review the changes made by Annotator.

## Installation

Using Swift Package Manager:

```
$ git clone https://github.com/jozsef-vesza/Annotator
$ cd Annotator
$ swift build -c release -Xswiftc -static-stdlib
$ cp -f .build/release/Annotator /usr/local/bin/annotator
```

## Usage

Annotator takes a JSON configuration file as input with the following format:
```json
// config.json
{
    "projectFolderPath": "path_to_project_root_folder",
    "excludedFileNames": [
        "ExcludedFile.swift"
    ],
    "excludedSubfolders": [
        "ExcludedFolderName"
    ]
}
```
* `projectFolderPath` (required): the absolute path to the project's root folder
* `excludedFileNames` (optional): a list of filenames to exclude
* `excludedSubfolders` (optional): a list of folders to exclude

Once the configuration file is ready, supply it to Annotator as a parameter:
```
$ annotator path_to_configuration_json_file
```