; extends
; Prevent function *calls* from being highlighted
(call_expression function: (identifier) @function.call)
(call_expression function: (member_expression property: (property_identifier) @function.call))

; Highlight React Hook usage
(call_expression function: (identifier) @reactHook (#match? @reactHook "^use[A-Z]"))

; (class_declaration name: (identifier) @className)
; Highlight class properties whose value is an arrow function
; (public_field_definition
  ; property: (property_identifier) @function
  ; value: (arrow_function)
; )

; import/require keywords and names
((identifier) @namespace (#eq? @namespace "require"))
(namespace_import (identifier) @none)
[
"import"
"from"
"as"
] @namespace

; JSX element names
(jsx_self_closing_element (identifier) @tag)
(jsx_opening_element (identifier) @tag)
(jsx_closing_element (identifier) @tag)
(jsx_self_closing_element name: (nested_identifier (identifier) @tag))
(jsx_opening_element name: (nested_identifier (identifier) @tag))
(jsx_closing_element name: (nested_identifier (identifier) @tag))

; JSX element brackets
(jsx_element open_tag: (jsx_opening_element ["<" ">"] @tag.delimiter))
(jsx_element close_tag: (jsx_closing_element ["<" "/" ">"] @tag.delimiter))
(jsx_self_closing_element ["/" ">" "<"] @tag.delimiter)
(jsx_fragment [">" "<" "/"] @tag.delimiter)

; JSX attributes
(jsx_attribute (property_identifier) @jsxAttribute)
