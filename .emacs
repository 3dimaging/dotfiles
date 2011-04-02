; Emacs Load Path
; (setq load-path (cons "~/.emacs.d" load-path))
; (add-to-list 'load-path "~/.emacs.d/color-theme-sunburst.el")

(add-to-list 'load-path "~/.emacs.d")
(add-to-list 'load-path "~/.emacs.d/themes")
(add-to-list 'load-path "~/.emacs.d/plugins")

; Set whitespace on
(require 'whitespace)
(custom-set-variables
  '(whitespace-style (quote (face tabs spaces trailing lines space-before-tab indentation empty space-after-tab tab-mark)))
  '(global-whitespace-mode t)
)

; Change the color-theme
(require 'color-theme)
(color-theme-initialize)
; Load the zenburn color-theme from
; https://github.com/bbatsov/zenburn-emacs
(require 'zenburn)
(zenburn)

; Highlight both the row and column
(require 'crosshairs)
(custom-set-variables '(crosshairs-mode t))

; Try to fix the craziness of customization
; (require 'cus-edit+)
; (customize-toggle-outside-change-updates 99)
; (remove-hook 'kill-emacs-query-functions 'customize-customized)

; Change the right command button to meta
(custom-set-variables '(ns-right-command-modifier (quote meta)))

; YASnippet
(add-to-list 'load-path "~/.emacs.d/plugins/yasnippet-0.6.1c")
(require 'yasnippet) ;; not yasnippet-bundle
(yas/initialize)
(yas/load-directory "~/.emacs.d/plugins/yasnippet-0.6.1c/snippets")
(yas/global-mode 1)

; Load auto-complete
(add-to-list 'load-path "~/.emacs.d/plugins/auto-complete-1.3.1")
(require 'auto-complete-config)
(add-to-list 'ac-dictionary-directories "~/.emacs.d/plugins/auto-complete-1.3.1/ac-dict")
(ac-config-default)

; Load auto-complete-clang
(add-to-list 'load-path "~/.emacs.d/plugins/auto-complete-clang-dc923a379b76d8089b26")
(require 'auto-complete-clang)
(setq clang-completion-suppress-error 't)

(defun my-c-mode-common-hook()
  (setq ac-auto-start nil)
  (setq ac-expand-on-auto-complete nil)
  (setq ac-quick-help-delay 0.3)
  (define-key c-mode-base-map (kbd "M-/") 'ac-complete-clang)
)

(add-hook 'c-mode-common-hook 'my-c-mode-common-hook)
