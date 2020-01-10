(defun wheel-scroll-up   ()   (lambda () (interactive) (scroll-up   4)))
(defun wheel-scroll-down ()   (lambda () (interactive) (scroll-down 4)))

(define-key global-map [mouse-4] (wheel-scroll-down))
(define-key global-map [mouse-5] (wheel-scroll-up))

(define-key global-map "\C-cr" 'replace-string)
(define-key global-map "\C-xg" 'goto-line)

(global-unset-key [(control x) (control c)])
(global-unset-key [(control z)])
(global-set-key [C-tab] 'other-window)

(define-key global-map "\C-q" 'delete-trailing-whitespace)

;; Set up eclipse-style commenting for programming languages
(defun comment-eclipse ()
  (interactive)
  (let ((start (line-beginning-position))
        (end (line-end-position)))
    (when (or (not transient-mark-mode) (region-active-p))
      (setq start (save-excursion
                    (goto-char (region-beginning))
                    (beginning-of-line)
                    (point))
            end (save-excursion
                  (goto-char (region-end))
                  (end-of-line)
                  (point))))
    (comment-or-uncomment-region start end)))

(define-key global-map [(control ?/)] 'comment-eclipse)

;; Set-up trailing whitespace highlighting.
(setq whitespace-line-column 80)
(setq whitespace-style '(face empty tabs lines-tail trailing))

;; (setq whitespace-display-mappings
;;   ;; all numbers are Unicode codepoint in decimal. ⁖ (insert-char 182 1)
;;   '(
;;     (space-mark 32 [183] [46]) ; 32 SPACE 「 」, 183 MIDDLE DOT 「·」, 46 FULL STOP 「.」
;;     (newline-mark 10 [182 10]) ; 10 LINE FEED
;;     (tab-mark 9 [9655 9] [92 9]) ; 9 TAB, 9655 WHITE RIGHT-POINTING TRIANGLE 「▷」
;;     ))


'(whitespace-trailing ((t (:background "LightSalmon1" :foreground "black" :weight bold))))

(global-whitespace-mode t)

;; Set emacs backup directory to the temp directory
(setq backup-directory-alist
      `((".*" . ,temporary-file-directory)))
(setq auto-save-file-name-transforms
      `((".*" ,temporary-file-directory t)))

;; Use vscode-dark theme
(add-to-list 'custom-theme-load-path "~/.emacs.d/themes/")
(load-theme 'vscode-dark-plus t)

;; Don't show the startup screen
(setq inhibit-startup-message t)

;; Ensure we can access MELPA
(require 'package)
(let* ((no-ssl (and (memq system-type '(windows-nt ms-dos))
                    (not (gnutls-available-p))))
       (proto (if no-ssl "http" "https")))
  (when no-ssl
    (warn "No SSL."))
  ;; Comment/uncomment these two lines to enable/disable MELPA and MELPA Stable as desired
  (add-to-list 'package-archives (cons "melpa" (concat proto "://melpa.org/packages/")) t)
  ;;(add-to-list 'package-archives (cons "melpa-stable" (concat proto "://stable.melpa.org/packages/")) t)
  (when (< emacs-major-version 24)
    ;; For important compatibility libraries like cl-lib
    (add-to-list 'package-archives (cons "gnu" (concat proto "://elpa.gnu.org/packages/")))))
(package-initialize)
(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 )

;; SET UP SOME KEYBINDINGS ;;

;; more familiar forward and backward word
(global-set-key (kbd "M-f") 'forward-same-syntax)
(global-set-key (kbd "M-b") (lambda () (interactive)
                              (forward-same-syntax -1)))

;; C-a: move to indentation or beginning of line if already there
(defun beginning-of-indentation-or-line ()
  (interactive)
  (if (= (point) (save-excursion (back-to-indentation) (point)))
      (beginning-of-line)
    (back-to-indentation)))
(global-set-key (kbd "C-a") 'beginning-of-indentation-or-line)

;; saner forward and backward delete-word using thingatpt
(defun delete-syntax (&optional arg)
  (interactive "p")
  (let ((opoint (point)))
    (forward-same-syntax arg)
    (delete-region opoint (point))))
(defun backward-delete-syntax (&optional arg)
  (interactive)
  (delete-syntax -1))
(global-set-key (kbd "M-d") 'delete-syntax)
(global-set-key (kbd "M-<backspace>") 'backward-delete-syntax)
(global-set-key (kbd "C-<backspace>") 'backward-delete-syntax)

;; completion that uses many different methods to find options
(setq hippie-expand-try-functions-list '(try-expand-dabbrev try-expand-dabbrev-all-buffers try-expand-dabbrev-from-kill try-complete-file-name-partially try-complete-file-name try-expand-all-abbrevs try-expand-list try-expand-line try-complete-lisp-symbol-partially try-complete-lisp-symbol))
(global-set-key (kbd "M-/") 'hippie-expand)

;; switch to regexp as default search
(global-set-key (kbd "C-s") 'isearch-forward-regexp)
(global-set-key (kbd "\C-r") 'isearch-backward-regexp)
(global-set-key (kbd "C-M-s") 'isearch-forward)
(global-set-key (kbd "C-M-r") 'isearch-backward)

;; Press <F12> to glash the current buffer
(global-set-key (kbd "<f12>") 'flash-active-buffer)
(make-face 'flash-active-buffer-face)
(set-face-attribute 'flash-active-buffer-face nil
                    :background "dim grey" :foreground nil)
(defun flash-active-buffer ()
  (interactive)
  (run-at-time "100 millisec" nil
               (lambda (remap-cookie)
                 (face-remap-remove-relative remap-cookie))
               (face-remap-add-relative 'default 'flash-active-buffer-face)))

;; highlight the current line
(global-hl-line-mode 1)
(set-face-background 'hl-line "#3e4446")
(set-face-foreground 'highlight nil)

;; highlight matching brackets
(setq show-paren-delay 0)
(show-paren-mode 1)

;; duplicate lines up and down

(defun duplicate-line-up (arg)
  "Duplicate current line, leaving point in upper line."
  (interactive "*p")

  ;; save the point for undo
  (setq buffer-undo-list (cons (point) buffer-undo-list))

  ;; local variables for start and end of line
  (let ((bol (save-excursion (beginning-of-line) (point)))
        eol)
    (save-excursion

      ;; don't use forward-line for this, because you would have
      ;; to check whether you are at the end of the buffer
      (end-of-line)
      (setq eol (point))

      ;; store the line and disable the recording of undo information
      (let ((line (buffer-substring bol eol))
            (buffer-undo-list t)
            (count arg))
        ;; insert the line arg times
        (while (> count 0)
          (newline)         ;; because there is no newline in 'line'
          (insert line)
          (setq count (1- count)))
        )

      ;; create the undo information
      (setq buffer-undo-list (cons (cons eol (point)) buffer-undo-list)))
    )) ; end-of-let

(defun duplicate-line-down (arg)
  "Duplicate current line, leaving point in lower line."
  (interactive "*p")

  (duplicate-line-up arg)

  ;; put the point in the lowest line and return
  (next-line arg))

(global-set-key (kbd "C-M-n") 'duplicate-line-down)
(global-set-key (kbd "C-M-p") 'duplicate-line-up)

(global-set-key [C-M-down] 'duplicate-line-down)
(global-set-key [C-M-up] 'duplicate-line-up)

;; move lines up and down (TODO: this doesn't quite work properly)

(defun move-text-internal (arg)
  (cond
   ((and mark-active transient-mark-mode)
    (if (> (point) (mark))
        (exchange-point-and-mark))
    (let ((column (current-column))
          (text (delete-and-extract-region (point) (mark))))
      (forward-line arg)
      (move-to-column column t)
      (set-mark (point))
      (insert text)
      (exchange-point-and-mark)
      (setq deactivate-mark nil)))
   (t
    (let ((column (current-column)))
      (beginning-of-line)
      (when (or (> arg 0) (not (bobp)))
        (forward-line)
        (when (or (< arg 0) (not (eobp)))
          (transpose-lines arg))
        (forward-line -1))
      (move-to-column column t)))))

(defun move-text-down (arg)
  "Move region (transient-mark-mode active) or current line
  arg lines down."
  (interactive "*p")
  (move-text-internal arg))

(defun move-text-up (arg)
  "Move region (transient-mark-mode active) or current line
  arg lines up."
  (interactive "*p")
  (move-text-internal (- arg))
  (forward-line -1))

(provide 'move-text)


(global-set-key (kbd "M-p") 'move-text-up)
(global-set-key (kbd "M-n") 'move-text-down)

(global-set-key [M-up] 'move-text-up)
(global-set-key [M-down] 'move-text-down)

(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(custom-safe-themes
   (quote
    ("29f48a0aae460677f00232447a640a17ec2d85fce5eae0aa9308112e5d2c5749" default))))
