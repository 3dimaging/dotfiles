(setq server-use-tcp t)

;; custom fonts

;; icomoon allows use of custom ranges so just upload there and make sure that
;; range matches the range below
(when (fboundp 'set-fontset-font)
  (add-hook! 'doom-init-ui-hook
    (set-fontset-font "fontset-default" '(#xe900 . #xe902) "smf-custom-icons")))

;; don't prompt please
(setq confirm-kill-emacs nil)

;; really convenient mode for copying the whole line or region
(whole-line-or-region-global-mode)

;; make new frames fullscreen by default
(add-hook 'after-make-frame-functions (lambda (frame)
                                        (select-frame frame)
                                        (toggle-frame-fullscreen)
                                        ;; don't really like creating a random
                                        ;; workspace when a new frame is created
                                        (+workspace/delete "#1")))

;; save and restore the scratch buffer
(def-package! persistent-scratch
  :init
  (setq persistent-scratch-save-file
        (expand-file-name "persistent-scratch"
                          doom-cache-dir))

  :config
  (persistent-scratch-setup-default)
  (persistent-scratch-autosave-mode)

  (defun smf/scratch-init ()
    (switch-to-buffer (get-buffer-create "*scratch*"))
    (lisp-interaction-mode))

  (add-hook 'doom-scratch-buffer-hook #'smf/scratch-init))

;; automatically add some buffers to the workspace
(after! persp-mode
  (defun smf/unreal-buffer-p (buffer-or-name)
    "Wrap `doom-unreal-buffer-p' but allow circe buffers through."
    (unless (derived-mode-p 'circe-mode)
      (doom-unreal-buffer-p buffer-or-name)))

  (setq persp-add-buffer-on-after-change-major-mode-filter-functions
        '(smf/unreal-buffer-p)))

;; enable hs-minor-mode
(add-hook 'prog-mode-hook #'hs-minor-mode)

;; git stuff
(after! git-commit
  (setq git-commit-summary-max-length 72))
;; smart-jump
(smart-jump-setup-default-registers)


;; load personal modules
(load! "+utils")
(load! "+mac")
(load! "+bindings")
(load! "info+")
(load! "+ivy")
(load! "+org")
(load! "+org-starter")
(load! "+irc")
(load! "+twitter")
