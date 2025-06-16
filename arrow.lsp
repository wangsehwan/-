(defun c:PolyArrow (/ ent elst start end angle p1 p2 p3)
  (vl-load-com)
  (if (setq ent (car (entsel "\nSelect polyline: ")))
    (progn
      (setq elst (entget ent))
      (if (wcmatch (cdr (assoc 0 elst)) "*POLYLINE")
        (progn
          ;; get the last vertex of the polyline
          (setq end (cdr (assoc 10 (entget (entlast)))))
          ;; The start of the arrow is the last vertex; get previous vertex
          ;; We'll use vlax-curve functions to get start and end points
          (setq start (vlax-curve-getpointatparam ent
                    (- (vlax-curve-getendparam ent) 1)))
          (setq end (vlax-curve-getendpoint ent))
          (setq angle (angle start end))
          (setq p1 end)
          (setq p2 (polar p1 (+ angle (/ pi 2)) 10))
          (setq p3 (polar p1 (- angle (/ pi 2)) 10))
          (entmake
            (list
              (cons 0 "LWPOLYLINE")
              (cons 100 "AcDbEntity")
              (cons 100 "AcDbPolyline")
              (cons 90 3)
              (cons 70 1)
              (cons 10 p1)
              (cons 10 p2)
              (cons 10 p3)
              (cons 10 p1)
            )
          )
        )
        (princ "\nNot a polyline.")
      )
    )
  )
  (princ)
)

(princ "\nType POLYARROW to add arrowhead.")

