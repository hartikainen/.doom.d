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

(after! multiple-cursors
  (dolist (cmd '(;; motion (incl. your custom C-a)
                 beginning-or-indentation
                 back-to-indentation
                 move-beginning-of-line
                 move-end-of-line
                 forward-word
                 backward-word
                 forward-sexp
                 backward-sexp
                 ;; newlines / indentation
                 newline
                 newline-and-indent
                 electric-newline-and-maybe-indent
                 open-line
                 indent-for-tab-command
                 ;; python-specific indent
                 python-indent-shift-left
                 python-indent-shift-right
                 python-indent-dedent-line-backspace
                 ;; markdown
                 markdown-outdent-or-delete
                 ;; kill / delete
                 kill-line
                 kill-whole-line
                 kill-region
                 kill-ring-save
                 kill-word
                 backward-kill-word
                 delete-char
                 delete-forward-char
                 delete-backward-char
                 ;; yank
                 yank
                 yank-pop
                 ;; transforms
                 upcase-word
                 downcase-word
                 capitalize-word
                 transpose-chars
                 transpose-words
                 ;; comments
                 comment-line
                 comment-dwim))
    (add-to-list 'mc/cmds-to-run-for-all cmd))

  (dolist (cmd '(;; files / buffers / windows
                 save-buffer
                 other-window
                 balance-windows
                 ;; command dispatch & escape
                 execute-extended-command
                 doom/escape
                 keyboard-escape-quit
                 keyboard-quit
                 ;; completion popups should not multiply
                 completion-at-point
                 copilot-accept-completion
                 copilot-accept-completion-by-word
                 copilot-next-completion
                 copilot-previous-completion
                 ;; undo/redo behaves better as a single global operation
                 undo-fu-only-undo
                 undo-fu-only-redo))
    (add-to-list 'mc/cmds-to-run-once cmd)))


(after! flycheck
  (set-face-attribute 'flycheck-warning nil
                      :background nil
                      :foreground "red"
                      :underline '(:color "red" :style wave))
  (set-face-attribute 'flycheck-error nil
                      :background nil
                      :foreground "red"
                      :underline t))

;; Disable flymake-popon's at-point popup (didn't like how it rendered in the
;; terminal). Diagnostics still show in the echo area via eldoc and in the list
;; from `flymake-show-buffer-diagnostics'.
(remove-hook 'flymake-mode-hook #'flymake-popon-mode)

(after! grep
  (add-to-list 'grep-find-ignored-directories ".venv"))

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
    (if (equal (point) previous-point) (move-beginning-of-line 1))))

(map! :gi "C-a" #'beginning-or-indentation)

(after! ws-butler
  (setq ws-butler-keep-whitespace-before-point nil))

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
(defun my/copilot-safe-turn-on ()
  "Enable copilot in the current buffer without ever breaking other hooks.
Skips activation when prerequisites (node, the copilot package) are
missing, and demotes any activation error to a `*Messages*' log entry
so that the rest of `prog-mode-hook' (font-lock, lsp, etc.) still runs."
  (when (and (executable-find "node")
             (require 'copilot nil 'noerror))
    (with-demoted-errors "copilot-mode failed: %S"
      (copilot-mode 1))
    (when (fboundp 'copilot-nes-mode)
      (with-demoted-errors "copilot-nes-mode failed: %S"
        (copilot-nes-mode 1)))))

(use-package! copilot
  :hook (prog-mode . my/copilot-safe-turn-on)
  :bind (:map copilot-completion-map
              ("<tab>" . 'copilot-accept-completion)
              ("TAB" . 'copilot-accept-completion)
              ("C-TAB" . 'copilot-accept-completion-by-word)
              ("C-<tab>" . 'copilot-accept-completion-by-word)
              ("C-n" . 'copilot-next-completion)
              ("C-p" . 'copilot-previous-completion))
  :config
  (setq copilot-chat-model "claude-opus-4-7")
  (add-to-list 'copilot-disable-predicates
               (lambda () (or (minibufferp)
                              (derived-mode-p 'vterm-mode)))))

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

(after! python
  (add-hook! 'python-mode-hook #'flymake-ruff-load)
  ;; Pin formatting to ruff (sort imports, then format). Set explicitly so
  ;; eglot/`ty' doesn't take over formatting via `+format-with-lsp-toggle-h'.
  (setq-hook! '(python-mode-hook python-ts-mode-hook)
    +format-with '(ruff-isort ruff)))

(set-eglot-client! '(python-mode python-ts-mode) '("ty" "server"))

(use-package! gptel
  :config
  (setq auth-sources '("~/.authinfo.gpg" "~/.authinfo"))

  ;; --- Backend Configuration ---
  (setq gptel-backend (gptel-make-gemini "Gemini"
                        :key (auth-source-pick-first-password :host "generativelanguage.googleapis.com")
                        :stream t))

  ;; --- Model Selection ---
  ;; Set your preferred default model. You can easily switch models interactively.
  (setq gptel-model 'gemini-3.1-pro-preview)

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

;; Workaround: `yaml-ts-mode' (Emacs 29+) does not define `yaml-indent-offset',
;; which causes errors in packages like `dtrt-indent' and `editorconfig'.
(defvar yaml-indent-offset 2 "Fallback for packages expecting yaml-mode variables in yaml-ts-mode.")

(after! tramp
  (setq tramp-verbose 1)  ;; Quiet TRAMP down
  (setq tramp-default-remote-shell "/bin/sh")
  (setq tramp-use-ssh-controlmaster-options nil) ;; Use your ~/.ssh/config settings instead
  ;; Disable version control (VC) on remote files to stop TRAMP from checking Git status constantly.
  ;; Guard so repeated `doom/reload's don't keep appending the same regexp.
  (unless (string-match-p (regexp-quote tramp-file-name-regexp) vc-ignore-dir-regexp)
    (setq vc-ignore-dir-regexp
          (format "%s\\|%s" vc-ignore-dir-regexp tramp-file-name-regexp)))
  ;; Enable direct async processes for ALL TRAMP connections. This is the big
  ;; win for magit/compile/LSP, which spawn many short-lived remote processes;
  ;; without it each one pays for a fresh remote shell.
  (connection-local-set-profile-variables
   'tramp-fast-connection
   '((tramp-direct-async-process . t)))
  (connection-local-set-profiles
   '(:application tramp)
   'tramp-fast-connection)
  ;; Keep temp files on the remote's /tmp instead of copying them back to the
  ;; Mac. Scoped to the eka hosts (the machines actually in use).
  (add-to-list 'tramp-connection-properties
               (list "eka-" "tmpdir" "/tmp")))

(defun my-tramp-optimization-hacks ()
  "Disable expensive UI features in TRAMP buffers."
  (when (file-remote-p default-directory)
    ;; 1. Disable Flymake/Flycheck (syntax checking)
    (flymake-mode -1)
    (when (fboundp 'flycheck-mode) (flycheck-mode -1))

    ;; 2. Disable Copilot (huge source of lag on remote)
    (when (fboundp 'copilot-mode) (copilot-mode -1))

    ;; 3. Disable Eldoc (the little help messages in the bottom bar)
    (eldoc-mode -1)

    ;; 4. Stop LSP from trying to manage the remote file if it's slow
    ;; (Optional: only if you still see jsonrpc in the profiler)
    ;; (lsp-disconnect)
    ))

;; Apply these hacks every time a new file is opened
(add-hook 'find-file-hook #'my-tramp-optimization-hacks)

(after! recentf
  ;; Keep remote files in the recent list WITHOUT stat-ing them. Otherwise
  ;; recentf's periodic cleanup tries to connect to every remembered remote
  ;; host; a slow/unreachable one then blocks Emacs for seconds at a time.
  (add-to-list 'recentf-keep 'file-remote-p))

(after! gcmh
  (setq gcmh-idle-delay 'auto  ; Let it decide when to GC
        gcmh-high-read-threshold (* 128 1024 1024))) ; 128MB

(after! doom-modeline
  ;; Disable project detection in the modeline (major source of lag)
  (setq doom-modeline-project-detection nil))

(after! projectile
  (setq projectile-project-search-path '(("~/Development" . 2)
                                         ("~/Developer" . 2)))
  ;; Stop projectile from trying to index your whole remote home directory
  (setq projectile-file-exists-remote-cache-expire nil))

(defun my/disable-magit-auto-revert-mode ()
  "Turn off the globalized `magit-auto-revert-mode'.
A plain `setq' can't tear down the mode's hooks, and magit may defer
activation to `after-init-hook', so this is called both on load and
(appended) on `after-init-hook' to be order-independent."
  (when (fboundp 'magit-auto-revert-mode)
    (magit-auto-revert-mode -1)))

(defun my/magit-lighten-remote-status ()
  "Drop git-call-heavy, low-value status sections for remote repos.
Magit over TRAMP pays a network round-trip per `git' call; in the common
case (no rebase/am/bisect/stash in progress) these sections produce
nothing yet cost ~1s combined. Applied buffer-locally so local repos
keep the full status."
  (when (file-remote-p default-directory)
    (setq-local
     magit-status-sections-hook
     (cl-remove-if
      (lambda (fn)
        (memq fn '(magit-insert-merge-log
                   magit-insert-rebase-sequence
                   magit-insert-am-sequence
                   magit-insert-sequencer-sequence
                   magit-insert-bisect-output
                   magit-insert-bisect-rest
                   magit-insert-bisect-log
                   magit-insert-stashes
                   magit-insert-unpushed-to-pushremote
                   magit-insert-unpushed-to-upstream-or-recent
                   magit-insert-unpulled-from-pushremote
                   magit-insert-unpulled-from-upstream)))
      magit-status-sections-hook))))

(after! magit
  (setq magit-refresh-status-buffer nil)
  (my/disable-magit-auto-revert-mode)
  (add-hook 'after-init-hook #'my/disable-magit-auto-revert-mode 100)
  (add-hook 'magit-status-mode-hook #'my/magit-lighten-remote-status))
