// Generated by BUCKLESCRIPT VERSION 2.1.0, PLEASE EDIT WITH CARE
'use strict';

var List                         = require("bs-platform/lib/js/list.js");
var Path                         = require("path");
var Block                        = require("bs-platform/lib/js/block.js");
var Pervasives                   = require("bs-platform/lib/js/pervasives.js");
var Json_decode                  = require("bs-json/src/Json_decode.js");
var Color$LonaCompilerCore       = require("../core/color.bs.js");
var TextStyle$LonaCompilerCore   = require("../core/textStyle.bs.js");
var SwiftFormat$LonaCompilerCore = require("./swiftFormat.bs.js");

function join(sep, nodes) {
  if (nodes) {
    return List.fold_left((function (acc, node) {
                  return Pervasives.$at(acc, /* :: */[
                              sep,
                              /* :: */[
                                node,
                                /* [] */0
                              ]
                            ]);
                }), /* [] */0, nodes);
  } else {
    return /* [] */0;
  }
}

function joinGroups(sep, groups) {
  var nonEmpty = List.filter((function (x) {
            return +(List.length(x) > 0);
          }))(groups);
  if (nonEmpty) {
    return List.fold_left((function (acc, nodes) {
                  return Pervasives.$at(acc, Pervasives.$at(/* :: */[
                                  sep,
                                  /* [] */0
                                ], nodes));
                }), nonEmpty[0], nonEmpty[1]);
  } else {
    return /* [] */0;
  }
}

function nameWithoutExtension(path) {
  return Path.parse(path).name;
}

function importFramework(framework) {
  if (framework !== 0) {
    return /* ImportDeclaration */Block.__(14, ["AppKit"]);
  } else {
    return /* ImportDeclaration */Block.__(14, ["UIKit"]);
  }
}

function colorTypeName(framework) {
  if (framework !== 0) {
    return "NSColor";
  } else {
    return "UIColor";
  }
}

function fontTypeName(framework) {
  if (framework !== 0) {
    return "NSFont";
  } else {
    return "UIFont";
  }
}

function imageTypeName(framework) {
  if (framework !== 0) {
    return "NSImage";
  } else {
    return "UIImage";
  }
}

function layoutPriorityTypeDoc(framework) {
  if (framework !== 0) {
    return /* MemberExpression */Block.__(1, [/* :: */[
                /* SwiftIdentifier */Block.__(8, ["NSLayoutConstraint"]),
                /* :: */[
                  /* SwiftIdentifier */Block.__(8, ["Priority"]),
                  /* [] */0
                ]
              ]]);
  } else {
    return /* SwiftIdentifier */Block.__(8, ["UILayoutPriority"]);
  }
}

function labelAttributedTextName(framework) {
  if (framework !== 0) {
    return "attributedStringValue";
  } else {
    return "attributedText";
  }
}

function localImageName(framework, name) {
  var imageName = /* LiteralExpression */Block.__(0, [/* String */Block.__(3, [Path.parse(name).name])]);
  if (framework !== 0) {
    return /* FunctionCallExpression */Block.__(19, [{
                name: /* MemberExpression */Block.__(1, [/* :: */[
                      /* SwiftIdentifier */Block.__(8, ["NSImage"]),
                      /* :: */[
                        /* SwiftIdentifier */Block.__(8, ["Name"]),
                        /* [] */0
                      ]
                    ]]),
                arguments: /* :: */[
                  /* FunctionCallArgument */Block.__(18, [{
                        name: /* Some */[/* SwiftIdentifier */Block.__(8, ["rawValue"])],
                        value: imageName
                      }]),
                  /* [] */0
                ]
              }]);
  } else {
    return imageName;
  }
}

function typeAnnotationDoc(param) {
  switch (param.tag | 0) {
    case 0 : 
        var typeName = param[0];
        if (typeName === "Boolean") {
          return /* TypeName */Block.__(0, ["Bool"]);
        } else {
          return /* TypeName */Block.__(0, [typeName]);
        }
        break;
    case 1 : 
        return /* TypeName */Block.__(0, [param[0]]);
    case 2 : 
        return /* TypeName */Block.__(0, ["(() -> Void)?"]);
    
  }
}

