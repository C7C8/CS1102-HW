#!/usr/bin/racket
#lang racket

; Note: I *would* be using Racket block comments but Vim doesn't like them.
; I'll fix it later, right now I have code to write!
; 
; Proposed diff syntax:
; [0] NOP: \
;	-No operation. Only increments the location pointer by one.
; [1] Insert (INS): +
; 	-Inserts in place, *before* the currently selected character.
;	-Example:	"The quick brown fox..."
;	-Diff:		"\\\\+i\\\\\\\\\\\\\\\\\"
;	-Result:	"The qiuick brown fox..."
;
; [2] Replace (RPL): =
;	-Replaces a character, in-place.
;	-Example:	"Use tabs over spaces"
;	-Diff:		"\\\\=j\\\\\\\\\\\\\\\"
;	-Result:	'Use jabs over spaces"
;
; [3] Delete (DEL): -
;	-Deletes a character, in-place. LPR stays in place.
;	-Example:	"PRESS THE BUTTON!"
;	-Diff:		"\\\\\\\\\\\--\-\\"
;	-Result:	"PRESS THE BTN!"
;
; [4] Continuatons:
;	-The previous operation applies until a new op or a no-op is encountered.
;	 This saves space without going for hacks that would disrupt usability.
;	 Doesn't apply to deletion.
; 	-Example: 	"DON'T PRESS IT!"
;	-Diff:		"\\\\\\=DO---\\\\"
;	-Result:	"DON'T DO IT!"
;
; [5] Location pointer (lpr)
;	-Construct that exists in memory only, for operations on a string.
;	-NOP (\)
;		-Advances lpr by one in all cases.
;	-RPL (=)
;		-Advances lpr by one in all cases.
;	-DEL (-)
;		-When applying a patch, decrements lpr
;		-When creating a patch, increments lpr
;	-INS (+)
;		-When applying a patch, increments lpr by 2 (???)
;		-When creating a patch... increments lpr by two?
;
; Obviously all of the above is very much a work in progress


