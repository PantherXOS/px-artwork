;;; GNU Guix web site
;;; Initially written by sirgazil who waives all
;;; copyright interest on this file.

(define-module (apps base data)
  #:use-module (apps base types)
  #:use-module (apps base utils)
  #:export (contact-media))


;;;
;;; Data.
;;;

(define contact-media
  (list
   ;; The first three will be featured in the home page.
   (contact
    #:name "IRC Channel"
    #:description
    '(p
      "Join the " (code "#guix") " channel on the Freenode IRC network to chat
      with the community about GNU Guix or to get help in
      real-time.")
    #:url (guix-url "contact/irc/")
    #:log guix-irc-log-url)

   (contact
    #:name "Info Mailing List"
    #:description
    '(p "Subscribe to the " (code "info-guix") " low-traffic mailing
list to receive important announcements sent by the project maintainers (in
English).")
    #:url "https://lists.gnu.org/mailman/listinfo/info-guix"
    #:log "https://lists.gnu.org/archive/html/info-guix")

   (contact
    #:name "Help Mailing List"
    #:description
    `(("de"
       "Melden Sie sich bei der „Help“-Mailingliste an, um per E-Mail
gemeinschaftlichen Rat zu GuixSD und Guix zu bekommen.  Sie können
Nachrichten auch auf deutsch verfassen.")
      ("en"
       "Subscribe to the Help mailing list to get support from the
GNU Guix community via email.  You can post messages in English though we
also accept other languages.")
      ("eo"
       "Subskribu al la retmesaĝolisto \"Help\" por demandi helpon pri
GNU Guix al la grupo.  Vi povas skribi esperantlingve.")
      ("es"
       "Suscríbete a la lista de correo electrónico \"Help\" por pedir
ayuda con Guix.  Puedes escribir mensajes en Español.")
      ("fr"
       "Abonnez-vous à la liste de diffusion « Help » pour obtenir l'aide
de la communauté sur GNU Guix par courrier électronique.  Vous
pouvez envoyer des messages en français.")
      ("hu"
       "Iratkozzon fel a „Help“ levelezőlistára, hogy segítséget kaphasson
e-mailben a GuixSD és a GNU Guix közösségtől. Magyarul is küldhet
üzeneteket.")
      ("it"
       "Iscrivetevi alla mailing list 'Help' per essere aiutati da altri
utenti di Guix e GuixSD.  Potete scrivere sulla mailing list anche in
italiano.")
      ("ja"
       "メールでGNU GuixとGuixSDのコミュニティからサポートを受けるには、
「Help」のメーリングリストに登録してください。
メッセージ内容は日本語でも問題ございませんが、多言語でも受け付けております。")
      ("nb"
       "Meld deg på diskusjonslisten «Help» for å få råd og tips fra
andre GuixSD- og GNU Guix-brukere via e-post.  Du kan legge inn
meldinger på norsk.")
      ("nl"
       "Abonneer je op de discussielijst \"Help\" om hulp te vragen
van de GuixSD- en GNU Guix-gemeenschap.  Je kunt berichten sturen in
het Nederlands.")
      ("ru"
       "Подпишитесь на список рассылки «Help», чтобы получить помощь от
сообщества GuixSD и GNU Guix по электронной почте.  Вы можете писать на русском
языке.")
      ("zh-Hant"
       "訂閱「Help」郵件群組以電郵從GuixSD及GNU Guix社群取得支援。你可以使用
正體、繁體中文發送訊息。"))

    #:url "https://lists.gnu.org/mailman/listinfo/help-guix"
    #:log "https://lists.gnu.org/archive/html/help-guix")

   (contact
    #:name "Bug Reporting"
    #:description
    '(p
      "If you found a bug in Guix, check whether the bug is
      already in the "
      (a (@ (href "https://issues.guix.gnu.org"))
	 "bug database")
      ". If it is not, please "
      (a (@ (href "mailto:bug-guix@gnu.org")) "report it."))
    #:url "https://lists.gnu.org/mailman/listinfo/bug-guix"
    #:log "https://issues.guix.gnu.org/")

   (contact
    #:name "Development Mailing List"
    #:description
    '(p
      "Discussion about the development of GNU Guix. "
      (a (@ (href "https://lists.gnu.org/archive/html/bug-guix/2013-07/msg00039.html"))
	 " Until July 2013")
      ", the bug-Guix mailing list filled that role. ")
    #:url "https://lists.gnu.org/mailman/listinfo/guix-devel"
    #:log "https://lists.gnu.org/archive/html/guix-devel")

   (contact
    #:name "Patches Mailing List"
    #:description
    `(p
      "Submission of patches.  Every message sent to this mailing list
      leads to a new entry in our "
      (a (@ (href "https://issues.guix.gnu.org"))
	 "patch tracking tool")
      ".  See "
      (a (@ (href "https://debbugs.gnu.org/Advanced.html")) "this page")
      " for more information on how to use it; see "
      (a (@ (href ,(manual-url "Submitting-Patches.html")))
         "the manual")
      " for more information on how to submit a patch.  "
      (a (@ (href "https://lists.gnu.org/archive/html/guix-devel/2017-02/msg00627.html"))
	 "Until February 2017")
      ", the guix-devel mailing list filled that role.")
    #:url "https://lists.gnu.org/mailman/listinfo/guix-patches"
    #:log "https://issues.guix.gnu.org")

   (contact
    #:name "Commits Mailing List"
    #:description
    `(p
      "Notifications of commits made to the "
      (a (@ (href ,(guix-url "contribute/"))) "Git repositories")
      ".")
    #:url "https://lists.gnu.org/mailman/listinfo/guix-commits"
    #:log "https://lists.gnu.org/archive/html/guix-commits")

   (contact
    #:name "Security Mailing List"
    #:description
    `(p
      "This is a private mailing list that anyone can post to to "
      (a (@ (href ,(guix-url "security/"))) "report security issues")
      " in Guix itself or in "
      "the " (a (@ (href ,(guix-url "packages/"))) "packages")
      " it provides.  Posting here allows Guix developers to address
      the problem before it is widely publicized.")
    #:url "https://lists.gnu.org/mailman/listinfo/guix-security"
    #:log "")

   (contact
    #:name "Sysadmin Mailing List"
    #:description
    '(p
      "Private mailing list for the "
      (a (@ (href "https://hydra.gnu.org/")) "build farm")
      " system administration.")
    #:url "https://lists.gnu.org/mailman/listinfo/guix-sysadmin"
    #:log "")


   ;; Non-Guix lists.

   (contact
    #:name "GNU System Discuss Mailing List"
    #:description
    '(p "Discussion about the development of the broader GNU system.")
    #:url "https://lists.gnu.org/mailman/listinfo/gnu-system-discuss"
    #:log "https://lists.gnu.org/archive/html/gnu-system-discuss/")

   (contact
    #:name "GNU/Linux-libre Mailing List"
    #:description
    '(p "Workgroup for fully free GNU/Linux distributions.")
    #:url "https://lists.nongnu.org/mailman/listinfo/gnu-linux-libre"
    #:log "https://lists.nongnu.org/archive/html/gnu-linux-libre/")

   (contact
    #:name "GNU Info Mailing List"
    #:description
    '(p "GNU software announcements.")
    #:url "https://lists.gnu.org/mailman/listinfo/info-gnu"
    #:log "https://lists.gnu.org/archive/html/info-gnu/")))
