@echo off

setlocal

rem Set defaults
set KEEP=0
set TESTDIR=testdir


rem Parse arguments
:arg_loop
if "%1"=="" goto end_arg_loop

if "%1"=="-k" (
    set KEEP=1
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
    echo.
    goto end
    )


:end_arg_loop


rem Quickstart Sphinx into new directory
if exist %TESTDIR%\nul rmdir /s /q %TESTDIR%
python ..\..\sphinx-quickstart.py -p test -a test -v 0.0 -r 0.0 -q %TESTDIR%
if %ERRORLEVEL% GTR 0 (
    echo.
    echo Error quick-starting Sphinx.
    echo Exiting...
    echo.
    goto end
    )


rem Run the EXPECT-SUCCESS tests

call %TESTDIR%\make -h
if %ERRORLEVEL% EQU 0 (
    set TEST_H=PASS
    ) else (
    set TEST_H=FAIL
    )

call %TESTDIR%\make clean
if %ERRORLEVEL% EQU 0 (
    set TEST_CLEAN=PASS
    ) else (
    set TEST_CLEAN=FAIL
    )

call %TESTDIR%\make html
if %ERRORLEVEL% EQU 0 (
    set TEST_HTML=PASS
    ) else (
    set TEST_HTML=FAIL
    )


rem Run the EXPECT-FAIL tests

call %TESTDIR%\make -b html
if %ERRORLEVEL% EQU 1 (
    set TEST_B_HTML=PASS
    ) else (
    set TEST_B_HTML=FAIL
    )

call %TESTDIR%\make clean html -c ..
if %ERRORLEVEL% EQU 1 (
    set TEST_CLEAN_HTML_C_dd=PASS
    ) else (
    set TEST_CLEAN_HTML_C_dd=FAIL
    )

call %TESTDIR%\make foo
if %ERRORLEVEL% EQU 1 (
    set TEST_FOO=PASS
    ) else (
    set TEST_FOO=FAIL
    )



rem Report Results
echo.
echo.
echo ==========================================
echo                TEST RESULTS
echo ==========================================
echo.
echo          Args           Expect    Result
echo  --------------------  --------  --------
echo   -h                      OK       %TEST_H%
echo   clean                   OK       %TEST_CLEAN%
echo   html                    OK       %TEST_HTML%
echo.
echo   -b html                ERROR     %TEST_B_HTML%
echo   clean html -c ..       ERROR     %TEST_CLEAN_HTML_C_dd%
echo   foo                    ERROR     %TEST_FOO%
echo.
echo ==========================================



:end

rem Remove test folder if it exists and KEEP is 0
if "%KEEP%"=="0" (
    if exist %TESTDIR%\nul rmdir /s /q %TESTDIR%
    )

endlocal

