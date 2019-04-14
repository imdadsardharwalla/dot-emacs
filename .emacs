(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(c-basic-offset 4)
 '(current-language-environment "English")
 '(indent-tabs-mode nil)
 '(package-selected-packages (quote (php-mode)))
 '(select-enable-clipboard t)
 '(standard-indent 3))

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

;; Delete emacs backup files older than one week (NOT WORKING)
;; (message "Deleting old backup files...")
;; (let ((week (* 60 60 24 7))
;;       (current (float-time (current-time))))
;;   (dolist (file (directory-files temporary-file-directory t))
;;     (when (and (backup-file-name-p file)
;;                (> (- current (float-time (fifth (file-attributes file))))
;;                   week))
;;       (message "%s" file)
;;       (delete-file file))))

;; Load theme
(load-theme 'misterioso t)

;; Don't show the startup screen
(setq inhibit-startup-message t)

;; Ensure we can access MELPA
(require 'package)
(let* ((no-ssl (and (memq system-type '(windows-nt ms-dos))
                    (not (gnutls-available-p))))
       (proto (if no-ssl "http" "https")))
  (when no-ssl
    (warn "\
Your version of Emacs does not support SSL connections,
which is unsafe because it allows man-in-the-middle attacks.
There are two things you can do about this warning:
1. Install an Emacs version that does support SSL and be safe.
2. Remove this warning from your init file so you won't see it again."))
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
