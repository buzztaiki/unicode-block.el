;;; unicode-block-tests.el ---                       -*- lexical-binding: t; -*-

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

;; 

;;; Code:

(require 'ert)
(require 'unicode-block)

(ert-deftest test-unicode-block-read-blocks-buffer ()
  (with-temp-buffer
    (insert "
# comment

0000..007F; Basic Latin
0080..00FF; Latin-1 Supplement

# EOF
")
    (should (equal (unicode-block--read-blocks-buffer (current-buffer))
                   '(("Basic Latin" . (#x0000 . #x007F))
                     ("Latin-1 Supplement" . (#x0080 . #x00FF)))))))


(ert-deftest test-unicode-block-map-block-chars ()
  (let ((res (unicode-block-map-block-chars #'identity "Basic Latin")))
    (should (equal res (number-sequence #x0000 #x007F)))
    (should (equal (car res) #x0000))
    (should (equal (car (last res)) #x007F))))

(ert-deftest test-unicode-block-char-block ()
  (should (equal (unicode-block-char-block ?a) "Basic Latin"))
  (should (equal (unicode-block-char-block ?あ) "Hiragana"))
  (should-error (unicode-block-char-block (1+ (max-char)))
                :type '(wrong-type-argument)))

(provide 'unicode-block-tests)
;;; unicode-block-tests.el ends here
