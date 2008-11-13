@echo off

rmdir /s /q ../SpamSentry_bot
rmdir /s /q ../SpamSentry_report
rmdir /s /q ../SpamSentry_rp

move Bot ..\SpamSentry_bot
move Report ..\SpamSentry_report
move Rp ..\SpamSentry_rp