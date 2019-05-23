(setq server-use-tcp t
      server-port    9999)

;; custom fonts

;; optionally specifiy :weight 'light
(setq doom-font (font-spec :family "FuraCode Nerd Font" :size 14))

;; icomoon allows use of custom ranges so just upload there and make sure that
;; range matches the range below
(when (fboundp 'set-fontset-font)
  (add-hook! 'doom-init-ui-hook
    (set-fontset-font "fontset-default" '(#xe900 . #xe902) "smf-custom-icons")))

;; ;; example to test custom font; along with how to type raw unicode
;; (insert       (propertize "\ue900"
;;                   'face '(:family "smf-custom-icons")
;;                   'rear-nonsticky t
;;                   'display '(raise -0.1)
;;                   'font-lock-ignore t))

;; don't prompt please
(setq confirm-kill-emacs nil)

;; really convenient mode for copying the whole line or region
(whole-line-or-region-global-mode)

;; enable hs-minor-mode
(add-hook 'prog-mode-hook #'hs-minor-mode)

;; smart-jump
(smart-jump-setup-default-registers)

(defmacro smf/bitwarden-init ()
  `(progn
     (require 'bitwarden nil t)
     (setq bitwarden-user "sean@farley.io"

           bitwarden-automatic-unlock (let* ((auth-sources
                                              '(macos-keychain-internet))
                                             (matches (auth-source-search
                                                       :user "sean@farley.io"
                                                       :host "bitwarden.farley.in"
                                                       :require '(:secret)
                                                       :max 1))
                                             (entry (nth 0 matches)))
                                        (plist-get entry :secret)))
     (bitwarden-auth-source-enable)))

;; bitwardn password auth-source
(smf/bitwarden-init)

;; magit should use auth-source
(add-hook 'magit-process-find-password-functions
          'magit-process-password-auth-source)

;; (setq doom-theme 'doom-snazzy)

;; nifty package for popping up a quick emacs frame
(def-package! yequake
  :config
  (setq yequake-frames
      '(("Yequake & scratch" .
         ((name . "Yequake & scratch")
          (width . 0.75)
          (height . 0.5)
          (alpha . 0.75)
          (buffer-fns . ("~/projects/dotfiles/doom/config.el"
                         split-window-horizontally
                         "*scratch*"))
          (frame-parameters . ((undecorated . t))))))))

(setq pdf-view-use-scaling t)

(def-package! webpaste
  :bind (("C-c C-p C-b" . webpaste-paste-buffer)
         ("C-c C-p C-r" . webpaste-paste-region)))

;; load personal modules
(load! "+utils")
(load! "+mac")
(load! "+bindings")
(load! "+org")
(load! "+org-starter")
(load! "+irc")
(load! "+twitter")
(load! "+mail")
(load! "+modeline")
(load! "+lsp")
