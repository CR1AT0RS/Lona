// Lona Logic Grammar
// A subset of Swift for defining design tokens
//
// This parses Swift code as a LogicLanguage.types data type.
//
// ---
//
// VSCode extensions:
//
// For syntax highlighting: https://marketplace.visualstudio.com/items?itemName=SirTobi.pegjs-language
// For live preview/sandbox: https://marketplace.visualstudio.com/items?itemName=joeandaverde.vscode-pegjs-live

{
  // https://stackoverflow.com/questions/105034/create-guid-uuid-in-javascript
  function uuid() {
    if (typeof options.generateId === 'function') {
      return options.generateId()
    }

    return 'xxxxxxxx-xxxx-4xxx-yxxx-xxxxxxxxxxxx'.replace(/[xy]/g, function(c) {
      var r = Math.random() * 16 | 0, v = c == 'x' ? r : (r & 0x3 | 0x8);
      return v.toString(16);
    });
  }

  function extractList(list, index) {
    return list.map(function(element) { return element[index]; });
  }

  function buildList(head, tail, index) {
    return [head].concat(extractList(tail, index));
  }

  function placeholder() {
    return { data: { id: uuid() }, type: 'placeholder' }
  }

  function normalizeListWithPlaceholder(list) {
    return (list || []).concat([placeholder()])
  }
}

start =
  _ topLevelDeclarations:topLevelDeclarations _ {
    return topLevelDeclarations
  }

statement =
  declaration:declaration {
    return {
      data: {
        content: declaration,
        id: uuid()
      },
      type: 'declaration'
    }
  }

topLevelDeclarations =
  declarations:declarationList {
    return {
      data: {
      	declarations: normalizeListWithPlaceholder(declarations),
        id: uuid(),
      },
      type: 'topLevelDeclarations'
    }
  }

declaration =
  data:variableDeclaration {
    return {
      data,
      type: 'variable',
    }
  } / data:importDeclaration {
    return {
      data,
      type: 'importDeclaration',
    }
  } / data:recordDeclaration {
    return {
      data,
      type: 'record',
    }
  // This case determines its own type (enum/namespace)
  } / value:enumDeclaration {
    return value
  }

declarationList =
  head:declaration tail:(_ declaration)* {
    return buildList(head, tail, 1)
  }

importDeclaration =
  "import" _ name:pattern {
    return {
      id: uuid(),
      name,
    }
  }

recordDeclaration =
  "struct" _ name:pattern _ "{" _ declarations:declarationList? _ "}" {
    return {
      // Delete declaration modifier for now, since we don't store these
      declarations: normalizeListWithPlaceholder(declarations).map(declaration => {
        delete declaration.data.declarationModifier
        return declaration
      }),
      genericParameters: [],
      id: uuid(),
      name,
    }
  }

enumDeclaration =
  "enum" _ name:pattern _ "{" _ declarations:declarationList? _ "}" {
    return {
      data: {
        // Delete declaration modifier for now, since we don't store these
        declarations: normalizeListWithPlaceholder(declarations).map(declaration => {
          delete declaration.data.declarationModifier
          return declaration
        }),
        id: uuid(),
        name,
      },
      type: 'namespace',
    }

    // TODO: If there are cases, return an enum
    // return {
    //   data: {
    //     id: uuid(),
    //     name,
    //     genericParameters: [],
    //     cases: [],
    //     comment: null,
    //   },
    //   type: 'enum'
    // }
  }

declarationModifier = "static" { return text() }

variableDeclaration =
  declarationModifier:(declarationModifier _)?
  "let" _ name:pattern _ ":" _
  annotation:typeAnnotation _ "=" _ initializer:expression {
    const result = {
      annotation,
      id: uuid(),
      initializer,
      name,
    }

    if (declarationModifier) {
      result.declarationModifier = declarationModifier[0]
    }

    return result
  }

expression =
  literalExpression /
  memberExpression /
  identifierExpression

memberExpression =
  expression:identifierExpression "." memberName:identifier {
    return {
      data: { expression, id: uuid(), memberName },
      type: 'memberExpression',
    }
  }

literalExpression =
  literal:literal {
    return {
      data: { id: uuid(), literal },
      type: 'literalExpression',
    }
  }

identifierExpression =
  identifier:identifier {
    return {
      data: { id: uuid(), identifier },
      type: 'identifierExpression'
    }
  }

expressionList =
  head:expression tail:("," _ expression)* {
    return buildList(head, tail, 2)
  }

// memberExpression =
//   head:identifier "." tail:memberExpression {
//     return buildList(head, tail, 2)
//   }

// Literals

literal =
  booleanLiteral /
  numberLiteral /
  stringLiteral /
  arrayLiteral /
  colorLiteral

booleanLiteral =
  value:booleanValue {
    return {
      data: { id: uuid(), value },
      type: 'boolean',
    }
  }

numberLiteral =
  value:numberValue {
    return {
      data: { id: uuid(), value },
      type: 'number',
    }
  }

stringLiteral =
  value:stringValue {
    return {
      data: { id: uuid(), value },
      type: 'string',
    }
  }

arrayLiteral =
  value:arrayValue {
    return {
      data: { id: uuid(), value },
      type: 'array',
    }
  }

colorLiteral =
  value:colorValue {
    return {
      data: { id: uuid(), value },
      type: 'color',
    }
  }

// Type Annotations

typeAnnotation =
  identifier:identifier genericArguments:( "<" typeAnnotationList ">" )? {
    return {
      data: {
        genericArguments: genericArguments ? genericArguments[1] : [],
        id: uuid(),
        identifier
      },
      type: 'typeIdentifier',
    }
  }

typeAnnotationList =
  head:typeAnnotation tail:("," _ typeAnnotation)* {
    return buildList(head, tail, 2)
  }

pattern = name:rawIdentifier { return { id: uuid(), name } }

identifier =
  string:rawIdentifier {
    return {
      id: uuid(),
      isPlaceholder: false,
      string
    }
  }

// Values

numberValue = floatValue / intValue

floatValue = [+\-] ? [0-9] "." [0-9]+ { return Number(text()) }

intValue = [+\-] ? [0-9]+ { return Number(text()) }

booleanValue = "true" / "false" { return text() === "true" }

stringValue = "\"" (! "\"" .)* "\"" { return text().slice(1, -1) }

arrayValue = "[" _ expressionList:expressionList? _ "]" {
  return normalizeListWithPlaceholder(expressionList)
}

colorValue = "#color(css:" _ value:stringValue _ ")" { return value }

// Source characters

rawIdentifier = [_a-zA-Z] [_a-zA-Z0-9]* { return text() }

_ "whitespace"
  = [ \t\n\r]*
