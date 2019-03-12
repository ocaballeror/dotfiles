(require 'package)

(add-to-list 'package-archives '("org" . "http://orgmode.org/elpa/"))
(add-to-list 'package-archives '("melpa" . "http://melpa.org/packages/"))
(add-to-list 'package-archives '("melpa-stable" . "http://stable.melpa.org/packages/"))

(setq package-enable-at-startup nil)
;(package-refresh-contents)
(package-initialize)

;(require 'evil)
;(evil-mode 1)

(unless (package-installed-p 'use-package)
  (package-refresh-contents)
  (package-install 'use-package))

(eval-when-compile
  (require 'use-package))

(use-package helm
    :ensure t)

(use-package evil
  :ensure t
  :config

  (evil-mode 1)

  ;; Keep some basic keybindings in occur mode
  (add-hook 'occur-mode-hook
    (lambda()
      (evil-add-hjkl-bindings occur-mode-map 'emacs
	(kbd "/")       'evil-search-forward
	(kbd "n")       'evil-search-next
	(kbd "N")       'evil-search-previous
	(kbd "C-d")     'evil-scroll-down
	(kbd "C-u")     'evil-scroll-up
	(kbd "C-w C-w") 'other-window)))

  ;; Evil plugins
  (use-package evil-easymotion
    :ensure t)

  (use-package evil-leader
    :ensure t
    :config
	(global-evil-leader-mode)
    (evil-leader/set-leader ",")
    (evil-leader/set-key "f" 'evil-window-down)
    (evil-leader/set-key "d" 'evil-window-up)
    (evil-leader/set-key "g" 'evil-window-right)
    (evil-leader/set-key "s" 'evil-window-left)

    (evil-leader/set-key "e" 'evil-window-down)
    (evil-leader/set-key "w" (evilem-create 'next-line))
  )

  (use-package evil-surround
    :ensure t
	:config
	(global-evil-surround-mode 1))
  (use-package evil-matchit
    :ensure t
    :config
    (global-evil-matchit-mode 1)))
  (use-package evil-tabs
    :ensure t
    :config
    (global-evil-tabs-mode t))


;; Save bookmarks between sessions
(setq bookmark-default-file "~/.emacs.d/bookmarks"
      bookmark-save-flage 1) ;; save after every change

;; Some settings regarding backup files
(setq version-control t     ;; Use version numbers for backups.
      kept-new-versions 10  ;; Number of newest versions to keep.
      kept-old-versions 0   ;; Number of oldest versions to keep.
      delete-old-versions t ;; Don't ask to delete excess backup versions.
      backup-by-copying t)  ;; Copy all files, don't rename them.
(setq vc-make-backup-files t) ;; Also backup versioned files

;; Default and per-save backups go here:
(setq backup-directory-alist '(("" . "~/.emacs.d/backup/per-save")))

(defun force-backup-of-buffer ()
  ;; Make a special "per session" backup at the first save of each
  ;; emacs session.
  (when (not buffer-backed-up)
    ;; Override the default parameters for per-session backups.
    (let ((backup-directory-alist '(("" . "~/.emacs.d/backup/per-session")))
          (kept-new-versions 3))
      (backup-buffer)))
  ;; Make a "per save" backup on each save.  The first save results in
  ;; both a per-session and a per-save backup, to keep the numbering
  ;; of per-save backups consistent.
  (let ((buffer-backed-up nil))
    (backup-buffer)))

(add-hook 'before-save-hook  'force-backup-of-buffer)


;; Set the default window size
(if window-system
  (progn
    ;; use 120 char wide window for largeish displays
    ;; and smaller 80 column windows for smaller displays
    ;; pick whatever numbers make sense for you
    (if (> (x-display-pixel-width) 1280)
           (add-to-list 'default-frame-alist (cons 'width 200))
           (add-to-list 'default-frame-alist (cons 'width 80)))
    (if (> (x-display-pixel-width) 720)
           (add-to-list 'default-frame-alist (cons 'width 140))
           (add-to-list 'default-frame-alist (cons 'width 60)))))
    ;; for the height, subtract a couple hundred pixels
    ;; from the screen height (for panels, menubars and
    ;; whatnot), then divide by the height of a char to
    ;; get the height we want
    ;(add-to-list 'default-frame-alist
    ;     (cons 'height (/ (- (x-display-pixel-height) 200)
    ;                         (frame-char-height))))))

;; Relative line numbers
(use-package linum-relative
  :ensure t
  :config
  (linum-relative-global-mode))


;; Change the color of the cursor in the different evil modes
(setq evil-emacs-state-cursor '("red" box))
(setq evil-normal-state-cursor '("green" box))
(setq evil-visual-state-cursor '("orange" box))
(setq evil-insert-state-cursor '("blue" bar))
(setq evil-replace-state-cursor '("red" bar))
(setq evil-operator-state-cursor '("red" hollow))

;; Some key rebindings that I'm used to from vim
(evil-define-key 'normal global-map (kbd "SPC") 'evil-toggle-fold)
(evil-define-key 'normal global-map (kbd "C-j") 'evil-toggle-fold)
(evil-define-key 'normal global-map (kbd "C-k") 'evil-toggle-fold)

;;; Some other keybindings because why the hell not

;; Move the current line up or down with M-Up or M-Down
(defun move-line (n)
  "Move the current line up or down by N lines."
  (interactive "p")
  (setq col (current-column))
  (beginning-of-line) (setq start (point))
  (end-of-line) (forward-char) (setq end (point))
  (let ((line-text (delete-and-extract-region start end)))
    (forward-line n)
    (insert line-text)
    ;; restore point to original column in moved line
    (forward-line -1)
    (forward-char col)))

(defun move-line-up (n)
  "Move the current line up by N lines."
  (interactive "p")
  (move-line (if (null n) -1 (- n))))

(defun move-line-down (n)
  "Move the current line down by N lines."
  (interactive "p")
  (move-line (if (null n) 1 n)))

(global-set-key (kbd "M-<up>") 'move-line-up)
(global-set-key (kbd "M-<down>") 'move-line-down)

;; Set maximum line length
(setq-default fill-column 80)
(add-hook 'text-mode-hook 'turn-on-auto-fill)

;; Enable tabs in evil mode
(define-key evil-normal-state-map (kbd "C-0") (lambda() (interactive) (elscreen-goto 0)))
(define-key evil-normal-state-map (kbd "C-1") (lambda() (interactive) (elscreen-goto 1)))
(define-key evil-normal-state-map (kbd "C-2") (lambda() (interactive) (elscreen-goto 2)))
(define-key evil-normal-state-map (kbd "C-3") (lambda() (interactive) (elscreen-goto 3)))
(define-key evil-normal-state-map (kbd "C-4") (lambda() (interactive) (elscreen-goto 4)))
(define-key evil-normal-state-map (kbd "C-5") (lambda() (interactive) (elscreen-goto 5)))
(define-key evil-normal-state-map (kbd "C-6") (lambda() (interactive) (elscreen-goto 6)))
(define-key evil-normal-state-map (kbd "C-7") (lambda() (interactive) (elscreen-goto 7)))
(define-key evil-normal-state-map (kbd "C-8") (lambda() (interactive) (elscreen-goto 8)))
(define-key evil-normal-state-map (kbd "C-9") (lambda() (interactive) (elscreen-goto 9)))
(define-key evil-insert-state-map (kbd "C-0") (lambda() (interactive) (elscreen-goto 0)))
(define-key evil-insert-state-map (kbd "C-1") (lambda() (interactive) (elscreen-goto 1)))
(define-key evil-insert-state-map (kbd "C-2") (lambda() (interactive) (elscreen-goto 2)))
(define-key evil-insert-state-map (kbd "C-3") (lambda() (interactive) (elscreen-goto 3)))
(define-key evil-insert-state-map (kbd "C-4") (lambda() (interactive) (elscreen-goto 4)))
(define-key evil-insert-state-map (kbd "C-5") (lambda() (interactive) (elscreen-goto 5)))
(define-key evil-insert-state-map (kbd "C-6") (lambda() (interactive) (elscreen-goto 6)))
(define-key evil-insert-state-map (kbd "C-7") (lambda() (interactive) (elscreen-goto 7)))
(define-key evil-insert-state-map (kbd "C-8") (lambda() (interactive) (elscreen-goto 8)))
(define-key evil-insert-state-map (kbd "C-9") (lambda() (interactive) (elscreen-goto 9)))

;; Auto enable ggtags mode
(add-hook 'c-mode-common-hook
    (lambda ()
	(when (derived-mode-p 'c-mode 'c++-mode 'java-mode)
	    (ggtags-mode 1))))


;; Flycheck
(use-package flycheck
  :ensure t
  :config

  (setq flycheck-check-syntax-automatically '(save mode-enabled))
  (setq flycheck-checkers (delq 'emacs-lisp-checkdoc flycheck-checkers))
  (setq flycheck-checkers (delq 'html-tidy flycheck-checkers))
  (setq flycheck-standard-error-navigation nil)

  (global-flycheck-mode t))

;; Some org mode options
(require 'org)
(define-key global-map "\C-cl" 'org-store-link)
(define-key global-map "\C-ca" 'org-agenda)
(setq org-startup-truncated nil) ;; Enable line wrapping
(setq org-log-done t)

;; web-mode and default filetypes
(use-package web-mode :ensure t)
(add-to-list 'auto-mode-alist '("\\.phtml\\'" . web-mode))
(add-to-list 'auto-mode-alist '("\\.tpl\\.php\\'" . web-mode))
(add-to-list 'auto-mode-alist '("\\.[agj]sp\\'" . web-mode))
(add-to-list 'auto-mode-alist '("\\.as[cp]x\\'" . web-mode))
(add-to-list 'auto-mode-alist '("\\.erb\\'" . web-mode))
(add-to-list 'auto-mode-alist '("\\.mustache\\'" . web-mode))
(add-to-list 'auto-mode-alist '("\\.djhtml\\'" . web-mode))
(add-to-list 'auto-mode-alist '("\\.html?\\'" . web-mode))
(add-to-list 'auto-mode-alist '("\\.js\\'" . web-mode))
(add-to-list 'auto-mode-alist '("\\.css\\'" . web-mode))

;; Automatically open latex preview pane with .tex files
(use-package latex-preview-pane
  :ensure t
  :config (latex-preview-pane-enable))

(setq web-mode-engines-alist
      '(("php"   . "\\.phtml\\'")
	("blade" . "\\.blade\\'")))

(use-package ac-html :ensure t)
(use-package ac-html-csswatcher :ensure t)
(use-package ac-php  :ensure t)

(setq web-mode-enable-auto-pairing t)
(setq web-mode-enable-css-colorization t)
(setq web-mode-ac-sources-alist
      '(("css"  . (ac-source-css-property))
	("html" . (acsource-words-in-buffer ac-source-abbrev))))

;; PHP configuration for webmode
(defun setup-webmode-php ()
  ;; enable web mode
  (web-mode)

  ;; make these variables local
  (make-local-variable 'web-mode-code-indent-offset)
  (make-local-variable 'web-mode-markup-indent-offset)
  (make-local-variable 'web-mode-css-indent-offset)

  ;; set indentation, can set different indentation levels for different code types
  (setq web-mode-code-indent-offset 4)
  (setq web-mode-css-indent-offset 2)
  (setq web-mode-markup-indent-offset 2)

  (flycheck-select-checker php)
  (flycheck-mode t))

(add-to-list 'auto-mode-alist '("\\.php$" . setup-webmode-php))

(flycheck-define-checker php
  "Make flycheck work with webmode using the cli interpreter"

  :command ("php" "-1" "-d" "error_reporting=E_ALL" "-d" "display_errors=1" "-d" "log_errors=0" source)
  :error-patterns
  ((error line-start (or "Parse" "Fatal" "syntax") " error" (any ":" ",") " "
	  (message) " in " (file-name) " on line " line line-end))
  :modes (web-mode))


(use-package org-bullets :ensure t)
(add-hook 'org-mode-hook
	  (lambda ()
	    (org-bullets-mode t)))
(setq org-hide-leading-stars t)


;; Use j/k for moving between wrapped lines
(define-key evil-normal-state-map (kbd "j") 'evil-next-visual-line)
(define-key evil-normal-state-map (kbd "k") 'evil-previous-visual-line)

;; Use ESC to quit (easier than C-g)
(defun minibuffer-keyboard-quit ()
  "Abort recursive edit.
In Delete Selection mode, if the mark is active, just deactivate it;
then it takes a second \\[keyboard-quit] to abort the minibuffer."
  (interactive)
  (if (and delete-selection-mode transient-mark-mode mark-active)
      (setq deactivate-mark  t)
    (when (get-buffer "*Completions*") (delete-windows-on "*Completions*"))
    (abort-recursive-edit)))
(define-key evil-normal-state-map [escape] 'keyboard-quit)
(define-key evil-visual-state-map [escape] 'keyboard-quit)
(define-key minibuffer-local-map [escape] 'minibuffer-keyboard-quit)
(define-key minibuffer-local-ns-map [escape] 'minibuffer-keyboard-quit)
(define-key minibuffer-local-completion-map [escape] 'minibuffer-keyboard-quit)
(define-key minibuffer-local-must-match-map [escape] 'minibuffer-keyboard-quit)
(define-key minibuffer-local-isearch-map [escape] 'minibuffer-keyboard-quit)
(global-set-key [escape] 'evil-exit-emacs-state)

;; Apply my indentation settings to every file I open
(use-package dtrt-indent :ensure t)
(dtrt-indent-mode 1)

;; Auto indent new line on Enter
(define-key global-map (kbd "RET") 'newline-and-indent)

;; Show matching parentheses/brackets/whatever
(show-paren-mode t)

;; Dont move back the cursor one position when exiting insert mode
(setq save-place-file "~/.emacs.d/saveplace")
(setq-default save-place t)
(require 'saveplace)


(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(ansi-color-faces-vector
   [default default default italic underline success warning error])
 '(ansi-color-names-vector
   ["#242424" "#e5786d" "#95e454" "#cae682" "#8ac6f2" "#333366" "#ccaa8f" "#f6f3e8"])
 '(custom-safe-themes
   (quote
    ("628278136f88aa1a151bb2d6c8a86bf2b7631fbea5f0f76cba2a0079cd910f7d" "1b8d67b43ff1723960eb5e0cba512a2c7a2ad544ddb2533a90101fd1852b426e" "bb08c73af94ee74453c90422485b29e5643b73b05e8de029a6909af6a3fb3f58" "10e231624707d46f7b2059cc9280c332f7c7a530ebc17dba7e506df34c5332c4" "84d2f9eeb3f82d619ca4bfffe5f157282f4779732f48a5ac1484d94d5ff5b279" "3c83b3676d796422704082049fc38b6966bcad960f896669dfc21a7a37a748fa" default)))
 '(display-time-24hr-format nil)
 '(display-time-day-and-date t)
 '(doc-view-continuous t)
 '(focus-follows-mouse t)
 '(inhibit-startup-screen t)
 '(latex-preview-pane-multifile-mode (quote off))
 '(menu-bar-mode nil)
 '(package-selected-packages
   (quote
    (zoom ggtags latex-preview-pane px htmlize markdown-mode+ markdown-preview-mode org-bullets org-evil powerline-evil evil-surround evil-leader powerline org helm use-package evil)))
 '(pdf-latex-command "pdflatex")
 '(scroll-bar-mode nil)
 '(shell-escape-mode "-shell-escape")
 '(size-indication-mode t)
 '(tool-bar-mode nil))
(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(default ((t (:inherit nil :stipple nil :inverse-video nil :box nil :strike-through nil :overline nil :underline nil :slant normal :weight normal :height 95 :width normal :foundry "PfEd" :family "DejaVu Sans Mono")))))


(defconst user-init-dir
  (cond ((boundp 'user-emacs-directory)
	 user-emacs-directory)
	((boundp 'user-init-directory)
	 user-init-directory)
	(t "~/.emacs.d/")))


(defun load-user-file (file)
  (interactive "f")
  "Load a file in current user's configuration directory"
  (load-file (expand-file-name file user-init-dir)))

(load-user-file "init-colors.el")
