; extends
; Prevent function *calls* from being highlighted
(call_expression function: (identifier) @function.call)
(call_expression function: (member_expression property: (property_identifier) @function.call))

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
