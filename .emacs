(custom-set-variables
 '(c-basic-offset 4)
 '(current-language-environment "English")
 '(select-enable-clipboard t)
 '(standard-indent 3)
 '(indent-tabs-mode nil)
)

(defun wheel-scroll-up   ()   (lambda () (interactive) (scroll-up   4)))
(defun wheel-scroll-down ()   (lambda () (interactive) (scroll-down 4)))

(define-key global-map [mouse-4] (wheel-scroll-down))
(define-key global-map [mouse-5] (wheel-scroll-up))

(define-key global-map "\C-cr" 'replace-string)
(define-key global-map "\C-cg" 'goto-line)

(global-unset-key [(control x) (control c)])
(global-unset-key [(control z)])
(global-set-key [C-tab] 'other-window)

(require 'whitespace)
 (setq whitespace-line-column 80)
 (setq whitespace-style '(face empty tabs lines-tail trailing))
 (global-whitespace-mode t)

;; Set emacs backup directory to the temp directory
(setq backup-directory-alist
      `((".*" . ,temporary-file-directory)))
(setq auto-save-file-name-transforms
      `((".*" ,temporary-file-directory t)))

;; Delete emacs backup files older than one week
(message "Deleting old backup files...")
(let ((week (* 60 60 24 7))
      (current (float-time (current-time))))
  (dolist (file (directory-files temporary-file-directory t))
    (when (and (backup-file-name-p file)
               (> (- current (float-time (fifth (file-attributes file))))
                  week))
      (message "%s" file)
      (delete-file file))))

;; Load theme
(load-theme 'misterioso t)
