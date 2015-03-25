#lang racket/gui

(require net/url)
(require file/unzip)

(define ardublockzip "ardublock.zip")
(define ardublockdir (string-append (getenv "HOMEDRIVE") (getenv "HOMEPATH") "/Documents/Arduino/tools/ArduBlockTool/tool/"))
(define arduinolibdir (string-append (getenv "HOMEDRIVE") (getenv "HOMEPATH") "/Documents/Arduino/libraries/"))

(define (delete-ardublock)
  (for-each (lambda (arg)
			  (let ([cur (string-append ardublockdir (path->string arg))])
				(update-msg (string-append "Deleting " (path->string arg) "... "))
				(delete-file cur)
				(update-msg "Done!\n")))
			(directory-list ardublockdir)))

(define (fetch-ardublock)
  (let* ([zipfile (open-output-file ardublockzip #:mode 'binary #:exists 'replace)]
		 [fileurl "http://make.icewire.ca/wp-content/uploads/ardublock/ardublock.zip"]
		 [infile (get-pure-port (string->url fileurl))])
	(update-msg (string-append "Fetching " fileurl "... "))
	(copy-port infile zipfile)
	(close-output-port zipfile))
  (update-msg "Done!\n"))

(define (copy-ardublock)
  (let ([zipfile (open-input-file ardublockzip #:mode 'binary)])
	(unzip zipfile)
	(close-input-port zipfile))
  (let ([jarpath "Arduino/tools/ArduBlockTool/tool/"])
	(for-each (lambda (arg)
				(let* ([newjar (path->string arg)]
					   [jarfile (open-input-file (string-append jarpath newjar))])
				  (update-msg (string-append "Copying " newjar "... "))
				  (copy-file (string-append jarpath newjar) (string-append ardublockdir newjar))
				  (close-input-port jarfile)))
			  (directory-list jarpath)))
  (update-msg "Done!\n"))

(define (clean-ardublock)
  (update-msg "Cleaning up... ")
  (delete-file ardublockzip)
  (delete-directory/files "Arduino")
  (update-msg "Done!\n"))

(define (update-ardublock)
  (let/ec return
		  (update-msg "Updating ArduBlock...\n")
		  (with-handlers ([exn:fail?
						   (lambda (exn) (update-msg (string-append "Error: " (exn-message exn))) (return))])
						 (delete-ardublock))
		  (with-handlers ([exn:fail?
						   (lambda (exn) (update-msg (string-append "Error: " (exn-message exn))) (return))])
						 (fetch-ardublock))
		  (with-handlers ([exn:fail?
						   (lambda (exn) (update-msg (string-append "Error: " (exn-message exn))) (return))])
						 (copy-ardublock))
		  (sleep 1)
		  (with-handlers ([exn:fail?
						   (lambda (exn) (update-msg (string-append "Error: " (exn-message exn))) (return))])
						 (clean-ardublock))))

(define (get-zumo-libraries)
  (define zumolibzip "zumolib.zip")
  (define tmpdir "zumo-shield-master/")
  (let* ([zipfile (open-output-file zumolibzip #:mode 'binary #:exists 'replace)]
		 [fileurl "https://codeload.github.com/pololu/zumo-shield/zip/master"]
		 [infile (get-pure-port (string->url fileurl))])
	(update-msg (string-append "Fetching " fileurl "... "))
	(copy-port infile zipfile)
	(close-output-port zipfile))
  (update-msg "Done!\n")
  (let ([zipfile (open-input-file zumolibzip #:mode 'binary)])
	(unzip zipfile)
	(close-input-port zipfile))
  (for-each (lambda (arg)
			  (let* ([dir (path->string arg)]
					 [fulldir (string-append tmpdir dir)]
					 [localdir (string-append arduinolibdir dir)])
				(when (directory-exists? fulldir) ; Only operate on directories
					  (when (directory-exists? localdir)
							(update-msg (string-append "Deleting " localdir "... "))
							(delete-directory/files localdir #:must-exist? #f)
							(update-msg "Done!\n"))
					  (update-msg (string-append "Copying " dir "... "))
					  (copy-directory/files fulldir localdir)
					  (update-msg "Done!\n"))))
  			(directory-list tmpdir))
  (update-msg "Cleaning up... ")
  (delete-file zumolibzip)
  (delete-directory/files tmpdir)
  (update-msg "Done!\n"))

(define (get-libraries)
  (let/ec return
		  (update-msg "Getting libraries...\n")
		  (with-handlers ([exn:fail?
						   (lambda (exn) (update-msg (string-append "Error: " (exn-message exn))) (return))])
						 (get-zumo-libraries))))

(define frame (new frame%
				   [label "ArduBlock Updater"]))

(define main-panel (new horizontal-panel%
						[parent frame]))

(define button-panel (new vertical-panel%
						  [parent main-panel]
						  [alignment '(center top)]))

(define msg-canvas (new editor-canvas%
						[parent main-panel]
						[min-width 600]
						[min-height 300]))

(define msg (new text%))
(send msg insert "Make a selection\n")
(send msg-canvas set-editor msg)

(define (update-msg s)
  (send msg insert s))

(define (clear-msg)
  (send msg erase))

(define update-button (new button%
	 [parent button-panel]
	 [label "Full &Update"]
	 [callback (lambda (button event)
				 (clear-msg)
				 (update-ardublock)
				 (update-msg "\n")
				 (get-libraries))]))
(send update-button focus)

(new button%
	 [parent button-panel]
	 [label "Get &Libraries"]
	 [callback (lambda (button event)
				 (clear-msg)
				 (with-handlers ([exn:fail?
								  (lambda (exn) (update-msg (string-append "Error: " (exn-message exn))))])
								(get-libraries)))])

(define exit-button-panel (new vertical-panel%
						  [parent button-panel]
						  [alignment '(center bottom)]))
(new button%
	 [parent exit-button-panel]
	 [label "E&xit"]
	 [callback (lambda (button event)
				 (exit))])

(send frame show #t)
