*** Settings ***
Suite Setup       Run Tests    ${EMPTY}    standard_libraries/builtin/log.robot
Resource          atest_resource.robot

*** Variables ***
${HTML}           <a href="http://robotframework.org">Robot Framework</a>

*** Test Cases ***
Log
    ${tc} =    Check Test Case    ${TEST NAME}
    Check Log Message    ${tc[0, 0]}     Hello, world!
    Check Log Message    ${tc[1, 0]}     42
    Check Log Message    ${tc[2, 0]}     None
    Check Log Message    ${tc[3, 0]}     String presentation of MyObject

Log with different levels
    ${tc} =    Check Test Case    ${TEST NAME}
    Check Log Message    ${tc[0, 1]}     Log says: Hello from tests!    INFO
    Check Log Message    ${tc[1, 1]}     Trace level    TRACE
    Check Log Message    ${tc[2, 1]}     Debug level    DEBUG
    Check Log Message    ${tc[3, 1]}     Info level     INFO
    Check Log Message    ${tc[4, 1]}     Warn level     WARN
    Check Log Message    ${tc[5, 1]}     Error level    ERROR
    Check Log Message    ${ERRORS[0]}    Warn level     WARN
    Check Log Message    ${ERRORS[1]}    Error level    ERROR
    Length Should Be     ${ERRORS}       4    # Two deprecation warnings from `repr`.

Invalid log level failure is catchable
    Check Test Case    ${TEST NAME}

HTML is escaped by default
    ${tc} =    Check Test Case    ${TEST NAME}
    Check Log Message    ${tc[0, 0]}    <b>not bold</b>
    Check Log Message    ${tc[1, 0]}    ${HTML}

HTML pseudo level
    ${tc} =    Check Test Case    ${TEST NAME}
    Check Log Message    ${tc[0, 0]}    <b>bold</b>    html=True
    Check Log Message    ${tc[1, 0]}    ${HTML}    html=True

Explicit HTML
    ${tc} =    Check Test Case    ${TEST NAME}
    Check Log Message    ${tc[0, 0]}    <b>bold</b>    html=True
    Check Log Message    ${tc[1, 0]}    ${HTML}    DEBUG    html=True
    Check Log Message    ${tc[2, 0]}    ${HTML}    DEBUG

FAIL is not valid log level
    Check Test Case    ${TEST NAME}

Log also to console
    ${tc} =    Check Test Case    ${TEST NAME}
    Check Log Message    ${tc[0, 0]}    Hello, console!
    Check Log Message    ${tc[1, 0]}    ${HTML}    DEBUG    html=True
    Stdout Should Contain    Hello, console!\n
    Stdout Should Contain    ${HTML}\n

CONSOLE pseudo level
    ${tc} =    Check Test Case    ${TEST NAME}
    Check Log Message    ${tc[0, 0]}    Hello, info and console!
    Stdout Should Contain    Hello, info and console!\n

repr=True
    ${tc} =    Check Test Case    ${TEST NAME}
    Check Log Message    ${tc[0, 0]}    The 'repr' argument of 'BuiltIn.Log' is deprecated. Use 'formatter=repr' instead.    WARN
    Check Log Message    ${tc[0, 1]}    Nothing special here
    Check Log Message    ${tc[1, 0]}    The 'repr' argument of 'BuiltIn.Log' is deprecated. Use 'formatter=repr' instead.    WARN
    Check Log Message    ${tc[1, 1]}    'Hyvää yötä ☃!'

formatter=repr
    ${tc} =    Check Test Case    ${TEST NAME}
    Check Log Message    ${tc[0, 0]}    'Nothing special here'
    Check Log Message    ${tc[1, 0]}    'Hyvää yötä ☃!'
    Check Log Message    ${tc[2, 0]}    42    DEBUG
    Check Log Message    ${tc[4, 0]}    b'\\x00abc\\xff (formatter=repr)'
    Check Log Message    ${tc[6, 0]}    'hyvä'
    Stdout Should Contain    b'\\x00abc\\xff (formatter=repr)'

