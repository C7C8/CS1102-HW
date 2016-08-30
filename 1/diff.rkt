#!/usr/bin/racket
#lang racket


; Operation, contains data about... well, an operation!
; opcode, symbol; position, number; data, string
(define-struct operation (opcode position data))


