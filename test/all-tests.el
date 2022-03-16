;; all-tests.el

;; If the directory happens to have both compiled and uncompiled
;; version, prefer to use the newer (typically the uncompiled) version.
(setq load-prefer-newer t)

(require 'tcsv) ; Require the csv parsing test
