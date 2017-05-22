@echo off

setlocal

rem Set defaults
set KEEP=0
set VERBOSE=0
set TESTDIR=testdir
set MAKEMODE=0


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

if "%1"=="-o" (
    set MAKEMODE=1
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
    echo -o   - Test the old-style make.bat
    echo -v   - Show output from executed commands
    echo.
    goto end
    )


:end_arg_loop

rem Set the make mode option to use based on the passed flag
if "%MAKEMODE%"=="0" (
    set MAKEMODEOPT=--use-make-mode
    ) else (
    set MAKEMODEOPT=--no-use-make-mode
    )


rem Quickstart Sphinx into new directory
if exist %TESTDIR%\nul rmdir /s /q %TESTDIR%
if "%VERBOSE%"=="1" (
    python ..\..\sphinx-quickstart.py -p test -a test -v 0.0 -r 0.0 -q %TESTDIR% %MAKEMODEOPT%
    ) else (
    echo Creating Sphinx doc sandbox ...
    echo.
    python ..\..\sphinx-quickstart.py -p test -a test -v 0.0 -r 0.0 -q %TESTDIR% %MAKEMODEOPT% 1>nul 2>nul
    )
if %ERRORLEVEL% GTR 0 (
    echo.
    echo Error quick-starting Sphinx.
    echo Exiting...
    echo.
    goto end
    )


rem Run the EXPECT-SUCCESS tests
echo Running make operations expected to succeed:
echo.

rem 'help' test is oddly behaved
if "%MAKEMODE%"=="0" (
    rem === make -h ===
    set PARAMS=-h
    set RETURN=RET_H_NEW
    set ELVAL=0
    goto run_test
    :RET_H_NEW
    set TEST_H=%RESULT%
    goto end_help_test
    ) else (
    rem === make help ===
    set PARAMS=help
    set RETURN=RET_H_OLD
    set ELVAL=1
    goto run_test
    :RET_H_OLD
    set TEST_H=%RESULT%
    )

:end_help_test


rem Rest should exit success
set ELVAL=0

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


rem Run the EXPECT-FAIL tests
echo.
echo Running make operations expected to fail:
echo.
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
echo.
echo.
echo ==========================================
echo                TEST RESULTS
echo ==========================================
echo.
echo          Args           Expect    Result
echo  --------------------  --------  --------
if "%MAKEMODE%"=="0" (
    echo   -h                      OK      %TEST_H%
    ) else (
    echo   help                    OK      %TEST_H%
    )
echo   clean                   OK      %TEST_CLEAN%
echo   html                    OK      %TEST_HTML%
echo.
echo   -b html                ERROR    %TEST_B_HTML%
echo   clean html -c ..       ERROR    %TEST_CLEAN_HTML_C_dd%
echo   foo                    ERROR    %TEST_FOO%
echo.
echo ==========================================
echo.
echo.

goto end


:run_test
rem Run the test, with output suppressed by default
if "%VERBOSE%"=="0" (
    echo Testing 'make %PARAMS%' ...
    call %TESTDIR%\make %PARAMS% 1>nul 2>nul
    ) else (
    call %TESTDIR\make %PARAMS%
    )

rem Equality comparison to the indicated expected test result
if %ERRORLEVEL% EQU %ELVAL% (
    set RESULT=-pass-
    ) else (
    set RESULT=*FAIL*
    )

rem "Callback" to the particular test
goto %RETURN%





:end

rem Remove test folder if it exists and KEEP is 0
if "%KEEP%"=="0" (
    echo Removing Sphinx doc sandbox ...
    echo.
    if exist %TESTDIR%\nul rmdir /s /q %TESTDIR%
    echo Done.
    echo.
    ) else (
    echo Sphinx doc sandbox left on disk.
    echo.

endlocal

