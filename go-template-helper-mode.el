;;; go-template-helper-mode.el --- Go template highlighting in host modes (Helm/YAML) -*- lexical-binding: t; -*-

;; Copyright (C) 2026 Robert Charusta

;; Author: Robert Charusta <rch-public@posteo.net>
;; Maintainer: Robert Charusta <rch-public@posteo.net>
;; URL: https://codeberg.org/rch/go-template-helper-mode
;; Version: 2.0.0
;; Keywords: tools, faces
;; Package-Requires: ((emacs "28.1") (go-template-mode "2.0.0"))

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

;; This minor mode adds Go text/template highlighting to a host major mode,
;; such as `yaml-mode`, without changing its editing behavior.
;;
;; Fontification is provided by the shared `go-template-mode-font-lock'
;; library from `go-template-mode'.

;;; Code:

(require 'go-template-mode-font-lock)

(defgroup go-template-helper nil
  "Add Go template highlighting to host major modes."
  :group 'faces
  :prefix "go-template-helper-")

;;;###autoload
(define-minor-mode go-template-helper-mode
  "Toggle Go template highlighting in the current host-mode buffer."
  :lighter " Gtmpl"
  (if go-template-helper-mode
      (go-template-mode-font-lock-install)
    (go-template-mode-font-lock-uninstall)))

(provide 'go-template-helper-mode)
;;; go-template-helper-mode.el ends here
