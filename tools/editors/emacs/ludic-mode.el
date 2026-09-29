;;; ludic-mode.el --- Major mode for the Ludic game language -*- lexical-binding: t; -*-

;; Highlighting here is a deliberate minimum: enough for a file to be readable
;; with nothing installed. Everything real -- completion, diagnostics, hover,
;; formatting -- comes from ludic-lsp via eglot (built into Emacs 29) or lsp-mode.
;;
;; Usage:
;;   (add-to-list 'load-path "/path/to/gpp/tools/editors/emacs")
;;   (require 'ludic-mode)

;;; Code:

;; The vocabulary is written by `ludic-dev syntax` from the compiler's own table
;; (`ludicc --emit-syntax`) between the marked lines.
;; ludic-dev syntax: begin - generated from `ludicc --emit-syntax` (selfhost/frontend/vocab.ludic); run `ludic-dev syntax`, do not edit
(defconst ludic--declaration-keywords
  '("program" "module" "import" "property" "state" "event" "action" "reducer" "enum" "model"
    "prefab" "scene" "handler" "ui" "namespace" "alias" "port" "bind" "registry" "def"
    "component" "view" "prop" "const" "var" "function" "fn" "extern" "entry" "test"))
(defconst ludic--clause-keywords
  '("export" "internal" "friend" "uses" "open" "of" "as" "from" "numbers" "unsafe" "mut" "phase"
    "query" "on" "cancellable" "public" "layer" "start" "shows" "lasts" "then" "loads"
    "system"))
(defconst ludic--statement-keywords
  '("let" "if" "else" "while" "for" "in" "where" "match" "machine" "become" "return" "break"
    "continue" "new" "spawn" "despawn" "enable" "disable" "attach" "detach" "emit" "cancel"
    "dispatch" "try" "and" "or" "not"))
(defconst ludic--types
  '("int" "long" "float" "double" "fixed" "bool" "byte" "string" "pointer" "void" "entity"
    "countdown" "words" "floats" "doubles" "fixeds" "pointers" "Vector" "IVec2" "Rect"))
(defconst ludic--phases
  '("Start" "Input" "FixedUpdate" "Update" "LateUpdate" "Render" "Overlay"))
;; ludic-dev syntax: end

(defconst ludic-font-lock-keywords
  (list
   (cons (regexp-opt ludic--declaration-keywords 'symbols) 'font-lock-keyword-face)
   (cons (regexp-opt ludic--clause-keywords 'symbols) 'font-lock-preprocessor-face)
   (cons (regexp-opt ludic--statement-keywords 'symbols) 'font-lock-keyword-face)
   (cons (regexp-opt ludic--types 'symbols) 'font-lock-type-face)
   (cons (regexp-opt ludic--phases 'symbols) 'font-lock-builtin-face)
   (cons "\\_<\\(true\\|false\\|null\\)\\_>" 'font-lock-constant-face)
   (cons "@[A-Za-z_][A-Za-z0-9_]*" 'font-lock-preprocessor-face)
   ;; components, archetypes, scenes and UI handles are Capitalised by convention
   (cons "\\_<[A-Z][A-Za-z0-9_]*\\_>" 'font-lock-type-face)
   (cons "\\_<\\([a-z_][A-Za-z0-9_]*\\)\\s-*(" '(1 font-lock-function-name-face))))

(defvar ludic-mode-syntax-table
  (let ((table (make-syntax-table)))
    (modify-syntax-entry ?# "<" table)
    (modify-syntax-entry ?\n ">" table)
    (modify-syntax-entry ?_ "_" table)
    (modify-syntax-entry ?\" "\"" table)
    table)
  "Syntax table for `ludic-mode'.")

;;;###autoload
(define-derived-mode ludic-mode prog-mode "Ludic"
  "Major mode for editing Ludic source."
  :syntax-table ludic-mode-syntax-table
  (setq-local font-lock-defaults '(ludic-font-lock-keywords))
  (setq-local comment-start "# ")
  (setq-local comment-end "")
  (setq-local indent-tabs-mode nil)
  (setq-local tab-width 2)
  (setq-local standard-indent 2))

;;;###autoload
(add-to-list 'auto-mode-alist '("\\.ludic\\'" . ludic-mode))

;; eglot: one line, and the server does the rest. Markdown is registered too so
;; that ```ludic fences are analysed in prose files.
(with-eval-after-load 'eglot
  (add-to-list 'eglot-server-programs '(ludic-mode . ("ludic-lsp" "--stdio"))))

(provide 'ludic-mode)
;;; ludic-mode.el ends here
