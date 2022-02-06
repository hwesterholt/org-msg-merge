;;; org-msg-merge-old.el --- Extension of org-msg to send bulk email messages. -*- lexical-binding: t; -*-

;; Copyright (C) 2021 Hermann Graf von Westerholt

;; Author: Hermann Graf von Westerholt <hermann.westerholt@rwth-aachen.de>
;; Created: November 2021
;; Keywords: extensions mail

;; This program is free software; you can redistribute it and/or modify
;; it under the terms of the GNU General Public License as published by
;; the Free Software Foundation, either version 3 of the License, or
;; (at your option) any later version.

;; This program is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; GNU General Public License for more details.

;; You should have received a copy of the GNU General Public License
;; along with this program.  If not, see <http://www.gnu.org/licenses/>.

;;; Commentary:

;; None so far.

;;; Code:

(require 'org-msg)
(require 'pcsv)

(defcustom org-msg-merge-send-immediately nil
  "Whether created email is sent immediately.

If this is non-nil, then `message-send-and-exit' will be
called after the email has been composed."
  :type 'boolean)


(defun org-msg-merge-create-send-maybe (template alist &optional send)
  "Create mail from TEMPLATE with headers and replacers from LST.

TEMPLATE can be a string or a file path.
LST is a list of alists of the form:

    (((TO           . email1@xyz.com)
      (SUBJECT      . subject1)
      (replace-this . text1)
      (and-this     . moretext1))
     ((TO           . email2@xyz.com)
      (SUBJECT      . subject2)
      (replace-this . text2)
      (and-this     . moretext2))
     ...)"
  ;; if template is a file, use its contents
  (let* ((template (if (file-readable-p template)
		       (file-to-string template)
		     template))
	 ;; extract table headers and table rows
	 ;; (headings (car lst))
         ;; (rows (cdr lst))
         ;; (maillist (mapcar (lambda(row) (mapcar* 'cons headings row)) rows))
	 (send (or send org-msg-merge-send-immediately))
	 ;; disable greeting
         (org-msg-greeting-fmt nil))
    ;; (mapcar (lambda(recipient) (compose-mail (cdr (assoc "TO" recipient))
    ;;                                          (cdr (assoc "SUBJECT" recipient))
    ;;                                          (list (cons "CC"  (cdr (assoc "CC" recipient)))
    ;;                                                (cons "BCC" (cdr (assoc "BCC" recipient))))
    ;;                                          nil)
    ;;           (org-msg-goto-body)
    ;;           (insert (concat (s-format (file-to-string template) 'aget recipient) "\n"))
    ;; 	      (when send
    ;; 		(message-send-and-exit))
    ;;           maillist))))
    (dolist (recipient alist)
      (compose-mail (cdr (assoc "TO" recipient))
		    (cdr (assoc "SUBJECT" recipient))
		    (list (cons "CC" (cdr (assoc "CC" recipient)))
			  (cons "BCC" (cdr (assoc "BCC" recipient))))
		    nil)
      (org-msg-goto-body)
      (insert (concat (s-format template 'aget recipient) "\n"))
      (when send
     	(message-send-and-exit)))))

(defun org-msg-merge-from-csv ()
  ".")

(defun org-msg-merge-from-org-tbl ()
  ".")

(defun org-msg-merge-convert-tbl-to-alist (tbl)
  "Convert rows of TBL into list of alists for easier iteration.

Example:

    Input: ((\"header1\" \"header2\" \"header3\")
            (\"lin1col1\" \"lin1col2\" \"lin1col3\")
            (\"lin2col1\" \"lin2col2\" \"lin2col3\")
            (\"lin3col1\" \"lin3col2\" \"lin3col3\"))

    Output: (((\"header1\" . \"lin1col1\")
              (\"header2\" . \"lin1col2\")
              (\"header3\" . \"lin1col3\"))
             ((\"header1\" . \"lin2col1\")
              (\"header2\" . \"lin2col2\")
              (\"header3\" . \"lin2col3\"))
             ((\"header1\" . \"lin3col1\")
              (\"header2\" . \"lin3col2\")
              (\"header3\" . \"lin3col3\")))"

  (let* ((headers (car tbl))
         (rows (cdr tbl)))
  (mapcar (lambda(row)
		    (org-msg-merge-mapcar* 'cons headers row))
		  rows)))

(defun org-msg-merge-mapcar* (function &rest args)
  "Apply FUNCTION to successive cars of all ARGS.
Return the list of results. This function has been
stolen from section 13.6 of the Elisp manual."
  ;; If no list is exhausted,
  (if (not (memq nil args))
      ;; apply function to CARs.
      (cons (apply function (mapcar 'car args))
            (apply 'mapcar* function
                   ;; Recurse for rest of elements.
                   (mapcar 'cdr args)))))

(provide 'org-msg-merge-old)

;;; org-msg-merge-old.el ends here
