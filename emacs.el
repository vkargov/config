;; TODO
;; *) Problem: Cscope opens file in a totally other window. Solution: remember what window we called cscope from, and then open a new buffer inside the same window.


;; add local dir in front of the list

;; Added by Package.el.  This must come before configurations of
;; installed packages.  Don't delete this line.  If you don't want it,
;; just comment it out by adding a semicolon to the start of the line.
;; You may delete these explanatory comments.
(package-initialize)

(setq local-lisp-path "~/.emacs.d/lisp")
(add-to-list 'load-path local-lisp-path)

;; Scroll by 1 line at a time
(setq scroll-step 1)

(setq comment-style 'extra-line)

;; (set-default-font "-misc-fixed-small-r-normal--15-140-75-75-c-90-koi8-r")
(global-font-lock-mode 1)

(defun prev-window ()
  (interactive)
  (other-window -1))

(transient-mark-mode t)

(setq-default require-final-newline nil)

;; Disable the useless menu bar unless we're on mac where it doesn't take any space.
(or (string= system-type "darwin") (menu-bar-mode -1))
;; It may be broken... I need to test it on non-osx

;; Don't ask whether or not follow a symlink.
(setq vc-follow-symlinks t)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(defadvice select-window (after gud-grief activate)
  ;; Display file name in titlebar
  (setq frame-title-format
          (concat "emacs ("
		  (replace-regexp-in-string
		   (concat "/home/" user-login-name) "~"
		   (or buffer-file-name "%b"))
		  ")"))
  ;; Disable the useless toolbar unless we're in gud-mode (debugger).
  (when tool-bar-mode
    (if (string-match-p "\\b\\(gdb\\|gud\\)\\b" (symbol-name major-mode)) (tool-bar-mode 1) (tool-bar-mode -1))))
;; I couldn't find a good hook to selectively adjust the look of each frame.
;; I tried window-configuration-change-hook, but it's not called on some some
;; So using the advice thing instead.
;; PS it's still 糞

;; Run the configuration on the initial window
(select-window (selected-window))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; Follow the build text
(setq-default compilation-scroll-output t)

;; disable warning issued by narrow-to-region
(put 'narrow-to-region 'disabled nil)

;; delete all spaces until non-space character if deletion key is hit
;; C-c C-d to enable/disable
;; (setq-default c-hungry-delete-key f)

;; Display function name the cursor is currently in on the status bar.
(setq-default which-func-modes t)

(setq compilation-scroll-output t)

;; Enable column numbering
(column-number-mode t)

;; ;; I want to have access to the xcscope shortcuts from any buffer
;; For some reason it resets emacs to scratch at startup instead of showing the file I specified in command line
;; (add-hook 'find-file-hook (function cscope:hook))

;; toggle full-screen
;; TODO remove it?
(when (eq window-system 'x)
  (defun toggle-fullscreen ()
    (interactive)
    (x-send-client-message nil 0 nil "_NET_WM_STATE" 32
                           '(2 "_NET_WM_STATE_MAXIMIZED_VERT" 0))
    (x-send-client-message nil 0 nil "_NET_WM_STATE" 32
                           '(2 "_NET_WM_STATE_MAXIMIZED_HORZ" 0))
    )
  (toggle-fullscreen)
)

;; F5 = revisit(refresh) file
(defun revert-buffer-no-confirm ()
  "Revert buffer without confirmation."
  (interactive) (revert-buffer t t) (princ "Buffer updated."))
(global-set-key (kbd "<f5>") 'revert-buffer-no-confirm)
;; F7 = compile
(global-set-key (kbd "<f7>") 'compile)
;; C-; = "quick compile & run"
(defun vk-get-quick-build-string ()
  (let* ((file (shell-quote-argument (buffer-file-name)))
	 (base (shell-quote-argument (file-name-sans-extension (buffer-file-name)))))
    (cond ((file-exists-p "Makefile")
	   (concat "make clean && make && " base))
	  ((string= (file-name-extension file) "cpp")
	   (concat "clang++ -std=c++17 -lpthread -Wall -g " file " -o " base " && " base))
	  ((string= (file-name-extension file) "c")
	   (concat "clang -std=c11 -lpthread -g " file " -o " base " && " base))
	  ((string= (file-name-extension file) "py")
	   (concat "python3 " file))
	  ((string= (file-name-extension file) "js")
	   (concat "node " file))
	  ((string= (file-name-extension file) "swift")
	   (concat "swift " file))
	  (t "echo '¯\_(ツ)_/¯'"))))
(global-set-key (kbd "C-;") (lambda () (interactive) (compile (vk-get-quick-build-string))))

;; Don't ask if I want to reload TAGS
(setq tags-revert-without-query 1)

;; Mouse support for the text mode
(xterm-mouse-mode t)

;; Use uniquify to distinguish between buffers of files bearing the same name easier.
;; Let's see how it goes
(require 'uniquify)
;; (setq uniquify-buffer-name-style 'forward)

;; (require 'color-theme)
;; (color-theme-initialize)
;; (if window-system
;;         (color-theme-subtle-hacker)
;; 	(color-theme-hober))

;; Madness is above, sanity is below
;; Now that I think of it, I should probably try project 1 on all depths, then 2, then 3, etc, defaulting to the current dir if everything else fails
;; And learn ELisp properly, srsly >_>

;; TODO: get rid of all the SETQs!

;; Define the core dir trappings and blacklisted directories here
(setq vk-known-projects '((("gcc" "config" "libgcc" "libiberty") ("/testsuite/" "/test/" "/build/"))
			  (("CODE_OWNERS.TXT" "tools" "utils" "LLVMBuild.txt") ("/test/" "/build/"))
			  (("mono" "mcs" "docs" "tools") ("/build.*/"))
			  (("DROD" "DRODLib" "DRODUtil") ())
			  (("arch" "drivers" "include" "kernel") ("/drivers/")) ; Linux
			  (("cmake" "plugins" "panel" "doc") ()) ; Unity
			  (("README.md") ("/bin/")) ; generic software project #4 (e.g. CoreCLR)
			  (("README" "binutils" "gas") ()) ; binutils
			  (("README" "INSTALL") ("/.pc/")) ; generic software project #1
			  (("README") ("/.pc/")) ; generic software project #2
			  (("Makefile") ("/.pc/")) ; generic software project #3 (e.g. BSD Grep)
			  (("configure.ac") ()) ; GNU Make
			  ((".git") ()) ; Git
			  ((".svn") ()) ; Subversion
			  (("APPLE_LICENSE") ()) ; oringo
			  (() ())
			  ))

(defun vk-index-project () (interactive)
       (defun vk-dump-vars-to-file (varlist filename)
	 "simplistic dumping of variables in VARLIST to a file FILENAME"
	 (save-excursion
	   (let ((buf (find-file-noselect filename)))
	     (set-buffer buf)
	     (erase-buffer)
	     (cl-loop for var in varlist do
		   (princ (concat var "\n") buf))
	     (save-buffer)
	     (kill-buffer))))
       
       (defun vk-lookup-project (projects)
	 (catch 'project-found
	   (while (consp projects)
	     (let* ((project (pop projects))
		    (blacklist (cadr project))		    
		    (lookup-path buffer-file-name)
		    (lookup-failed nil))
	       ;;(message "Trying project %s" project) ; debug
	       (while (> (string-width lookup-path) 1)
		 (catch 'try-parent-dir		   
		   (let* ((remaining-trappings (car project)))
		     ;;(message "Trappings are: %s" remaining-trappings) ; debug
		     ;; For some reason (file-exists-p "main.c/.") = t!
		     (setq lookup-path (replace-regexp-in-string "/[^/]*$" "" lookup-path))
		     ;;(message "Trying path %s" lookup-path) ; debug
		     (while (consp remaining-trappings)
		       (when (not (file-exists-p (concat lookup-path "/" (pop remaining-trappings))))
			 ;;(message "try-parent-dir") ; debug
			 (throw 'try-parent-dir nil))
		       )
		     ;;(message "project-found") ; debug
		     (throw 'project-found (list lookup-path blacklist))
		     )))))
	     (list nil nil)))

       (let* ((project-info (vk-lookup-project vk-known-projects))
	      (project-root nil)
	      (files '())
	      (project-root (car project-info))
	      (project-blacklist (cadr project-info))	     
	      )
	 
	 (message "Project found at %s. Scanning files... (excluding %s)" project-root project-blacklist)

	 (when project-root
	   (defun vk-is-path-blacklisted (path blacklist)
	     ;;(message "vk-is-path-blacklisted %s %s" path blacklist) ; debug
	     (while (and blacklist (not (string-match (car blacklist) path))) (pop blacklist))
	     (if blacklist t nil))

	   (defun vk-build-cscope-database (root blacklist)
	     (let ((dirs (list root)))
	       (while dirs
		 (let* (
			(dir (pop dirs))
			(ls (directory-files dir))
			)
		   (while ls
		     (let* ((file (pop ls))
			    (file-path (concat dir "/" file)))
		       (unless (vk-is-path-blacklisted file-path blacklist)
			 (if (file-accessible-directory-p file-path)
			     (unless (or (string= file ".") (string= file "..")) (add-to-list 'dirs file-path))
			   (if (and (file-readable-p file-path) (string-match "\\.\\(c\\|cpp\\|vala\\|def\\)$" file-path))
			       (add-to-list 'files file-path))))))))
	       ;; Append some commonly used header files. Uncomment the "/usr/include" line above
	       ;; and remove/comment this one if you want to see them all their multitude instead
	       ;; of this selectivity.
	       ;; (dolist (header '("stdio.h" "stdlib.h" "stdarg.h" "ctype.h" "string.h" "math.h" "dlfcn.h"
	       ;; 			 "sys/types.h" "sys/time.h" "unistd.h" "assert.h" "limits.h" "poll.h"
	       ;; 			 "libgen.h" "signal.h" "fcntl.h"
	       ;; 			 "bits/stdio2.h" "bits/string2.h"
	       ;; 			 "secure/_string.h" "secure/_stdio.h" "secure/_common.h" ; Clang's "real" headers
	       ;; 			 "X11/Xos.h" "X11/Xlib.h" "X11/Xfuncproto.h" "X11/Xatom.h" "X11/Xproto.h"
	       ;; 			 "X11/extensions/Xrandr.h" "X11/extensions/shape.h" "X11/cursorfont.h"
	       ;; 			 "X11/extensions/XInput2.h" "X11/X.h"
	       ;; 			 "boost/bind.hpp" "boost/foreach.hpp"
	       ;; 			 "sys/wait.h" "sys/types.h" "sys/stat.h"
	       ;; 			 "glib-2.0/glib/gspawn.h" "glib-2.0/glib/gslice.h" "glib-2.0/glib/gmacros.h"
	       ;; 			 "glib-2.0/gobject/gobject.h" "glib-2.0/gobject/gtype.h"
	       ;; 			 ))
	       ;; 	 (let ((header_path (concat "/usr/include/" header)))
	       ;; 	   (if (file-exists-p header_path) (add-to-list 'files header_path)))
	       ;; 	 )

	       ;; Add SDL libraries.
	       ;; OSX-only, I need to make it system and path independent...
	       ;; (and (string= system-type "darwin")
	       ;; 	   (setcdr (last files) (let ((sdl-dir "/usr/local/Cellar/sdl2/2.0.5/include/SDL2/")) (mapcar (lambda (s) (concat sdl-dir s)) (directory-files sdl-dir)))))

	       files))

	   (vk-dump-vars-to-file (vk-build-cscope-database project-root project-blacklist)
			      (concat project-root "/" cscope-index-file))

	   (message "Processing...")
	   (cscope-set-initial-directory project-root)
	   (with-temp-buffer (shell-command (concat "cd " project-root "; cscope -b; ctags -Re .") t)) ; with-temp-buffer is needed to hide output
	   (setq tags-file-name (concat project-root "/TAGS"))
	   (message "Done processing")
	   ;; Set compilation-directory also, so the compile function would pick up the root as well.
	   (setq compilation-directory project-root)
	   ;; For the compile command
	   (setq default-directory project-root)
	   )
	 )
       )

(global-set-key (kbd "<f9>") 'vk-index-project)

;; Todo: identification of project by its topdir, making global variables local with let, speedup

;; Load cscharpmode
(autoload 'csharp-mode "csharp-mode" "Major mode for editing C# code." t)
(setq auto-mode-alist
      (append '(("\\.cs$" . csharp-mode)) auto-mode-alist))

;; Load markdown-mode
(autoload 'markdown-mode "markdown-mode"
   "Major mode for editing Markdown files" t)
(add-to-list 'auto-mode-alist '("\\.md\\'" . markdown-mode))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; CSCOPE
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Enable cscope support
;; Modified cscope from the local lisp directory should take the priority
(require 'xcscope nil t)

; Not needed on linux, needed on os x... looks like some init file is missing?
; Also see update-file-autoloads Emacs manual and ;;;###autoload in xcscope.el.
(cscope-setup)

;; Close window after hitting "enter" in the selection buffer
(setq cscope-close-window-after-select t)

;; Display the selected code fragment in the previous window which should normally replace the old code location.
;; The default behaviour uses `some-window` which picks a window at "random".
(setq cscope-display-buffer-args '((display-buffer-in-previous-window)))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


(setq backup-directory-alist '(("." . "~/.emacs.d/backup")))

;; Copy stuff to clipboard
(setq x-select-enable-clipboard t)

;; Empty scratch message
(setq initial-scratch-message nil)

;; 8/10 spaghetti manufacturers approve of this indentation level
(setq-default c-basic-offset 2)

;; More convenient navigation through buffers
;; TODO dunno what the difference between other-window(C-x o) and next-multiframe-window is...
(global-set-key (kbd "M-]") 'next-multiframe-window)
(global-set-key (kbd "M-[") 'previous-multiframe-window)

;; Use multi-term.el. It's a nicer term mode. Unstable from my early impressions, so not sure I can really utilize it...
;; (require 'multi-term)

;; M-n copies full file name (was undefined)
(global-set-key (kbd "M-n") (lambda () (interactive) (kill-new (buffer-file-name))))

;; If you launch Emacs from Spotlight/Gnome, it won't "see" changes
;; in the PATH variable that I make in bashrc.
(setenv "PATH" (concat (getenv "PATH") ":" (expand-file-name "~/usr/bin")))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Highlight shenenigans 
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(require 'hi-lock) ; reusing their faces
(defun vk-remove-overlays-in-region (beginning end) (interactive) (remove-overlays beginning end))
(defun vk-highlight-selection (face)
  (let*
      ((beginning (if (use-region-p) (region-beginning) (line-beginning-position)))
       (end (if (use-region-p) (region-end) (line-end-position))))
    (vk-remove-overlays-in-region beginning end)
    (if face (overlay-put (make-overlay beginning end) 'face face))
    )
  )
;; on Mac "s" is "alt" (after all my rebindings)
(global-set-key (kbd "s-1") (lambda () (interactive) (vk-highlight-selection 'hi-yellow)))
(global-set-key (kbd "s-2") (lambda () (interactive) (vk-highlight-selection 'hi-pink)))
(global-set-key (kbd "s-3") (lambda () (interactive) (vk-highlight-selection 'hi-green)))
(global-set-key (kbd "s-4") (lambda () (interactive) (vk-highlight-selection 'hi-blue)))
(global-set-key (kbd "s-5") (lambda () (interactive) (vk-highlight-selection 'hi-blue-b)))
(global-set-key (kbd "s-6") (lambda () (interactive) (vk-highlight-selection 'hi-green-b)))
(global-set-key (kbd "s-7") (lambda () (interactive) (vk-highlight-selection 'hi-red-b)))
(global-set-key (kbd "s-0") (lambda () (interactive) (vk-highlight-selection nil)))
; Prooooobably gonna break hi-lock, but oh well
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; set-goal-column (C-x C-n) sets default column for ⬆/⬇
(put 'set-goal-column 'disabled nil)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Fix newlines + draw dotty file with an external program
(defun vk-draw-flowchart ()
  (interactive)
  (let ((filename (buffer-file-name)))
    (if (string= (file-name-extension filename) "dot")
	(progn
	  (save-buffer)
	  
	  (start-process "dotty" nil "zgrviewer" filename)
	  )
      (message (concat "File " filename " is not a flowchart"))
      )
    )
  )
(global-set-key (kbd "<f12>") 'vk-draw-flowchart)
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; Auto-generated custom stuff goes at the end
(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(company-rtags-insert-arguments nil)
 '(custom-enabled-themes (quote (whiteboard)))
 '(elpy-modules
   (quote
    (elpy-module-company elpy-module-eldoc elpy-module-flymake elpy-module-pyvenv elpy-module-yasnippet elpy-module-django elpy-module-sane-defaults)))
 '(frame-background-mode (quote light))
 '(inhibit-startup-screen t)
 '(package-selected-packages
   (quote
    (modern-cpp-font-lock cuda-mode company-tern js2-mode elpy swift-mode company latex-preview-pane jedi ## helm)))
 '(preview-orientation (quote left))
 '(python-shell-interpreter "python3")
 '(safe-local-variable-values
   (quote
    ((eval add-hook
	   (quote prog-mode-hook)
	   (lambda nil
	     (whitespace-mode 1))
	   (not :APPEND)
	   :BUFFER-LOCAL)
     (eval let*
	   ((x
	     (dir-locals-find-file default-directory))
	    (this-directory
	     (if
		 (listp x)
		 (car x)
	       (file-name-directory x))))
	   (unless
	       (or
		(featurep
		 (quote swift-project-settings))
		(and
		 (fboundp
		  (quote tramp-tramp-file-p))
		 (tramp-tramp-file-p this-directory)))
	     (add-to-list
	      (quote load-path)
	      (concat this-directory "utils")
	      :append)
	     (let
		 ((swift-project-directory this-directory))
	       (require
		(quote swift-project-settings))))
	   (set
	    (make-local-variable
	     (quote swift-project-directory))
	    this-directory))
     (eval c-set-offset
	   (quote innamespace)
	   0)))))
(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 )

;; Show line numbers in reasonably large files
(setq line-number-display-limit-width 2000000)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Better completion mode


;; Documentation: https://www.gnu.org/software/emacs/manual/html_mono/ido.html
(require 'ido)
;; Don't open the buffer automatically when hitting tab.
;; One keystroke less, 10e11 activated neurons more trying to figure out whether I should press "enter" or not every time I switch buffers.
(setq ido-confirm-unique-completion t)
;; By default pressing backspace at the end of the line in IDO mode removes the whole directory/file name till the last slash. Not a fan.
;; TODO okay, this isn't working for some reason. I don't know why, but ARGHHH.
(add-hook 'ido-setup-hook (lambda()
			    (define-key ido-file-dir-completion-map [backspace] nil)
			    (define-key ido-file-dir-completion-map "\d" nil)
			    ))
;; ;; Okay I'm done with IDO. It needs some serious reworking to not be frustrating, and the config options don't seem lean enough for that.
;; (ido-mode t)

;; ;; Helm
;; way too much computer in it...
;; ;; Repo from which Helm is available
;; (add-to-list 'package-archives '("melpa" . "https://melpa.org/packages/"))
;; ;; https://github.com/emacs-helm/helm/wiki#install
;; (helm-mode t)
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; Enable the ability to undo/redo window configuration changes with C-<left>/<right>
;; https://www.gnu.org/software/emacs/manual/html_node/emacs/Window-Convenience.html
(setq winner-mode t)

;; Always prefer vertical window splits.
;; (setq split-height-threshold nil)

;; Show the name of the function we're currently in in the status bar.
;; https://www.gnu.org/software/emacs/manual/html_node/emacs/Which-Function.html
;; Disabled because semantic-stickyfunc-mode seems nicer.
;; (setq which-function-mode t)

;; *CAREFULLY* trying out CEDET with the tip of a toe
;; (semantic-mode 1)
;; (global-semantic-stickyfunc-mode 1)
;; (global-ede-mode 1)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Additional bindings
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Alt+↑/↓ move the cursor AND scroll the screen
(global-set-key (kbd "M-<up>")
		(lambda (&optional n) (interactive "^p")
		  (or n (setq n 1))
		  (scroll-down n)
		  (previous-line n)))
(global-set-key (kbd "M-<down>")
		(lambda (&optional n) (interactive "^p")
		  (or n (setq n 1))
		  (scroll-up n)
		  (next-line n)))

;; Dictionary-based completion.
;; Originally bound to M-<TAB> and unreachable in GUI for obvious reasons.
;; I don't think it's *that* useful, but I wanna try and see.
;; (global-set-key [C-tab] 'ispell-complete-word)
;; Nope not helpful

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Zoom functions that resize *all* frames;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(defun vk-zoom-in () (interactive)
       (set-face-attribute 'default nil :height
			   (+ (face-attribute 'default :height) 10)))
(defun vk-zoom-out () (interactive)
       (set-face-attribute 'default nil :height
			   (- (face-attribute 'default :height) 10)))

(global-set-key [C-mouse-4] 'vk-zoom-in)
(global-set-key [C-mouse-5] 'vk-zoom-out)
(global-set-key [?\C-+] 'vk-zoom-in)
(global-set-key [?\C-_] 'vk-zoom-out)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; REPOS
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; Standard package.el + MELPA setup
;; (See also: https://github.com/milkypostman/melpa#usage)
(require 'package)
(add-to-list 'package-archives
	      '("melpa" . "http://melpa.milkbox.net/packages/") t)
(package-initialize)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Python shenanigans
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Enable Elpy, the Emacs Lisp Python Environment
;; https://github.com/jorgenschaefer/elpy
(elpy-enable)
(setq elpy-rpc-python-command "python3")

;; Standard Jedi.el setting
;; (add-hook 'python-mode-hook 'jedi:setup)
;; (setq jedi:complete-on-dot t)
;; (setq jedi:environment-virtualenv
;;       (list "virtualenv3" "--system-site-packages"))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Additional packages to install (TODO automate)
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Real-time latex preview mode:
;; https://www.emacswiki.org/emacs/LaTeXPreviewPane

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Rtags & Company
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Company installation instructions: https://company-mode.github.io
;; Rtags installation instructions: https://github.com/Andersbakken/rtags
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(require 'company)
(add-to-list 'load-path "/usr/local/share/emacs/site-lisp/rtags")
(require 'rtags)
;; Use company-mode in all buffers
(add-hook 'after-init-hook 'global-company-mode)
;; Don't insert function arguments as a template after completion.
;; (this throws me off a lot and is never what I want)

;; Add the Rtags backend to Company.
(push 'company-rtags company-backends)
;; Purportedly needed to run company, though it seems more annoying than useful.
(setq rtags-autostart-diagnostics t)
;; Enable completions in RTags. Needed for Company interop.
(setq rtags-completions-enabled t)
;; Force complete. By default it auto-activates once you type . -> etc.
(define-key c-mode-base-map (kbd "<C-tab>") (function company-complete))
;; Flyspell is recommended but I'll keep it disabled for now.
;; (require 'flycheck-rtags)
(rtags-enable-standard-keybindings)

;; Launch rdm upon entering C/C++ mode if it hasn't been launched.
(add-hook 'c-mode-hook 'rtags-start-process-unless-running)
(add-hook 'c++-mode-hook 'rtags-start-process-unless-running)
(add-hook 'objc-mode-hook 'rtags-start-process-unless-running)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; JS
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; https://emacs.cafe/emacs/javascript/setup/2017/04/23/emacs-setup-javascript.html
;; https://emacs.cafe/emacs/javascript/setup/2017/05/09/emacs-setup-javascript-2.html
;; https://ternjs.net/doc/manual.html
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(require 'js2-mode)
(add-to-list 'auto-mode-alist '("\\.js\\'" . js2-mode))

;; Better imenu
(add-hook 'js2-mode-hook #'js2-imenu-extras-mode)

(require 'company)
(require 'company-tern)

(add-to-list 'company-backends 'company-tern)
(add-hook 'js2-mode-hook (lambda ()
                           (tern-mode)
                           (company-mode)))
                           
;; Disable completion keybindings, as we use xref-js2 instead
;; (define-key tern-mode-keymap (kbd "M-.") nil)
;; (define-key tern-mode-keymap (kbd "M-,") nil)
;; VK: I've commented these lines as I haven't adopted xref-js2 just yet.

;; Tern's autocomplete requires a config file named .tern-project to be
;; placed into the project's directly. This seems to work:
;; {
;;   "libs": [
;;     "jquery",
;;     "browser"
;;   ],
;;   "loadEagerly": [
;;     "./**/*.js"
;;   ],
;;   "dontLoad": [
;;     "./bower_components/"
;;   ],
;;   "plugins": {
;;     "requirejs": {
;;       "baseURL": "./",
;;       "paths": {}
;;     }
;;   }
;; }

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; Default C++ mode doesn't fully support C++11 and higher, have to use a third-party package for that.
(modern-c++-font-lock-global-mode t)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Make shortcuts work in the Russian locale
;; Copied from https://www.linux.org.ru/forum/general/13857712
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(defun reverse-input-method (input-method)
  "Build the reverse mapping of single letters from INPUT-METHOD."
  (interactive
   (list (read-input-method-name "Use input method (default current): ")))
  (if (and input-method (symbolp input-method))
      (setq input-method (symbol-name input-method)))
  (let ((current current-input-method)
	(modifiers '(nil (control) (meta) (control meta))))
    (when input-method
      (activate-input-method input-method))
    (when (and current-input-method quail-keyboard-layout)
      (dolist (map (cdr (quail-map)))
	(let* ((to (car map))
	       (from (quail-get-translation
		      (cadr map) (char-to-string to) 1)))
	  (when (and (characterp from) (characterp to))
	    (dolist (mod modifiers)
	      (define-key local-function-key-map
		(vector (append mod (list from)))
		(vector (append mod (list to)))))))))
    (when input-method
      (activate-input-method current))))

;; Hotkeys on russian layout
(reverse-input-method 'russian-computer)

;; Disable bell
(setq ring-bell-function 'ignore)

;; Navigate in/out rtags
(defun my-rtags-shortcuts ()
  (local-set-key [mouse-9] 'rtags-location-stack-back)
  (local-set-key (kbd "<M-left>") 'rtags-location-stack-back)
  (local-set-key [mouse-8] 'rtags-find-symbol-at-point)
  (local-set-key (kbd "<M-right>") 'rtags-find-symbol-at-point)
)

(add-hook 'c-mode-hook 'my-rtags-shortcuts)
(add-hook 'c++-mode-hook 'my-rtags-shortcuts)
