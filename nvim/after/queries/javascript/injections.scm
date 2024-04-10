;; extends

;; tell treesitter that sql.fragment`` and sql.type()`` strings should be SQL
(call_expression
  function: (member_expression
              (identifier) @_i (#eq? @_i "sql") (property_identifier) @_pi (#eq? @_pi "fragment"))
  arguments: (template_string
               (string_fragment) @injection.content
               (#set! injection.language "sql")
               (#set! injeciton.include-children true)))

((call_expression
   function: (member_expression
               (identifier)  @_i (#eq? @_i "sql") (property_identifier) @_pi (#eq? @_pi "type")))
 (template_string (string_fragment) @injection.content
                  (#set! injection.language "sql")
                  (#set! injection.include-children true)))
