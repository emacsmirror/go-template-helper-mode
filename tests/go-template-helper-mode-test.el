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

;; Minimal ERT tests for go-template-helper-mode.
;;
;; These tests enable the mode in a temporary buffer, run font-lock, and
;; assert that expected faces are applied.

;;; Code:

(require 'ert)
(require 'go-template-helper-mode)

(defun go-template-helper-test--has-face-p (pos face)
  "Return non-nil if text at POS has FACE (symbol) applied."
  (let ((f (get-text-property pos 'face)))
    (cond
     ((eq f face) t)
     ((listp f) (memq face f))
     (t nil))))

(ert-deftest go-template-helper-mode-fontifies-basic-tokens ()
  "Ensure delimiters, variables, keywords, builtins, and comments are fontified."
  (with-temp-buffer
    (fundamental-mode)
    (font-lock-mode 1)
    (insert "{{ if $x }} {{ printf \"hi\" }} {{/* c1\nc2 */}}\n")
    (go-template-helper-mode 1)
    (font-lock-ensure)

    ;; Delimiter {{
    (should (go-template-helper-test--has-face-p (point-min) 'font-lock-preprocessor-face))

    ;; Keyword "if"
    (should (go-template-helper-test--has-face-p (+ (point-min) 3) 'font-lock-keyword-face))

    ;; Variable "$x"
    (should (go-template-helper-test--has-face-p (+ (point-min) 6) 'font-lock-variable-name-face))

    ;; Builtin "printf"
    (should (go-template-helper-test--has-face-p (+ (point-min) 17) 'font-lock-builtin-face))

    ;; Comment content should be comment-faced somewhere inside {{/* ... */}}
    (let ((comment-start (string-match "{{/\\*" (buffer-string))))
      (should comment-start)
      (should (go-template-helper-test--has-face-p (+ (point-min) comment-start)
                                                  'font-lock-comment-face)))))

(ert-deftest go-template-helper-mode-disable-removes-fontification ()
  "Ensure disabling the mode removes its fontification after refontification."
  (with-temp-buffer
    (fundamental-mode)
    (font-lock-mode 1)
    (insert "{{ if $x }}\n")
    (go-template-helper-mode 1)
    (font-lock-ensure)
    (should (go-template-helper-test--has-face-p (point-min) 'font-lock-preprocessor-face))

    (go-template-helper-mode 0)
    (font-lock-flush)
    (font-lock-ensure)
    (should-not (get-text-property (point-min) 'face))))

(provide 'go-template-helper-mode-test)
;;; go-template-helper-mode-test.el ends here
