;; Author: Isaac H. Lopez Diaz <isaac.lopez@upr.edu>
;; Description: Weakest precondition eval
;; Licensed under MIT
(load "helpers.scm")

;; Evaluates the weakest precondition P
;; for statement S and postcondition R
(define wp
  (lambda (S R)
    (cond
     ((null? S) '())
     ((eq? (car S) 'skip)
      (reduce R))
     ((eq? (car S) 'abort)
      #f)
     ((eq? (car S) 'assignment)
      (let ((v (lookup (second S) R)))
	(if v
	    (reduce (substitute v (third S) R))
	    (error (second S) "variable does not exist."))))
     ((eq? (car S) 'seq)
      (wp (cadr S) (wp (caddr S) R)))
     ((eq? (car S) 'if)
      (let ((c (cadr S))
	    (t (wp (caddr S) R))
	    (e (wp (cadddr S) R)))
	(and (implies c t)
	     (implies (not c) e))))
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

;; Reverse an operator
(define rev
  (lambda (op)
    (cond
     ((eq? op '+) -)
     ((eq? op '-) +)
     ((eq? op '/) *)
     ((eq? op '*) /)
     (else
      (error op "not defined")))))

;; Reduce an expression (simplification)
(define reduce
  (lambda (expr)
    (if (null? expr)
	(error expr "is empty")
	(let ((rel (car expr))
	      (lhs (cadr expr))
	      (rhs (caddr expr)))
	  (cond
	   ((list? lhs)
	    (let ((op (car lhs))
		  (nlhs (cadr lhs))
		  (nrhs (caddr lhs)))
	      (if (symbol? nlhs)
		  `(,rel ,nlhs ,(apply (rev op) (list rhs nrhs)))
		  `(,rel ,(apply (rev op) (list rhs nlhs)) ,nrhs))))
	   ((list? rhs)
	    (let ((op (car lhs))
		  (nlhs (cadr lhs))
		  (nrhs (caddr lhs)))
	      (if (symbol? nrhs)
		  '(,rel ,(apply (rev op) (list lhs nlhs)) ,nrhs)
		  '(,rel ,nlhs ,(apply (rev op (list lhs nrhs))) ,nrhs))))
	   ((symbol? lhs)
	    `(,rel ,lhs ,rhs))
	   (else (eval expr user-initial-environment)))))))
