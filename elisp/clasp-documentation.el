
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

(defun make-clasp-documentation (force)
  "Create the documentation for clasp.
If prefix arg FORCE is non-nil, force rebuild files that were not updated."
  (interactive "P")
  (let ((org-html-htmlize-output-type 'css)
	(project-alist
	 (cons
	  "clasp-html"
	  (list
	   :base-directory
	   (or clasp-website-source-directory
	       (read-directory-name "Source (org) directory: " nil nil t nil))
	   :base-extension "org"
	   :publishing-directory
	   (or clasp-website-target-directory
	       (read-directory-name "Target (html) directory: "))
	   :recursive t
	   :publishing-function 'org-html-publish-to-html
	   :auto-sitemap t
	   :sitemap-filename "sitemap.org"
	   :sitemap-title "Sitemap"
	   :html-preamble 'create-clasp-project-menu-preamble
	   :html-postamble 'create-clasp-project-postamble
	   :html-head "<link rel=\"stylesheet\" type=\"text/css\" href=\"styles/readtheorg/css/htmlize.css\"/>\n<link rel=\"stylesheet\" type=\"text/css\" href=\"styles/readtheorg/css/readtheorg.css\"/>\n\n<script src=\"https://ajax.googleapis.com/ajax/libs/jquery/2.1.3/jquery.min.js\"></script>\n<script src=\"https://maxcdn.bootstrapcdn.com/bootstrap/3.3.4/js/bootstrap.min.js\"></script>\n<script type=\"text/javascript\" src=\"styles/lib/js/jquery.stickytableheaders.min.js\"></script>\n<script type=\"text/javascript\" src=\"styles/readtheorg/js/readtheorg.js\"></script>"))))
    (org-publish-project project-alist force)
    (message "Clasp website published.")))
