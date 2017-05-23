@echo off

setlocal

rem Set defaults
set KEEP=0
set VERBOSE=0
set SILENT=0
set TESTDIR=testdir
set ANYFAILED=0

set HDR1======
set HDR2=-----

rem Parse arguments
:arg_loop
if "%1"=="" goto end_arg_loop

if "%1"=="-k" (
    set KEEP=1
    shift /1
    goto arg_loop
    )

if "%1"=="-v" (
    set VERBOSE=1
    shift /1
    goto arg_loop
    )

if "%1"=="-s" (
    set SILENT=1
    shift /1
    goto arg_loop
    )

if "%1"=="-h" (
    echo.
    echo Test runner for Windows make.bat
    echo.
    echo Options
    echo =======
    echo.
    echo -h   - Show this help
    echo -k   - Keep test directory after running tests
    echo -s   - Run tests with all output suppressed
    echo -v   - Show output from executed commands
    echo.
    goto end_help
    )


:end_arg_loop

rem Can't have both silent and verbose
if %SILENT% EQU 1 (
    if %VERBOSE% EQU 1 (
        echo Cannot specify both '-s' and '-v'!
        echo Exiting ...
        set ANYFAILED=1
        goto end_help
        )
    )


rem Quickstart Sphinx into new directory
if %SILENT% EQU 0 (
    echo %HDR1% Creating new Sphinx doc sandbox ...
    echo.
    )

if exist %TESTDIR%\nul rmdir /s /q %TESTDIR%

if "%VERBOSE%"=="1" (
    python ..\..\sphinx-quickstart.py -p test -a test -v 0.0 -r 0.0 -q %TESTDIR%
    ) else (
    python ..\..\sphinx-quickstart.py -p test -a test -v 0.0 -r 0.0 -q %TESTDIR% 1>nul 2>nul
    )

if %ERRORLEVEL% GTR 0 (
    if %SILENT% EQU 0 (
        echo.
        echo %HDR1% Error quick-starting Sphinx.
        echo %HDR1% Exiting...
        echo.
        )
    goto end
    )


rem Run the EXPECT-SUCCESS tests
if %SILENT% EQU 0 (
    echo %HDR1% Running make operations expected to succeed:
    echo.
    )
set ELVAL=0

rem === make -h ===
set PARAMS=-h
set RETURN=RET_H
goto run_test
:RET_H
set TEST_H=%RESULT%

rem === make clean ===
set PARAMS=clean
set RETURN=RET_CLEAN
goto run_test
:RET_CLEAN
set TEST_CLEAN=%RESULT%

rem === make html ===
set PARAMS=html
set RETURN=RET_HTML
goto run_test
:RET_HTML
set TEST_HTML=%RESULT%

rem === make latex (no regen of env) ===
set PARAMS=latex
set RETURN=RET_LATEX
goto run_test
:RET_LATEX
set TEST_LATEX=%RESULT%

rem === make clean html ===
set PARAMS=clean html
set RETURN=RET_CLEAN_HTML
goto run_test
:RET_CLEAN_HTML
set TEST_CLEAN_HTML=%RESULT%

rem === make html -a ===
set PARAMS=html -a
set RETURN=RET_HTML_A
goto run_test
:RET_HTML_A
set TEST_HTML_A=%RESULT%

rem === make html -E ===
set PARAMS=html -E
set RETURN=RET_HTML_E
goto run_test
:RET_HTML_E
set TEST_HTML_E=%RESULT%


rem Run the EXPECT-FAIL tests
if %SILENT% EQU 0 (
    echo.
    echo %HDR1% Running make operations expected to fail:
    echo.
    )
set ELVAL=1

rem === make -b html ===
set PARAMS=-b html
set RETURN=RET_B_HTML
goto run_test
:RET_B_HTML
set TEST_B_HTML=%RESULT%

rem === make clean html -c .. ===
set PARAMS=clean html -c ..
set RETURN=RET_CLEAN_HTML_C_dd
goto run_test
:RET_CLEAN_HTML_C_dd
set TEST_CLEAN_HTML_C_dd=%RESULT%

rem === make foo ===
set PARAMS=foo
set RETURN=RET_FOO
goto run_test
:RET_FOO
set TEST_FOO=%RESULT%



rem Report Results
if %SILENT% EQU 0 (
    echo.
    echo.
    echo ==========================================
    echo                TEST RESULTS
    echo ==========================================
    echo.
    echo          Args           Expect    Result
    echo  --------------------  --------  --------
    echo   -h                      OK      %TEST_H%
    echo   clean                   OK      %TEST_CLEAN%
    echo   html                    OK      %TEST_HTML%
    echo   latex                   OK      %TEST_LATEX%
    echo   clean html              OK      %TEST_CLEAN_HTML%
    echo   html -a                 OK      %TEST_HTML_A%
    echo   html -E                 OK      %TEST_HTML_E%
    echo.
    echo   -b html                ERROR    %TEST_B_HTML%
    echo   clean html -c ..       ERROR    %TEST_CLEAN_HTML_C_dd%
    echo   foo                    ERROR    %TEST_FOO%
    echo.
    echo ==========================================
    echo.
    echo.
    )

goto end


:run_test
rem Run the test, with output suppressed by default
if "%VERBOSE%"=="1" echo. & echo.

if %SILENT% EQU 0 (echo %HDR2% Testing 'make %PARAMS%' ...)

if "%VERBOSE%"=="0" (
    call %TESTDIR%\make %PARAMS% 1>nul 2>nul
    ) else (
    call %TESTDIR%\make %PARAMS%
    )

rem Equality comparison to the indicated expected test result
if %ERRORLEVEL% EQU %ELVAL% (
    set RESULT=-pass-
    ) else (
    set RESULT=*FAIL*
    set ANYFAILED=1
    )

rem "Callback" to the particular test
goto %RETURN%





:end

rem Remove test folder if it exists and KEEP is 0
if "%KEEP%"=="0" (
    if %SILENT% EQU 0 (
        echo %HDR1% Removing Sphinx doc sandbox ...
        echo.
        )
    if exist %TESTDIR%\nul rmdir /s /q %TESTDIR%
    if %SILENT% EQU 0 (
        echo %HDR1% Done.
        echo.
        )
    ) else (
    if %SILENT% EQU 0 (
        echo %HDR1% Sphinx doc sandbox left in place.
        echo.
        )
    )

:end_help

endlocal & set ANYFAILED=%ANYFAILED%

exit /B %ANYFAILED%

