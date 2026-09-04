;;; go-template-helper-mode-test.el --- Tests for go-template-helper-mode -*- lexical-binding: t; -*-

;; Copyright (C) 2026 Robert Charusta

;; Author: Robert Charusta <rch-public@posteo.net>
;; URL: https://codeberg.org/rch/go-template-helper-mode
;; Package-Requires: ((emacs "28.1"))

;; This file is NOT part of GNU Emacs.

;; This program is free software; you can redistribute it and/or modify
;; it under the terms of the GNU General Public License as published by
;; the Free Software Foundation, either version 3 of the License, or
;; (at your option) any later version.
;;
;; This program is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; GNU General Public License for more details.
;;
;; You should have received a copy of the GNU General Public License
;; along with this program.  If not, see
;; <https://www.gnu.org/licenses/>.

;;; Commentary:

;; Integration tests for `go-template-helper-mode'.

;;; Code:

(require 'ert)

(defconst go-template-helper-test--auto-mode-alist-before-load
  (copy-tree auto-mode-alist)
  "Mode associations present before loading the helper.")

(require 'go-template-helper-mode)

(defconst go-template-helper-test--template-faces
  '(font-lock-builtin-face
    font-lock-comment-face
    font-lock-constant-face
    font-lock-keyword-face
    font-lock-preprocessor-face
    font-lock-string-face
    font-lock-variable-name-face)
  "Template faces checked by negative assertions.")

(defun go-template-helper-test--face-p (pos face)
  "Return non-nil when FACE is applied at POS."
  (let ((value (get-char-property pos 'face)))
    (if (listp value)
        (memq face value)
      (eq value face))))

(defun go-template-helper-test--position (text &optional occurrence)
  "Return the start of OCCURRENCE of TEXT in the current buffer."
  (let ((remaining (or occurrence 1)))
    (save-excursion
      (goto-char (point-min))
      (while (and (> remaining 0) (search-forward text nil t))
        (setq remaining (1- remaining)))
      (if (zerop remaining)
          (- (point) (length text))
        (ert-fail (format "Could not find occurrence %d of %S"
                          (or occurrence 1) text))))))

(defun go-template-helper-test--should-have-face
    (text face &optional occurrence offset)
  "Require TEXT at OCCURRENCE plus OFFSET to have FACE."
  (let ((pos (+ (go-template-helper-test--position text occurrence)
                (or offset 0))))
    (unless (go-template-helper-test--face-p pos face)
      (ert-fail (format "%S at %d has face %S, expected %S"
                        text pos (get-char-property pos 'face) face)))))

(defun go-template-helper-test--should-not-have-face
    (text face &optional occurrence offset)
  "Require TEXT at OCCURRENCE plus OFFSET not to have FACE."
  (let ((pos (+ (go-template-helper-test--position text occurrence)
                (or offset 0))))
    (when (go-template-helper-test--face-p pos face)
      (ert-fail (format "%S at %d unexpectedly has face %S"
                        text pos face)))))

(defun go-template-helper-test--should-have-no-template-face
    (text &optional occurrence offset)
  "Require TEXT at OCCURRENCE plus OFFSET to have no template face."
  (let ((pos (+ (go-template-helper-test--position text occurrence)
                (or offset 0))))
    (dolist (face go-template-helper-test--template-faces)
      (when (go-template-helper-test--face-p pos face)
        (ert-fail (format "%S at %d unexpectedly has template face %S"
                          text pos face))))))

(defmacro go-template-helper-test--with-fontified (mode text &rest body)
  "Insert TEXT, activate MODE and the helper, then evaluate BODY."
  (declare (indent 2) (debug t))
  `(with-temp-buffer
     (rename-buffer (generate-new-buffer-name "go-template-helper-test"))
     (insert ,text)
     (funcall ,mode)
     (let ((noninteractive nil))
       (font-lock-mode 1))
     (go-template-helper-mode 1)
     (font-lock-ensure)
     ,@body))

