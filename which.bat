@echo off
REM emulate the Linux which command from http://stackoverflow.com/questions/1437457/how-do-i-find-full-path-to-an-application-in-a-batch-script
if "%1" == "" (
  echo Usage: %~nx0 ^<command[.ext]^>
  exit /b
)
setlocal
for %%P in (%PATHEXT%) do (
  for %%I in (%1 %1%%P) do (
    if exist "%%~$PATH:I" (
      echo %%~$PATH:I
      exit /b
    )
  )
)
