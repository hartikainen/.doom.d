;;; $DOOMDIR/config.el -*- lexical-binding: t; -*-

;; Place your private configuration here! Remember, you do not need to run 'doom
;; sync' after modifying this file!


;; Some functionality uses this to identify you, e.g. GPG configuration, email
;; clients, file templates and snippets. It is optional.
(setq user-full-name "Kristian Hartikainen"
      user-mail-address "kristian.hartikainen@gmail.com")

;; Doom exposes five (optional) variables for controlling fonts in Doom:
;;
;; - `doom-font' -- the primary font to use
;; - `doom-variable-pitch-font' -- a non-monospace font (where applicable)
;; - `doom-big-font' -- used for `doom-big-font-mode'; use this for
;;   presentations or streaming.
;; - `doom-symbol-font' -- for symbols
;; - `doom-serif-font' -- for the `fixed-pitch-serif' face
;;
;; See 'C-h v doom-font' for documentation and more examples of what they
;; accept. For example:
;;
;;(setq doom-font (font-spec :family "Fira Code" :size 12 :weight 'semi-light)
;;      doom-variable-pitch-font (font-spec :family "Fira Sans" :size 13))
;;
;; If you or Emacs can't find your font, use 'M-x describe-font' to look them
;; up, `M-x eval-region' to execute elisp code, and 'M-x doom/reload-font' to
;; refresh your font settings. If Emacs still can't find your font, it likely
;; wasn't installed correctly. Font issues are rarely Doom issues!

;; There are two ways to load a theme. Both assume the theme is installed and
;; available. You can either set `doom-theme' or manually load a theme with the
;; `load-theme' function. This is the default:
;; (setq doom-theme 'doom-one)
(setq doom-theme 'doom-gruvbox)

;; This determines the style of line numbers in effect. If set to `nil', line
;; numbers are disabled. For relative line numbers, set this to `relative'.
(setq display-line-numbers-type t)

;; If you use `org' and don't want your org files in the default location below,
;; change `org-directory'. It must be set before org loads!
(setq org-directory "~/org/")


;; Whenever you reconfigure a package, make sure to wrap your config in an
;; `after!' block, otherwise Doom's defaults may override your settings. E.g.
;;
;;   (after! PACKAGE
;;     (setq x y))
;;
;; The exceptions to this rule:
;;
;;   - Setting file/directory variables (like `org-directory')
;;   - Setting variables which explicitly tell you to set them before their
;;     package is loaded (see 'C-h v VARIABLE' to look up their documentation).
;;   - Setting doom variables (which start with 'doom-' or '+').
;;
;; Here are some additional functions/macros that will help you configure Doom.
;;
;; - `load!' for loading external *.el files relative to this one
;; - `use-package!' for configuring packages
;; - `after!' for running code after a package has loaded
;; - `add-load-path!' for adding directories to the `load-path', relative to
;;   this file. Emacs searches the `load-path' when you load packages with
;;   `require' or `use-package'.
;; - `map!' for binding new keys
;;
;; To get information about any of these functions/macros, move the cursor over
;; the highlighted symbol at press 'K' (non-evil users must press 'C-c c k').
;; This will open documentation for it, including demos of how they are used.
;; Alternatively, use `C-h o' to look up a symbol (functions, variables, faces,
;; etc).
;;
;; You can also try 'gd' (or 'C-c c d') to jump to their definition and see how
;; they are implemented.

(load! "functions.el")


(after! conda
  (setq conda-env-home-directory (expand-file-name "~/conda/")
        conda-anaconda-home (expand-file-name "~/conda/")))

(after! flycheck
  (set-face-attribute 'flycheck-warning nil
                      :background nil
                      :foreground "red"
                      :underline '(:color "red" :style wave))
  (set-face-attribute 'flycheck-error nil
                      :background nil
                      :foreground "red"
                      :underline t))

(defun beginning-or-indentation (&optional n)
  "Move cursor to beginning of this line or to its indentation.
If at indentation position of this line, move to beginning of line.
If at beginning of line, move to beginning of previous line.
Else, move to indentation position of this line.

With arg N, move backward to the beginning of the Nth previous line.
Interactively, N is the prefix arg."
  (interactive "P")
  (let ((previous-point (point)))
    (back-to-indentation)
    (if (equal (point) previous-point) (move-beginning-of-line 1)))
  )

(map! :gi "C-a" #'beginning-or-indentation)

(after! ws-butler
  (setq ws-butler-keep-whitespace-before-point nil))

(after! ivy
  (define-key ivy-minibuffer-map (kbd "TAB") #'ivy-partial-or-done))

(after! (projectile persp-mode)
  (setq projectile-project-search-path '(("~/github" . 2)))
  ;; (setq +workspaces-switch-project-function #'magit-status)
  (setq +workspaces-switch-project-function (lambda (&rest _) (call-interactively #'projectile-commander))))

(after! yasnippet
  ;; Define custom yasnippet-related functions
  (defun yas-with-comment (str)
    (format "%s%s%s" (or comment-start "# ") str (or comment-end "")))
  (setq yas-indent-line 'fixed)
  (set-file-template! ".+\\.rs$" :trigger "__.rs" :mode 'rust-mode)
  (set-file-template! ".+\\.py$" :trigger "default_runnable" :mode 'python-mode)
  (set-file-template! ".+_test\\.py$" :trigger "absl_test" :mode 'python-mode)
  (set-file-template! "__init__\\.py$" :trigger "____init__.py" :mode 'python-mode))

;; accept completion from copilot and fallback to company
(use-package! copilot
  :hook (prog-mode . copilot-mode)
  :bind (:map copilot-completion-map
              ("<tab>" . 'copilot-accept-completion)
              ("TAB" . 'copilot-accept-completion)
              ("C-TAB" . 'copilot-accept-completion-by-word)
              ("C-<tab>" . 'copilot-accept-completion-by-word)
              ("C-n" . 'copilot-next-completion)
              ("C-p" . 'copilot-previous-completion)))

(use-package! bazel-mode
  :defer t
  :commands bazel-mode
  :init
  (add-to-list 'auto-mode-alist '("BUILD\\(\\.bazel\\)?\\'" . bazel-mode) t)
  (add-to-list 'auto-mode-alist '("WORKSPACE\\'" . bazel-mode) t)
  :config
  ;; disable format-all because it doesn't sort BUILD list variables
  (setq bazel-mode-buildifier-before-save t)
  (appendq! +format-on-save-enabled-modes '(bazel-mode)))

(after! (:and apheleia python)
  (setf (alist-get 'python-mode apheleia-mode-alist) '(ruff-isort ruff))
  (setf (alist-get 'python-ts-mode apheleia-mode-alist) '(ruff-isort ruff)))

(after! python
  (add-hook! 'python-mode-hook #'flymake-ruff-load))

(after! eglot
  (add-to-list 'eglot-server-programs
               '((python-mode python-ts-mode)
                 "basedpyright-langserver" "--stdio")))

(use-package! gptel
  :config
  (setq auth-sources '("~/.authinfo.gpg" "~/.authinfo"))

  ;; --- Backend Configuration ---
  (setq gptel-backend (gptel-make-gemini "Gemini"
                        :key (auth-source-pick-first-password :host "generativelanguage.googleapis.com")
                        :stream t))

  ;; --- Model Selection ---
  ;; Set your preferred default model. You can easily switch models interactively.
  (setq gptel-model 'gemini-2.5-pro)

  ;; --- User Experience Tweaks ---
  ;; Automatically scroll to the end of the response as it's being generated
  ;; (setq gptel-streaming-scroll-to-end t)

  ;; Use a transient menu for gptel commands for a more interactive experience
  (setq gptel-use-transient t)
  (setq gptel-include-reasoning nil)

  ;; --- Keybindings ---
  ;; Bind gptel-send to a convenient key combination
  ;; (map! :leader
  ;;       :prefix ("x" . "XXX")
  ;;       "g" #'gptel-send)
  )
