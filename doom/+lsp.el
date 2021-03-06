;;; ~/projects/dotfiles/doom/+lsp.el -*- lexical-binding: t; -*-

(after! lsp-mode
  (add-hook 'lsp-after-open-hook 'lsp-enable-imenu))

(after! lsp-mode
  (setq lsp-pyls-configuration-sources ["flake8"]
        lsp-pyls-plugins-pylint-enabled nil
        lsp-pyls-plugins-pycodestyle-enabled nil
        lsp-pyls-plugins-flake8-enabled t
        lsp-ui-doc-enable t)

  ;; python stuff

  ;; lsp-python-ms (or rather the ms-python server) doesn't use other backends,
  ;; so manually set `flycheck-checker' in `python-mode'
  (add-hook! lsp-mode (when (derived-mode-p 'python-mode)
                        (setq-local flycheck-checker 'python-flake8)))


  (let* ((ans-dir "/usr/local/Cellar/ansible/")
         (ans-vers-dir (car
                        (mapcar #'car
                                (sort (directory-files-and-attributes ans-dir)
                                      #'(lambda (x y) (time-less-p (nth 6 x) (nth 6 y))))))))

    (setq lsp-python-ms-extra-paths `("~/Library/Python/3.7/lib/python/site-packages"
                                      ,(concat ans-dir ans-vers-dir "/libexec/lib/python3.8/site-packages")))))

;====== helpful snippet to not start a process and just connect to a port ======

;; (defun lsp-tcp-connect-to-port ()
;;   (list
;;    :connect (lambda (filter sentinel name environment-fn)
;;               (let* ((host "localhost")
;;                      (port (string-to-number (read-string "Enter port: ")))
;;                      (tcp-proc (lsp--open-network-stream host port (concat name "::tcp"))))

;;                 (set-process-query-on-exit-flag tcp-proc nil)
;;                 (set-process-filter tcp-proc filter)
;;                 (cons tcp-proc tcp-proc)))
;;    :test? (lambda () t)))

;; (require 'lsp)
;; (lsp-register-client
;;  (make-lsp-client :new-connection (lsp-tcp-connect-to-port)
;;                   :major-modes '(gdscript-mode)
;;                   :priority -1
;;                   :server-id 'gdscript-ls))

(after! lsp-python-ms
  (set-lsp-priority! 'mspyls 1))
