;;; $DOOMDIR/config.el -*- lexical-binding: t; -*-

;; Place your private configuration here! Remember, you do not need to run 'doom
;; sync' after modifying this file!


;; Some functionality uses this to identify you, e.g. GPG configuration, email
;; clients, file templates and snippets.
(setq user-full-name "Kristian Hartikainen"
      user-mail-address "kristian.hartikainen@gmail.com")

;; Doom exposes five (optional) variables for controlling fonts in Doom. Here
;; are the three important ones:
;;
;; + `doom-font'
;; + `doom-variable-pitch-font'
;; + `doom-big-font' -- used for `doom-big-font-mode'; use this for
;;   presentations or streaming.
;;
;; They all accept either a font-spec, font string ("Input Mono-12"), or xlfd
;; font string. You generally only need these two:
;; (setq doom-font (font-spec :family "monospace" :size 12 :weight 'semi-light)
;;       doom-variable-pitch-font (font-spec :family "sans" :size 13))

;; There are two ways to load a theme. Both assume the theme is installed and
;; available. You can either set `doom-theme' or manually load a theme with the
;; `load-theme' function. This is the default:
;; (setq doom-theme 'doom-one)
(setq doom-theme 'doom-gruvbox)

;; If you use `org' and don't want your org files in the default location below,
;; change `org-directory'. It must be set before org loads!
(setq org-directory "~/org/")

;; This determines the style of line numbers in effect. If set to `nil', line
;; numbers are disabled. For relative line numbers, set this to `relative'.
(setq display-line-numbers-type t)


;; Here are some additional functions/macros that could help you configure Doom:
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

(after! (yasnippet)
  (set-file-templates!
   `(("/.+\.rs$" :trigger "__.rs" :mode 'rust-mode)
    ("/__init__\.py$" :trigger "____init__.py" :mode 'python-mode)
    ("/.+\.py$" :trigger "__.py" :mode 'python-mode))))
