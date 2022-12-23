;;; me-ui.el --- UI stuff -*- lexical-binding: t; -*-

;; Copyright (C) 2022  Abdelhak Bougouffa

;; Author: Abdelhak Bougouffa <abougouffa@fedoraproject.org>


(when (< emacs-major-version 29)
  (use-package emojify
    :straight t
    :after minemacs-loaded
    :general
    (+map "ie" '(emojify-insert-emoji :wk "Emoji"))
    :custom
    (emojify-emoji-set "emojione-v2.2.6")
    (emojify-emojis-dir (concat minemacs-cache-dir "emojify/emojis/"))
    (emojify-display-style 'image)
    :config
    (global-emojify-mode 1)))

(use-package svg-lib
  :straight t
  :defer t
  :custom
  (svg-lib-icons-dir (concat minemacs-cache-dir "svg-lib/icons/")))

(use-package writeroom-mode
  :straight t
  :general
  (+map "tw" #'writeroom-mode)
  :init
  (defvar +writeroom-text-scale 1.7
    "The text-scaling level for `writeroom-mode'.")
  :custom
  (writeroom-width 80)
  (writeroom-mode-line t)
  (writeroom-global-effects nil)
  (writeroom-maximize-window nil)
  (writeroom-fullscreen-effect 'maximized)
  :config
  (require 'mixed-pitch)
  (add-hook
   'writeroom-mode-hook
   (defun +writeroom--enable-mixed-pitch-mode-h ()
     "Enable `mixed-pitch-mode' when in supported modes."
     (when (apply #'derived-mode-p '(adoc-mode rst-mode markdown-mode org-mode))
       (mixed-pitch-mode (if writeroom-mode 1 -1)))))

  (add-hook
   'writeroom-mode-hook
   (defun +writeroom--enable-text-scaling-mode-h ()
     "Enable text scaling."
     (when (/= +writeroom-text-scale 0.0)
       (text-scale-set (if writeroom-mode +writeroom-text-scale 0.0))
       (visual-fill-column-adjust))))

  (defvar-local +writeroom-line-num-was-activate-p nil)
  (defvar-local +writeroom-org-format-latex-scale nil)

  ;; Disable line numbers when in Org mode
  (add-hook
   'writeroom-mode-enable-hook
   (defun +writeroom--disable-line-numbers-mode-h ()
     (when (and (or (derived-mode-p 'org-mode)
                    (derived-mode-p 'markdown-mode))
                (bound-and-true-p display-line-numbers-mode))
       (setq-local +writeroom-line-num-was-activate-p display-line-numbers-type)
       (display-line-numbers-mode -1))))

  (add-hook
   'writeroom-mode-disable-hook
   (defun +writeroom--restore-line-numbers-mode-h ()
     (when (and (or (derived-mode-p 'org-mode)
                    (derived-mode-p 'markdown-mode))
                +writeroom-line-num-was-activate-p)
       (display-line-numbers-mode +writeroom-line-num-was-activate-p))))

  (with-eval-after-load 'org
    ;; Increase latex previews scale in Zen mode
    (add-hook 'writeroom-mode-enable-hook
              (defun +writeroom--scale-up-latex-h ()
                (setq-local +writeroom-org-format-latex-scale
                            (plist-get org-format-latex-options :scale))
                (setq org-format-latex-options
                      (plist-put org-format-latex-options
                                 :scale (if (+emacs-features-p 'pgtk) 1.4 2.1)))))

    (add-hook 'writeroom-mode-disable-hook
              (defun +writeroom--scale-down-latex-h ()
                (setq org-format-latex-options
                      (plist-put org-format-latex-options
                                 :scale (or +writeroom-org-format-latex-scale 1.0)))))))

(use-package mixed-pitch
  :straight t
  :general
  (+map "tm" #'mixed-pitch-mode)
  :custom
  (mixed-pitch-variable-pitch-cursor t)
  :config
  (setq mixed-pitch-fixed-pitch-faces
        (delete-dups
         (append mixed-pitch-fixed-pitch-faces
                 '(org-date
                   org-footnote
                   org-drawer
                   org-special-keyword
                   org-property-value
                   org-cite-key
                   org-ref-cite-face
                   org-tag
                   org-tag-group
                   org-block
                   org-inline-src-block
                   org-todo-keyword-todo
                   org-latex-and-related
                   org-macro
                   org-link
                   org-todo-keyword-habt
                   org-todo-keyword-done
                   org-todo-keyword-wait
                   org-todo-keyword-kill
                   org-todo-keyword-outd
                   org-todo
                   org-done
                   font-lock-comment-face)))))

(use-package focus
  :straight t
  :general
  (+map "tF" #'focus-mode))


(provide 'me-ui)
