;;; ~/.doom.d/+org.el -*- lexical-binding: t; -*-

(def-package! org-starter
  :init

  ;; TODO this is duplicating entries in org-agenda
  (setq-default
   ;; set up root org directory
   org-directory "~/Nextcloud/org"

   ;; set the file for capturing todos
   org-default-notes-file (concat org-directory "/inbox.org"))

  :config
  (when (all-the-icons-faicon "mercury")
    ;; icons for each org file, only works in gui mode
    (setq-default
     org-agenda-category-icon-alist
     `(("hg" ,(list (propertize
                     (all-the-icons-faicon "mercury")
                     'face `(:family ,(all-the-icons-faicon-family) :height 1.3)))
        nil nil :height (16) :width (16) :ascent center)
       ("personal" ,(list (all-the-icons-faicon "user")) nil nil :ascent center)
       ("phd" ,(list (all-the-icons-faicon "superscript")) nil nil :ascent center))))

  (setq-default +org-capture-todo-file "inbox.org")

  (setq-default
   ;; add a nice, little template to use along with some shortcuts
   org-capture-templates
   '(("t" "Tasks" entry
      (file+headline (lambda () org-default-notes-file) "Inbox")
      "* TODO %?\n  Captured %<%Y-%m-%d %H:%M>\n  %a\n\n  %i")))

  ;; ;; shortcut to launch file for refiling
  ;; (smf/add-launcher "o" (lambda ()
  ;;                         (interactive)
  ;;                         (find-file org-default-notes-file)))

  (org-starter-def org-directory
    :files
    ("personal.org" :agenda t :refile (:maxlevel . 4))
    ("phd.org" :agenda t :refile (:maxlevel . 4))
    ("entertainment.org" :agenda nil))

  ;; after persp-mode is loaded, open all our org files and add them to the main
  ;; workspace
  (after! persp-mode
    (defun smf/org-init ()
      "method to load org files and agenda when emacs starts"
      (interactive)
      ;; load all org files
      (org-starter-load-all-files-in-path)
      (split-window-right)
      ;; start org-agenda
      (org-agenda nil "a")
      (display-buffer "*Org Agenda(a)*" t)

      ;; add the org files to the main workspace
      (persp-add-buffer
       (mapcar (lambda (f)
                 (file-name-nondirectory f)) org-starter-known-files)
       (persp-get-by-name +workspaces-main))

      ;; also add the agenda
      (persp-add-buffer "*Org Agenda(a)*" (persp-get-by-name +workspaces-main)))

    ;; once the scratch buffer has loaded it should be late enough to load the org
    ;; agenda files as well
    (add-hook 'doom-init-ui-hook #'smf/org-init)))

(after! org
  (map!
   ;; I'll change the prefix for these function (instead of using smf/launcher)
   ;; since they are so common
   "C-c l" #'org-store-link
   "C-c a" #'org-agenda

   :map org-mode-map
   ;; I use meta-arrow keys for navigation so let's stop org from
   ;; using them to indent
   "<M-S-left>" nil
   "<M-left>" nil
   "<M-right>" nil
   ;; since I commonly mistype =C-c C-'= instead of =C-c '=, let's
   ;; add that keybinding,
   "C-c C-'" #'org-edit-special

   ;; same as python
   "C-c <" #'org-shiftmetaleft
   "C-c >" #'org-shiftmetaright

   :map org-src-mode-map
   "C-c C-'" #'org-edit-src-exit
   ;; I find it infuriating that my muscle memory =⌘+s= in
   ;; =org-src-mode= will save the buffer as a new file. Instead,
   ;; let's make it do the same thing as =C-c '=
   "s-s" #'org-edit-src-exit)

  (define-key global-map "\C-cc"
    (lambda () (interactive) (org-capture nil "t")))
  (define-key global-map "\C-cj"
    (lambda () (interactive) (org-capture nil "j")))

  (setq-default
   ;; don't auto-fold my documents
   org-startup-folded nil

   ;; automatically apply syntax highlighting:
   org-src-fontify-natively t
   org-src-tab-acts-natively t
   org-ellipsis " ⤵"

   ;; and don't prompt
   org-confirm-babel-evaluate nil

   ;; when using imenu, make sure I can follow the outline to the full available
   ;; depth
   org-imenu-depth 6

   ;; also, I like using shift+arrow keys to highlight, so let's set that
   org-support-shift-select 'always

   ;; also search archive files
   ;; org-agenda-text-search-extra-files '(agenda-archives)

   ;; please don't close and mess up my windows,
   org-agenda-window-setup 'current-window
   org-agenda-restore-windows-after-quit 't

   ;; more agenda settings
   org-agenda-persistent-filter t
   org-agenda-sticky t

   org-todo-keywords '((sequence "TODO(t)" "SOMEDAY(s)" "|" "DONE(d)" "CANCELED(c)"))

   ;; use a bit better looking colors for todo faces
   org-todo-keyword-faces '(("TODO" . (:foreground "OrangeRed" :weight bold))
                            ("SOMEDAY" . (:foreground "GoldenRod" :weight bold))
                            ("DONE" . (:foreground "LimeGreen" :weight bold))
                            ("CANCELED" . (:foreground "gray" :weight bold)))

   ;; misc todo settings
   org-enforce-todo-dependencies t
   org-use-fast-todo-selection t
   org-fast-tag-selection-single-key nil

   ;; force me to write a note about the task when marking it done
   org-log-done 'note
   org-log-into-drawer t
   org-log-state-notes-insert-after-drawers nil

   ;; also log when items are rescheduled and refiled
   org-log-reschedule 'time
   org-log-refile     'time

   ;; prepend the filename for each org target
   org-refile-use-outline-path 'file

   ;; since we're using ivy just put all the files + headers in a list
   org-outline-path-complete-in-steps nil

   ;; try to minimize blank lines
   org-cycle-separator-lines 0
   org-blank-before-new-entry '((heading)
                                (plain-list-item . auto))

   org-return-follows-link t
   org-confirm-babel-evaluate nil)

  ;; auto save all org files after doing a common action
  (advice-add 'org-agenda-quit      :before #'org-save-all-org-buffers)
  ;; (advice-add 'org-agenda-schedule  :after #'org-save-all-org-buffers)
  (advice-add 'org-agenda-todo      :after #'org-save-all-org-buffers)
  (advice-add 'org-agenda-refile    :after #'org-save-all-org-buffers)
  (advice-add 'org-agenda-clock-in  :after #'org-save-all-org-buffers)
  ;; (advice-add 'org-agenda-clock-out :after #'org-save-all-org-buffers)

  ;; (advice-add 'org-deadline         :after #'org-save-all-org-buffers)
  ;; (advice-add 'org-schedule         :after #'org-save-all-org-buffers)
  ;; (advice-remove 'org-schedule  #'org-save-all-org-buffers)

  (advice-add 'org-todo             :after #'org-save-all-org-buffers)
  (advice-add 'org-refile           :after #'org-save-all-org-buffers)
  ;; (advice-add 'org-clock-in         :after #'org-save-all-org-buffers)
  ;; (advice-add 'org-clock-out        :after #'org-save-all-org-buffers)
  (advice-add 'org-store-log-note   :after #'org-save-all-org-buffers)

  ;; also, let's turn on auto-fill-mode
  (add-hook 'org-mode-hook 'auto-fill-mode))
