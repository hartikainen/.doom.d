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
