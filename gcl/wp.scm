;; Author: Isaac H. Lopez Diaz <isaac.lopez@upr.edu>
;; Description: Weakest precondition eval
;; Licensed under GPLv3

;; Evaluates the weakest precondition P
;; for statement S and postcondition R
(define wp
  (lambda (S R)
    (cond
     ((null? S) '())
     ((eq? (car S) 'skip)
      (reduction R))
     ((eq? (car S) 'abort)
      #f)
     ((eq? (car S) 'assignment)
      (let ((v (lookup (second S) R)))
	(if v
	    (substitute v (third S) R)
	    (error (second S) "variable does not exist."))))
     (else
      (error (car S) "not defined")))))

;; Lookup for a variable v in R
(define lookup
  (lambda (v R)
    (cond
     ((null? R) #f)
     ((eq? v (car R)) v)
     ((list? (car R))
      (or (lookup v (car R))
	  (lookup v (cdr R))))
     (else
      (lookup v (cdr R))))))

;; Substitute variable v for expression e in R
(define substitute
  (lambda (v e R)
    (cond
     ((null? R) '())
     ((eq? v (car R))
      (cons e (cdr R)))
     ((list? (car R))
      (cons (substitute v e (car R))
	    (substitute v e (cdr R))))
     (else
      (cons (car R)
	    (substitute v e (cdr R)))))))

#;(define (simplify expr)
  (cond
    ((and (pair? expr) (eq? (car expr) '>))
     (let* ((lhs (cadr expr))  ;; (- x 5)
            (rhs (caddr expr))) ;; 10
       (if (and (pair? lhs) (eq? (car lhs) '-))
           ;; If LHS is (- x c), rearrange to x > (rhs + c)
           (let ((var (cadr lhs))
                 (const (caddr lhs)))
             `(> ,var ,(+ rhs const)))
           expr)))  ;; Otherwise, return as is

    ;; Base case: return unchanged
    (else expr)))
