;; functions.el -*- lexical-binding: t; -*-

(after! clipetty
  (defun copy-strip-whitespace (&optional beg end)
    "Save the current region (or line) to the `kill-ring' after stripping extra whitespace and new lines"
    (interactive
     (if (region-active-p)
         (list (region-beginning) (region-end))
       (list (line-beginning-position) (line-end-position))))
    (let ((my-text (buffer-substring-no-properties beg end)))
      (with-temp-buffer
        (insert my-text)
        (goto-char 1)
        (while (looking-at "[ \t\n]")
          (delete-char 1))
        (let ((fill-column 9333999))
          (fill-region (point-min) (point-max)))
        (set-mark (point-min))
        (goto-char (point-max))
        (clipetty-kill-ring-save)))))

(defun my/magit-branch-merged-pr-p (branch)
  "Return non-nil if GitHub reports BRANCH's exact tip as merged."
  (and (executable-find "gh")
       (condition-case nil
           (let ((head (magit-rev-parse branch)))
             (with-temp-buffer
               (and (eq 0 (process-file
                           "gh" nil (list (current-buffer) nil) nil
                           "pr" "view" branch "--json" "state,headRefOid"))
                    (progn
                      (goto-char (point-min))
                      (let ((pr (json-parse-buffer :object-type 'alist)))
                        (and head
                             (equal (alist-get 'state pr) "MERGED")
                             (equal (alist-get 'headRefOid pr) head)))))))
         (error nil))))

(defun my/magit-clean-worktree-and-branch (&optional force)
  "Remove this linked worktree and its local branch after confirmation.
Refuse dirty worktrees and unsaved files.  Accept branches merged into
the primary worktree's branch and their upstream, or whose exact tip
GitHub reports as merged.  With prefix argument FORCE, skip the merge
check.  Return to Magit in the primary worktree."
  (interactive "P")
  (require 'magit)
  (require 'magit-worktree)
  (let* ((worktree (or (magit-toplevel)
                       (user-error "This buffer is not in a Git worktree")))
         (primary (file-name-as-directory (caar (magit-list-worktrees))))
         (branch (magit-get-current-branch))
         (status-buffer (and (derived-mode-p 'magit-status-mode)
                             (current-buffer))))
    (when (file-equal-p worktree primary)
      (user-error "Cannot remove the primary worktree"))
    (unless branch
      (user-error "This worktree has a detached HEAD"))
    (when (magit-git-string "status" "--porcelain" "--untracked-files=normal")
      (user-error "Commit or remove changes and untracked files first"))
    (dolist (buffer (buffer-list))
      (with-current-buffer buffer
        (when (and buffer-file-name
                   (buffer-modified-p)
                   (file-in-directory-p buffer-file-name worktree))
          (user-error "Save or discard edits in %s first" (buffer-name)))))
    ;; Check against the surviving checkout, since this worktree's HEAD
    ;; would make its own branch appear merged.
    (let* ((default-directory primary)
           (merged (and (not force) (magit-branch-merged-p branch)))
           (merged-pr (and (not force) (not merged)
                           (my/magit-branch-merged-pr-p branch))))
      (unless (or force merged merged-pr)
        (user-error "Cannot verify branch %s as merged; use C-u to allow deletion"
                    branch))
      (when (yes-or-no-p
             (format "Remove worktree %s and %sdelete local branch %s? "
                     worktree (if force "forcibly " "") branch))
        (unwind-protect
            (let ((magit-process-raise-error t))
              (magit-call-git "worktree" "remove" "--" worktree)
              ;; Squash merges do not preserve branch ancestry.
              (magit-call-git "branch" (if (or force merged-pr) "-D" "-d")
                              "--" branch))
          ;; Branch deletion can fail after worktree removal succeeds.
          (unless (file-directory-p worktree)
            (when (buffer-live-p status-buffer)
              (kill-buffer status-buffer))
            (magit-status-setup-buffer primary)))))))
