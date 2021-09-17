;;; PACKAGES ;;;
(require 'package)

(setq package-archives '(("melpa" . "https://melpa.org/packages/")
			 ("org" . "https://orgmode.org/elpa/")
			 ("elpa" . "https://elpa.gnu.org/packages/")))

(package-initialize)
(unless package-archive-contents
  (package-refresh-contents))

; Initialize use-package
(unless (package-installed-p 'use-package)
  (package-install 'use-package))
(require 'use-package)
(setq use-package-always-ensure t)

(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(custom-safe-themes
   '("47db50ff66e35d3a440485357fb6acb767c100e135ccdf459060407f8baea7b2" "4b0e826f58b39e2ce2829fab8ca999bcdc076dec35187bf4e9a4b938cb5771dc" default))
 '(package-selected-packages
   '(pipenv pyvenv docker-compose-mode undo-tree lsp-ivy evil-surround flycheck lsp-treemacs lsp-ui company-box company lsp-mode global-tags counsel-gtags evil-magit magit counsel-projectile projectile evil-collection evil evil-mode doom-themes ivy-rich which-key rainbow-delimiters doom-modeline counsel ivy use-package))
 '(safe-local-variable-values
   '((projectile-project-compilation-cmd "docker build --build-arg NEXUS_PYPI_USERNAME=$NEXUS_PYPI_USERNAME --build-arg NEXUS_PYPI_PASSWORD=$NEXUS_PYPI_PASSWORD -t $(basename $(realpath .)):latest ."))))
(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 )

;; Parse user env variables
(dolist (envvar (mapcar
		 (lambda (line)
		   (split-string
		    (replace-regexp-in-string "^export " "" line)
		    "=" t " "))
		 (with-temp-buffer
		   (insert-file-contents "~/.env")
		   (split-string (buffer-string) "\n" t)))
		)
  (apply 'setenv envvar))

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

; Ivy
(use-package ivy
  :diminish
  :bind (("C-s" . swiper)
	 :map ivy-minibuffer-map
	 ("TAB" . ivy-alt-done)
	 ("C-l" . ivy-alt-done)
	 :map ivy-switch-buffer-map
	 ("C-l" . ivy-done)
	 ("C-d" . ivy-switch-buffer-kill)
	 :map ivy-reverse-i-search-map
	 ("C-d" . ivy-reverse-i-search-kill))
  :config  (ivy-mode 1))
;  (setq ivy-use-virtual-buffers t)
 ; (setq ivy-wrap t)
  ;(setq ivy-count-format "(%d/%d) ")
					; (setq enable-recursive-minibuffers t))

; get a description of items in the list
(use-package ivy-rich
  :init (ivy-rich-mode 1))

; Counsel
(use-package counsel
  :bind (("M-x" . counsel-M-x)
	 ("C-x b" . counsel-ibuffer)
	 ("C-x C-f" . counsel-find-file)
	 :map minibuffer-local-map
	 ("C-r" . 'counsel-minibuffer-history)))

; show completions for multi key commands
(use-package which-key
  :init (which-key-mode)
  :diminish which-key-mode
  :config
  (setq which-key-idle-delay 1))

(use-package helpful
  :custom
  (counsel-describe-function-function #'helpful-callable)
  (counsel-describe-variable-function #'helpful-variable)
  :bind
  ([remap describe-function] . counsel-describe-function)
  ([remap describe-command] . helpful-command)
  ([remap describe-variable] . counsel-describe-variable)
  ([remap describe-key] . helpful-key))

;;; LOOKS ;;;
(setq inhibit-startup-message t)
(scroll-bar-mode -1)  ; disable scrollbar
(tool-bar-mode -1)    ; disable toolbar
(tooltip-mode -1)     ; disable tooltips
(set-fringe-mode 10)  ; give some breathing room
(menu-bar-mode -1)    ; disable menu bar

; set font
(set-face-attribute 'default nil :font "Fira Code Retina" :height 110)

(use-package doom-themes)
(load-theme 'doom-tomorrow-night t)

(use-package doom-modeline
  :ensure t
  :init (doom-modeline-mode 1)
  :custom ((doom-modeline-height 10)))

; add line numbers
(global-display-line-numbers-mode t)
(column-number-mode)

; disable line numbers for some modes
(dolist (mode '(org-mode-hook
		term-mode-hook
		eshell-mode-hook))
  (add-hook mode (lambda () (display-line-numbers-mode 0))))

; highlight delimiters
(show-paren-mode t)
(use-package rainbow-delimiters
  :hook (prog-mode . rainbow-delimiters-mode))

;;; KEY BINDINGS ;;;
(global-set-key (kbd "C-S-B") 'counsel-switch-buffer)

(use-package evil
  :init
  (setq evil-want-integration t)
  (setq evil-want-keybinding nil)
  (setq evil-want-C-u-scroll t)
  ;(setq evail-want-C-i-jump nil)
  :init (setq evil-want-keybinding nil) ; required by evil-collection
  :hook (evil-mode lambda () (
			      dolist (mode '(custom-mode
					     eshell-mode
					     git-rebase-mode
					     erc-mode
					     sauron-mode
					     term-mode))
			      (add-to-list 'evil-emacs-state-modes mode)))
  :config
  (evil-mode 1)
  (define-key evil-insert-state-map (kbd "C-g") 'evil-normal-state)

  ; correctly move inside a wrapped line
  (evil-global-set-key 'motion "j" 'evil-next-visual-line)
  (evil-global-set-key 'motion "k" 'evil-previous-visual-line)

  (evil-set-initial-state 'messages-buffer-mode 'normal)
  (evil-set-initial-state 'dashboard-mode 'normal))

(use-package evil-surround
  :after evil
  :config
  (global-evil-surround-mode 1))

(use-package evil-collection
  :after evil
  :config
  (evil-collection-init))

(use-package undo-tree
  :hook (evil-mode . undo-tree-mode)
  :config
  (setq evil-undo-system "undo-tree")
  (define-key evil-normal-state-map (kbd "u") 'undo-tree-undo)
  (define-key evil-normal-state-map (kbd "C-r") 'undo-tree-redo))

(use-package projectile
  :diminish projectile-mode
  :config (projectile-mode)
  :custom ((projectile-completion-system 'ivy))
  :bind-keymap
  ("C-c p" . projectile-command-map)
  :init
  (when (file-directory-p "~/Documents")
    (setq projectile-project-search-path '("~/Documents" "~/Stuff")))
  (setq projectile-switch-project-action #'projectile-dired))

(use-package counsel-projectile
  :config (counsel-projectile-mode))

(use-package magit
  ;:commands (magit-status magit-get-current-branch)
  :custom
  (magit-display-buffer-function #'magit-display-buffer-same-window-except-diff-v1))

(use-package lsp-mode
  :init
  (setq lsp-keymap-prefix "C-c l")
  :hook
  (python-mode . lsp)
  :config
  (lsp-enable-which-key-integration t)
  (setq lsp-pylsp-plugins-pydocstyle-enabled nil)
  (setq lsp-pylsp-plugins-flake8-enabled nil)
  (setq lsp-pylsp-plugins-flake8-max-line-length 120)
  :commands (lsp lsp-deferred))

(use-package lsp-ui
  :hook (lsp-mode . lsp-ui-mode)
  :config
  (lsp-ui-doc-hide)
  (setq lsp-idle-delay 0.2)
  (setq lsp-ui-sideline-show-diagnostics t)
  (setq lsp-ui-sideline-show-hover t)
  (setq lsp-ui-sideline-show-code-actions t)
  (setq lsp-ui-sideline-delay 0.2))

(with-eval-after-load 'lsp-mode
  (add-to-list 'lsp-file-watch-ignored-directories "[/\\\\]\\.venv\\'"))

(use-package lsp-ivy
  :commands
  (lsp-ivy-workspace-symbol))

(use-package company
  :after lsp-mode
  :hook (lsp-mode . company-mode)
  :bind
  (:map company-active-map
	("<tab>" . company-complete-selection))
  (:map lsp-mode-map
	("<tab>" . company-indent-or-complete-common))
  :custom
  (company-minimum-prefix-length 1)
  (company-idle-delay 0.2))

(use-package company-box
  :hook (company-mode . company-box-mode))

(use-package dockerfile-mode)
(use-package docker-compose-mode
  :config
  (setq projectile-project-compilation-cmd "docker-compose --ansi never build")
  (setq projectile-project-run-cmd "docker-compose --ansi never up -d")
  (setq projectile-project-configure-cmd "docker-compose --ansi never down"))

(use-package pipenv
  :hook (python-mode . pipenv-mode)
  :init
  (setq pipenv-projectile-after-switch-function #'pipenv-projectile-after-switch-extended))