formatter=ascii
    ${tc} =    Check Test Case    ${TEST NAME}
    Check Log Message    ${tc[0, 0]}    'Nothing special here'
    Check Log Message    ${tc[1, 0]}    'Hyv\\xe4\\xe4 y\\xf6t\\xe4 \\u2603!'
    Check Log Message    ${tc[2, 0]}    42    DEBUG
    Check Log Message    ${tc[4, 0]}    b'\\x00abc\\xff (formatter=ascii)'
    Check Log Message    ${tc[6, 0]}    'hyva\\u0308'
    Stdout Should Contain    b'\\x00abc\\xff (formatter=ascii)'

formatter=str
    ${tc} =    Check Test Case    ${TEST NAME}
    Check Log Message    ${tc[0, 0]}    Nothing special here
    Check Log Message    ${tc[1, 0]}    Hyvää yötä ☃!
    Check Log Message    ${tc[2, 0]}    42    DEBUG
    Check Log Message    ${tc[4, 0]}    abc\xff (formatter=str)
    Check Log Message    ${tc[6, 0]}    hyvä
    Stdout Should Contain    abc\xff (formatter=str)

formatter=repr pretty prints
    ${tc} =    Check Test Case    ${TEST NAME}
    ${long string} =    Evaluate    ' '.join(['Robot Framework'] * 1000)
    ${small dict} =    Set Variable    {'small': 'dict', 3: b'items', 'NOT': 'sorted'}
    ${small list} =    Set Variable    ['small', b'list', 'not sorted', 4]
    Check Log Message    ${tc[1, 0]}     '${long string}'
    Check Log Message    ${tc[3, 0]}     ${small dict}
    Check Log Message    ${tc[5, 0]}     {'big': 'dict',\n 'long': '${long string}',\n 'nested': ${small dict},\n 'list': [1, 2, 3],\n 'sorted': False}
    Check Log Message    ${tc[7, 0]}     ${small list}
    Check Log Message    ${tc[9, 0]}     ['big',\n 'list',\n '${long string}',\n b'${long string}',\n ['nested', ('tuple', 2)],\n ${small dict}]
    Check Log Message    ${tc[11, 0]}    ['hyvä', b'hyv\\xe4', {'☃': b'\\x00\\xff'}]
    Stdout Should Contain    ${small dict}
    Stdout Should Contain    ${small list}

formatter=len
    ${tc} =    Check Test Case    ${TEST NAME}
    Check Log Message    ${tc[0, 0]}    20
    Check Log Message    ${tc[1, 0]}    13    DEBUG
    Check Log Message    ${tc[3, 0]}    21
    Check Log Message    ${tc[5, 0]}    5

formatter=type
    ${tc} =    Check Test Case    ${TEST NAME}
    Check Log Message    ${tc[0, 0]}    str
    Check Log Message    ${tc[1, 0]}    str
    Check Log Message    ${tc[2, 0]}    int    DEBUG
    Check Log Message    ${tc[4, 0]}    bytes
    Check Log Message    ${tc[6, 0]}    datetime

formatter=invalid
    Check Test Case    ${TEST NAME}

Log callable
    ${tc} =    Check Test Case    ${TEST NAME}
    Check Log Message    ${tc[0, 0]}    *objects_for_call_method.MyObject*    pattern=yes
    Check Log Message    ${tc[2, 0]}    <function <lambda*> at *>    pattern=yes

Log Many
    ${tc} =    Check Test Case    ${TEST NAME}
    Check Log Message    ${tc[0, 0]}    Log Many says:
    Check Log Message    ${tc[0, 1]}    1
    Check Log Message    ${tc[0, 2]}    2
    Check Log Message    ${tc[0, 3]}    3
    Check Log Message    ${tc[0, 4]}    String presentation of MyObject
    Check Log Message    ${tc[1, 0]}    Log Many says: Hi!!
    Check Log Message    ${tc[2, 0]}    1
    Check Log Message    ${tc[2, 1]}    2
    Check Log Message    ${tc[2, 2]}    3
    Check Log Message    ${tc[2, 3]}    String presentation of MyObject
    Should Be Empty      ${tc[3].body}
    Should Be Empty      ${tc[4].body}
    Check Log Message    ${tc[5, 0]}    preserve
    Check Log Message    ${tc[5, 1]}    ${EMPTY}
    Check Log Message    ${tc[5, 2]}    empty
    Check Log Message    ${tc[5, 3]}    ${EMPTY}
    Check Log Message    ${tc[6, 0]}    --
    Check Log Message    ${tc[6, 1]}    -[]-
    Check Log Message    ${tc[6, 2]}    -{}-
    Check Log Message    ${tc[7, 0]}    1
    Check Log Message    ${tc[7, 1]}    2

