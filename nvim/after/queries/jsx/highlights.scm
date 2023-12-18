; extends

; React Hook usage
(call_expression function: (identifier) @reactHook (#match? @reactHook "^use[A-Z]"))

; JSX element names
(jsx_self_closing_element name: (identifier) @tag)
(jsx_self_closing_element ((member_expression (identifier) @tag (property_identifier) @tag)))
(jsx_opening_element name: (identifier) @tag)
(jsx_closing_element name: (identifier) @tag)
(jsx_opening_element ((member_expression (identifier) @tag (property_identifier) @tag)))
(jsx_closing_element ((member_expression (identifier) @tag (property_identifier) @tag)))
