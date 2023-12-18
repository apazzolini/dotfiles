; extends

; function *calls* highlighted differently than definitions
(call_expression function: (identifier) @function.call)
(call_expression function: (member_expression property: (property_identifier) @function.call))
(new_expression constructor: (identifier) @function.call)

; import/require keywords and names
((identifier) @namespace (#eq? @namespace "require"))
(namespace_import (identifier) @none)
[
"import"
"from"
"as"
] @namespace

