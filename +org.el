;;;  -*- lexical-binding: t; -*-

;; Org-mode
;; customize org-settings
(after! org
  (setq outline-blank-line nil)
  (setq org-cycle-separator-lines 2)
  (setq org-log-done 'time))
;; Turn of highlight line in org-mode
(add-hook 'org-mode-hook (lambda ()
                           (hl-line-mode -1)))
;; automatically redisplay images generated by babel
(add-hook 'org-babel-after-execute-hook 'org-redisplay-inline-images)
;; place latex-captions below figures and tables
(setq org-latex-caption-above nil)
;; Disable line-numbers in org-mode
(add-hook 'org-mode-hook #'doom|disable-line-numbers)
;; Agenda
;; specify the main org-directory
(setq org-directory "~/org")
;; set which directories agenda should look for todos
(setq org-agenda-files '("~/org" "~/org/brain"))

;; Org-Noter
(def-package! org-noter
  :after org
  :config
  (setq org-noter-always-create-frame nil
        org-noter-auto-save-last-location t)
  (map! :localleader
        :map org-mode-map
        (:prefix-map ("n" . "org-noter")
          :desc "Open org-noter" :n "o" #'org-noter
          :desc "Kill org-noter session" :n "k" #'org-noter-kill-session
          :desc "Insert org-note" :n "i" #'org-noter-insert-note
          :desc "Insert precise org-note" :n "p" #'org-noter-insert-precise-note
          :desc "Sync current note" :n "." #'org-noter-sync-current-note
          :desc "Sync next note" :n "]" #'org-noter-sync-next-note
          :desc "Sync previous note" :n "[" #'org-noter-sync-prev-note)))

;; Hugo
(def-package! ox-hugo
  :defer t                      ;Auto-install the package from Melpa (optional)
  :after ox)

;; ;; LaTeX export
(after! 'org
  (require  'ox-latex)
  ;; (add-to-list 'org-latex-packages-alist '("newfloat" "minted"))
  (setq org-latex-listings 'minted)
  ;; set minted options
  (setq org-latex-minted-options
        '(("frame" "lines")))
  ;; set pdf generation process
  (setq org-latex-pdf-process
        '("xelatex -shell-escape -interaction nonstopmode %f"
          "xelatex -shell-escape -interaction nonstopmode %f"
          "xelatex -shell-escape -interaction nonstopmode %f"))
  (add-to-list 'org-latex-minted-langs '(calc "mathematica"))
  ;; Add org-latex-class
  (add-to-list 'org-latex-classes
               '("zarticle"
                 "\\documentclass[11pt,Wordstyle]{Zarticle}
                    \\usepackage[utf8]{inputenc}
                    \\usepackage{graphicx}
                        [NO-DEFAULT-PACKAGES]
                        [PACKAGES]
                        [EXTRA] "
                 ("\\section{%s}" . "\\section*{%s}")
                 ("\\subsection{%s}" . "\\subsection*{%s}")
                 ("\\subsubsection{%s}" . "\\subsubsection*{%s}")
                 ("\\paragraph{%s}" . "\\paragraph*{%s}"))))


;; Jira
(def-package! org-jira
  :defer t
  :config
  (setq jiralib-url "https://jira.zenuity.com"
        org-jira-users `("Niklas Carlsson" . ,(shell-command-to-string "printf %s \"$(pass show work/zenuity/login | sed -n 2p | awk '{print $2}')\""))
        jiralib-token `("Cookie". ,(my/init-jira-cookie))))

;; Customization
;; You can define one or more custom JQL queries to run and have your
;; results inserted into, as such:
(setq org-jira-custom-jqls
      '(
        (:jql " project = DUDE AND issuetype != Sub-task AND issuetype != Epic AND resolution = Unresolved AND  (Sprint = EMPTY OR Sprint NOT IN (openSprints(), futureSprints()))"
              :limit 50
              :filename "dude-backlog")
        (:jql " project = DUDE AND issuetype != Sub-task AND sprint in openSprints() AND sprint NOT IN futureSprints()"
              :limit 20
              :filename "dude-current-sprint-user-stories")
        (:jql " project = DUDE AND issuetype = Sub-task AND sprint in openSprints() AND sprint NOT IN futureSprints()"
              :limit 50
              :filename "dude-current-sprint-sub-tasks")
        (:jql " project = DUDE AND issuetype = Epic"
              :limit 20
              :filename "dude-epics")
        (:jql " project = DUDE AND assignee = currentuser() order by created DESC "
              :limit 20
              :filename "dude-niklas")
        ))
;; Please note this feature still requires some testing - things that
;; may work in the existing proj-key named buffers (DUDE.org etc.) may
;; behave unexpectedly in the custom named buffers.

;; One thing you may notice is if you create an issue in this type of
;; buffer, the auto-refresh of the issue will appear in the
;; PROJ-KEY.org specific buffer (you will then need to refresh this
;; JQL buffer by re-running the command C-c ij).

;; The following variable, org-jira-worklog-sync-p, is set to true by
;; default, but this causes an error on my machine when attempting to
;; update issues. I believe I don't have the need for syncing the
;; clocks.
(setq org-jira-worklog-sync-p nil)

;;Streamlined transition flow
;; You can define your own streamlined issue progress flow as such:
; If your Jira is set up to display a status in the issue differently
; than what is shown in the button on Jira, your alist may look like
; this (use the labels shown in the org-jira Status when setting it
; up, or manually work out the workflows being used through standard
; C-c iw options/usage):
 (defconst org-jira-progress-issue-flow
   '(("To Do" . "In Progress")
     ("In Progress" . "Review")
     ("Review" . "Done")))
