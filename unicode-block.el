;;; unicode-block.el --- Unicode Block Utility       -*- lexical-binding: t; -*-

;; Copyright (C) 2022  Taiki Sugawara

;; Author: Taiki Sugawara <buzz.taiki@gmail.com>

;; This program is free software; you can redistribute it and/or modify
;; it under the terms of the GNU General Public License as published by
;; the Free Software Foundation, either version 3 of the License, or
;; (at your option) any later version.

;; This program is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; GNU General Public License for more details.

;; You should have received a copy of the GNU General Public License
;; along with this program.  If not, see <https://www.gnu.org/licenses/>.

;;; Commentary:

;; This package provides `unicode-block-blocks' to discover Unicode Blocks.

;;; Code:

(require 'cl-lib)
(require 'pcase)

(defun unicode-block--read-blocks-buffer (buffer)
  "Read unicode blocks from a BUFFER."
  (let (blocks)
    (with-current-buffer buffer
      (goto-char (point-min))
      (while (not (eobp))
        (when (looking-at "[0-9A-F]+")
          (pcase-let* ((`(,range ,name) (split-string (buffer-substring (point) (line-end-position)) "; +"))
                       (`(,start-code ,end-code) (mapcar (lambda (x) (string-to-number x 16)) (split-string range "\\.+"))))
            (push (cons name (cons start-code end-code)) blocks)))
        (forward-line)))
    (nreverse blocks)))

(defun unicode-block--read-blocks-file (file)
  "Read unicode blocks from a FILE."
  (with-temp-buffer
    (insert-file-contents file)
    (unicode-block--read-blocks-buffer (current-buffer))))

(defconst unicode-block--blocks-file (expand-file-name "Blocks.txt" (file-name-directory (or load-file-name buffer-file-name)))
  "File name that contains Unicode Blocks.

It is original by https://www.unicode.org/Public/UNIDATA/Blocks.txt")

;;;###autoload
(defconst unicode-block-blocks (unicode-block--read-blocks-file unicode-block--blocks-file)
  "Alist of Unicode Blocks.

Each element has the form: (NAME . (START-CODE . END-CODE))")


;;;###autoload
(defun unicode-block-map-block-chars (fn block)
  "Apply FN to each character of Unicode's BLOCK."
  (pcase-let ((`(,start . ,end) (alist-get block unicode-block-blocks nil nil #'equal)))
    (mapcar fn (seq-filter #'characterp (number-sequence start end)))))

;;;###autoload
(defun unicode-block-list-block-chars (block)
  "Display a list of characters in Unicode's BLOCK."
  (interactive (list (completing-read "Unicode block: " unicode-block-blocks nil t)))
  (with-output-to-temp-buffer "*Unicode block*"
    (with-current-buffer standard-output
      (unicode-block-map-block-chars
       (lambda (x) (insert (format "%c\t#%06x\t%s\n" x x (or (get-char-code-property x 'name) "-"))))
       block))))

(provide 'unicode-block)
;;; unicode-block.el ends here
