; extends

(template_string) @indent.ignore

[
  (comment)
  (ERROR)
] @indent.auto

(binary_expression) @indent.end

(ternary_expression
  consequence: (object) @indent.align
  (#set! indent.open_delimiter "{"))

(ternary_expression
  alternative: (object) @indent.align
  (#set! indent.open_delimiter "{"))
