;;; Dependencies
(require 'org)
(require 'package)
(add-to-list 'package-archives '("nongnu" . "https://elpa.nongnu.org/nongnu/"))
(package-initialize)
(package-refresh-contents)
(package-install 'htmlize)
(require 'htmlize)

;;; Get the pathnames we need, in kind of a stupid way.
(setq script-dir (file-name-directory load-file-name))
(setq repo-dir (file-name-directory (directory-file-name script-dir)))
(setq clasp-website-target-directory (expand-file-name "_site/" repo-dir))
(setq clasp-website-source-directory (expand-file-name "org/" repo-dir))

(load-file (expand-file-name "clasp-website.el" script-dir))
(make-directory clasp-website-target-directory)
(make-clasp-website t)