function lonaValue(framework, colors, textStyles, _value) {
  while(true) {
    var value = _value;
    var match = value[/* ltype */0];
    switch (match.tag | 0) {
      case 0 : 
          var typeName = match[0];
          var exit = 0;
          switch (typeName) {
            case "Boolean" : 
                return /* LiteralExpression */Block.__(0, [/* Boolean */Block.__(0, [Json_decode.bool(value[/* data */1])])]);
            case "Number" : 
                return /* LiteralExpression */Block.__(0, [/* FloatingPoint */Block.__(2, [Json_decode.$$float(value[/* data */1])])]);
            case "String" : 
                return /* LiteralExpression */Block.__(0, [/* String */Block.__(3, [Json_decode.string(value[/* data */1])])]);
            case "Color" : 
            case "TextStyle" : 
                exit = 1;
                break;
            default:
              return /* SwiftIdentifier */Block.__(8, ["UnknownReferenceType: " + typeName]);
          }
          if (exit === 1) {
            _value = /* record */[
              /* ltype : Named */Block.__(1, [
                  typeName,
                  /* Reference */Block.__(0, ["String"])
                ]),
              /* data */value[/* data */1]
            ];
            continue ;
            
          }
          break;
      case 1 : 
          var alias = match[0];
          switch (alias) {
            case "Color" : 
                var rawValue = Json_decode.string(value[/* data */1]);
                var match$1 = Color$LonaCompilerCore.find(colors, rawValue);
                if (match$1) {
                  return /* MemberExpression */Block.__(1, [/* :: */[
                              /* SwiftIdentifier */Block.__(8, ["Colors"]),
                              /* :: */[
                                /* SwiftIdentifier */Block.__(8, [match$1[0][/* id */0]]),
                                /* [] */0
                              ]
                            ]]);
                } else {
                  return /* LiteralExpression */Block.__(0, [/* Color */Block.__(4, [rawValue])]);
                }
            case "TextStyle" : 
                var rawValue$1 = Json_decode.string(value[/* data */1]);
                var match$2 = TextStyle$LonaCompilerCore.find(textStyles[/* styles */0], rawValue$1);
                if (match$2) {
                  return /* MemberExpression */Block.__(1, [/* :: */[
                              /* SwiftIdentifier */Block.__(8, ["TextStyles"]),
                              /* :: */[
                                /* SwiftIdentifier */Block.__(8, [match$2[0][/* id */0]]),
                                /* [] */0
                              ]
                            ]]);
                } else {
                  return /* MemberExpression */Block.__(1, [/* :: */[
                              /* SwiftIdentifier */Block.__(8, ["TextStyles"]),
                              /* :: */[
                                /* SwiftIdentifier */Block.__(8, [textStyles[/* defaultStyle */1][/* id */0]]),
                                /* [] */0
                              ]
                            ]]);
                }
            case "URL" : 
                var rawValue$2 = Json_decode.string(value[/* data */1]);
                if (rawValue$2.startsWith("file://./")) {
                  return /* FunctionCallExpression */Block.__(19, [{
                              name: /* SwiftIdentifier */Block.__(8, [imageTypeName(framework)]),
                              arguments: /* :: */[
                                /* FunctionCallArgument */Block.__(18, [{
                                      name: /* Some */[/* SwiftIdentifier */Block.__(8, ["named"])],
                                      value: localImageName(framework, rawValue$2)
                                    }]),
                                /* [] */0
                              ]
                            }]);
                } else {
                  return /* SwiftIdentifier */Block.__(8, ["RemoteOrAbsoluteImageNotHandled"]);
                }
            default:
              return /* SwiftIdentifier */Block.__(8, ["UnknownNamedTypeAlias" + alias]);
          }
          break;
      case 2 : 
          return /* SwiftIdentifier */Block.__(8, ["PLACEHOLDER"]);
      
    }
  };
}

function memberOrSelfExpression(first, statements) {
  var exit = 0;
  if (typeof first === "number") {
    exit = 1;
  } else if (first.tag === 8) {
    if (first[0] === "self") {
      return /* MemberExpression */Block.__(1, [statements]);
    } else {
      exit = 1;
    }
  } else {
    exit = 1;
  }
  if (exit === 1) {
    return /* MemberExpression */Block.__(1, [Pervasives.$at(/* :: */[
                    first,
                    /* [] */0
                  ], statements)]);
  }
  
}

function layerNameOrSelf(rootLayer, layer) {
  var match = +(layer === rootLayer);
  return /* SwiftIdentifier */Block.__(8, [match !== 0 ? "self" : SwiftFormat$LonaCompilerCore.layerName(layer[/* name */1])]);
}

function layerMemberExpression(rootLayer, layer, statements) {
  return memberOrSelfExpression(layerNameOrSelf(rootLayer, layer), statements);
}

function binaryExpressionList(operator, items) {
  if (items) {
    var tl = items[1];
    var x = items[0];
    if (tl) {
      return /* BinaryExpression */Block.__(2, [{
                  left: x,
                  operator: operator,
                  right: binaryExpressionList(operator, tl)
                }]);
    } else {
      return x;
    }
  } else {
    return /* Empty */0;
  }
}

exports.join                    = join;
exports.joinGroups              = joinGroups;
exports.nameWithoutExtension    = nameWithoutExtension;
exports.importFramework         = importFramework;
exports.colorTypeName           = colorTypeName;
exports.fontTypeName            = fontTypeName;
exports.imageTypeName           = imageTypeName;
exports.layoutPriorityTypeDoc   = layoutPriorityTypeDoc;
exports.labelAttributedTextName = labelAttributedTextName;
exports.localImageName          = localImageName;
exports.typeAnnotationDoc       = typeAnnotationDoc;
exports.lonaValue               = lonaValue;
exports.memberOrSelfExpression  = memberOrSelfExpression;
exports.layerNameOrSelf         = layerNameOrSelf;
exports.layerMemberExpression   = layerMemberExpression;
exports.binaryExpressionList    = binaryExpressionList;
/* path Not a pure module */