Log Many with named and dict arguments
    ${tc} =    Check Test Case    ${TEST NAME}
    Check Log Message    ${tc[0, 0]}    a=1
    Check Log Message    ${tc[0, 1]}    b=2
    Check Log Message    ${tc[0, 2]}    3=c
    Check Log Message    ${tc[0, 3]}    obj=String presentation of MyObject
    Check Log Message    ${tc[1, 0]}    a=1
    Check Log Message    ${tc[1, 1]}    b=2
    Check Log Message    ${tc[1, 2]}    3=c
    Check Log Message    ${tc[1, 3]}    obj=String presentation of MyObject
    Check Log Message    ${tc[2, 0]}    a=1
    Check Log Message    ${tc[2, 1]}    b=2
    Check Log Message    ${tc[2, 2]}    3=c
    Check Log Message    ${tc[2, 3]}    obj=String presentation of MyObject
    Check Log Message    ${tc[2, 4]}    b=no override
    Check Log Message    ${tc[2, 5]}    3=three

Log Many with positional, named and dict arguments
    ${tc} =    Check Test Case    ${TEST NAME}
    Check Log Message    ${tc[0, 0]}     1
    Check Log Message    ${tc[0, 1]}     2
    Check Log Message    ${tc[0, 2]}     three=3
    Check Log Message    ${tc[0, 3]}     4=four
    Check Log Message    ${tc[1, 0]}     1
    Check Log Message    ${tc[1, 1]}     2
    Check Log Message    ${tc[1, 2]}     3
    Check Log Message    ${tc[1, 3]}     String presentation of MyObject
    Check Log Message    ${tc[1, 4]}     a=1
    Check Log Message    ${tc[1, 5]}     b=2
    Check Log Message    ${tc[1, 6]}     3=c
    Check Log Message    ${tc[1, 7]}     obj=String presentation of MyObject
    Check Log Message    ${tc[1, 8]}     1
    Check Log Message    ${tc[1, 9]}     2
    Check Log Message    ${tc[1, 10]}    3
    Check Log Message    ${tc[1, 11]}    String presentation of MyObject
    Check Log Message    ${tc[1, 12]}    a=1
    Check Log Message    ${tc[1, 13]}    b=2
    Check Log Message    ${tc[1, 14]}    3=c
    Check Log Message    ${tc[1, 15]}    obj=String presentation of MyObject

Log Many with non-existing variable
    Check Test Case    ${TEST NAME}

Log Many with list variable containing non-list
    Check Test Case    ${TEST NAME}

Log Many with dict variable containing non-dict
    Check Test Case    ${TEST NAME}

Log To Console
    ${tc} =    Check Test Case    ${TEST NAME}
    FOR    ${i}    IN RANGE    4
        Should Be Empty    ${tc[${i}].body}
    END
    Stdout Should Contain    stdout äö w/ newline\n
    Stdout Should Contain    stdout äö w/o new......line äö
    Stderr Should Contain    stderr äö w/ newline\n
    Stdout Should Contain    42

Log To Console With Formatting
    Stdout Should Contain    ************test middle align with star padding*************
    Stdout Should Contain    ####################test right align with hash padding
    Stdout Should Contain    ${SPACE * 6}test-with-spacepad-and-weird-characters+%?,_\>~}./asdf
    Stdout Should Contain    ${SPACE * 24}message starts here,this sentence should be on the same sentence as "message starts here"
    Stderr Should Contain    ${SPACE * 26}test log to stderr
