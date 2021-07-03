;;; clasp-website.el - Emacs Lisp for generating the clasp website.
;;;
;;; This program is free software: you can redistribute it and/or modify
;;; it under the terms of the GNU General Public License as published by
;;; the Free Software Foundation, either version 3 of the License, or
;;; (at your option) any later version.
;;;
;;; This program is distributed in the hope that it will be useful,
;;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;;; GNU General Public License for more details.
;;;
;;; You should have received a copy of the GNU General Public License
;;; along with this program.  If not, see <http://www.gnu.org/licenses/>.
;;;
;;; Usage:
;;; =====
;;; The functions in this file can be used to create the
;;; webpage for clasp.
;;; Simply evaluate this file and call make-clasp-website.
;;; If you don't want to enter the directories every time you
;;; use the function, customize clasp-website-source-directory
;;; and clasp-website-target-directory.
 

(defgroup clasp-website nil
  "Customization of the system for creating the clasp website.")

(defcustom clasp-website-source-directory nil
  "The source (root) directory of the clasp website.
All org files within this directory (or subdirectories) will be 
converted to html."
  :type '(directory)
  :group 'clasp-website)

(defcustom clasp-website-target-directory nil
  "The target directory of the clasp website.
The generated html files will be placed in this directory."
  :type '(directory)
  :group 'clasp-website)

(defcustom clasp-website-youtube-video-format (cons 560 315)
  "A a cons cell consisiting of width and height for
embedded youtube videos."
  :type '(cons integer integer)
  :group 'clasp-website)

(defcustom youtube-iframe-format
  ""
  (concat "<iframe width=\"440\""
          " height=\"335\""
          " src=\"https://www.youtube.com/embed/%s\""
          " frameborder=\"0\""
          " allowfullscreen>%s</iframe>"))

(org-add-link-type
 "youtube"
 (lambda (handle)
   (browse-url
    (concat "https://www.youtube.com/embed/"
            handle)))
 (lambda (path desc backend)
   (cl-case backend
     (html (format "<iframe width=\"%d\" height=\"%d\" src=\"https://www.youtube.com/embed/%s\" frameborder=\"0\" allowfullscreen>%s</iframe>"
                   (car clasp-website-youtube-video-format)
		   (cdr clasp-website-youtube-video-format)
		   path (or desc "")))
     (latex (format "\href{%s}{%s}"
                    path (or desc "video"))))))

(defun create-menu-preamble (menu-file &optional ul-class prefix postfix)
  "Creates a preamble from MENU-FILE.
MENU-FILE should be an org file with a list representing the menu.
UL-CLASS is the class of the unordered lists in the resulting html.
PREFIX is html code that is prepended to the menu.
POSTFIX is html code that is appended to the menu."
  (let ((org-export-show-temporary-export-buffer t))
    (with-temp-buffer
      (insert-file-contents menu-file)
      (org-html-export-as-html nil nil nil t)
      (while (re-search-forward "<ul class=\"org-ul\">" nil t)
	(replace-match
	 (concat "<ul"
		 (if ul-class
		     (concat " class=\"" ul-class "\">")
		   ">"))))
      (let ((html-menu (buffer-string)))
	(kill-buffer)
	(concat prefix html-menu postfix)))))

(defun create-clasp-project-menu-preamble (info)
  "Creates a html preamble for the clasp project page."
  (create-menu-preamble
   "menu.org" nil
   "<div id=\"top-menu\">\n"
   "</div>"))

(defun create-clasp-project-postamble (info)
  "Creates an html postamble for the clasp project page."
  (create-menu-preamble
   "footer.org" nil "<center>" "</center>"))

(defun make-clasp-website-impl (force base-directory publishing-directory)
  "Create the website for clasp.
If prefix arg FORCE is non-nil, force rebuild files that were not updated.
Use FORCE, if you have updated menu.org, in order to update the menu on all files."
  (let ((org-html-htmlize-output-type 'css)
	(project-alist
	 (cons
	  "clasp-html"
	  (list
	   :base-directory base-directory
	   :base-extension "org"
	   :publishing-directory publishing-directory
	   :recursive t
	   :publishing-function 'org-html-publish-to-html
	   :auto-sitemap t
	   :sitemap-filename "sitemap.org"
	   :sitemap-title "Sitemap"
	   :html-preamble 'create-clasp-project-menu-preamble
	   :html-postamble 'create-clasp-project-postamble
	   :html-head "<link rel=\"stylesheet\" type=\"text/css\" href=\"styles/readtheorg/css/htmlize.css\"/>\n<link rel=\"stylesheet\" type=\"text/css\" href=\"styles/readtheorg/css/readtheorg-no-toc.css\"/>\n\n<script src=\"https://ajax.googleapis.com/ajax/libs/jquery/2.1.3/jquery.min.js\"></script>\n<script src=\"https://maxcdn.bootstrapcdn.com/bootstrap/3.3.4/js/bootstrap.min.js\"></script>\n<script type=\"text/javascript\" src=\"styles/lib/js/jquery.stickytableheaders.min.js\"></script>\n<script type=\"text/javascript\" src=\"styles/readtheorg/js/readtheorg.js\"></script>"))))
    (org-publish-project project-alist force)
    (message "Clasp website published.")))


(defun make-clasp-website (force)
  "Create the website for clasp.
If prefix arg FORCE is non-nil, force rebuild files that were not updated.
Use FORCE, if you have updated menu.org, in order to update the menu on all files."
  (interactive "P")
  (make-clasp-website-impl
   force
   (or clasp-website-source-directory
       (read-directory-name "Source (org) directory: " nil nil t nil))
   (or clasp-website-target-directory
       (read-directory-name "Target (html) directory: "))))
