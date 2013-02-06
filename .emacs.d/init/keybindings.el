; -------------------------
; Keybindings
; -------------------------

; Add modifier keys for M-x
(global-set-key "\C-x\C-m" 'monky-status)

; Moving between windows
(global-set-key (kbd "C-H-<up>") 'windmove-up)
(global-set-key (kbd "C-H-<down>") 'windmove-down)
(global-set-key (kbd "C-H-<right>") 'windmove-right)
(global-set-key (kbd "C-H-<left>") 'windmove-left)

; Cmd-backspace delete to beginning of line (by default, you can do
; this is emacs with C-0 C-k)
(global-set-key [s-backspace] '(lambda () (interactive) (kill-line 0)))

(global-set-key [C-s-268632070] 'ns-toggle-fullscreen)

(global-set-key (kbd "s-r") 'recompile)
