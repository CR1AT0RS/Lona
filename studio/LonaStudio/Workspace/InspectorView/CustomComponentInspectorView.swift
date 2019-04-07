//
//  ComponentInspectorView.swift
//  LonaStudio
//
//  Created by Nghia Tran on 2/15/18.
//  Copyright © 2018 Devin Abbott. All rights reserved.
//

import Cocoa

final class CustomComponentInspectorView: NSStackView {

    // MARK: - Variable

    private let componentLayer: CSComponentLayer
    var onChangeData: (CSData, CSParameter) -> Void = {_, _ in}

    // MARK: - Init

    init(componentLayer: CSComponentLayer) {
        self.componentLayer = componentLayer
        super.init(frame: NSRect.zero)
        setupViews()
    }

    required init?(coder decoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Public

    func reload() {
        valueFields = []
        subviews.forEach({ subview in subview.removeFromSuperview() })

        setupViews()
    }

    // MARK: - Private

    // We need to retain the value fields. Without this, only the view of the value field is retained.
    private var valueFields: [CSValueField] = []

    private func setupViews() {
        let views = setupValueFields()
        valueFields = views.map { $0.field }
        let parametersSection = DisclosureContentRow(title: "Parameters", views: views.map { $0.view }, stretched: true)
        parametersSection.contentSpacing = 8
        parametersSection.contentEdgeInsets = NSEdgeInsets(top: 0, left: 0, bottom: 15, right: 0)

        orientation = .vertical
        [parametersSection].forEach { (item) in
            addArrangedSubview(item, stretched: true)
        }
        translatesAutoresizingMaskIntoConstraints = false
    }

    private func setupValueFields() -> [(view: NSView, field: CSValueField)] {
        let views: [(view: NSView, field: CSValueField)] = componentLayer.component.parameters.map({ parameter in
            let defaultData: CSData
            if parameter.type.unwrappedNamedType().isOptional() {
                defaultData = CSUnitValue.wrap(in: parameter.type, tagged: "None").data
            } else if parameter.type.unwrappedNamedType().isVariant {
                defaultData = CSValue.defaultValue(for: parameter.type).data
            } else {
                defaultData = CSData.Null
            }

            let value = CSValue(type: parameter.type, data: componentLayer.parameters[parameter.name] ?? defaultData)

            let valueField = CSValueField(value: value, options: [
                CSValueField.Options.isBordered: true,
                CSValueField.Options.drawsBackground: true,
                CSValueField.Options.submitOnChange: false,
                CSValueField.Options.usesLinkStyle: false
                ])
            valueField.onChangeData = {[unowned self] data in
                var data = data

                if case .named("URL", .string) = value.type, let url = URL(string: data.stringValue) {
                    if let relativePath = url.path.pathRelativeTo(basePath: CSUserPreferences.workspaceURL.path) {
                        data = ("file://" + relativePath).toData()
                    } else {
                        data = url.absoluteString.toData()
                    }
                }

                self.onChangeData(data, parameter)
            }
            valueField.view.translatesAutoresizingMaskIntoConstraints = false
            valueFields.append(valueField)

            let stackView = NSStackView(views: [
                NSTextField(labelWithString: parameter.name)
                ], orientation: .vertical)
            stackView.alignment = .left
            stackView.addArrangedSubview(valueField.view, stretched: !(valueField.view is CheckboxField))
            return (view: stackView, field: valueField)
        })

        for (index, view) in views.enumerated() {
            if index == views.count - 1 { continue }
            view.field.view.nextKeyView = views[index + 1].field.view
        }
        return views
    }
}
