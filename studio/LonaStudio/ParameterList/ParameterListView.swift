//
//  listEditor.swift
//  ComponentStudio
//
//  Created by devin_abbott on 5/26/17.
//  Copyright © 2017 Devin Abbott. All rights reserved.
//

import Foundation
import Cocoa

class ParameterListView: NSOutlineView, NSOutlineViewDataSource, NSOutlineViewDelegate, NSTextFieldDelegate {

    func setup() {
        let columnName = NSTableColumn(identifier: NSUserInterfaceItemIdentifier(rawValue: "Parameter"))
        columnName.title = "Parameter"

        self.addTableColumn(columnName)
        self.outlineTableColumn = columnName

        self.dataSource = self
        self.delegate = self

        self.focusRingType = .none
        self.rowSizeStyle = .medium
        self.headerView = nil

        self.registerForDraggedTypes([NSPasteboard.PasteboardType(rawValue: "component.parameter")])

        self.reloadData()

        columnAutoresizingStyle = .uniformColumnAutoresizingStyle
        columnName.resizingMask = NSTableColumn.ResizingOptions.autoresizingMask
    }

    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        setup()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }

    var list: [CSParameter] = [CSParameter]() {
        didSet {
            self.reloadData()
            onChange(list)
        }
    }

    var onChange: ([CSParameter]) -> Void = {_ in }

    override func viewWillDraw() {
        sizeLastColumnToFit()
        super.viewWillDraw()
    }

    func outlineView(_ outlineView: NSOutlineView, numberOfChildrenOfItem item: Any?) -> Int {
        if item == nil {
            return list.count
        }

        if let parameter = item as? CSParameter {
            return parameter.childCount()
        }

        return 0
    }

    func outlineView(_ outlineView: NSOutlineView, child index: Int, ofItem item: Any?) -> Any {
        if item == nil {
            return list[index]
        }

        if let parameter = item as? CSParameter {
            return parameter.child(at: index)
        }

        // Should never get here
        Swift.print("Bad parameter child")
        return CSParameter()
    }

    func outlineView(_ outlineView: NSOutlineView, isItemExpandable item: Any) -> Bool {
        return self.outlineView(outlineView, numberOfChildrenOfItem: item) > 0
    }

    private let defaultValueType = CSType.variant(tags: ["no default", "default"])

    private let requiredType = CSType.variant(tags: ["required", "optional"])

    func outlineView(_ outlineView: NSOutlineView, viewFor tableColumn: NSTableColumn?, item: Any) -> NSView? {
        let frame = NSRect(x: 0, y: 0, width: 2000, height: 26)

        if let parameter = item as? CSParameter {
            var components: [CSStatementView.Component] = [
                .text("Parameter"),
                .value("name", CSValue(type: .string, data: CSData.String(parameter.name)), []),
                .text("of type")
            ]

            switch parameter.type {
            case .named(let typeName, .variant(let cases)) where !parameter.type.isOptional() && typeName != "BorderStyle":
                let variantCaseType = CSType.dictionary([
                    "case": (CSType.string, .write),
                    "type": (CSType.parameterType(), .write)
                    ])
                let variantCasesType = CSType.array(variantCaseType)
                let casesData: [CSData] = cases.map({ arg in
                    let (key, value) = arg
                    return CSData.Object([
                        "case": key.toData(),
                        "type": CSUnitValue.wrap(
                            in: CSType.parameterType(),
                            tagged: (value.unwrapOptional() ?? value).toString()).data,
                        "optional": value.isOptional().toData()
                        ])
                })
                let fieldsValue = CSValue(type: variantCasesType, data: CSData.Array(casesData))

                components.append(.value("type", CSUnitValue.wrap(in: CSType.parameterType(), tagged: parameter.type.toString()), []))
                components.append(.value("typealias", CSValue(type: .string, data: CSData.String(typeName)), []))
                components.append(.value("typedef", fieldsValue, []))
            default:
                let typeValue = CSValue(type: CSType.namedParameterType(), data: parameter.type.toData())
                components.append(.value("type", typeValue, []))
            }

            components.append(contentsOf: [
                .text("that is"),
                .value(
                    "required",
                    parameter.type.isOptional()
                        ? CSUnitValue.wrap(in: requiredType, tagged: "optional")
                        : CSUnitValue.wrap(in: requiredType, tagged: "required"),
                    []),
                .text("with"),
                .value(
                    "hasDefaultValue",
                    parameter.hasDefaultValue
                        ? CSUnitValue.wrap(in: defaultValueType, tagged: "default")
                        : CSUnitValue.wrap(in: defaultValueType, tagged: "no default"),
                    [])
                ])

            if parameter.hasDefaultValue {
                components.append(.text("of"))
                components.append(.value("defaultValue", parameter.defaultValue, []))
            }

            let cell = CSStatementView(
                frame: frame,
                components: components
            )

            cell.onChangeValue = { [unowned self] name, value, _ in
                switch name {
                case "name":
                    parameter.name = value.data.stringValue
                case "type":
                    var newBaseType = CSType(value.data)

                    switch newBaseType {
                    case .variant:
                        newBaseType = CSType.named("NewType", newBaseType)
                    default:
                        break
                    }

                    parameter.type = parameter.type.isOptional() ? newBaseType.makeOptional() : newBaseType

                    if parameter.hasDefaultValue {
                        parameter.defaultValue = parameter.defaultValue.cast(to: parameter.type)
                    }

                    // TODO: Cast all cases to their new type (?)
//                    parameter.examples = parameter.examples.map({ $0.cast(to: parameter.type) })
                case "typealias":
                    switch parameter.type {
                    case .named(_, let innerType):
                        // TODO: This adds a new type, but the type won't be added to CSType.parameterType(),
                        // which is loaded at launch. Since the type isn't in the list of types, it won't appear
                        // in the dropdown. If the file were saved, we could reload the list of types. However,
                        // a forced file save isn't required for anything else like this, so it's not a great
                        // option. We could consider adding the type to the list of module types manually.
                        parameter.type = CSType.named(value.data.stringValue, innerType)
                    default:
                        break
                    }

                    if parameter.hasDefaultValue {
                        parameter.defaultValue = parameter.defaultValue.cast(to: parameter.type)
                    }
                case "typedef":
                    switch parameter.type {
                    case .named(let typeName, .variant):
                        let cases: [(String, CSType)] = value.data.arrayValue.map({ field in
                            let tag = field.get(key: "case").stringValue
                            let type = CSType.from(
                                string: CSValue(type: CSType.parameterType(), data: field.get(key: "type")).tag())
                            let optional = field.get(key: "optional").boolValue
                            return (tag, type: optional ? type.makeOptional() : type)
                        })

                        parameter.type = CSType.named(typeName, CSType.variant(cases))
                    default:
                        break
                    }

                    if parameter.hasDefaultValue {
                        parameter.defaultValue = parameter.defaultValue.cast(to: parameter.type)
                    }
                case "required":
                    if value.tag() == "required" {
                        if let unwrappedType = parameter.type.unwrapOptional() {
                            parameter.type = unwrappedType
                        }
                    } else {
                        if !parameter.type.isOptional() {
                            parameter.type = parameter.type.makeOptional()
                        }
                    }

                    if parameter.hasDefaultValue {
                        parameter.defaultValue = parameter.defaultValue.cast(to: parameter.type)
                    }
                case "hasDefaultValue":
                    if value.tag() == "no default" {
                        parameter.defaultValue = CSUndefinedValue
                    } else {
                        parameter.defaultValue = parameter.defaultValue.cast(to: parameter.type)
                    }
                case "defaultValue":
                    parameter.defaultValue = value
                default:
                    break
                }

                // Async to fix a crash. Without this, clicking the table view when a text field is active
                // will crash.
                DispatchQueue.main.async {
                    self.reloadData()
                }

                self.onChange(self.list)
            }

            return cell
        }

        return CSStatementView(frame: NSRect.zero, components: [])
    }

    var selectedItem: Any? {
        return item(atRow: selectedRow)
    }

    override func mouseDown(with event: NSEvent) {
        let selfPoint = convert(event.locationInWindow, from: nil)
        let row = self.row(at: selfPoint)

        if row >= 0 {
            let cell = view(atColumn: 0, row: row, makeIfNecessary: false)

            if let cell = cell as? CSStatementView {
                let activated = cell.mouseDownForTextFields(with: event)

                if activated { return }
            }
        }

        super.mouseDown(with: event)
    }

    override func keyDown(with event: NSEvent) {
        let characters = event.charactersIgnoringModifiers!

        if characters == String(Character(UnicodeScalar(NSEvent.SpecialKey.delete.rawValue)!)) {
            if selectedItem == nil { return }

            if let parameter = selectedItem as? CSParameter {
                for (index, item) in list.enumerated() where item === parameter {
                    list.remove(at: index)
                    break
                }
            }

            self.reloadData()
            self.onChange(self.list)
        }
    }

    // <DragAndDrop>

    func outlineView(_ outlineView: NSOutlineView, pasteboardWriterForItem item: Any) -> NSPasteboardWriting? {

        let pasteboardItem = NSPasteboardItem()

        let index = outlineView.row(forItem: item)

        pasteboardItem.setString(String(index), forType: NSPasteboard.PasteboardType(rawValue: "component.parameter"))

        return pasteboardItem
    }

    func outlineView(_ outlineView: NSOutlineView, validateDrop info: NSDraggingInfo, proposedItem item: Any?, proposedChildIndex index: Int) -> NSDragOperation {

        // If we're dragging onto an item (item != nil),
        // or into the list but not above or below a specific item (index == -1)
        if item != nil || index == -1 {
            return NSDragOperation()
        }

        return NSDragOperation.move
    }

    func outlineView(_ outlineView: NSOutlineView, acceptDrop info: NSDraggingInfo, item: Any?, childIndex index: Int) -> Bool {

        let sourceIndexString = info.draggingPasteboard.string(forType: NSPasteboard.PasteboardType(rawValue: "component.parameter"))

        if sourceIndexString != nil, let sourceIndex = Int(sourceIndexString!) {

            let sourceItem = outlineView.item(atRow: sourceIndex) as! CSParameter

            list.remove(at: sourceIndex)

            if sourceIndex < index {
                list.insert(sourceItem, at: index - 1)
            } else {
                list.insert(sourceItem, at: index)
            }

            return true
        }

        return false
    }

    // </DragAndDrop>

}
