*** Settings ***
Suite Setup       Run Tests    \    variables/variables_in_import_settings
Resource          atest_resource.robot

*** Test Cases ***
Variable Defined In Test Case File Is Used To Import Resources
    ${tc} =    Check Test Case    Test 1
    Check Log Message    ${tc[0, 0, 0]}    Hello, world!
    ${tc} =    Check Test Case    Test 2
    Check Log Message    ${tc[0, 0, 0]}    Hi, Tellus!
