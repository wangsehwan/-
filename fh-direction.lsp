(defun c:FH-DIR
  ( / p1 p2 centerSel centerline textSel i ent txt val pt cpt dist data highest low )
  ;; Prompt for a rectangular area
  (setq p1 (getpoint "\n첫 번째 코너 지점 지정: ")
        p2 (getcorner p1 "\n반대 코너 지점 지정: "))
  ;; Select the centerline polyline on layer "도로중심선" within the area
  (setq centerSel (ssget "_C" p1 p2 '((0 . "*POLYLINE") (8 . "도로중심선"))))
  (if (and centerSel (> (sslength centerSel) 0))
    (progn
      (setq centerline (vlax-ename->vla-object (ssname centerSel 0)))
      ;; Get text labels from layer "도로체인계획고" within the area
      (setq textSel (ssget "_C" p1 p2 '((0 . "TEXT,MTEXT") (8 . "도로체인계획고"))))
      (if textSel
        (progn
          (setq i 0 data '())
          (repeat (sslength textSel)
            (setq ent (ssname textSel i)
                  txt (cdr (assoc 1 (entget ent)))
            )
            (if (and txt (wcmatch (strcase txt) "FH:*"))
              (progn
                (setq val (atof (substr txt 4))
                      pt (cdr (assoc 10 (entget ent)))
                      cpt (vlax-curve-getClosestPointTo centerline pt)
                      dist (vlax-curve-getDistAtPoint centerline cpt)
                )
                (setq data (cons (list dist val cpt) data))
              )
            )
            (setq i (1+ i))
          )
          ;; Sort by distance along centerline
          (setq data (vl-sort data '(lambda (a b) (< (car a) (car b)))))
          ;; Find highest and lowest FH
          (setq highest (car data) low (car data))
          (foreach item data
            (if (> (cadr item) (cadr highest)) (setq highest item))
            (if (< (cadr item) (cadr low)) (setq low item))
          )
          (if (and highest low)
            (progn
              ;; Draw leader from high to low
              (command "_.LEADER" (nth 2 highest) (nth 2 low) "" "")
              (princ (strcat "\nLeader drawn from FH:" (rtos (cadr highest) 2 2) " to FH:" (rtos (cadr low) 2 2)))
            )
          )
        )
      )
    )
  )
  (princ)
)
(princ "\nType FH-DIR to run.\n")
