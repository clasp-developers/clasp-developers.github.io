(require 'org)

;;; Get the pathnames we need, in kind of a stupid way.
(setq script-dir (file-name-directory load-file-name))
(setq repo-dir (file-name-directory (directory-file-name script-dir)))
(setq clasp-website-target-directory repo-dir)
(setq clasp-website-source-directory (expand-file-name "org/" repo-dir))

(load-file (expand-file-name "clasp-website.el" script-dir))
(make-clasp-website t)