(ert-deftest go-template-helper-mode-loads-only-shared-fontification ()
  "Load shared fontification without activating the owner major mode."
  (should (featurep 'go-template-mode-font-lock))
  (should-not (featurep 'go-template-mode))
  (should (equal auto-mode-alist
                 go-template-helper-test--auto-mode-alist-before-load)))

(ert-deftest go-template-helper-mode-fontifies-only-complete-actions ()
  "Fontify representative shared syntax only inside complete actions."
  (go-template-helper-test--with-fontified
      #'fundamental-mode
      "if printf $x {{break $x}}{{true}}{{slice .Values 0}}"
    (go-template-helper-test--should-have-no-template-face "if")
    (go-template-helper-test--should-have-no-template-face "printf")
    (go-template-helper-test--should-have-no-template-face "$x" 1)
    (go-template-helper-test--should-have-face
     "break" 'font-lock-keyword-face)
    (go-template-helper-test--should-have-face
     "$x" 'font-lock-variable-name-face 2)
    (go-template-helper-test--should-have-face
     "true" 'font-lock-constant-face)
    (go-template-helper-test--should-have-face
     "slice" 'font-lock-builtin-face)))

(ert-deftest go-template-helper-mode-preserves-and-restores-html-host ()
  "Preserve HTML editing state and restore its string face on disable."
  (with-temp-buffer
    (rename-buffer (generate-new-buffer-name "go-template-helper-test"))
    (insert "<div class=\"prefix {{if .Enabled}} suffix\">text</div>")
    (html-mode)
    (let ((noninteractive nil))
      (font-lock-mode 1))
    (font-lock-ensure)
    (go-template-helper-test--should-have-face
     "if" 'font-lock-string-face)
    (let ((host-mode major-mode)
          (host-syntax (syntax-table))
          (host-keymap (current-local-map))
          (host-indent indent-line-function)
          (host-comment-start comment-start)
          (host-comment-end comment-end)
          (host-font-lock-defaults font-lock-defaults))
      (go-template-helper-mode 1)
      (go-template-helper-mode 1)
      (font-lock-ensure)
      (should (eq major-mode host-mode))
      (should (eq (syntax-table) host-syntax))
      (should (eq (current-local-map) host-keymap))
      (should (eq indent-line-function host-indent))
      (should (equal comment-start host-comment-start))
      (should (equal comment-end host-comment-end))
      (should (equal font-lock-defaults host-font-lock-defaults))
      (go-template-helper-test--should-have-face
       "prefix" 'font-lock-string-face)
      (go-template-helper-test--should-have-face
       "if" 'font-lock-keyword-face)
      (go-template-helper-test--should-not-have-face
       "if" 'font-lock-string-face)
      (go-template-helper-mode 0)
      (go-template-helper-mode 0)
      (go-template-helper-test--should-not-have-face
       "if" 'font-lock-keyword-face)
      (go-template-helper-test--should-have-face
       "if" 'font-lock-string-face)
      (should (eq major-mode host-mode))
      (should (eq (syntax-table) host-syntax))
      (should (eq (current-local-map) host-keymap))
      (should (eq indent-line-function host-indent))
      (should (equal comment-start host-comment-start))
      (should (equal comment-end host-comment-end))
      (should (equal font-lock-defaults host-font-lock-defaults)))))

(ert-deftest go-template-helper-mode-recovers-after-delimiter-edit ()
  "Clear and restore action faces after a narrow closing-delimiter edit."
  (go-template-helper-test--with-fontified
      #'fundamental-mode "before {{if .Enabled}} after"
    (go-template-helper-test--should-have-face
     "if" 'font-lock-keyword-face)
    (let ((close (go-template-helper-test--position "}}")))
      (delete-region close (+ close 2))
      (font-lock-flush (1- close) (1+ close))
      (font-lock-ensure (1- close) (1+ close))
      (go-template-helper-test--should-have-no-template-face "{{")
      (go-template-helper-test--should-have-no-template-face "if")
      (goto-char close)
      (insert "}}")
      (font-lock-flush (1- close) (+ close 3))
      (font-lock-ensure (1- close) (+ close 3))
      (go-template-helper-test--should-have-face
       "if" 'font-lock-keyword-face))))

(ert-deftest go-template-helper-mode-cleans-up-on-major-mode-change ()
  "Remove helper fontification before changing the host major mode."
  (go-template-helper-test--with-fontified
      #'text-mode "{{if .Enabled}}"
    (go-template-helper-test--should-have-face
     "if" 'font-lock-keyword-face)
    (fundamental-mode)
    (go-template-helper-test--should-have-no-template-face "if")))

(provide 'go-template-helper-mode-test)
;;; go-template-helper-mode-test.el ends here
