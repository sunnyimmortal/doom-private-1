;;; autoload.el -*- lexical-binding: t; -*-

;;;###autoload
(defun +transmission-start-daemon-a ()
  "Start the transmission daemon.
The function is intended to be used to advice the transmission command. Ensuring
that the daemon always runs when needed."
  (unless (member "transmission-da"
                  (mapcar
                   (lambda (pid) (alist-get 'comm (process-attributes pid)))
                   (list-system-processes)))
    (call-process "transmission-daemon")
    (sleep-for 1)))


;;;###autoload
(defun +eshell/info-manual ()
  "Select and open an info manual."
  (info "dir")
  (call-interactively #'Info-menu))


;;;###autoload
(defun +eshell/fd (regexp)
  "Recursively find items matching REGEXP and open in dired."
  (fd-dired default-directory regexp))


;;;###autoload
(defun +eshell/bat (file)
    "Like `cat' but output the content of FILE with Emacs syntax highlighting."
    (with-temp-buffer
      (insert-file-contents file)
      (let ((buffer-file-name file))
        (delay-mode-hooks
          (set-auto-mode)
          (if (fboundp 'font-lock-ensure)
              (font-lock-ensure)
            (with-no-warnings
              (font-lock-fontify-buffer)))))
      (buffer-string)))


;;;###autoload
(defun +vterm/paste-from-register ()
    (interactive)
    (let ((content))
      (with-temp-buffer
        (call-interactively #'evil-paste-from-register)
        (setq content (buffer-substring-no-properties (point-min) (point-max))))
      (vterm-send-string content)))


;;;###autoload
(defun +dired/ediff-files ()
  "Ediff two marked files in a dired buffer.
The function originates from, https://oremacs.com/2017/03/18/dired-ediff/"
  (interactive)
  (let ((files (dired-get-marked-files))
        (wnd (current-window-configuration)))
    (if (<= (length files) 2)
        (let ((file1 (car files))
              (file2 (if (cdr files)
                         (cadr files)
                       (read-file-name
                        "file: "
                        (dired-dwim-target-directory)))))
          (if (file-newer-than-file-p file1 file2)
              (ediff-files file2 file1)
            (ediff-files file1 file2))
          (add-hook 'ediff-after-quit-hook-internal
                    (lambda ()
                      (setq ediff-after-quit-hook-internal nil)
                      (set-window-configuration wnd))))
      (error "no more than 2 files should be marked"))))
