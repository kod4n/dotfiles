; extends

; Keep case labels level with their switch when the project's clang-format has
; IndentCaseLabels: false (predicate defined in lua/config/clang_format.lua).
; branch pulls the label line back; dedent cancels the extra level for its body.
((case_statement) @indent.branch @indent.dedent
  (#flush-case-labels?))

; Braced case body: the brace starts on the label row, so cancel its extra level too.
((case_statement
  (compound_statement) @indent.dedent)
  (#flush-case-labels?))
